# Boss 与敌人设计指南

本文档深入分析游戏中配置 Boss / 敌人的完整机制、可用接口和属性体系。

---

## 1. 核心数据类

敌人由两个核心数据类驱动：

| 类 | 文件 | 作用 |
|---|---|---|
| `EnemyData` | `data/prototype/EnemyData.gd` | 敌人的原型数据：血量、类型、意图图、难度修正、死亡行为 |
| `EnemyIntentData` | `data/readonly/embedded/EnemyIntentData.gd` | 单个意图状态的数据：攻击伤害、次数、护盾、自定义行动 |

敌人是 `event_weighted_enemy_object_ids` 中引用的 object_id，必须在 `add_enemies()` 中通过 `Global.register_rod()` 注册。

---

## 2. EnemyData — 全属性详解

### 2.1 基础属性

```gdscript
@export var enemy_name: String = ""                 # 显示名称
@export var enemy_texture_path: String = "..."       # 精灵图路径
@export var enemy_animation_id: String = ""          # 动画 ID（可用 add_standard_animations() 自动生成）
```

### 2.2 血量系统

```gdscript
@export var enemy_health: int = 20                              # 当前血量
@export var enemy_health_max: int = 20                          # 最大血量
@export var enemy_health_max_random_lower: int = 20             # 血量下限
@export var enemy_health_max_random_upper: int = 25             # 血量上限（生成时随机）
@export var enemy_block: int = 0                                # 起始护盾（第 1 回合）
```

血量上线/下限在生成时随机抽一个值作为 `enemy_health_max`。可通过 `add_health_bounds(lower, upper, difficulty_level)` 按难度设置不同血量。

### 2.3 敌人类型

```gdscript
enum ENEMY_TYPES {STANDARD, MINIBOSS, BOSS}
@export var enemy_type: int = ENEMY_TYPES.STANDARD

@export var enemy_is_minion: bool = false
```

- `STANDARD`：普通敌人
- `MINIBOSS`：精英敌人
- `BOSS`：Boss
- `enemy_is_minion`：设为 `true` 表示该敌人不需要被击杀即可结束战斗。适合 Boss 召唤的小怪

### 2.4 初始状态效果

```gdscript
@export var enemy_initial_status_effects: Dictionary[String, int] = {}
```

战斗开始时自动给敌人挂上的状态效果及其层数。例如：
```gdscript
enemy_initial_status_effects = {"status_effect_negate_damage": 1}
```

### 2.5 死亡行为

```gdscript
@export var enemy_actions_on_death: Array[Dictionary] = []
```

敌人死亡时执行的一系列 action。例如死亡时给所有战斗单位施加腐蚀：
```gdscript
enemy_actions_on_death = [
    {
        Scripts.ACTION_APPLY_STATUS: {
            "status_charge_amount": 5,
            "status_effect_object_id": "status_effect_corrosion",
            "target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS,
        },
    },
]
```

### 2.6 难度修正体系

#### 2.6.1 难度是什么

`PlayerData.player_run_difficulty_level` 是新游戏开始时由玩家在开局界面选择的难度等级，初始为 0。**整个 run 中保持不变**，不会因章节推进而自动递增。

`Global.start_run(character_id, seed, difficulty_level)` 将选定的难度写入 `player_run_difficulty_level`，之后敌人生成时读取此值判断使用哪档数据。

#### 2.6.2 难度与章节的关系

**难度和章节是两套独立的系统：**

- **章节（Act）**：由 `player_act` 追踪，值为 1 / 2 / 3，通关 Boss 后递增，控制当前所处的关卡内容（地图、事件池）。
- **难度（Difficulty）**：由 `player_run_difficulty_level` 追踪，值为 0 / 1 / 2 / 3+，开局时一次选定后不变，控制敌人的数值强度。

打个比方：难度 0 的第三章和难度 3 的第三章，遇到的是**相同的敌人类型和事件**，但难度 3 的敌人血量更高、伤害更大、意图更强。

#### 2.6.3 不同难度分别加强谁

游戏使用四个难度常量，分层控制不同类型的敌人何时被强化：

| 常量 | 值 | 触发条件 | 适用敌人 | 设计意图 |
|---|---|---|---|---|
| `DIFFICULTY_STARTING` | 0 | 开局难度 ≥ 0（始终生效） | 所有敌人（基准） | 最低难度，敌人基础数值低 |
| `DIFFICULTY_STANDARD_ENEMIES_HARDER` | 1 | 开局难度 ≥ 1 | **普通敌人** (enemy_1~4) | 提高杂兵战的日常压力 |
| `DIFFICULTY_MINIBOSS_ENEMIES_HARDER` | 2 | 开局难度 ≥ 2 | **精英敌人** (miniboss) | 精英战也需要更强挑战 |
| `DIFFICULTY_BOSS_ENEMIES_HARDER` | 3 | 开局难度 ≥ 3 | **Boss** | 终局高难，Boss 数值拉满 |

**设计原则**：越常见的敌人越早受高难度影响。普通杂兵全章节都会遇到，在难度 1 就变强；Boss 只在特定节点出现，到难度 3 才变强——这样避免 Boss 在高难开局时不可战胜。

#### 2.6.4 数据结构

```gdscript
@export var enemy_difficulty_to_enemy_modfiers: Dictionary[String, Dictionary] = {}
```

- **外层 key**：难度值，但必须用字符串形式（JSON 兼容），如 `"1"`, `"2"`, `"3"`
- **外层 value**：一个字典，key 是 EnemyData 的属性名（字符串），value 是该属性在到达此难度后的新值

**示例**：难度 2 时给敌人加初始护盾，难度 3 时再加大血量：
```gdscript
enemy_difficulty_to_enemy_modfiers = {
    "2": {"enemy_block": 10},
    "3": {"enemy_health_max_random_lower": 60, "enemy_health_max_random_upper": 70},
}
```

#### 2.6.5 可修改的属性

`enemy_difficulty_to_enemy_modfiers` 可以覆盖 EnemyData 上的**任何 `@export` 属性**，引擎通过 `set(property_name, new_value)` 直接写入。常用覆盖项：

| 属性名 | 类型 | 作用 |
|---|---|---|
| `enemy_block` | int | 战斗第 1 回合起始护盾 |
| `enemy_health_max_random_lower` | int | 血量随机下限 |
| `enemy_health_max_random_upper` | int | 血量随机上限 |
| `enemy_texture_path` | String | 贴图（换皮） |
| `enemy_actions_on_death` | Array[Dictionary] | 死亡触发行为（高难度加额外惩罚） |
| `enemy_initial_status_effects` | Dictionary[String, int] | 初始状态效果（高难度自带 Buff） |

**注意**：不要在难度修正里改 `enemy_intents`。意图的难度变体应通过**意图覆盖**实现（见 2.7），逻辑分离更清晰。

#### 2.6.6 敌人生成全流程

敌人生成时，`EnemyContainer` 调用以下方法（按顺序）：

```
① apply_enemy_difficulty_modifiers()
   └── for 难度 0 .. 当前难度:
         把 enemy_difficulty_to_enemy_modfiers[难度] 中每个属性 set() 到 EnemyData 上
       └── 构建 _intent_override_cache：同 key 的意图，保留难度最高的一版

② randomize_health()
   └── 从 [enemy_health_max_random_lower, enemy_health_max_random_upper] 区间随机血量
```

**顺序很重要**：如果高难度要加大血量，必须前一步 `apply_enemy_difficulty_modifiers()` 先更新了 `enemy_health_max_random_*` 的区间，再 `randomize_health()` 才能在高区间内随机。

#### 2.6.7 `add_health_bounds()` 的作用

`add_health_bounds(lower, upper, difficulty_level)` 是设置血量的便捷封装：

- `difficulty_level = 0`（默认）：直接设 `enemy_health_max_random_lower/upper`
- `difficulty_level > 0`：内部把这两个值**写入 `enemy_difficulty_to_enemy_modfiers[difficulty_level]`**，与手写等价

所以下面两段代码完全等价：

```gdscript
# 写法 1：便捷封装
enemy.add_health_bounds(100, 100)
enemy.add_health_bounds(120, 120, 3)

# 写法 2：手写字典
enemy.enemy_health_max_random_lower = 100
enemy.enemy_health_max_random_upper = 100
enemy.enemy_difficulty_to_enemy_modfiers["3"] = {
    "enemy_health_max_random_lower": 120,
    "enemy_health_max_random_upper": 120,
}
```

### 2.7 意图图（Intent Graph）

```gdscript
@export var enemy_intents: Dictionary[String, EnemyIntentData] = {}
```

敌人在战斗中的行为由**有向随机加权图**定义。每个状态是一个 `EnemyIntentData`，通过 `enemy_intent_next_intent_weights` 指定下一个状态的权重跳转。

**意图覆盖机制**：如果两个 `EnemyIntentData` 拥有相同的 `enemy_intent_overrides_id` 但不同 `difficulty_level`，系统会自动在高难度替换为更强的版本，无需重新定义整个行为树。

关键变量：
```gdscript
var enemy_intent_current_id: String = EnemyIntentData.INTENT_INITIAL
```

- 初始状态固定为 `"intent_initial"`，不执行任何行为，只用于随机选择第一个真正的意图
- 每回合开始时调用 `cycle_next_intent_state()` 进行跳转

添加意图的便捷方法：
```gdscript
enemy.add_intent_state([
    EnemyIntentData.new("intent_id", difficulty, attack_damage, attack_count, impact_anim, block, audio, next_weights, custom_actions),
])
```

---

## 3. EnemyIntentData — 意图状态详解

### 3.1 构造函数

```gdscript
EnemyIntentData.new(
    intent_object_id: String,          # 意图 ID（如 "intent_attack"）
    difficulty_level: int,             # 此意图启用的难度
    intent_attack_damage: int,         # 每次攻击伤害
    intent_number_of_attacks: int,     # 攻击次数
    intent_attack_impact_animation_id: String,  # 攻击命中 VFX 动画 ID
    intent_block: int,                 # 获得护盾量
    intent_audio_path: String,         # 音效路径
    intent_next_intent_weights: Dictionary,  # 下一个意图的权重映射
    intent_custom_actions: Array[Dictionary],  # 自定义额外行动
    intent_display_types: Array[int]   # 手动覆盖意图显示图标（通常自动推断）
)
```

### 3.2 属性一览

| 属性 | 类型 | 说明 |
|---|---|---|
| `enemy_intent_name` | String | 意图名称（自动从 ID 生成或从中文映射表取） |
| `enemy_intent_difficulty_level` | int | 最低适用难度 |
| `enemy_intent_overrides_id` | String | 覆盖键（同键高难度覆盖低难度） |
| `enemy_intent_attack_damage` | int | 每次攻击的基础伤害 |
| `enemy_intent_number_of_attacks` | int | 攻击次数 |
| `enemy_intent_attack_impact_animation_id` | String | 命中特效动画 |
| `enemy_intent_block` | int | 获得的护盾值 |
| `enemy_intent_audio_path` | String | 攻击音效（如果是多段攻击，每段播放一次） |
| `enemy_intent_custom_actions` | Array[Dictionary] | 额外行为（召唤、施加状态等） |
| `enemy_intent_next_intent_weights` | Dictionary | 下一个意图的加权映射 |

### 3.3 意图名称中文映射

```gdscript
const INTENT_NAME_ZH = {
    "intent_initial": "初始",
    "intent_attack": "攻击",
    "intent_attack_1": "攻击 1",
    "intent_attack_2": "攻击 2",
    "intent_attack_vulnerable": "易伤攻击",
    "intent_attack_multi": "多重攻击",
    "intent_block": "防火墙",
    "intent_summon": "召唤",
}
```

可以自由添加新 ID → 名称的映射条目。

### 3.4 意图头顶图标自动推断

系统会根据参数自动推断敌人头顶的图标类型（无需手动设置）：

| 条件 | 图标 |
|---|---|
| `enemy_intent_attack_damage > 0` 或 `enemy_intent_number_of_attacks > 0` | 🗡️ 攻击 |
| `enemy_intent_block > 0` | 🛡️ 护盾 |
| custom_actions 含 `ACTION_SUMMON_ENEMIES` | 🔄 召唤 |
| custom_actions 含 `ACTION_APPLY_STATUS`（BUFF 型 + 友方目标） | ⬆️ 增益 |
| custom_actions 含 `ACTION_APPLY_STATUS`（DEBUFF 型 + 玩家目标） | ⬇️ 减益 |

---

## 4. 自定义行动（Custom Actions）

`enemy_intent_custom_actions` 是一个 `Array[Dictionary]`，每个字典的 key 是 action 脚本路径（即 `Scripts` 常量），value 是该 action 的参数.

### 4.1 召唤敌人 `ACTION_SUMMON_ENEMIES`

**重要限制**：只能在 `event_enemy_placement_is_automatic = false` 的 Boss 事件中使用。

参数：
```gdscript
{
    "number_of_spawns": 2,                  # 召唤数量
    "spawn_slots": [1, 2],                  # 目标槽位（对应 EventData 的 positions 数组索引）
    "time_delay": 0.5,                      # 间隔
    "random_enemy_object_ids": ["enemy_minion_1", "enemy_minion_2"],  # 候选敌人池
    "target_override": BaseAction.TARGET_OVERRIDES.PARENT,
}
```

- 按 `spawn_slots` 顺序尝试填充
- 每个 slot 如果已有活敌则跳过，有尸体则清理后重生
- 从 `random_enemy_object_ids` 中随机选一种生成

### 4.2 施加状态 `ACTION_APPLY_STATUS`

参数：
```gdscript
{
    "status_effect_object_id": "status_effect_vulnerable",  # 状态 ID
    "status_charge_amount": 3,                              # 层数
    "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,  # 目标
}
```

**target_override 取值**：

| 值 | 含义 |
|---|---|
| `TARGET_OVERRIDES.PLAYER` | 玩家 |
| `TARGET_OVERRIDES.PARENT` | 自身 |
| `TARGET_OVERRIDES.ALL_ENEMIES` | 所有敌人 |
| `TARGET_OVERRIDES.ALL_COMBATANTS` | 所有战斗单位 |

### 4.3 可用的 Action 类型

任何 `Scripts.ACTION_*` 常量都可以作为 custom action 使用，包括但不限于：
- `Scripts.ACTION_ATTACK_GENERATOR` — 攻击生成器
- `Scripts.ACTION_BLOCK` — 获得护盾
- `Scripts.ACTION_RESET_BLOCK` — 清空护盾
- `Scripts.ACTION_ADD_HEALTH` — 回血
- `Scripts.ACTION_APPLY_STATUS` — 施加状态
- `Scripts.ACTION_SUMMON_ENEMIES` — 召唤敌人
- `Scripts.ACTION_DEBUG_LOG` — 调试日志

---

## 5. 游戏中可用的状态效果

以下是当前已注册的全部状态效果，可在 `enemy_initial_status_effects` 或 `enemy_intent_custom_actions` 中引用：

### BUFF 型（增益）

| ID | 名称 | 效果 |
|---|---|---|
| `status_effect_overshield` | 超频护盾 | 回合结束时保留护盾 |
| `status_effect_preserve_energy` | 节能 | 保留未用能量到下一回合 |
| `status_effect_preserve_overshield` | 护盾保持 | 保留部分超频护盾 |
| `status_effect_pointy` | 尖刺 | 反射伤害 |
| `status_effect_pollen` | 花粉 | 回合触发腐蚀伤害 |
| `status_effect_critical` | 暴击 | 提升暴击率 |
| `status_effect_overheat` | 过热 | 提升伤害但每回合掉血 |
| `status_effect_feedback_loop` | 反馈循环 | 机制联动 |
| `status_effect_bomb` | 炸弹 | 延迟爆炸 |
| `status_effect_damage_increase` | 增伤 | 伤害加成 |
| `status_effect_preserve_block` | 护盾永驻 | 永久保留护盾 |
| `status_effect_temp_preserve_block` | 临时护盾保留 | 临时保留护盾 |
| `status_effect_block_on_turn_end` | 回合结束护盾 | 回合结束获得护盾 |
| `status_effect_energy_next_turn` | 下回合能量 | 下回合额外能量 |
| `status_effect_increase_turn_draw` | 增加抽牌 | 提升回合抽牌数 |
| `status_effect_duplicate_attacks` | 攻击翻倍 | 攻击次数翻倍 |
| `status_effect_duplicate_card_plays` | 卡牌翻倍 | 卡牌打出次数翻倍 |
| `status_effect_rebound_card_plays` | 卡牌反弹 | 卡牌打出反弹效果 |

### DEBUFF 型（减益）

| ID | 名称 | 效果 |
|---|---|---|
| `status_effect_corrosion` | 腐蚀 | 每回合受到伤害 |
| `status_effect_weaken` | 虚弱 | 降低伤害 |
| `status_effect_vulnerable` | 脆弱 | 受到伤害增加 |

### 防御/其他

| ID | 名称 | 效果 |
|---|---|---|
| `status_effect_negate_damage` | 免伤 | 抵挡首次伤害 |
| `status_effect_cap_damage` | 伤害上限 | 限制单次最大伤害 |
| `status_effect_negate_debuff` | 免疫减益 | 抵挡首次减益 |

---

## 6. EventData — 事件/Boss 战配置

### 6.1 敌人生成

```gdscript
# 每个字典是一个槽位，键=敌人ID，值=权重
@export var event_weighted_enemy_object_ids: Array[Dictionary] = [
    {"enemy_boss": 1},        # 槽位 0 — Boss 自身
    {"enemy_minion_a": 1, "enemy_minion_b": 1},  # 槽位 1 — 随机小怪
]

# 布局模式
@export var event_enemy_placement_is_automatic: bool = true

# 手动布局坐标（仅当 automatic = false）
@export var event_enemy_placement_positions: Array[Array] = [[0, 0], [180, 0], [360, 0]]
```

**Boss 战必须设置 `event_enemy_placement_is_automatic = false`**，否则无法使用召唤技能。

### 6.2 战斗事件

```gdscript
# 战斗开始时触发
@export var event_initial_combat_actions: Array[Dictionary] = []

# 战斗结束后触发
@export var event_post_combat_actions: Array[Dictionary] = []

# 是否有战斗奖励
@export var event_has_combat_rewards: bool = true
```

### 6.3 氛围

```gdscript
@export var event_music_file_path: String = ""          # 专属 BGM
@export var event_background_texture_path: String = ""   # 专属背景图
@export var event_death_message_bbcode: String = "..."    # 死亡提示（支持富文本）
```

---

## 7. Boss 完整示例（当前游戏第一章 Boss）

```gdscript
# —— 敌人定义 ——
var enemy_act_1_boss_1: EnemyData = EnemyData.new("enemy_act_1_boss_1")

# 血量（不同难度）
enemy_act_1_boss_1.add_health_bounds(200, 200)
enemy_act_1_boss_1.add_health_bounds(250, 250, DIFFICULTY_BOSS_ENEMIES_HARDER)

# 类型与显示
enemy_act_1_boss_1.enemy_type = EnemyData.ENEMY_TYPES.BOSS
enemy_act_1_boss_1.enemy_name = "第一章头目"
enemy_act_1_boss_1.enemy_texture_path = "external/sprites/enemies/enemy_red_large.png"

# 意图 1：初始（随机跳转到 intent_summon）
enemy_act_1_boss_1.add_intent_state([
    EnemyIntentData.new(
        EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING,
        0, 0, "", 0, "",
        {"intent_summon": 1},   # 下一回合必然召唤
    ),
])

# 意图 2：召唤爪牙
var summon_actions: Array[Dictionary] = [
    {Scripts.ACTION_SUMMON_ENEMIES: {
        "number_of_spawns": 2,
        "spawn_slots": [1, 2],
        "time_delay": 0.5,
        "random_enemy_object_ids": ["enemy_minion_1", "enemy_minion_2"],
        "target_override": BaseAction.TARGET_OVERRIDES.PARENT,
    }},
]
enemy_act_1_boss_1.add_intent_state([
    EnemyIntentData.new(
        "intent_summon", DIFFICULTY_STARTING,
        0, 0, "", 0, "",
        {"intent_attack": 1},   # 下一回合攻击
        summon_actions,
    ),
])

# 意图 3：攻击
enemy_act_1_boss_1.add_intent_state([
    EnemyIntentData.new(
        "intent_attack", DIFFICULTY_STARTING,
        3, 2, "", 7, "",        # 2 段攻击 × 3 伤害，7 护盾
        {"intent_attack": 1},   # 循环自身
    ),
    EnemyIntentData.new(
        "intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER,
        5, 2, "", 7, "",        # 高难度：2 段 × 5 伤害
        {"intent_attack": 1},
    ),
])

# 动画
enemy_act_1_boss_1.add_standard_animations(
    ["external/sprites/enemies/enemy_red_large.png"],
)

Global.register_rod(enemy_act_1_boss_1)

# —— 爪牙定义 ——
var enemy_minion_1: EnemyData = EnemyData.new("enemy_minion_1")
enemy_minion_1.enemy_is_minion = true    # 不需要全灭即可结束战斗
# ...（意图定义）

# —— Boss 事件 ——
var event_boss: EventData = EventData.new("event_act_1_boss_1")
event_boss.event_enemy_placement_is_automatic = false
event_boss.event_enemy_placement_positions = [[0, 0], [180, 0], [360, 0]]
# 槽位 0 = Boss 中心，槽位 1、2 = 召唤位置
event_boss.event_weighted_enemy_object_ids = [
    {"enemy_act_1_boss_1": 1},
]
```

### 意图图示意

```
[intent_initial] ──→ [intent_summon] ──→ [intent_attack] ──↻
                         │                    (循环攻击)
                    召唤 2 个爪牙
```

---

## 8. 总结：设计新 Boss 的完整清单

1. **创建 EnemyData**：设置名称、贴图、血量范围、类型 `BOSS`
2. **设计意图图**：至少 `intent_initial` + 1 个实际意图，通过 `enemy_intent_next_intent_weights` 串联
3. **利用难度覆盖**：同名意图 + 不同难度 → 自动替换更强版本
4. **添加 custom_actions**：召唤、施加状态、回血等
5. **注册动画**：`add_standard_animations()`
6. **创建 EventData**：`event_enemy_placement_is_automatic = false`，定义 `positions`
7. **创建爪牙**：`enemy_is_minion = true`
8. **加入事件池**：通过 `EventPoolData.add_events_to_pool()` 挂到对应章节的 Boss 池
9. **设置氛围**：死亡消息、BGM、背景图
