# 外设插件（Artifacts）设计指南

本文档深入分析游戏中配置外设插件（Artifacts）的完整机制、可用接口和属性体系。

---

## 1. 核心数据类

外设插件由以下核心数据类驱动：

| 类 | 文件 | 作用 |
|---|---|---|
| `ArtifactData` | `data/prototype/ArtifactData.gd` | 外设插件的原型数据：名称、描述、充能、触发行为 |
| `BaseArtifact` | `scripts/artifacts/BaseArtifact.gd` | 运行时脚本基类，监听信号并执行逻辑 |
| `ActionInterceptorData` | `data/readonly/ActionInterceptorData.gd` | 行为拦截器数据定义，跨系统拦截并修改动作 |
| `ArtifactPackData` | `data/readonly/ArtifactPackData.gd` | 外设插件卡包数据，控制掉落池过滤 |
| `ArtifactFilter` | `data/filters/ArtifactFilter.gd` | 链式过滤器，运行时从全池中筛选外设插件 |

外设插件在 `GlobalProdDataGenerator.add_artifacts()` 中创建，通过 `Global.register_rod()` 注册到全局只读数据中。

---

## 2. ArtifactData — 全属性详解

### 2.1 基础信息

```gdscript
@export var artifact_name: String = ""                    # 显示名称
@export var artifact_description: String = ""              # 描述文本
@export var artifact_texture_path: String = "..."          # 图标路径
@export var artifact_script_path: String = "res://scripts/artifacts/BaseArtifact.gd"
@export var artifact_color_id: String = "color_white"      # 所属颜色（用于边框着色和卡包过滤）
@export var artifact_rarity: int = ARTIFACT_RARITIES.COMMON # 稀有度
@export var artifact_appears_in_artifact_packs: bool = true # 是否在卡包中掉落
```

### 2.2 稀有度枚举

```gdscript
enum ARTIFACT_RARITIES {
    BASIC,      # 自带外设（角色初始外设）
    COMMON,     # 常见外设
    UNCOMMON,   # 罕见外设
    RARE,       # 稀有外设
    BOSS,       # Boss 专属外设
    SHOP,       # 商店专属外设
    EVENT,      # 事件专属外设（不在常规卡包中出现）
}
```

`STANDARD_ARTIFACT_RARITIES = [COMMON, UNCOMMON, RARE]` 是卡包默认掉落的稀有度范围。

### 2.3 充能系统（Counter）

```gdscript
@export var artifact_counter: int = 0                  # 当前充能值（不要手动修改）
@export var artifact_counter_max: int = 1               # 充能上限
@export var artifact_counter_wraparound: bool = true     # 是否循环计数
```

充能系统是外设插件的核心机制之一：

- **基础充能逻辑 (`increment_artifact_counter(increment)`)**: 
  - 当 `wraparound = false`：充能达到上限后不再增长，只触发 `artifact_max_counter_actions` 一次
  - 当 `wraparound = true`：充能溢出后自动循环，溢出几次就触发几次 `artifact_max_counter_actions`

示例：`counter_max = 3`，`wraparound = true`，一次充能 +9 会触发 3 次满充效果。

- **充能重置规则**:
```gdscript
@export var artifact_counter_reset_on_turn_start: int = -1    # 每回合开始重置到此值（-1 = 不重置）
@export var artifact_counter_reset_on_combat_end: int = -1    # 战斗结束重置到此值（-1 = 不重置）
```

- **禁用状态**:
```gdscript
@export var artifact_disabled: bool = false
```
被禁用的外设插件完全失效：无法监听事件、不能触发动作、不能修改充能值。适用于一次性使用的外设。

### 2.4 拦截器系统（Interceptors）

```gdscript
@export var artifact_interceptor_ids: Array[String] = []
```

外设插件可以通过注册拦截器来修改或拦截特定类型的动作。拦截器是系统中优先级最高、最深层的机制之一。

#### 2.4.1 拦截器工作原理

拦截器（`ActionInterceptorProcessor`）在**每个动作执行前**运行，按照优先级顺序处理：

1. **父方拦截器**（`modifies_parent = true`）：如"伤害增加"拦截器，附着在发起动作的单位上
2. **目标拦截器**（`modifies_parent = false`）：如"漏洞暴露"拦截器，附着在承受动作的单位上

拦截器链通过 `get_shadowed_action_values()` 和 `set_shadowed_action_values()` 来覆盖动作的原始参数值，而不是直接修改它们。

#### 2.4.2 ActionInterceptorData 属性

```gdscript
@export var action_interceptor_script_path: String = ""        # 拦截器脚本路径
@export var action_intercepted_action_paths: Array[String] = [] # 被拦截的动作类型路径
@export var action_interceptor_modifies_parent: bool = true     # true=父方拦截, false=目标拦截
@export var action_interceptor_priority: int = 0                # 优先级（越高越先处理，建议用1000的倍数留空间）
```

#### 2.4.3 拦截器处理结果枚举

拦截器的 `process_action_interception()` 返回以下结果：

| 枚举值 | 含义 |
|---|---|
| `ACCEPTED` | 继续处理下一个拦截器 |
| `STOPPED` | 停止当前链路，动作继续执行 |
| `REJECTED` | 拒绝动作，动作不执行 |

#### 2.4.4 内置拦截器一览

| 拦截器 ID | 脚本 | 作用 |
|---|---|---|
| `interceptor_negate_add_money` | `InterceptorNegateAddMoney.gd` | 阻止获得数据币 |
| `interceptor_vulnerable` | `InterceptorVulnerable.gd` | 漏洞暴露：受到的攻击伤害 +50% |
| `interceptor_weaken` | `InterceptorWeaken.gd` | 输出降级：造成的攻击伤害 -25% |
| `interceptor_damage_increase` | `InterceptorDamageIncrease.gd` | 算力增幅：造成的攻击伤害提升 |
| `interceptor_temp_preserve_block` | `InterceptorTempPreserveBlock.gd` | 缓存防御：临时保留防火墙 |
| `interceptor_duplicate_attacks` | `InterceptorDuplicateAttacks.gd` | 多线程攻击：攻击次数翻倍 |
| `interceptor_increase_turn_draw` | `InterceptorIncreaseTurnDraw.gd` | 扩容内存队列：回合开始时抽更多牌 |
| `interceptor_preserve_energy` | `InterceptorPreserveEnergy.gd` | 算力保留：回合结束保留未用算力 |
| `interceptor_preserve_block` | `InterceptorPreserveBlock.gd` | 保留永久防火墙 |
| `interceptor_damage_from_block` | `InterceptorDamageFromBlock.gd` | 攻防一体：从防火墙获取伤害 |
| `interceptor_damage_from_overshield` | `InterceptorDamageFromOvershield.gd` | 过载转化：从过载防护墙获取伤害 |
| `interceptor_duplicate_card_plays` | `InterceptorDuplicateCardPlays.gd` | 双重执行：卡牌打出翻倍 |
| `interceptor_next_attack_free` | `InterceptorNextAttackFree.gd` | 免耗攻击：下次攻击不消耗算力 |
| `interceptor_negate_damage` | `InterceptorNegateDamage.gd` | 伤害免疫 |
| `interceptor_negate_debuff` | `InterceptorNegateDebuff.gd` | 减益免疫 |
| `interceptor_cap_damage` | `InterceptorCapDamage.gd` | 伤害上限 |
| `interceptor_rebound_card_plays` | `InterceptorReboundCardPlays.gd` | 弹回卡牌 |
| `interceptor_overshield` | `InterceptorOvershield.gd` | 过载防护墙 |
| `interceptor_pointy` | `InterceptorPointy.gd` | 反弹伤害 |

#### 2.4.5 动作级拦截器控制参数

在任意动作的 Dictionary 中，可以使用以下参数控制拦截器行为：

```gdscript
"ignore_all_interceptors": true,       # 忽略所有拦截器，原样执行
"ignored_interceptor_ids": [],         # 指定忽略的拦截器 ID 列表
"forced_interceptor_ids": [],          # 强制启用的拦截器 ID 列表
```

---

## 3. 行为触发时机（Action Hooks）

外设插件可以在以下生命周期节点挂载行为（`Array[Dictionary]`），每个字典是标准的 Action 配置：

### 3.1 获取与移除

```gdscript
@export var artifact_add_actions: Array[Dictionary] = []      # 获得外设时触发
@export var artifact_remove_actions: Array[Dictionary] = []    # 移除外设时触发
```

典型用途：获得时加钱/回血/修改游戏机制，移除时撤销修改。

**注意**：`artifact_add_actions` 在外设被添加到玩家背包时触发，`BaseArtifact.add_artifact()` 中调用。如果想在 `add_actions` 中使用充能相关的 `custom_key_names`（如 `artifact_counter`），需要在 `BaseArtifact` 子类中覆写 `add_artifact()` 调用 `perform_artifact_actions()`，因为此时 `artifact_data` 已绑定。

### 3.2 回合与战斗阶段

```gdscript
@export var artifact_first_turn_actions: Array[Dictionary] = []     # 玩家首回合开始时
@export var artifact_turn_start_actions: Array[Dictionary] = []      # 每个玩家回合开始时
@export var artifact_turn_end_actions: Array[Dictionary] = []        # 每个玩家回合结束时（敌人回合前）
@export var artifact_end_of_combat_actions: Array[Dictionary] = []   # 战斗胜利后
```

执行顺序（每个回合）：`artifact_counter_reset_on_turn_start` → `artifact_first_turn_actions`（仅第1回合）→ `artifact_turn_start_actions` → ... → `artifact_turn_end_actions`

### 3.3 右键点击

```gdscript
@export var artifact_right_click_actions: Array[Dictionary] = []    # 右键点击外设图标时
@export var artifact_right_click_validators: Array[Dictionary] = [
    {Scripts.VALIDATOR_PLAYER_TURN: {}},
]
```

右键点击外设图标会触发这些动作。默认需要 `VALIDATOR_PLAYER_TURN` 才能在玩家回合中使用。

### 3.4 充能满格触发

```gdscript
@export var artifact_max_counter_actions: Array[Dictionary] = []    # 充能达到上限时
```

每次充能恰好到达 `artifact_counter_max` 时触发。配合 `artifact_counter_wraparound` 控制多次触发。

---

## 4. BaseArtifact — 自定义脚本基类

### 4.1 基础生命周期

```gdscript
extends Resource
class_name BaseArtifact

var artifact_data: ArtifactData = null

func _init(_artifact_data: ArtifactData):
    artifact_data = _artifact_data
    connect_signals()
```

初始化时自动调用 `connect_signals()`，连接信号监听。

### 4.2 可覆写方法

| 方法 | 默认行为 | 覆写用途 |
|---|---|---|
| `connect_signals()` | 连接 `combat_ended`、`player_turn_started`、`player_turn_ended` | 连接自定义信号 |
| `add_artifact()` | 执行 `artifact_add_actions` | 获取时执行自定义逻辑 |
| `remove_artifact()` | 执行 `artifact_remove_actions` | 移除时执行清理逻辑 |
| `right_click_artifact()` | 执行 `artifact_right_click_actions` | 右键自定义行为 |
| `get_artifact_description()` | 返回 `artifact_description` | 动态追加描述文本 |

### 4.3 自动事件处理

`BaseArtifact` 会自动处理以下事件：

- **`_on_player_turn_started()`**: 重置充能 → 执行首回合动作 → 执行回合开始动作
- **`_on_combat_ended()`**: 重置充能 → 执行战斗结束动作
- **`_on_player_turn_ended()`**: 执行回合结束动作

### 4.4 编写自定义外设脚本

创建新文件继承 `BaseArtifact`，覆写 `connect_signals()` 来监听全局信号：

```gdscript
extends BaseArtifact

func connect_signals() -> void:
    super()  # 保留基类的回合/战斗信号连接
    Signals.card_played.connect(_on_card_played)

func _on_card_played(card_play_request: CardPlayRequest) -> void:
    # 通过 ActionGenerator 生成动作并加入队列
    ActionGenerator.generate_artifact_counter_increment_action(artifact_data, 1)
```

**关键设计准则**：
1. 在信号回调中**不要直接修改游戏状态**，而是生成 `BaseAction` 加入 `ActionHandler` 排队
2. 充能变更使用 `artifact_data.increment_artifact_counter()` 或 `ActionGenerator.generate_artifact_counter_increment_action()`
3. 外设触发行为后自动发射 `Signals.artifact_proc.emit(artifact_data)`（在 `perform_artifact_actions()` 中） 和 `Signals.artifact_counter_changed.emit(artifact_data)`（在 `set_artifact_counter()` 中）

### 4.5 perform_artifact_actions() 详解

```gdscript
func perform_artifact_actions(action_data: Array[Dictionary], bypass_disabled: bool = false)
```

此方法创建一次性的虚拟 `CardPlayRequest`，并将外设自身和充能计数注入为 `card_values`：
```gdscript
card_play_request.card_values = {
    "artifact_data": self,       # 可被 ActionIncreaseArtifactCharge 读取
    "artifact_counter": artifact_counter
}
```

这意味着在 `artifact_*_actions` 中配置的动作，可以通过 `custom_key_names` 读取充能计数：
```gdscript
artifact_turn_start_actions = [
    {
        Scripts.ACTION_APPLY_STATUS: {
            "status_effect_object_id": "status_effect_damage_increase",
            "custom_key_names": {
                "status_charge_amount": "artifact_counter",  # 用充能数作为状态层数
            },
        },
    },
]
```

---

## 5. 外设插件相关 Action

### 5.1 增减外设

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_ADD_ARTIFACT` | `ActionAddArtifact.gd` | 添加指定 ID 的外设 |
| `ACTION_ADD_ARTIFACTS_FROM_POOL` | `ActionAddArtifactsFromPool.gd` | 从奖池中随机添加外设 |
| `ACTION_SWAP_BOSS_ARTIFACT` | `ActionSwapBossArtifact.gd` | 替换起始外设（Boss 外设交换） |

**`ACTION_ADD_ARTIFACT` 参数**:
```gdscript
{"artifact_id": "artifact_draw_on_kill"}
```

**`ACTION_ADD_ARTIFACTS_FROM_POOL` 参数**:
```gdscript
{
    "artifact_count": 3,
    "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON],
    "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
}
```

### 5.2 充能控制

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_INCREASE_ARTIFACT_CHARGE` | `ActionIncreaseArtifactCharge.gd` | 增加/减少指定外设的充能 |
| `ACTION_CHANGE_ARTIFACT_CHARGE` | `ActionChangeArtifactCharge.gd` | 直接设置充能值 |
| `ACTION_CHANGE_ARTIFACT_ENABLED` | `ActionChangeArtifactEnabled.gd` | 启用/禁用外设 |

**`ACTION_INCREASE_ARTIFACT_CHARGE` 参数**:
```gdscript
{
    "artifact_id": "artifact_block_on_attacks",  # 按 ID 查找所有同类型外设
    "artifact_charge_increase": 1,                # 增量（可为负）
}
# 或者针对特定实例（BaseArtifact.perform_artifact_actions 自动注入）：
{
    "artifact_data": <特定 ArtifactData 实例>,
    "artifact_charge_increase": 2,
}
```

### 5.3 辅助方法

```gdscript
# 在自定义脚本中便捷生成充能增加 Action
ActionGenerator.generate_artifact_counter_increment_action(artifact_data, 1)
```

---

## 6. 外设插件池与过滤系统

### 6.1 ArtifactPackData — 卡包配置

```gdscript
@export var artifact_pack_artifact_ids: Array[String] = []      # 显式包含的外设 ID
@export var artifact_pack_color_id: String = ""                  # 颜色过滤
@export var exclude_non_standard_rarities = false                # 是否排除非标稀有度
```

角色初始外设通过 `CharacterData.character_starting_artifact_pack_ids` 指定卡包。角色选择界面的初始外设显示取自 `character_starting_artifact_ids[0]`。

### 6.2 ArtifactFilter — 链式过滤

`ArtifactFilter` 是运行时筛选外设的核心工具，支持方法链式调用：

```gdscript
var filter = ArtifactFilter.new()
    .filter_colors(["color_red"])               # 只保留红色外设
    .filter_rarity(ArtifactData.STANDARD_ARTIFACT_RARITIES)  # 只保留标准稀有度
    .filter_appears_in_artifact_packs(true)      # 只保留可掉落的外设
    .first_results(3)                            # 取前3个结果

var artifacts = filter.convert_to_artifact_prototypes()  # 转为可修改实例
```

#### 完整的过滤器链方法

| 方法 | 参数 | 作用 |
|---|---|---|
| `filter_colors(ids, include)` | 颜色 ID 数组，是否包含 | 按颜色过滤 |
| `filter_rarity(rarities, include)` | 稀有度数组，是否包含 | 按稀有度过滤 |
| `filter_appears_in_artifact_packs(include)` | 是否在卡包中 | 过滤不可掉落外设 |
| `include_artifact_object_ids(ids)` | ID 数组 | 强制包含指定外设（白名单） |
| `first_results(n)` | 数量，-1=不限 | 截取前 N 个 |
| `cache_filter(id)` | 缓存 ID | 锁定过滤结果并缓存到 Global |
| `convert_to_artifact_prototypes()` | — | 终止链：转为可修改实例副本 |
| `convert_to_unique_artifact_prototypes()` | — | 终止链：转为去重实例副本 |
| `convert_to_artifact_object_ids()` | — | 终止链：转为 ID 列表 |
| `convert_to_unique_artifact_object_ids()` | — | 终止链：转为去重 ID 列表 |

### 6.3 PlayerData 外设管理

```gdscript
func add_artifact(artifact_id: String)     # 添加外设
func remove_artifact(artifact_id: String)  # 移除外设
func get_player_artifacts() -> Array       # 获取所有外设
func get_player_artifacts_with_artifact_id(id: String) -> Array[ArtifactData]  # 按 ID 查找
func initialize_artifact_pool()            # 初始化外设奖池（新游戏时调用）
func get_next_boss_artifacts_from_pool(n: int) -> Array[String]  # 从 Boss 池获取
```

---

## 7. 外设插件设计示例

### 7.1 纯事件型外设（不需要自定义脚本）

适用于只在特定时机触发一次性/周期性效果的外设：

```gdscript
var artifact_heal: ArtifactData = ArtifactData.new("artifact_heal_on_combat_ended")
artifact_heal.artifact_name = "战后治疗外设插件"
artifact_heal.artifact_description = "战斗结束时恢复5点完整度"
artifact_heal.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
artifact_heal.artifact_texture_path = "sprites/artifacts/artifact_heal.png"
artifact_heal.artifact_end_of_combat_actions = [
    {
        Scripts.ACTION_ADD_HEALTH: {
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
            "health_amount": 5,
        },
    },
]
Global.register_rod(artifact_heal)
```

### 7.2 充能型外设（使用 artifact_max_counter_actions）

适用于累进式效果的外设：

```gdscript
var artifact_block_on_attacks: ArtifactData = ArtifactData.new("artifact_block_on_attacks")
artifact_block_on_attacks.artifact_name = "攻击防火墙外设插件"
artifact_block_on_attacks.artifact_description = "每3次攻击获得5点防火墙"
artifact_block_on_attacks.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
artifact_block_on_attacks.artifact_color_id = "color_red"
artifact_block_on_attacks.artifact_texture_path = "sprites/artifacts/artifact_block_on_attacks.png"
artifact_block_on_attacks.artifact_script_path = "res://scripts/artifacts/ArtifactBlockOnAttacks.gd"
# 充能配置
artifact_block_on_attacks.artifact_counter_max = 3
artifact_block_on_attacks.artifact_counter_wraparound = true
artifact_block_on_attacks.artifact_counter_reset_on_turn_start = 0
artifact_block_on_attacks.artifact_counter_reset_on_combat_end = 0
# 满充动作
artifact_block_on_attacks.artifact_max_counter_actions = [
    {
        Scripts.ACTION_BLOCK: {
            "block": 5,
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
        },
    },
]
Global.register_rod(artifact_block_on_attacks)
```

配套的自定义脚本：
```gdscript
extends BaseArtifact

func connect_signals() -> void:
    super()
    Signals.card_played.connect(_on_card_played)

func _on_card_played(card_play_request: CardPlayRequest) -> void:
    if card_play_request.card_data.card_type == CardData.CARD_TYPES.ATTACK:
        ActionGenerator.generate_artifact_counter_increment_action(artifact_data, 1)
```

### 7.3 获得/移除时修改全局机制的外设

适用于改变游戏底层规则的外设，通过拦截器实现：

```gdscript
var artifact_negate_money: ArtifactData = ArtifactData.new("artifact_negate_money_gain")
artifact_negate_money.artifact_name = "算力外设插件"
artifact_negate_money.artifact_description = "每回合获得 {0}。无法再获得数据币".format([Card.ENERGY_ICON_KEYWORD])
# 获得时加每回合算力
artifact_negate_money.artifact_add_actions = [
    {
        Scripts.ACTION_ADD_ENERGY: {
            "target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
            "energy_amount_max": 1,
        },
    },
]
# 移除时撤销算力
artifact_negate_money.artifact_remove_actions = [
    {
        Scripts.ACTION_ADD_ENERGY: {
            "target_overrides": BaseAction.TARGET_OVERRIDES.PLAYER,
            "energy_amount_max": -1,
        },
    },
]
# 注册拦截器阻止数据币获取
artifact_negate_money.artifact_interceptor_ids = ["interceptor_negate_add_money"]
Global.register_rod(artifact_negate_money)
```

### 7.4 右键主动使用的外设

适用于可手动触发效果的外设：

```gdscript
var artifact_shuffle: ArtifactData = ArtifactData.new("artifact_right_click_shuffle_deck")
artifact_shuffle.artifact_name = "重洗外设插件"
artifact_shuffle.artifact_description = "右键将回收站的数据重新分配入内存队列"
artifact_shuffle.artifact_rarity = ArtifactData.ARTIFACT_RARITIES.COMMON
artifact_shuffle.artifact_script_path = "res://scripts/artifacts/BaseArtifact.gd"
artifact_shuffle.artifact_right_click_actions = [
    {Scripts.ACTION_RESHUFFLE: {}},
]
Global.register_rod(artifact_shuffle)
```

### 7.5 充能关联状态的外设

使用 `custom_key_names` 将充能值注入状态效果层数：

```gdscript
var artifact_rest_attack: ArtifactData = ArtifactData.new("artifact_rest_attack")
artifact_rest_attack.artifact_counter_max = 3
# 获取时添加维护动作
artifact_rest_attack.artifact_add_actions = [
    {
        Scripts.ACTION_UPDATE_REST_ACTIONS: {
            "add_rest_action_object_ids": ["rest_action_increase_attack"],
        },
    },
]
# 战斗开始根据充能值施加状态
artifact_rest_attack.artifact_first_turn_actions = [
    {
        Scripts.ACTION_APPLY_STATUS: {
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
            "status_effect_object_id": "status_effect_damage_increase",
            "custom_key_names": {
                "status_charge_amount": "artifact_counter",  # 充能 → 状态层数
            },
        },
    },
]
Global.register_rod(artifact_rest_attack)
```

---

## 8. 外设插件 UI（Artifact.gd）

外设图标 UI 组件 (`scripts/ui/Artifact.gd`) 支持：

- **自动显示充能计数**：监听 `Signals.artifact_counter_changed`，非 0 时在图标右上角显示数字
- **触发动画**：监听 `Signals.artifact_proc`，播放 `proc_anim` 动画
- **Hover 缩放**：通过 `UIHover.scale_up/scale_down` 实现浮动效果
- **悬停提示**：鼠标悬停时通过 `HandManager.tooltip.display_artifact_tooltip()` 显示外设说明
- **右键交互**：右键点击调用 `artifact_script.right_click_artifact()`

### 充能计数显示规则

- `artifact_counter == 0`：不显示数字
- `artifact_counter > 0`：显示当前计数（如 `3`）
- 配合 `artifact_counter_wraparound` + `artifact_counter_max`，玩家可见充能进度

---

## 9. 角色初始外设配置

角色通过 `CharacterData` 定义初始外设：

```gdscript
# 单一外设（角色选择界面显示）
character_red.character_starting_artifact_ids = ["artifact_block_on_attacks"]

# 外设卡包（掉落池过滤）
character_red.character_starting_artifact_pack_ids = [
    "artifact_pack_white",          # 白色（通用）
    "artifact_pack_red",            # 红色（角色专属）
]
```

角色初始外设通常是 `BASIC` 稀有度，不需要出现在通用掉落池中。第一个初始外设会在角色选择界面中展示。

---

## 10. 设计新外设检查清单

- [ ] `artifact_name` 和 `artifact_description` 已设置
- [ ] `artifact_rarity` 已设置（COMMON / UNCOMMON / RARE / BOSS / SHOP / EVENT）
- [ ] `artifact_color_id` 已设置（不设则为通用白色）
- [ ] `artifact_texture_path` 指向正确资源
- [ ] 选择正确的触发时机（`artifact_add_actions` / `artifact_turn_start_actions` / 等）
- [ ] 如需自定义信号监听，继承 `BaseArtifact` 创建脚本并设置 `artifact_script_path`
- [ ] 如需拦截动作，配置 `artifact_interceptor_ids` 并注册拦截器
- [ ] 如需充能机制，配置 `artifact_counter_max` + `artifact_counter_wraparound` + `artifact_counter_reset_on_*`
- [ ] 通过 `Global.register_rod()` 注册
- [ ] 如果是角色初始外设，在 `CharacterData.character_starting_artifact_ids` 中引用
- [ ] 如果是卡包外设，确保在相应的 `ArtifactPackData` 范围内

## 11. 当前全部外设属性对比表

| # | 内部 ID | 名称 | 颜色 | 稀有度 | 是否掉落 | 角色初始外设 | 描述摘要 |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 1 | `artifact_add_money` | 数据币外设插件 | 白 | BASIC | 是 | — | 获得时增加 200 数据币 |
| 2 | `artifact_negate_money_gain` | 算力外设插件 | 白 | BASIC | 是 | — | 每回合获得 1 算力，无法获得数据币 |
| 3 | `artifact_heal_on_combat_ended` | 战后治疗外设插件 | 白 | COMMON | 是 | — | 战斗结束时恢复 5 点完整度 |
| 4 | `artifact_full_heal` | 完全治疗外设插件 | 白 | RARE | 是 | — | 获得时完全恢复完整度 |
| 5 | `artifact_draw_on_kill` | 击杀加载脚本外设插件 | 白 | UNCOMMON | 是 | — | 击杀敌人时抽 1 张牌 |
| 6 | `artifact_draw_on_combat_start` | 初始加载脚本外设插件 | 绿 | UNCOMMON | 是 | 赛博植物学家 | 首回合额外加载 2 个脚本 |
| 7 | `artifact_energy_on_combat_start` | 初始算力外设插件 | 白 | UNCOMMON | 是 | — | 首回合获得 1 算力 |
| 8 | `artifact_easy_mode` | 安全模式外设插件 | 白 | EVENT | 是 | — | 将敌人完整度设为 1 |
| 9 | `artifact_block_on_attacks` | 攻击防火墙外设插件 | 红 | COMMON | 是 | 码农 | 每 3 次攻击获得 5 点防火墙 |
| 10 | `artifact_retain_hand` | 当前线程保留外设插件 | 白 | BOSS | 是 | — | 回合结束时不丢弃手牌 |
| 11 | `artifact_preserve_energy` | 算力保留外设插件 | 白 | RARE | 是 | — | 回合结束未用算力保留至下回合 |
| 12 | `artifact_increase_attack_on_rest` | 碎片整理增伤外设插件 | 橙 | COMMON | 是 | — | 维护终端永久提升 1 点攻击力（最高 3） |
| 13 | `artifact_see_top_of_draw_pile` | 查看脚本库外设插件 | 蓝 | COMMON | 是 | 渗透专家 | 查看脚本库顶部的脚本 |
| 14 | `artifact_top_deck_attack_card` | 攻击脚本置顶外设插件 | 白 | COMMON | 是 | — | 选择一个攻击脚本置于脚本库顶部 |
| 15 | `artifact_right_click_shuffle_deck` | 重洗外设插件 | 绿 | COMMON | 是 | — | 右键将回收站的数据重新分配入内存队列 |

### 属性统计

| 维度 | 分布 |
|:---|:---|
| 稀有度 | BASIC x2，COMMON x7，UNCOMMON x3，RARE x2，BOSS x1，EVENT x1 |
| 颜色分布 | 白(通用) x9，绿 x2，红 x1，蓝 x1，橙 x1 |
| 角色初始外设 | 3 个（码农→攻击防火墙，渗透专家→查看脚本库，赛博植物学家→初始加载脚本） |


所有场景共用的前提过滤 ：颜色过滤（白通用 + 角色专属色）+ 是否掉落过滤。这两个在游戏启动时就固定好了。

各自的不同点 ：

场景 稀有度过滤 商店（普通外设） COMMON / UNCOMMON / RARE 商店（商店专属外设） SHOP Boss 奖励 BOSS 宝箱 / 精英 按权重随机抽一个稀有度（COMMON 居多）