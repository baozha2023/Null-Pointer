# 物理删除品（Consumables）设计指南

本文档深入分析游戏中配置物理删除品（Consumables）的完整机制、可用接口和属性体系。

---

## 1. 概念概述

物理删除品是玩家随身携带的一次性战斗道具，在战斗中使用后消失。玩家拥有固定 3 个槽位（`player_consumable_slot_count = 3`），物理删除品可通过宝箱、商店、休息点等途径获取。

每个物理删除品都是 `ConsumableData` 的实例，在 `add_consumables()` 中创建，通过 `Global.register_rod()` 注册到全局只读数据中。

---

## 2. 核心数据类

| 类 | 文件 | 作用 |
|---|---|---|
| `ConsumableData` | `data/readonly/ConsumableData.gd` | 物理删除品的原型数据：名称、效果、使用方式、稀有度 |
| `ConsumablePackData` | `data/readonly/ConsumablePackData.gd` | 物理删除品卡包数据，控制掉落池过滤 |
| `ConsumableFilter` | `data/filters/ConsumableFilter.gd` | 链式过滤器，运行时从全池中筛选物理删除品 |

物理删除品在 `GlobalProdDataGenerator.add_consumables()` 中注册，对应的卡包在 `add_consumable_packs()` 中注册。

---

## 3. ConsumableData — 全属性详解

### 3.1 基础信息

```gdscript
@export var consumable_name: String = ""              # 显示名称
@export var consumable_description: String = ""        # 描述文本（支持格式化字符串）
@export var consumable_texture_path: String = "..."    # 图标路径
@export var consumable_color_id: String = ""           # 所属颜色（用于卡包过滤）
```

### 3.2 稀有度枚举

```gdscript
enum CONSUMABLE_RARITIES {
    COMMON,     # 内置
    UNCOMMON,   # 开源
    RARE,       # 闭源
    LEGENDARY,  # 零日
}
@export var consumable_rarity: int = CONSUMABLE_RARITIES.COMMON
```

稀有度中文显示映射定义在 [`Tooltips.gd`](file:///f:/Godot/games/Slay-The-Robot/scripts/ui/Tooltips.gd#L149-L153)：

| 稀有度 | 中文名 |
|---|---|
| `COMMON` | 内置 |
| `UNCOMMON` | 开源 |
| `RARE` | 闭源 |
| `LEGENDARY` | 零日 |

### 3.3 使用方式

```gdscript
## 使用动作的文本描述，如"饮用"、"投掷"
@export var consumable_use_text: String = "Drink"

## 是否需要点击目标敌人使用
@export var consumable_requires_target: bool = false

## 使用时消耗的算力（0 则不显示消耗）
@export var consumable_energy_cost: int = 0
```

- `consumable_use_text`：UI 上显示的按键文字，无实际逻辑影响
- `consumable_requires_target`：为 `true` 时点击使用按钮后会要求玩家选择一个敌人目标
- `consumable_energy_cost`：使用时的算力消耗，为 0 时不显示算力图标。UI 中会自动判断当前算力是否足够，不足时按钮变灰

### 3.4 手动/自动使用

```gdscript
## 若为 true，玩家无法通过 UI 手动使用（按钮禁用）
@export var consumable_use_disabled: bool = false
```

`consumable_use_disabled = true` 适用于被动触发的物理删除品（如自动复活护符），使用按钮永远灰色。

**动态禁用**：可通过拦截器在运行时修改 `consumable_use_disabled`。`ConsumableData.get_consumable_intercepted_action_results()` 会生成 `ActionConsumable` 进行拦截，返回的字典包含拦截后的 `consumable_use_disabled` 值，UI 据此决定按钮状态。

### 3.5 被动战斗效果

```gdscript
## 战斗开始时，如果你持有此物理删除品，自动执行的行动
@export var consumable_initial_combat_actions: Array[Dictionary] = []
```

此属性定义物理删除品在战斗开始时的被动效果。系统不会消耗该物理删除品，只会执行其中的 actions。适用于"持有即生效"的设计。

### 3.6 核心效果定义

```gdscript
## 使用物理删除品时执行的动作列表
@export var consumable_actions: Array[Dictionary] = []

## 注入到 CardPlayRequest.card_values 中的自定义键值对
## 用于 consumable_actions 中通过 custom_key_names 动态读取
@export var consumable_values: Dictionary[String, Variant] = {}
```

#### `consumable_actions`

标准的 Action 数组，格式与 `artifact_*_actions`、`enemy_intent_custom_actions` 完全一致：

```gdscript
consumable_actions = [
    {
        Scripts.ACTION_HEAL_PERCENT: {
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
        },
    },
]
```

#### `consumable_values` + `custom_key_names`

`consumable_values` 存储自定义键值对，在物理删除品使用时（`ActionUseConsumable`），这些值会被复制到 `CardPlayRequest.card_values` 中。actions 可通过 `custom_key_names` 动态引用这些值：

```gdscript
# consumable_values 中定义动态参数
consumable_values = {
    "percentage_heal_amount": 0.20,
    "force_dead_targets": true,
}

# consumable_actions 中通过 custom_key_names 引用
consumable_actions = [
    {
        Scripts.ACTION_HEAL_PERCENT: {
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
            # "percentage_heal_amount": 从 card_values 自动读取
            # "force_dead_targets": 从 card_values 自动读取
        },
    },
]
```

这种模式使得多个物理删除品可以复用同一 Action，仅需配置不同的 `consumable_values`。

---

## 4. 物理删除品相关 Action

### 4.1 添加物理删除品

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_ADD_CONSUMABLE` | `ActionAddConsumable.gd` | 添加物理删除品到空槽位 |

**参数**：
```gdscript
{
    "consumable_object_id": "consumable_heal",      # 指定 ID 的物理删除品
    "random_consumable": false,                      # 设为 true 则随机从池中选取
    "fill_all_slots": false,                         # 填充所有空槽位
    "slot_count": 1,                                 # 填充的槽位数量
    "consumable_whitelist_ids": [],                  # 随机时的白名单
    "consumable_blacklist_ids": [],                  # 随机时的黑名单
    "rng_name": "rng_consumables",                   # 使用的随机数生成器名称
}
```

**三种使用模式**：

1. **指定 ID**：`consumable_object_id = "consumable_heal"`，添加指定的物理删除品
2. **随机**：`random_consumable = true`，从全部已注册 ID 中随机选取（可配合黑白名单）
3. **填充所有空位**：`fill_all_slots = true`，无视 `slot_count`

**添加逻辑**（`Consumables.gd.add_consumable()`）：从 slot 0 开始遍历，找到第一个空槽位即填入。如果所有槽位已满则什么都不做。

### 4.2 使用物理删除品

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_USE_CONSUMABLE` | `ActionUseConsumable.gd` | 使用指定槽位的物理删除品 |

**参数**：
```gdscript
{
    "consumable_slot_index": 0,                          # 槽位编号
    "perform_comsumable_actions_instantly": false,       # 是否立即执行（不等 ActionHandler 队列）
}
```

**执行流程**：
1. 通过拦截器获取参数
2. 从 `player_consumable_slot_to_consumable_object_id` 中读取对应 ID
3. 删除槽位中的物理删除品
4. 创建 `CardPlayRequest`，注入 `consumable_values`
5. 生成 actions 并执行
6. 发射 `Signals.consumable_used`

**`perform_comsumable_actions_instantly = true`** 用于必须在队列之前立即生效的效果（如自动复活）。设为 `true` 时，物理删除品的 actions 通过 `action.perform_action()` 直接同步执行，不经过 `ActionHandler` 队列。

### 4.3 虚拟消耗品动作（拦截预览）

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_CONSUMABLE` | `ActionConsumable.gd` | 空壳 Action，仅用于拦截预览 |

`ActionGenerator.generate_consumable(card_play_request)` 生成一个不执行任何实际效果的 `ActionConsumable`，仅用于 `get_consumable_intercepted_action_results()` 中获取拦截器修改后的值（如动态禁用、修改算力消耗）。UI 层用此方法在按钮渲染前预判状态。

### 4.4 修改物理删除品掉落池

| Action 常量 | 脚本 | 用途 |
|---|---|---|
| `ACTION_UPDATE_CONSUMABLE_DRAFTS` | `ActionUpdateConsumableDrafts.gd` | 动态修改物理删除品奖池 |

**参数**：
```gdscript
{
    "reset_to_starting_consumable_packs": false,   # 重置为角色初始卡包
    "remove_all_consumable_packs": false,           # 清空所有卡包
    "add_consumable_pack_object_ids": [],           # 添加卡包
    "remove_consumable_pack_object_ids": [],        # 移除卡包
    "whitelist_consumable_object_ids": [],          # 白名单（强制包含）
    "blacklist_consumable_object_ids": [],          # 黑名单（永远排除）
}
```

所有修改在动作执行后会自动调用 `PlayerData.regenerate_consumable_available_id_cache()` 重建缓存。白名单和黑名单会持久化到 `player_reward_draft_consumable_id_whitelist/blacklist`。

---

## 5. 物理删除品生成函数（ActionGenerator）

### 5.1 generate_consumable()

```gdscript
func generate_consumable(card_play_request: CardPlayRequest) -> BaseAction
```

生成一个虚拟的 `ActionConsumable`，用于获取拦截后的物理删除品属性（算力消耗、禁用状态、使用文本）。UI 在渲染物理删除品按钮时调用它来预览状态。

### 5.2 generate_use_consumable()

```gdscript
func generate_use_consumable(
    selected_target: BaseCombatant,
    consumable_slot_index: int,
    perform_comsumable_actions_instantly: bool = false
) -> void
```

生成一个 `ActionUseConsumable` 并**立即执行**（不经过 ActionHandler 队列）。这是 UI 使用物理删除品的入口：

- `selected_target`：需要点击目标时传入敌人，否则传入 `null`
- `consumable_slot_index`：槽位编号
- `perform_comsumable_actions_instantly`：自动复活等特殊场景用

---

## 6. PlayerData 物理删除品管理体系

### 6.1 数据存储

```gdscript
## 最大槽位数量
@export var player_consumable_slot_count: int = 3

## 槽位编号 → 物理删除品 ID 的映射（字符串 key，从 "0" 开始）
@export var player_consumable_slot_to_consumable_object_id: Dictionary[String, String] = {}
```

### 6.2 核心方法

```gdscript
## 检查是否所有槽位已满
func are_consumable_slots_full() -> bool

## 获取空槽位数量
func get_empty_consumable_slot_count() -> int

## 获取指定槽位的 ConsumableData（返回 null 表示空槽）
func get_consumable_in_slot(consumable_slot: int) -> ConsumableData

## 获取所有非空槽位的物理删除品 ID 列表
func get_available_consumable_ids() -> Array[String]
```

### 6.3 奖池缓存系统

```gdscript
## 可获取的物理删除品 ID 集合（Set 结构，key 为 ID，value 为 null）
var player_consumable_available_consumable_id_cache: Dictionary[String, Variant]

## 按稀有度分桶缓存的 ID 列表，供奖励生成时使用
var player_reward_consumable_rarity_cache: Dictionary[int, Array]

## 奖池过滤器缓存（由 regenerate_consumable_available_id_cache() 构建）
var player_reward_consumable_filter_cache: ConsumableFilter
```

`regenerate_consumable_available_id_cache()` 的构建逻辑：
1. 合并所有 `player_consumable_pack_ids` 对应的 ConsumablePackData 过滤器结果
2. 应用白名单（强制添加）和黑名单（强制排除）
3. 按稀有度分桶缓存

### 6.4 卡包与黑白名单

```gdscript
## 物理删除品卡包 ID 列表（控制奖池范围）
@export var player_consumable_pack_ids: Array[String] = []

## 白名单（必定出现在奖池中的物理删除品 ID）
@export var player_reward_draft_consumable_id_whitelist: Array[String] = []

## 黑名单（永远不出现在奖池中的物理删除品 ID）
@export var player_reward_draft_consumable_id_blacklist: Array[String] = []
```

---

## 7. ConsumablePackData — 卡包配置

```gdscript
@export var consumable_pack_consumable_ids: Array[String] = []  # 显式包含的 ID
@export var consumable_pack_color_id: String = ""                # 颜色过滤
```

`create_consumable_pack_consumable_filter()` 方法：
1. 如果设置了颜色，先按颜色过滤
2. 再强制包含 `consumable_pack_consumable_ids` 中的 ID

当前游戏中预注册的卡包：

| ID | 颜色过滤 | 用途 |
|---|---|---|
| `consumable_pack_all` | 无 | 无过滤，包含全部 |
| `consumable_pack_white` | `color_white` | 通用（白色）池 |
| `consumable_pack_red` | `color_red` | 红色角色池 |
| `consumable_pack_blue` | `color_blue` | 蓝色角色池 |
| `consumable_pack_green` | `color_green` | 绿色角色池 |
| `consumable_pack_orange` | `color_orange` | 橙色角色池 |

游戏启动时，`Global._generate_consumable_pack_cache()` 为每个卡包生成一次 `ConsumableFilter` 并缓存，后续奖励生成直接复用缓存结果。

---

## 8. ConsumableFilter — 链式过滤

`ConsumableFilter` 支持方法链式调用，与 `ArtifactFilter` 设计一致：

```gdscript
var filter = ConsumableFilter.new()
    .filter_colors(["color_white"])           # 只保留白色
    .include_consumable_object_ids([...])      # 强制包含指定 ID
    .first_results(3)                          # 取前 3 个结果
    .cache_filter("my_custom_cache")           # 缓存结果

# 终止链：转为 ID 列表
var ids = filter.convert_to_consumable_object_ids()
```

### 完整的过滤器链方法

| 方法 | 参数 | 作用 |
|---|---|---|
| `filter_colors(ids, include)` | 颜色 ID 数组，是否包含 | 按颜色过滤 |
| `include_consumable_object_ids(ids)` | ID 数组 | 强制包含指定 ID（白名单） |
| `first_results(n)` | 数量，-1=不限 | 截取前 N 个 |
| `cache_filter(id)` | 缓存 ID | 锁定结果并缓存到 Global |
| `convert_to_consumable_object_ids()` | — | 终止链：转为 ID 列表 |
| `convert_to_unique_consumable_object_ids()` | — | 终止链：转为去重 ID 列表 |

**注意**：`ConsumableFilter` 不支持稀有度过滤（`filter_rarity`），因为物理删除品奖池不需要按稀有度预先过滤——稀有度筛选在 `Random.get_shop_consumable_prices()` 中按价格区间间接体现。

---

## 9. 商店定价

物理删除品在商店中的价格由稀有度决定，定义在 [`ShopData.gd`](file:///f:/Godot/games/Slay-The-Robot/data/mutable/ShopData.gd#L43-L48)：

```gdscript
const CONSUMABLE_RARITY_TO_PRICE_RANGE: Dictionary = {
    ConsumableData.CONSUMABLE_RARITIES.COMMON: [50, 80],
    ConsumableData.CONSUMABLE_RARITIES.UNCOMMON: [85, 115],
    ConsumableData.CONSUMABLE_RARITIES.RARE: [120, 140],
    ConsumableData.CONSUMABLE_RARITIES.LEGENDARY: [130, 150],
}
```

价格在区间内随机生成：`price = min + (rng.randi() % (max - min))`。

---

## 10. 信号系统

| 信号 | 触发时机 | 参数 |
|---|---|---|
| `consumable_added` | 物理删除品被添加到槽位 | `(consumable_index, consumable_object_id)` |
| `consumable_discarded` | 物理删除品被丢弃 | `(consumable_index, consumable_object_id)` |
| `consumable_used` | 物理删除品被使用 | `(consumable_index, consumable_object_id)` |
| `consumable_purchased` | 从商店购买物理删除品 | `(consumable_object_id)` |
| `add_consumable_requested` | 请求添加物理删除品 | `(consumable_object_id)` |

---

## 11. UI 系统

### 11.1 Consumables.gd — 物理删除品容器

管理整个物理删除品栏的 UI 交互：

- 初始化：`_on_run_started()` 时创建 3 个 `ConsumableButton`
- 选择：点击按钮 → 弹出下拉菜单（使用/丢弃）
- 使用流程：
  1. 检查 `consumable_use_disabled` 和算力是否足够
  2. 若 `consumable_requires_target = true`，显示"选择目标"提示
  3. 点击敌人后调用 `use_consumable(enemy, slot_index)`
  4. 内部通过 `get_consumable_intercepted_action_results()` 获取拦截后属性
  5. 扣除算力 → 调用 `ActionGenerator.generate_use_consumable()` → 发射信号 → 刷新按钮
- 丢弃：直接移除槽位数据，发射 `consumable_discarded`

### 11.2 ConsumableButton.gd — 单个槽位按钮

- 显示物理删除品图标（有物品时），空槽位半透明
- 鼠标悬停显示 tooltip
- 点击发射 `consumable_slot_button_up` 信号

### 11.3 ConsumableShopButton.gd — 商店按钮

- 显示图标
- 鼠标悬停显示 `display_codex_consumable_tooltip()`

### 11.4 CodexConsumable.gd — 图鉴条目

- 显示图标
- 鼠标悬停显示 `display_codex_consumable_tooltip()`

### 11.5 CodexConsumablesMenu.gd — 图鉴菜单

- 按稀有度排序展示所有已注册物理删除品

---

## 12. 高级设计模式

### 12.1 自动复活物理删除品

这是物理删除品中最复杂的设计模式，演示了如何使用拦截器 + 自动使用 + 全局 RunModifier 实现被动效果。

#### ConsumableData 定义

```gdscript
var consumable_auto_revive: ConsumableData = ConsumableData.new("consumable_auto_revive")
consumable_auto_revive.consumable_name = "自动复活护符"
consumable_auto_revive.consumable_description = "玩家死亡时回复20%完整度"
consumable_auto_revive.consumable_use_text = "使用"
consumable_auto_revive.consumable_requires_target = false
consumable_auto_revive.consumable_use_disabled = true       # 不可手动使用
consumable_auto_revive.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
consumable_auto_revive.consumable_texture_path = "sprites/consumables/consumable_auto_revive.png"
consumable_auto_revive.consumable_values = {
    "percentage_heal_amount": 0.20,
    "force_dead_targets": true,         # 即使目标已死亡也能生效
}
consumable_auto_revive.consumable_actions = [
    {
        Scripts.ACTION_HEAL_PERCENT: {
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
        },
    },
]
Global.register_rod(consumable_auto_revive)
```

#### 拦截器定义

```gdscript
var interceptor_consumable_auto_revive: ActionInterceptorData = ActionInterceptorData.new("interceptor_consumable_auto_revive")
interceptor_consumable_auto_revive.action_interceptor_priority = 10000    # 极高优先级，确保在死亡结算前触发
interceptor_consumable_auto_revive.action_interceptor_modifies_parent = true
interceptor_consumable_auto_revive.action_interceptor_script_path = Scripts.INTERCEPTOR_CONSUMABLE_AUTO_REVIVE
interceptor_consumable_auto_revive.action_intercepted_action_paths = [Scripts.ACTION_DEATH]
Global.register_rod(interceptor_consumable_auto_revive)
```

#### 拦截器脚本实现

[`InterceptorConsumableAutoRevive.gd`](file:///f:/Godot/games/Slay-The-Robot/scripts/action_interceptors/InterceptorConsumableAutoRevive.gd)：

```gdscript
extends BaseActionInterceptor

const AUTO_REVIVE_CONSUMAMBLE_ID: String = "consumable_auto_revive"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
    # 扫描所有槽位寻找复活护符
    var auto_revive_consumable_slot_index: int = -1
    for consumable_slot_index: int in Global.player_data.player_consumable_slot_count:
        var consumable_data: ConsumableData = Global.get_player_consumable_in_slot_index(consumable_slot_index)
        if consumable_data != null and consumable_data.object_id == AUTO_REVIVE_CONSUMAMBLE_ID:
            auto_revive_consumable_slot_index = consumable_slot_index
            break

    if auto_revive_consumable_slot_index != -1:
        # 立即执行使用（不等队列，确保在死亡检查前完成回血）
        ActionGenerator.generate_use_consumable(parent_combatant, auto_revive_consumable_slot_index, true)
        return ACTION_ACCEPTENCES.STOPPED    # 阻止死亡

    return ACTION_ACCEPTENCES.CONTINUE         # 没有复活护符，继续死亡流程
```

#### RunModifier 确保拦截器永远激活

```gdscript
var run_modifier_consumable_auto_revive: RunModifierData = RunModifierData.new("run_modifier_consumable_auto_revive")
run_modifier_consumable_auto_revive.run_modifier_is_automatic = true  # 无视难度自动注册
run_modifier_consumable_auto_revive.run_modifier_interceptor_ids = ["interceptor_consumable_auto_revive"]
Global.register_rod(run_modifier_consumable_auto_revive)
```

**关键设计要点**：
- `perform_comsumable_actions_instantly = true`：必须立即执行，不能加入 ActionHandler 队列，否则可能在回血前玩家已经判定死亡
- 拦截器优先级设为 `10000`（极高），确保在死亡链中第一个触发
- 如果找到复活护符返回 `STOPPED`（阻止死亡），否则返回 `CONTINUE`（继续死亡）
- `force_dead_targets = true`：治疗 Action 可以作用于已死亡的战斗单位

### 12.2 持有即生效的被动物理删除品

利用 `consumable_initial_combat_actions`，物理删除品可以在持有状态下自动在战斗开始时生效而不会被消耗：

```gdscript
consumable_initial_combat_actions = [
    {
        Scripts.ACTION_APPLY_STATUS: {
            "status_effect_object_id": "status_effect_damage_increase",
            "status_charge_amount": 3,
            "target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
        },
    },
]
```

### 12.3 需要目标的物理删除品

设置 `consumable_requires_target = true` 后，使用流程变为：

1. 点击物理删除品按钮 → 弹出下拉
2. 点击"使用" → 显示"选择目标"提示
3. 点击敌方目标 → 执行使用

配合 `TARGET_OVERRIDES.SELECTED_TARGETS` 传递选中的目标：

```gdscript
consumable_actions = [
    {
        Scripts.ACTION_ATTACK: {
            "damage": 10,
            # 目标由 Consumables.gd 选择敌人时传入
        },
    },
]
```

---

## 13. 角色初始消耗品配置

角色通过 `CharacterData` 定义初始物理删除品卡包：

```gdscript
# 通用 + 角色专属双卡包
character_red.character_starting_consumable_pack_ids = [
    "consumable_pack_white",
    "consumable_pack_red",
]
```

新游戏开始时，`Global.start_run()` 会将 `character_starting_consumable_pack_ids` 复制到 `PlayerData.player_consumable_pack_ids`，后续所有物理删除品奖励由此决定。

**注意**：角色没有"初始自带物理删除品"的设定（不同于外设插件的 `character_starting_artifact_ids`）。物理删除品只在游戏过程中通过奖励/商店/事件获得。

---

## 14. 当前物理删除品完整属性对比表

| # | 内部 ID | 名称 | 颜色 | 稀有度 | 算力消耗 | 需要目标 | 描述摘要 |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 1 | `consumable_heal` | 治疗道具 | 白 | 内置 | 0 | 否 | 回复 20% 最大完整度 |
| 2 | `consumable_block` | 防火墙道具 | 白 | 内置 | 0 | 否 | 获得 10 点防火墙 |
| 3 | `consumable_damaging` | 伤害道具 | 白 | 内置 | 0 | 是 | 对目标造成 10 点伤害 |
| 4 | `consumable_energy` | 算力注射剂 | 白 | 内置 | 0 | 否 | 获得 2 点算力 |
| 5 | `consumable_money` | 数据币钱包 | 白 | 内置 | 0 | 否 | 获得 50 数据币 |
| 6 | `consumable_multi_damaging` | 群体伤害道具 | 白 | 开源 | 0 | 否 | 对所有敌人造成 10 点伤害 |
| 7 | `consumable_draw` | 内存扩容模块 | 白 | 开源 | 0 | 否 | 读取 3 个脚本 |
| 8 | `consumable_reshuffle` | 碎片整理器 | 白 | 开源 | 0 | 否 | 将回收站所有脚本洗入待加载区 |
| 9 | `consumable_reset_block` | 防火墙渗透器 | 白 | 开源 | 0 | 是 | 清除目标敌人的防火墙 |
| 10 | `consumable_auto_revive` | 自动复活护符 | 白 | 闭源 | — | 否 | 死亡时自动回复 20% 完整度（不可手动使用） |
| 11 | `consumable_vulnerable` | 漏洞扫描器 | 白 | 闭源 | 1 | 否 | 对所有敌人施加 3 层漏洞暴露 |
| 12 | `consumable_damage_boost` | 超频核心 | 白 | 闭源 | 1 | 否 | 获得 5 层算力增幅 |
| 13 | `consumable_corrosion` | 内存泄漏协议 | 白 | 零日 | 2 | 否 | 对所有战斗单位施加 15 层内核腐蚀 |

---

## 15. 新增物理删除品检查清单

- [ ] `consumable_name` 已设置（显示名）
- [ ] `consumable_description` 已设置（提示文本）
- [ ] `consumable_use_text` 已设置（如"饮用""投掷""使用"）
- [ ] `consumable_texture_path` 指向正确图标资源
- [ ] `consumable_rarity` 已设置（COMMON/UNCOMMON/RARE/LEGENDARY）
- [ ] `consumable_color_id` 已设置（如果不设则为通用白色）
- [ ] `consumable_energy_cost` 已设置（0 = 免费）
- [ ] `consumable_requires_target` 已设置（是否需要点击敌人）
- [ ] `consumable_use_disabled` 已设置（自动触发的设为 true）
- [ ] `consumable_actions` 已配置实际效果
- [ ] 如有效果参数，放入 `consumable_values` 并通过 `custom_key_names` 引用
- [ ] 通过 `Global.register_rod()` 注册
- [ ] 如果是自动触发的物理删除品，需配合拦截器 + RunModifier 实现完整逻辑
- [ ] 如果需要在图鉴中显示，确保贴图存在
