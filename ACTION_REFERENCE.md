# Action Reference

本文档整理当前项目中 `scripts/actions/` 下的 Action，用于制作卡牌、敌人意图、事件、外设、锻造、奖励和 Mod 行为。

本文档以当前工作区源码为准，覆盖 `autoload/Scripts.gd` 中注册的 **101 个 `ACTION_*` 常量**，并额外记录抽象基类、共享辅助类和特殊拦截器。参数默认值、读取方式和组合关系均按实际实现描述；已经完成统一的接口按当前规范记录，不再保留旧拼写或旧参数别名。

## 阅读方式

Action 数据通常写成：

```gdscript
[
	{
		Scripts.ACTION_ATTACK_GENERATOR: {
			"damage": 6,
			"number_of_attacks": 2,
			"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
		}
	}
]
```

`ActionGenerator.create_actions()` 会把这些字典生成 `BaseAction` 实例，`ActionHandler` 负责排队、执行、异步等待和 `time_delay`。

## 参数读取与自动捕获

### “自动捕获”的准确含义

Action 参数不是只从当前 Action 字典读取。调用 `BaseAction.get_action_value(key, default)` 时，系统会先用当前 Action 自己的 `custom_key_names` 将标准键转换为实际键，再按以下优先级取值：

1. 当前 Action 的 `values`
2. `CardPlayRequest.card_values`
3. `CardPlayRequest.card_data.card_values`
4. `Global.player_data.player_values`
5. 调用处给出的默认值

因此，本文件把通过 `get_action_value()` 或 `get_shadowed_action_values()` 读取的参数称为“支持自动捕获”。这意味着卡牌可以只在 `CardData.card_values` 中声明一次 `damage`、`block` 等数值，子 Action 无需重复填写。

### 参数读取标记

后文参数表使用以下标记，精确区分参数是否可自动捕获、是否可被拦截器修改：

| 标记 | 源码读取方式 | 自动捕获 | 拦截器可改写 | 说明 |
|---|---|---:|---:|---|
| `I` | `ActionInterceptorProcessor.get_shadowed_action_values()` | 是 | 是 | 推荐的常规效果参数读取方式。先走自动捕获，再应用当前父级/目标的拦截器链。 |
| `V` | `BaseAction.get_action_value()` | 是 | 否 | 支持层级取值，但当前 Action 不通过 shadow 值接收拦截器改写。 |
| `A` | 直接读取 `values` | 否 | 否 | 只认当前 Action 字典。典型例子是 `custom_key_names` 本身。 |
| `R` | 运行时上下文或对象字段 | 否 | 否 | 来自 `CardPlayRequest`、目标、玩家状态、选牌结果等，不是配置参数。 |
| `C` | 子 Action/调用方传入的上下文 | 视子 Action 而定 | 视子 Action 而定 | 当前 Action 负责生成或转交，不代表包装层会解释内部每个键。 |

`get_shadowed_action_values()` 的拦截器 shadow 层位于上述层级之上。`custom_key_names` 对 shadow 层同样生效，所以拦截器应继续使用标准参数名，由系统完成映射。

### `custom_key_names`

可以用 `custom_key_names` 重映射标准键。例如同一张牌有两段伤害：

```gdscript
{
	Scripts.ACTION_ATTACK_GENERATOR: {
		"custom_key_names": {"damage": "damage_2"},
		"damage_2": 10,
	}
}
```

上例中 Action 读取 `damage` 时会实际读取 `damage_2`。映射方向必须是“Action 标准键 -> 实际数据键”。`custom_key_names` 必须直接写在当前 Action 的 `values` 中，它自己不参与自动捕获。

### 自动捕获的边界

- `custom_key_names`、Action 脚本路径以及嵌套 Action 字典的结构不自动捕获。
- `picked_cards` 虽然通过 Value Hierarchy 读取，但通常来自父 `ActionBasePickCards` 的运行时结果，详见 Cardset 规则。
- `generated_cards`、`unblocked_damage`、`overkill_damage` 等是 Action 写回 `CardPlayRequest.card_values` 的运行时输出；后续 Action 可以像普通卡牌数值一样自动捕获它们。
- 包装型 Action 的 `action_data` 支持自动捕获，但 `action_data` 内部的键仍由对应子 Action 自己读取。
- 没有 `CardPlayRequest` 时会跳过请求级和卡牌级数据；若同时没有 `Global.player_data`，则只能使用 Action 自身值或默认值。
- `ActionVariableCostModifier`、`ActionVariableCombatStatsModifier` 等会直接改写 `CardPlayRequest.card_values`；同一请求中重复嵌套时可能产生累乘或二次加工，不能把它们视为纯函数。

## 所有 Action 通用参数

这些参数来自 `BaseAction` 或拦截器处理器。除非具体 Action 明确绕过相应流程，否则都可使用：

| 参数 | 类型 | 默认值 | 读取 | 准确作用 |
|---|---|---|---|---|
| `time_delay` | `float` | `0.0` | `V` | Action 初始化时缓存。`ActionHandler` 在 Action 完成后等待该秒数，再执行当前队列的下一个 Action。`is_instant_action() == true` 时不等待；直接调用 `perform_action()` 时也不会等待。 |
| `action_tags` | `Array[String]` | `[]` | `V` | Action 初始化时缓存的语义标签，供拦截器或其他逻辑区分同一脚本的不同用途。标签不会自动传播给生成的子 Action。 |
| `custom_key_names` | `Dictionary[String, String]` | `{}` | `A` | 将标准参数名映射到实际键名，例如 `{"damage": "damage_2"}`。只从当前 Action 的 `values` 读取。 |
| `target_override` | `BaseAction.TARGET_OVERRIDES` | `SELECTED_TARGETS` | `V`；部分生成器为 `I` | 在 `_intercept_action()` 默认取目标时重算目标集合。生成器可能把该值转交给子 Action。 |
| `force_dead_targets` | `bool` | `false` | `V` | 为 `false` 时过滤死亡目标；为 `true` 时保留原目标。只影响部分目标分支，不能让所有 Action 都安全处理死亡对象。 |
| `enemy_ids` | `Array[String]` | `[]` | `V` | 仅 `target_override == ENEMY_ID` 使用；按场上 Enemy 的 `enemy_data.object_id` 匹配，可命中多个同 ID 敌人。 |
| `rng_name` | `String` | 由具体 Action 决定 | `V` 或 `I` | 选择 `PlayerData.player_rng_tracks` 中的确定性 RNG 轨道。不同 Action 的默认轨道不同，不能假设统一为 `rng_general`。 |
| `action_short_circuits` | `bool` | `false`；部分 Action 为 `true` | `V` | `ActionHandler` 执行前调用。返回 `true` 且场上已无剩余敌人时跳过该 Action。它不是“无目标即跳过”，现有名称/旧文档容易造成误解。 |
| `ignore_all_interceptors` | `bool` | `false` | `I` | 跳过当前 Action 的全部拦截器。仍会执行 Action 本体。 |
| `ignored_interceptor_ids` | `Array[String]` | `[]` | `I` | 忽略指定 `ActionInterceptorData.object_id`。同时影响父执行者和目标侧拦截器。 |
| `forced_interceptor_ids` | `Array[String]` | `[]` | `I` | 允许指定拦截器绕过“必须已注册在战斗单位上”的条件；仍服从 `ignored_interceptor_ids`、Action 路径白名单和 `ActionInterceptorData.action_interceptor_scope`，同 ID 不会重复加入。 |

### `target_override`

| 枚举值 | 作用 | 额外参数/限制 |
|---|---|---|
| `SELECTED_TARGETS` | 使用传入 Action 的目标。 | 无 |
| `PARENT` | 使用 `parent_combatant`。 | 父执行者为空时得到空目标。 |
| `PLAYER` | 取 `players` 组中的存活节点。 | 当前框架通常只有一个玩家，但实现返回数组。 |
| `ALL_COMBATANTS` | 取存活玩家与存活敌人。 | 顺序为玩家在前、敌人在后。 |
| `ALL_ENEMIES` | 取 `enemies` 组中的存活敌人。 | 不包含死亡敌人。 |
| `LEFTMOST_ENEMY` | 从 `enemies_alive_or_dead` 组中过滤有效目标，再按 `global_position.x` 升序取第一个。 | `force_dead_targets` 为 true 时死亡敌人也参与坐标排序。 |
| `ENEMY_ID` | 取 `enemy_data.object_id` 位于 `enemy_ids` 中的敌人。 | `enemy_ids: Array[String]`；可返回多个。 |
| `RANDOM_ENEMY` | 从存活敌人中确定性随机取一个。 | `rng_name` 默认 `rng_targeting`。 |
| `RANDOM_COMBATANT` | 从存活玩家和敌人中确定性随机取一个。 | `rng_name` 默认 `rng_targeting`。 |

枚举/常量依赖：

- `BaseAction.TARGET_OVERRIDES`：上述所有目标模式。
- Godot 场景组：`players`、`enemies`。

## Cardset Action 通用参数

继承 `BaseCardsetAction` 的 Action 会先取得一组 `CardData`，再对这组牌操作。

| 参数 | 类型 | 默认值 | 读取 | 准确作用 |
|---|---|---|---|---|
| `pick_played_card` | `bool` | `false` | `V` | 为 `true` 时优先使用 `CardPlayRequest.card_data`，并忽略显式 `picked_cards` 与父选牌结果。请求或卡牌为空时记录错误并返回空数组。 |
| `picked_cards` | `Array[CardData]` | `[]` | `V` | 显式指定待操作实例。常与 `custom_key_names: {"picked_cards": "generated_cards"}` 配合，读取前序 Action 写回请求的生成牌。 |

解析优先级固定为：`pick_played_card` -> Value Hierarchy 中存在 `picked_cards` -> `parent_action is ActionBasePickCards` 的运行时 `picked_cards` -> 空数组。这里检查的是“是否存在该键”，所以显式传入空数组也会阻止回退到父选牌结果。

类型/常量依赖：

- `CardData`：操作对象必须是实际卡牌实例，不是 card object id。
- `ActionBasePickCards`：父 Action 结果回退来源。
- `CardPlayRequest.card_data`：`pick_played_card` 的来源。

## Pick Cards 通用参数

`ActionPickCards`、`ActionPickUpgradeCards`、`ActionCreateCards`、`ActionDuplicateCards` 等共享部分选牌逻辑。

| 参数 | 类型 | 默认值 | 读取 | 准确作用 |
|---|---|---|---|---|
| `card_pick_type` | `String` | `HandManager.HAND_PILE` | `V` | 决定输入卡集和 UI。普通值交给 `HandManager.get_pile()`；特殊值见下方依赖表。 |
| `card_pick_text` | `String` | `"请选择 {0} 张卡牌。已选 {1} 张"` | `V` | 选牌 UI 文案。`String.format()` 依次传入最大可选数、已选数、剩余数、过滤后展示上限，对应 `{0}` 至 `{3}`。 |
| `validator_data` | `Array[Dictionary]` | `[]` | `V` | 交给 `CardFilter.filter_card_validators()`；每个元素是 Validator 的数据字典，不是 Validator 实例。 |
| `min_card_amount` | `int` | `0` | `V` | 选择有效所需下限。随机选择时实际抽取该数量，而不是 `max_card_amount`。 |
| `max_card_amount` | `int` | `HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX` | `V` | 手动选择有效上限。UI 单卡是否还能选择还会再与默认手牌上限取较小值。 |
| `min_cards_are_required_for_action` | `bool` | `false` | `V` | 为 `true` 且可选牌少于 `min_card_amount` 时结束 Action，不执行子效果；为 `false` 时会自动选中所有可选牌并继续。 |
| `pickable_cards_max_amount` | `int` | `-1` | `V` | Validator 过滤后只保留前 N 张；`<= 0` 表示不截断。牌序来自相应牌堆当前顺序。 |
| `random_selection` | `bool` | `false` | `V` | 可选牌多于下限时，不打开 UI，而是洗牌后选取前 `min_card_amount` 张。 |
| `quick_pick` | `bool` | `true` | `V` | 已选数量达到 `max_card_amount` 时，UI 是否自动确认。 |
| `can_back_out` | `bool` | `false` | `V` | 仅相应选牌 Overlay 使用；返回会被视为选择 0 张，通常应配合必选下限。 |
| `pick_draft_cards` | `bool` | `false` | `V` | 为 `true` 时直接把 `draft_cards` 当输入集；空数组会记录错误并返回空集。优先级高于从卡池生成。 |
| `draft_cards` | `Array[CardData]` | `[]` | `V` | 已实例化的候选卡，不会在这里克隆。仅 `pick_draft_cards == true` 时读取。 |
| `draft_from_card_pool` | `bool` | `false` | `V` | 为 `true` 时调用 `get_drafted_cards()` 动态生成候选集。 |
| `draft_card_pack_id` | `String` | `""` | `V` | 非空时从指定 `CardPackData` 无权重抽取，优先于 `draft_use_player_draft`。 |
| `draft_use_player_draft` | `bool` | `false` | `V` | 使用玩家当前奖励卡池；此模式下再应用 `validator_data` 可能破坏已生成 draft，源码注释建议保持为空。 |
| `draft_is_weighted` | `bool` | `false` | `V` | 玩家卡池模式下是否按稀有度表抽取。指定 CardPack 时当前不支持加权。 |
| `draft_use_pity_system` | `bool` | `false` | `V` | 仅加权玩家卡池模式生效，是否推进/使用稀有牌保底。 |
| `draft_max_card_amount` | `int` | `3` | `V` | 动态 draft 最大候选数；`<= 0` 传给随机工具时表示不过滤全部候选。 |
| `rng_name` | `String` | 见说明 | `V` | 随机自动选牌默认 `rng_card_picking`；动态 draft 默认 `rng_non_reward_card_drafting`。同一个参数会在两个阶段复用。 |
| `enchant_free` | `bool` | `false` | `V` | 供 `CardEnchantOverlay` 查询，本基类不直接扣费。 |
| `enchant_random_cost` | `int` | `25` | `V` | 随机附魔的基础金币价格，最终价格可由价格拦截器调整。 |
| `enchant_specific_cost` | `int` | `100` | `V` | 指定附魔的基础金币价格，最终价格可由价格拦截器调整。 |
| `is_filter_enabled` | `bool` | `false` | `V` | 控制选牌 UI 的筛选控件，本基类的 Validator 过滤不依赖此开关。 |

枚举/常量依赖：

- `ActionBasePickCards.PICK_DRAFT`：使用 draft 选择界面；候选来源仍由 `pick_draft_cards` 或 `draft_from_card_pool` 决定。
- `ActionBasePickCards.PICK_PARENT_CARD`：自动选择发起 Action 的卡；内部强制随机模式、最少 1 张且不要求失败中止。
- `ActionBasePickCards.PICK_ADJACENT_CARDS`：从 `CardPlayRequest.hand_at_play_time` 取发起卡左右邻牌；发起卡当时不在手牌则返回空集。
- `HandManager.HAND_PILE`、`DRAW_PILE`、`DISCARD_PILE`、`EXHAUST_PILE`、`DECK`：普通输入来源。
- `HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX`：默认最大选择数，目前为 10。
- `Random.CARD_DRAFT_TABLE_TYPES.STANDARD`：加权玩家卡池 draft 固定使用的稀有度表类型，当前没有对应 Action 参数。

## 执行顺序与嵌套规则

`ActionHandler` 名为 stack/queue 混合结构，理解它对制作卡牌很重要：

- `ActionHandler.add_actions(actions)` 默认把数组中每个 Action 作为独立队列压栈，之后从栈尾弹出，所以 **数组会逆序执行**。
- `ActionHandler.add_actions(actions, true)` 将整个数组追加到当前队列，按数组顺序执行。
- `ActionHandler.add_actions(actions, true, true)` 将整个数组插到当前队列前端，仍按数组顺序执行。
- 大多数包装型 Action 调用的是默认 `add_actions(generated_actions)`，因此其 `action_data` 也遵循逆序执行。部分脚本（例如 `ACTION_PLAY_CARDS`、`ACTION_TAKE_FROM_FORGE`）会先手动 `reverse()` 来补偿这一规则。
- 直接调用 `child.perform_action()` 不经过 `ActionHandler`，不会等待异步完成、不会应用 `time_delay`，也不会触发常规队列边界。只有明确要求“同一调用栈内立即生效”的底层逻辑才适合这样做。

例如希望实际顺序是“先攻击、后抽牌”时，在当前默认压栈语义下，数据通常需要把抽牌写在攻击前面：

```gdscript
[
	{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}},
	{Scripts.ACTION_ATTACK_GENERATOR: {"damage": 6}},
]
```

这条顺序规则比较反直觉，也是后续最值得统一的 Action 基础规范之一。

## Action 设计交集审计

### 总体结论

当前 Action 系统确实存在大量交集，但应分成三类看待：

1. **有意的组合层**：生成器、选择器、条件器只负责组织子 Action，属于框架核心能力，不是坏重复。
2. **语义相近但仍有边界**：例如 Attack/DirectDamage、Create/Duplicate、各种卡牌移动 Action；保留独立脚本有利于拦截器按路径精确区分。
3. **可维护性或规范问题**：复制整段实现、字符串伪枚举、参数拼写不一致、直接执行子 Action、占位 Action、部分同类 Action 不走拦截器等。这些会让制卡规则变得难预测。

### 功能重叠与建议边界

| Action 家族 | 交集 | 当前仍有意义的差异 | 审计判断 |
|---|---|---|---|
| `ATTACK_GENERATOR` / `TIME_ATTACK_GENERATOR` | 目标、连击、合并、随机伤害、动画、音效、VFX、击杀子动作几乎全部相同。 | 后者只把基础 `damage` 改成从锁定时间提取。 | **高重复**。建议把“计算基础伤害”提取为可覆写方法，时间版继承普通生成器，避免两份逻辑继续漂移。 |
| `ATTACK` / `DIRECT_DAMAGE` | 都调用 `target.damage()`，都写回三种伤害统计，也都支持 `actions_on_lethal`。 | 脚本路径不同，因此命中的拦截器集合不同；`ATTACK` 额外检查目标存活、支持音效、默认短路。 | **有意语义分层**，但共同的伤害结果记录和击杀处理可抽成共享方法。 |
| `ADD_HEALTH` / `SET_HEALTH` / `HEAL_PERCENT` | 都修改当前/最大生命。 | 分别是增量、绝对赋值、按最大生命比例治疗；拦截器可针对不同脚本。 | **合理拆分**。参数命名可统一成 amount/max/percentage 规范。 |
| `APPLY_STATUS` / `DECAY_STATUS` / `MULTIPLY_STATUS` / `BLOCK_TO_STATUS` | 最终都修改状态层数。 | `DECAY_STATUS` 是专供衰减拦截的独立入口；后两者计算增量后复用 Apply Status。 | **语义有价值**，但后两者直接调用子 Action，队列语义不统一。 |
| `DRAW_GENERATOR` / `DRAW` | 前者只重复生成后者。 | 每张抽牌成为独立可拦截 Action；生成器的 `draw_count` 也可单独拦截。 | **标准生成器模式**，建议保留。 |
| `VARIABLE_*_MODIFIER` 三种 | 都深复制 `action_data`，按某个乘数修改子 Action 值，再生成子 Action。 | 乘数分别来自投入能量、选中卡数、战斗统计。 | Cost 与 Combat Stats 已共享 `BaseVariableActionModifier` 和隔离请求语义；Cardset 版仍保留独立的选牌来源逻辑。 |
| `CREATE_CARDS` / `DUPLICATE_CARDS` / `PICK_DUPLICATE_CARDS` | 都创建新 `CardData` 实例，写出 `generated_cards` 并执行卡组子 Action。 | 来源分别是卡牌 ID、现有实例、玩家选中的实例。 | **合理同族**。命名可更明确为 CreateById / CloneInstance / PickAndClone。 |
| `PICK_UPGRADE_CARDS` / `PICK_CARDS` + `UPGRADE_CARDS` | 都能完成“选牌并升级”。 | 前者是方便包装，后者可自由组合 Validator 和后续动作。 | **有意提供便捷版与组合版**。两者现在都遵守 `upgrade_count`、`bypass_upgrade_max` 和最大升级数检查。 |
| 卡牌移动 Actions | 都把 `_get_picked_cards()` 交给 `HandManager`、`CardMoveOperation` 或永久牌组 API。 | 手牌、抽牌、弃牌、消耗、放逐、Limbo、保留、永久牌组具有不同信号/统计/生命周期语义。 | **保持独立脚本路径并统一拦截协议**。所有具体 Cardset Action 均经过拦截器；移动族可由 shadow 替换 `picked_cards`。 |
| `CHANGE_CARD_VALUES` / `IMPROVE_CARD_VALUES` / `CLAMP_CARD_VALUES` | 都修改 `CardData.card_values`。 | 覆盖、加法、范围钳制。 | **合理操作族**。建议共享 `modify_parent_card` 处理，减少三份 parent 查找逻辑。 |
| `CHANGE_CARD_PROPERTIES` / `IMPROVE_CARD_PROPERTIES` | 都修改 `CardData` 字段而非 `card_values`。 | 覆盖与数值增量。 | **合理拆分**，但任意字符串属性名缺少 schema 校验。 |
| `CHANGE_CARD_ENERGIES` / `RANDOMIZE_CARD_ENERGIES` | 都修改四层能量费用字段。 | 固定赋值与随机赋值。 | **合理拆分**；随机版统一使用 `rng_energy_cost`。 |
| `UPDATE_CARD_DRAFTS` / `UPDATE_CONSUMABLE_DRAFTS` | 重置包、清空包、增删包、白名单、黑名单的流程几乎一致。 | 操作的数据池类型不同。 | **高重复**。可抽为通用内容池更新帮助方法。 |
| `INCREASE_ARTIFACT_CHARGE` / `CHANGE_ARTIFACT_CHARGE` | 都按外设 ID 或实例修改计数器。 | 前者增量且会走增量副作用；后者绝对设置且明确不触发 charge actions。 | **语义合理并均已注册**。按“增量事件”与“绝对赋值”选择，不应互相替代。 |
| `OPEN_CHEST` / `GRANT_REWARDS` | 宝箱 Action 负责生成/选择奖励，再交给 Grant Rewards 展示。 | 前者是来源策略，后者是奖励落地。 | **合理分层**，但当前用直接 `perform_action()` 连接，且消耗品分支未完成。 |
| `GET_SHOP_PRICE` / `GET_ENCHANT_PRICE` / `CARD_PLAY` / `CONSUMABLE` / `DEATH` | Action 本体为空或几乎为空，仅提供可拦截的脚本类型。 | 它们是“语义事件令牌”，由拦截器或外部调用方读取结果。 | **不是冗余**，但文档和命名必须明确“不可单独产生效果”。 |

### 包装与“套娃”关系

下表列出 Action 内部创建或调用其他 Action 的情况。`入栈` 表示仍由 `ActionHandler` 管理；`直调` 表示直接调用 `perform_action()`：

| 外层 Action | 内层 Action/数据 | 方式 | 目的与风险 |
|---|---|---|---|
| `ACTION_ATTACK_GENERATOR` | 多个 `ATTACK` | 入栈 | 每段 `ATTACK` 在同一帧启动攻击动画、命中 VFX、音效和伤害表现。 |
| `ACTION_TIME_ATTACK_GENERATOR` | 多个 `ATTACK` | 入栈 | 复用普通攻击生成器的命中批次构建器。 |
| `ACTION_DRAW_GENERATOR` | 多个 `DRAW` | 入栈 | 让每次抽牌独立可拦截。 |
| `ATTACK` / `DIRECT_DAMAGE` | `actions_on_lethal` | 入栈 | 命中目标死亡后生成任意子动作。 |
| `BLOCK_TO_STATUS` | `APPLY_STATUS` | **直调** | 保证先加状态再清空格挡，但绕过 ActionHandler 的延迟/异步语义。 |
| `MULTIPLY_STATUS` | `APPLY_STATUS` | **直调** | 把倍增转换为增量层数；内层会重新运行 Apply Status 拦截器。 |
| `ADD_ARTIFACTS_FROM_POOL` | `ADD_ARTIFACT` | **经 ActionGenerator 直调** | 每件外设再次经过 Add Artifact 的拦截入口。 |
| `USE_CONSUMABLE` | Consumable 的 `consumable_actions` | 入栈或**逐个直调** | `perform_consumable_actions_instantly` 为 true 时会绕过异步等待和 delay；只适合自动复活等强即时场景。 |
| `PICK_CARDS` 及 Create/Duplicate 变体 | `action_data` | 入栈 | 父级运行时 `picked_cards` 供 Cardset 子 Action 回退读取。 |
| `VALIDATOR` | passed/failed payload | 入栈 | if/else 包装。 |
| `RANDOM_SELECTION` | 某个 weighted payload | 入栈 | 随机分支包装。 |
| `VARIABLE_ACTION_GENERATOR` | 重复的 `action_data` | 入栈 | for-loop 包装。 |
| 三种 `VARIABLE_*_MODIFIER` | 修改后的 `action_data` | 入栈 | 动态数值包装；成本版和统计版还会改写请求级值。 |
| `PICK_OPTIONS` | `OptionData.option_sub_actions` | 入栈 | 每个已选选项生成一组子动作。 |
| `LOW_LEVEL_FORMAT` | 注入计数后的 `action_data` | 入栈 | 跨牌堆筛选、操作并导出数量。 |
| `SCHEDULE_DELAYED_ACTIONS` | `APPLY_STATUS`；状态到期后再生成 `action_data` | 入栈 -> 延后入栈 | 两级嵌套：先创建独立延时状态，再由 `StatusEffectDelayedExecution` 恢复原请求值并执行。 |
| `ADD_TO_FORGE` | `APPLY_STATUS` | 入栈 | 同步锻造负载状态；缺少代码锻炉时则直接调用 PlayerData 添加外设。 |
| `TAKE_FROM_FORGE` | fallback、锻造条目 Actions、`PLAY_SOUND` | 入栈 | 可直接执行锻造内容或生成一张动态融合卡。 |
| `SHOP_PURCHASE_ITEMS` | `ADD_MONEY` + Add Card/Artifact/Consumable | 入栈 | 购买交易拆成资源扣除与物品发放。 |
| `OPEN_CHEST` | `GRANT_REWARDS` | **直调** | 奖励生成后立即写入 UI 奖励组；不经过 Handler delay。 |

### 接口一致性审计与处理结果

以下项目已经按可扩展接口完成统一；语义钩子 Action 则明确保留其无副作用设计：

| 级别 | 位置 | 不一致 | 影响/建议 |
|---|---|---|---|
| 已处理 | `ActionVariableCostModifier` / `ActionVariableCombatStatsModifier` | 通过 `BaseVariableActionModifier` 生成隔离的子请求快照，不再改写原始 `CardPlayRequest`。 | 支持无卡牌请求、嵌套 Action 数据和兄弟 Action 隔离。 |
| 已处理 | 时间攻击、Low Level Format、Delayed Actions、Forge Take | 离散参数改用 `TIME_EXTRACTION_MODES`、`CardMoveOperation.TYPES`、`TAKE_TYPES`。 | 生成器与卡牌必须引用命名枚举，不再接受旧字符串或魔法整数规范。 |
| 已处理 | Cardset Action | `BaseCardsetAction._intercept_cardset_action()` 作为统一入口；所有 Cardset Action 均可被拒绝，移动族和升级 Action 还支持 shadow 改写 `picked_cards`。 | 新 Cardset Action 应沿用该入口。 |
| 已处理 | `ActionAddArtifact` | `artifact_id`、`custom_values` 均从 interceptor shadow 层读取。 | 拦截器可拒绝或改写完整参数。 |
| 已处理 | `ActionDecayStatus` | 专用参数改为 `status_charge_delta`，默认 `-1`。 | 参数明确表示有符号层数变化；负数衰减，正数增加。 |
| 已处理 | 调试输出 | 修正 `ActionPlayAnimation._to_string()`，移除 `ActionPickOptions` 的无条件 `print()`。 | 日志只保留有效信息。 |
| 保留设计 | `ACTION_CONSUMABLE`、`ACTION_CARD_PLAY`、价格查询 Action | 本体无效果，仅靠外部预览/拦截流程。 | 它们是语义钩子，不应期待加入 ActionHandler 后产生可见效果。 |
| 已处理 | `ActionChangeArtifactCharge.gd` | 已注册 `Scripts.ACTION_CHANGE_ARTIFACT_CHARGE`。 | 数据、Mod 和生成器可通过统一常量引用绝对计数设置 Action。 |

### 已统一的参数与内部接口

以下旧写法没有兼容别名。项目内生成器与卡牌均已迁移；外部 Mod/JSON 数据也必须同步更新：

| 旧写法 | 当前写法 | 范围与说明 |
|---|---|---|
| `perform_comsumable_actions_instantly` | `perform_consumable_actions_instantly` | `ACTION_USE_CONSUMABLE`；true 仅用于必须同步结算的非异步子 Action。 |
| `rng_engergy_cost` | `rng_energy_cost` | `ACTION_RANDOMIZE_CARD_ENERGIES` 默认 RNG 轨道。 |
| `target_overrides` | `target_override` | 所有 Action 的单一目标覆盖参数。 |
| `chest_money_amount` | `chest_money` | 固定宝箱金币，仅在 `chest_generates_money = false` 时使用。 |
| `ACTION_DECAY_STATUS.status_charge_amount` | `status_charge_delta` | 有符号状态层数变化量，默认 -1。 |
| 时间模式字符串 | `ActionTimeAttackGenerator.TIME_EXTRACTION_MODES` | GDScript 使用枚举名；JSON 使用文档列出的整数。 |
| 卡牌操作字符串 | `CardMoveOperation.TYPES` | Low Level Format 与 Delayed Actions 共用。 |
| `take_type = -1/0/1` 的魔法值写法 | `ActionTakeFromForge.TAKE_TYPES` | GDScript 必须引用 `ALL/FIRST/LAST`；JSON 使用对应整数。 |
| `is_action_instant()` | `is_instant_action()` | Action 子类的 instant 判定覆写方法；`RESET_ENERGY`、`REST_ACTION_END` 已统一。 |

### 建议的新 Action 规范

- 参数优先使用 `get_shadowed_action_values()`；只有明确不允许拦截器改写时才用 `get_action_value()`。
- 对外可配的离散值必须声明 enum 或命名常量，不再新增裸字符串和魔法整数。
- 生成子 Action 时，默认入栈；只有同步事务且子 Action 保证非异步、无 delay 时才允许直调，并在源码注释原因。
- 包装 Action 不应原地改写共享 `CardPlayRequest.card_values`，除非“写回供后续 Action 捕获”就是公开契约；否则使用副本。
- 同族 Action 应统一 `target_override`、interceptor、short-circuit、RNG 和 `time_delay` 语义。
- 新 Action 参数名遵循 `<domain>_<noun>_<qualifier>`，bool 使用 `is_` / `has_` / `use_` / `allow_` 等清晰前缀；发现拼写错误时统一更新定义、调用方和文档，不保留错误别名。
- 如果 Action 只是语义拦截钩子，应在名称或文档中明确 `HOOK`/`QUERY` 属性，并说明由谁调用、谁读取 shadow 结果。

## Combatant Actions

### `ACTION_ATTACK_GENERATOR`

路径：`res://scripts/actions/combatant_actions/ActionAttackGenerator.gd`

生成一个或多个 `ACTION_ATTACK`，自身不直接造成伤害。卡牌攻击通常优先用它。

| 参数 | 默认值 | 作用 |
|---|---:|---|
| `damage` | `0` | 每段基础伤害。 |
| `additional_damage` | `0` | 额外伤害，和 `damage` 相加。 |
| `number_of_attacks` | `1` | 攻击段数。 |
| `merge_attacks` | `false` | 是否合并为一段总伤害。 |
| `damage_random` | `0` | 若 >1，额外随机 `0..damage_random` 伤害。 |
| `rng_damage_name` | `rng_damage` | 随机伤害 RNG。 |
| `target_override` | `SELECTED_TARGETS` | 传给生成的攻击 Action。 |
| `time_delay` | `0.25` | 每段攻击延迟。 |
| `attack_animation_name` | `AnimationData.ANIMATION_ATTACK` | 父 combatant 播放的一次性动画。 |
| `per_attack_animation_name` | `AnimationData.ANIMATION_NONE` | 每段攻击前播放的动画。 |
| `impact_vfx_animation_id` | `""` | 每段命中目标时创建的 VFX。 |
| `audio_path` | `[]` | 每段攻击音效组。 |
| `actions_on_lethal` | `[]` | 击杀目标后追加执行的 Action。 |

`attack_animation_name`、`impact_vfx_animation_id` 和 `audio_path` 都传给同一个 `ACTION_ATTACK`。每段命中会同时启动攻击者动画、目标 VFX、音效、伤害结算和 `time_delay` 计时，并等待延迟与阻塞表现中最后一个结束。

### `ACTION_TIME_ATTACK_GENERATOR`

路径：`res://scripts/actions/combatant_actions/ActionTimeAttackGenerator.gd`

时间系攻击生成器。根据 `CardPlayRequest.card_values["locked_run_time"]` 提取时间数值，计算 `提取值 × time_multiplier + additional_damage`，再按普通攻击生成器的连击、合并、目标、动画、VFX、音效和击杀参数生成 `ACTION_ATTACK`。音效只交给每段子攻击播放一次，不再额外生成重复的声音 Action。

| 参数 | 默认值 | 作用 |
|---|---:|---|
| `time_extraction_mode` | `ActionTimeAttackGenerator.TIME_EXTRACTION_MODES.ONES_DIGIT` | 支持 `ONES_DIGIT`（整数秒个位）、`TOTAL_SECONDS`（整数总秒数）、`TOTAL_MINUTES`（整分钟）。类型为 `int` 枚举值。 |
| `time_multiplier` | `1` | 时间提取值倍率。 |
| 其余攻击参数 | 同 `ACTION_ATTACK_GENERATOR` | 包括段数、目标、动画、音效、击杀动作等。 |

注意：卡牌若依赖稳定时间快照，应设置 `CardData.card_requires_time_snapshot = true`。

枚举：`ActionTimeAttackGenerator.TIME_EXTRACTION_MODES` = `ONES_DIGIT: 0`、`TOTAL_SECONDS: 1`、`TOTAL_MINUTES: 2`。GDScript 生成器应引用枚举名；JSON/Mod 数据只能写对应整数。

### `ACTION_ATTACK`

路径：`res://scripts/actions/combatant_actions/ActionAttack.gd`

实际造成攻击伤害。一般由 `ACTION_ATTACK_GENERATOR` 生成；攻击动画、目标 VFX、音效和伤害表现属于同一个并发表现批次。

| 参数 | 默认值 | 作用 |
|---|---:|---|
| `damage` | `0` | 伤害。 |
| `bypass_block` | `false` | 是否绕过格挡。 |
| `audio_path` | `[]` | 攻击音效。 |
| `attack_animation_name` | `AnimationData.ANIMATION_NONE` | 本段开始时播放的攻击者动画。 |
| `impact_vfx_animation_id` | `""` | 本段开始时在目标上播放的命中特效。 |
| `actions_on_lethal` | `[]` | 击杀后执行。 |
| `action_short_circuits` | `true` | 无有效目标时短路。 |

输出到 `CardPlayRequest.card_values`：`unblocked_damage`、`unblocked_damage_capped`、`overkill_damage`，会在同一次卡牌请求内累加。

### `ACTION_DIRECT_DAMAGE`

路径：`res://scripts/actions/combatant_actions/ActionDirectDamage.gd`

直接伤害，受更少攻击相关拦截器影响。

参数：`damage`、`bypass_block`、`actions_on_lethal`。同样输出 `unblocked_damage`、`unblocked_damage_capped`、`overkill_damage`。

### `ACTION_BLOCK`

路径：`res://scripts/actions/combatant_actions/ActionBlock.gd`

给目标增加格挡。

参数：`block` 默认 0，`additional_block` 默认 0，`audio_path` 默认 `[]`。

### `ACTION_BLOCK_BY_STATUS`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionBlockByStatus.gd`

根据玩家某个状态层数获得格挡。

参数：`status_effect_object_id`、`block_multiplier` 默认 1、`include_pending_status_charges` 默认 false、`status_charge_amount` 默认 0。若 `include_pending_status_charges` 为 true，会把当前 Action 待添加层数也算入。

### `ACTION_ADD_HEALTH`

路径：`res://scripts/actions/combatant_actions/ActionAddHealth.gd`

增加当前生命和/或最大生命。

参数：`health_amount` 默认 0，`health_max_amount` 默认 0，`health_max_percent` 默认 0.0。

### `ACTION_SET_HEALTH`

路径：`res://scripts/actions/combatant_actions/ActionSetHealth.gd`

设置当前生命和最大生命。

参数：`health_amount` 默认目标当前生命，`health_max_amount` 默认目标当前最大生命。

### `ACTION_HEAL_PERCENT`

路径：`res://scripts/actions/combatant_actions/ActionHealPercent.gd`

按最大生命百分比治疗目标。

参数：`percentage_heal_amount` 默认 1.0。

### `ACTION_RESET_BLOCK`

路径：`res://scripts/actions/combatant_actions/ActionResetBlock.gd`

清空目标格挡。无专用参数。

### `ACTION_DEATH`

路径：`res://scripts/actions/combatant_actions/ActionDeath.gd`

死亡前的可拦截哑 Action，不直接杀死目标。主要给拦截器阻止死亡或触发死亡相关逻辑。无专用参数。

### `ACTION_PLAY_ANIMATION`

路径：`res://scripts/actions/combatant_actions/ActionPlayAnimation.gd`

让每个有效目标立即调用 `play_animation(animation_name)`。Action 本身为 instant；调试字符串会输出实际动画名，不再误报为 Block Action。

参数：`animation_name` 默认 `AnimationData.ANIMATION_IDLE`。

### `ACTION_CREATE_EFFECT_ANIMATION`

路径：`res://scripts/actions/combatant_actions/ActionCreateEffectAnimation.gd`

在目标上创建命中特效动画。

参数：`impact_vfx_animation_id` 默认 `""`。

### `ACTION_TALK`

路径：`res://scripts/actions/combatant_actions/ActionTalk.gd`

让目标排队显示气泡文本。

参数：`message_bbcode` 默认内置文本。

## Status Actions

### `ACTION_APPLY_STATUS`

路径：`res://scripts/actions/combatant_actions/status_actions/ActionApplyStatus.gd`

给目标添加状态层数，或强制新建状态实例。

| 参数 | 默认值 | 作用 |
|---|---:|---|
| `status_effect_object_id` | `""` | 状态 ID。 |
| `status_charge_amount` | `1` | 主层数。 |
| `status_secondary_charge_amount` | `0` | 副层数。 |
| `status_force_apply_new_effect` | `false` | 是否强制创建新的状态实例。 |
| `status_custom_values` | `{}` | 新状态实例自定义值。仅强制新建时传入。 |
| `action_short_circuits` | `true` | 无目标时短路。 |

### `ACTION_DECAY_STATUS`

路径：`res://scripts/actions/combatant_actions/status_actions/ActionDecayStatus.gd`

即时、可拦截的状态层数变化入口，主要由 `BaseCombatant._decay_status_effect()` 通过 `ActionGenerator.generate_decay_status_effect()` 直接调用。它保留独立脚本路径，使“阻止或修改自然衰减”的拦截器不会误伤普通 `ACTION_APPLY_STATUS`。

参数：`status_effect_object_id`、`status_charge_delta` 默认 -1、`action_short_circuits` 默认 true。`status_charge_delta` 是传给 `add_status_effect_charges()` 的有符号变化量：负数减少，正数增加；旧参数名 `status_charge_amount` 不再读取。

### `ACTION_MULTIPLY_STATUS`

路径：`res://scripts/actions/combatant_actions/status_actions/ActionMultiplyStatus.gd`

把目标已有状态层数乘以指定倍率。

参数：`status_effect_object_id`、`status_effect_multiplier_amount` 默认 1、`action_short_circuits` 默认 true。

### `ACTION_BLOCK_TO_STATUS`

路径：`res://scripts/actions/combatant_actions/status_actions/ActionBlockToStatus.gd`

将目标当前格挡转为指定状态层数，然后清空格挡。

参数：`status_effect_object_id`。

## Player Actions

### `ACTION_ADD_ENERGY`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionAddEnergy.gd`

增加玩家当前能量和/或最大能量。

参数：`energy_amount` 默认 0，`energy_amount_max` 默认 0。

### `ACTION_RESET_ENERGY`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionResetEnergy.gd`

即时、可拦截地把玩家当前能量设为 0，并发出 `Signals.energy_changed`。通常在回合开始与 `ACTION_ADD_ENERGY` 组合使用。无专用参数。

### `ACTION_ADD_MONEY`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionAddMoney.gd`

增加金币/数据币。

参数：`money_amount` 默认 0，`money_percent` 默认 0.0。百分比按当前金币计算。

### `ACTION_DRAW_GENERATOR`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionDrawGenerator.gd`

生成多次 `ACTION_DRAW`。

参数：`draw_count` 默认 1。

### `ACTION_DRAW`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionDraw.gd`

抽一张牌进手牌。

参数：`hand_card_count_max` 默认 `HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX`。

### `ACTION_RESHUFFLE`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionReshuffle.gd`

洗牌。

参数：`shuffle_discard_into_draw` 默认 true，表示将弃牌堆洗入抽牌堆。

### `ACTION_END_TURN`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionEndTurn.gd`

请求结束玩家回合。

参数：`end_turn_immediacy_level` 默认 `CombatEndTurn.END_TURN_QUEUE_IMMEDIACY.WAIT_FOR_ALL_CARD_PLAYS`。

### `ACTION_ADD_ARTIFACT`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionAddArtifact.gd`

根据 `artifact_id` 从全局外设原型表取得数据，并调用 `PlayerData.add_artifact()` 添加实例。`artifact_id` 与 `custom_values` 都从 interceptor shadow 层读取，因此拦截器既可拒绝发放，也可替换外设 ID 或初始化值；ID 无效时记录错误并终止。

参数：`artifact_id`，`custom_values` 默认 `{}`。

### `ACTION_ADD_ARTIFACTS_FROM_POOL`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionAddArtifactsFromPool.gd`

从玩家外设池抽取并添加外设。

参数：`artifact_count` 默认 1，`artifact_rarities` 默认 `[]`，`use_rarity_ordering` 默认 true，`from_back` 默认 false。`artifact_id` 仅用于字符串展示。

### `ACTION_SWAP_BOSS_ARTIFACT`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionSwapBossArtifact.gd`

移除角色初始外设，换取一个 Boss 外设。无专用参数。

### `ACTION_ADD_CONSUMABLE`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionAddConsumable.gd`

添加消耗品。

参数：`consumable_object_id`、`fill_all_slots` 默认 false、`random_consumable` 默认 false、`consumable_whitelist_ids`、`consumable_blacklist_ids`、`slot_count` 默认 1、`rng_name` 默认 `rng_consumables`。

### `ACTION_USE_CONSUMABLE`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionUseConsumable.gd`

使用指定槽位的消耗品：先验证槽位并从玩家槽位映射中移除，再用消耗品 `consumable_values` 创建独立的无卡牌 `CardPlayRequest`，最后生成其 `consumable_actions`。默认子 Action 入栈；即时模式会逐个直接调用 `perform_action()`，不会等待异步 Action，也不会遵守 Handler delay。

参数：`consumable_slot_index` 默认 0，`perform_consumable_actions_instantly` 默认 false。

### `ACTION_CONSUMABLE`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionConsumable.gd`

消耗品预览/使用前的特殊可拦截哑 Action。无 `perform_action()`，主要给拦截器动态启用、禁用或修改消耗品效果。

### `ACTION_UPDATE_CARD_DRAFTS`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionUpdateCardDrafts.gd`

修改玩家后续卡牌奖励池。执行顺序为：恢复初始包、可选清空、添加包、移除包、更新白名单、更新黑名单、重建过滤缓存。白名单与黑名单互斥：加入一侧会从另一侧删除同一 ID。

参数：`reset_to_starting_card_packs`、`remove_all_card_packs`、`add_card_pack_object_ids`、`remove_card_pack_object_ids`、`whitelist_card_object_ids`、`blacklist_card_object_ids`。

### `ACTION_UPDATE_CONSUMABLE_DRAFTS`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionUpdateConsumableDrafts.gd`

修改玩家后续消耗品奖励池。流程与卡牌奖励池一致，最终调用 `regenerate_consumable_available_id_cache()`。白名单与黑名单互斥：加入一侧会从另一侧删除同一消耗品 ID。

参数：`reset_to_starting_consumable_packs`、`remove_all_consumable_packs`、`add_consumable_pack_object_ids`、`remove_consumable_pack_object_ids`、`whitelist_consumable_object_ids`、`blacklist_consumable_object_ids`。

### `ACTION_UPDATE_REST_ACTIONS`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionUpdateRestActions.gd`

启用或禁用维护点/营火动作。

参数：`add_rest_action_object_ids`、`remove_rest_action_object_ids`。

### `ACTION_UPDATE_PLAYER_VALUE`

路径：`res://scripts/actions/combatant_actions/player_actions/ActionUpdatePlayerValue.gd`

写入 `Global.player_data.player_values`。

参数：`player_value_name`，`new_player_value`。

## Enemy Actions

### `ACTION_CYCLE_ENEMY_INTENT`

路径：`res://scripts/actions/combatant_actions/enemy_actions/ActionCycleEnemyIntent.gd`

让目标敌人切换到下一个意图。

参数：`action_short_circuits` 默认 true。

### `ACTION_CHANGE_ENEMY_INTENT_STATE`

路径：`res://scripts/actions/combatant_actions/enemy_actions/ActionChangeEnemyIntentState.gd`

强制目标敌人切换到指定意图状态。

参数：`new_intent_id`、`action_short_circuits` 默认 true。

### `ACTION_SUMMON_ENEMIES`

路径：`res://scripts/actions/combatant_actions/enemy_actions/ActionSummonEnemies.gd`

在指定敌人槽位召唤随机敌人。

参数：`number_of_spawns` 默认 1，`spawn_slots`，`is_minion` 默认 false，`random_enemy_object_ids`，`rng_name` 默认 `rng_enemy_spawning`。

## Card Play Actions

### `ACTION_CARD_PLAY`

路径：`res://scripts/actions/card_actions/card_play_actions/ActionCardPlay.gd`

卡牌打出前的特殊可拦截哑 Action。用于修改费用、复制、阻止、预览等。通常由 `HandManager` / `ActionGenerator.generate_card_play()` 生成，不手写到卡牌效果里。

### `ACTION_CARD_PLAY_END`

路径：`res://scripts/actions/card_actions/card_play_actions/ActionCardPlayEnd.gd`

一次卡牌打出结束时发出 `Signals.card_played`。通常由系统生成。

### `ACTION_CHANGE_CARD_PLAY_DESTINATION`

路径：`res://scripts/actions/card_actions/card_play_actions/ActionChangeCardPlayDestination.gd`

只修改当前 `CardPlayRequest` 的结算去向，不永久修改卡牌。

参数：`card_destination` 默认当前请求的目标牌堆，`card_destination_strategy` 默认当前插入策略。

## Pick Card Actions

### `ACTION_PICK_CARDS`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionPickCards.gd`

通用选牌 Action。选中牌后执行 `action_data` 子 Action，子 Action 可从父 Action 自动取得 `picked_cards`。

专用参数：`action_data`。另支持所有 Pick Cards 通用参数。

### `ACTION_PICK_UPGRADE_CARDS`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionPickUpgradeCards.gd`

选牌并升级的便捷异步包装器。可直接选择永久牌组中的卡，也可选择战斗实例并用 `upgrade_parent_card` 同步永久 parent。可选性检查使用实际目标卡的 `card_upgrade_amount_max`，并把 `upgrade_count` 与 `bypass_upgrade_max` 同时用于检查和最终升级。

参数：`upgrade_parent_card` 默认 false，`upgrade_count` 默认 1，`bypass_upgrade_max` 默认 false，`max_card_amount` 参与可选判断。另支持 Pick Cards 通用参数。

### `ACTION_PICK_DUPLICATE_CARDS`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionPickDuplicateCards.gd`

选牌后复制这些牌，将复制结果写入 `CardPlayRequest.card_values["generated_cards"]`，再执行子 Action。子 Action 通常用 `custom_key_names: {"picked_cards": "generated_cards"}` 或直接读取 `generated_cards`。

支持 Pick Cards 通用参数和 `action_data`。

### `ACTION_CREATE_CARDS`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionCreateCards.gd`

按 prototype ID 生成新卡牌，并作为 `picked_cards` 交给子 cardset Action。

参数：`created_card_object_id`、`number_of_cards` 默认 1。输出：`generated_cards`。

### `ACTION_DUPLICATE_CARDS`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionDuplicateCards.gd`

复制传入的已实例化 `CardData`。

参数：`created_card_data`、`number_of_cards` 默认 1。输出：`generated_cards`。

### `ACTION_DEBUG_PICK_ANY_CARD`

路径：`res://scripts/actions/card_actions/pick_card_actions/ActionDebugPickAnyCard.gd`

调试用，从所有卡牌中选牌并克隆。无专用参数。

## Cardset Actions

### `ACTION_ADD_CARDS_TO_HAND`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionAddCardsToHand.gd`

将选中的牌加入手牌。

参数：`hand_card_count_max` 默认手牌上限。另支持 Cardset 通用参数。

### `ACTION_ADD_CARDS_TO_DRAW`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionAddCardsToDraw.gd`

将选中的牌加入抽牌堆。

参数：`card_destination_strategy` 默认 `TOP`。

### `ACTION_ADD_CARDS_TO_DECK`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionAddCardsToDeck.gd`

将选中的牌加入永久牌组。无专用参数。

### `ACTION_REMOVE_CARDS_FROM_DECK`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionRemoveCardsFromDeck.gd`

从永久牌组移除选中的牌。无专用参数。

### `ACTION_DISCARD_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionDiscardCards.gd`

丢弃选中的牌。

参数：`is_manual_discard` 默认 **true**。true 会触发主动弃牌统计/副作用；false 只做自然移动。

### `ACTION_EXHAUST_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionExhaustCards.gd`

将选中的牌移入消耗/销毁牌堆。无专用参数。

### `ACTION_BANISH_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionBanishCards.gd`

从本场战斗中彻底移除选中的牌。无专用参数。

### `ACTION_MOVE_CARDS_TO_LIMBO`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionMoveCardsToLimbo.gd`

将选中的牌移入 limbo 临时区。无专用参数。

### `ACTION_RETAIN_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionRetainCards.gd`

保留选中的牌。无专用参数。

### `ACTION_SWAP_HAND_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionSwapHandCards.gd`

交换手牌中的选中牌。无专用参数。

### `ACTION_PLAY_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionPlayCards.gd`

让选中的牌被自动打出。

参数：`rng_name` 用于随机目标等内部行为。

### `ACTION_ATTACH_CARDS_ONTO_ENEMY`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionAttachCardsOntoEnemy.gd`

将选中的牌放逐，并作为 `status_effect_attached_card` 附加到目标敌人。通常应只针对单个敌人。

无专用参数。

### `ACTION_CHANGE_CARD_VALUES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionChangeCardValues.gd`

覆盖/更新选中牌的 `card_values`。

参数：`new_card_values`，`modify_parent_card` 默认 true。

### `ACTION_IMPROVE_CARD_VALUES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionImproveCardValues.gd`

对选中牌的 `card_values` 做加法增量。

参数：`card_value_improvements`，`modify_parent_card` 默认 true。

### `ACTION_IMPROVE_CARD_VALUES_UNUSED_ENERGY`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionImproveCardValuesUnusedEnergy.gd`

按未使用能量增益 `card_values`。

参数：`card_value_improvements`，`modify_parent_card` 默认 true。

### `ACTION_CLAMP_CARD_VALUES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionClampCardValues.gd`

限制选中牌 `card_values` 的范围。

参数：`clamped_card_values`，`modify_parent_card` 默认 true。`clamped_card_values` 形如 `{value_key: [min, max]}`。

### `ACTION_CHANGE_CARD_PROPERTIES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionChangeCardProperties.gd`

覆盖选中牌的 `CardData` 属性，不是 `card_values`。

参数：`card_properties`，`modify_parent_card` 默认 true。

### `ACTION_IMPROVE_CARD_PROPERTIES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionImproveCardProperties.gd`

对选中牌的数值型 `CardData` 属性做加法增量。

参数：`card_property_improvements`，`card_property_min_values` 默认 `{}`，`modify_parent_card` 默认 true。

### `ACTION_CHANGE_CARD_ENERGIES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionChangeCardEnergies.gd`

修改选中牌的费用字段。

参数：`card_energy_cost`、`card_energy_cost_until_combat`、`card_energy_cost_until_played`、`card_energy_cost_until_turn`，默认均为 -1，-1 表示不改。

### `ACTION_RANDOMIZE_CARD_ENERGIES`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionRandomizeCardEnergies.gd`

使用玩家确定性 RNG 轨道随机修改选中牌的四层费用字段。每张牌、每个开启的费用层都会独立从闭区间 `[card_cost_min, card_cost_max]` 抽取一次；统一的默认轨道名为 `rng_energy_cost`。

参数：`card_cost_min`、`card_cost_max`、`randomize_card_energy_cost`、`randomize_card_energy_cost_until_combat`、`randomize_card_energy_cost_until_played`、`randomize_card_energy_cost_until_turn`、`rng_name`。

### `ACTION_UPGRADE_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionUpgradeCards.gd`

升级选中牌，并可同步永久 parent 与同一 parent 的其他战斗副本。Action 通过统一 Cardset 拦截入口执行，拦截器可以拒绝操作，也可以 shadow 改写 `picked_cards`、升级次数和上限策略。

参数：`upgrade_count` 默认 1，`upgrade_parent_card` 默认 **true**，`bypass_upgrade_max` 默认 false。

### `ACTION_TRANSFORM_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionTransformCards.gd`

将选中牌转化成其他卡牌。

| 参数 | 默认值 | 作用 |
|---|---:|---|
| `transform_into_card_object_id` | `""` | 指定转化目标；为空则随机。 |
| `transform_parent_card` | `true` | 是否转化永久父卡。 |
| `keep_upgrade_level` | `false` | 是否继承升级层数。 |
| `force_upgrade_level` | `-1` | 强制升级层数，-1 不强制。 |
| `keep_rarity` | `false` | 随机时保持稀有度。 |
| `keep_color` | `true` | 随机时保持颜色。 |
| `keep_type` | `false` | 随机时保持类型。 |
| `transform_rarities` | 所有稀有度 | 随机候选稀有度。 |
| `transform_colors` | 所有颜色 | 随机候选颜色。 |
| `transform_types` | 标准类型 | 随机候选类型。 |
| `rng_name` | `rng_card_transforming` | RNG 轨道。 |

### `ACTION_DECORATE_CARDS`

路径：`res://scripts/actions/card_actions/cardset_actions/ActionDecorateCards.gd`

给选中牌添加 `CardDecorator`。指定 `card_decorator_object_id` 时使用 `card_decorator_values`；未指定 ID 时会用确定性 RNG 打乱 `random_card_decorators`，选择第一个可应用的装饰器，并使用该候选自身对应的 values。`decorate_parent_card = true` 时同步永久 parent。

参数：`decorate_parent_card` 默认 true，`card_decorator_object_id`，`card_decorator_values`，`random_card_decorators`，`rng_name` 默认 `rng_card_decoration`。

### `ACTION_LOW_LEVEL_FORMAT`

路径：`res://scripts/actions/card_actions/ActionLowLevelFormat.gd`

按 `source_zones` 顺序扫描多个战斗牌区，以类型、颜色 ID、卡牌 ID 三组条件做 AND 过滤并按实例去重。随后通过 `CardMoveOperation.TYPES` 统一处理全部命中牌，把命中数量注入每个一级子 Action 的 `variable_name_to_export` 参数，再生成 `action_data`。

参数：`source_zones` 默认手牌/抽牌/弃牌，`filter_card_types`，`filter_card_colors`，`filter_card_ids`，`operation` 默认 `CardMoveOperation.TYPES.EXHAUST`，`variable_name_to_export` 默认 `format_count`，`action_data` 默认 `[]`。

颜色过滤使用 `CardData.card_color_id`，因此 `filter_card_colors` 的元素应为 `"color_blue"` 这类 ColorData object id。

## Meta Actions

### `ACTION_VALIDATOR`

路径：`res://scripts/actions/meta_actions/ActionValidator.gd`

运行验证器，根据结果执行不同子 Action。

参数：`validator_data`，`passed_action_data`，`failed_action_data`。

### `ACTION_RANDOM_SELECTION`

路径：`res://scripts/actions/meta_actions/ActionRandomSelection.gd`

先执行 `validator_data`，全部通过后才从 `weights` 中进行一次确定性加权选择，并从 `weighted_action_data` 取得同名分支生成子 Action。验证失败时不消耗该 RNG 轨道；缺失分支按空 Action 数组处理。没有 `CardPlayRequest` 时 Validator 收到 null `CardData`。

参数：`weights`，`weighted_action_data`，`rng_name` 默认 `rng_general`，`validator_data`。

### `ACTION_VARIABLE_ACTION_GENERATOR`

路径：`res://scripts/actions/meta_actions/ActionVariableActionGenerator.gd`

将同一组子 Action 生成多次。

参数：`action_data`，`action_count` 默认 1。

### `ACTION_VARIABLE_COST_MODIFIER`

路径：`res://scripts/actions/meta_actions/ActionVariableCostModifier.gd`

根据 X 费输入能量改写隔离的子请求及子 Action 数据中的指定键，不修改原始 `CardPlayRequest`。它会深复制 `action_data`，递归修改嵌套 payload 中显式声明的同名参数，并把计算结果写入子请求 `card_values`，因此所有生成的后代 Action 都能通过值层级捕获结果，而外层兄弟 Action 保持原值。

参数：`action_data`，`multiplied_values`，`multiplied_values_bases`，`multiplier_offset` 默认 0。

计算：`base + value * (input_energy + multiplier_offset)`。

### `ACTION_VARIABLE_CARDSET_MODIFIER`

路径：`res://scripts/actions/meta_actions/ActionVariableCardsetModifier.gd`

类似 `ACTION_VARIABLE_COST_MODIFIER`，但作为 Cardset 包装器使用。

参数：`action_data`，`multiplied_values`，`multiplied_values_bases`，`multiplier_offset`。

### `ACTION_VARIABLE_COMBAT_STATS_MODIFIER`

路径：`res://scripts/actions/meta_actions/ActionVariableCombatStatsModifier.gd`

根据战斗统计、实时战斗状态或锻造区内容计算乘数，再复用 `BaseVariableActionModifier` 生成隔离的子请求和递归修改后的 payload。生成的子 Action 共享同一份快照，可在内部继续交换运行时值，但不会污染包装器外部的兄弟 Action。

参数：`action_data`，`multiplied_values`，`multiplied_values_bases`，`combat_stat_name`，`stat_variable_name`，`stat_enum`，`turn_stat_type`，`stat_divisor`，`action_types`。

支持的 `combat_stat_name` 包括：`cards_in_hand`、`attack_cards_in_hand`、`skill_cards_played_this_turn`、`target_status_effect_charges`、`player_status_effect_charges`、`block_amount`、`actions_in_forge`。

## Artifact Actions

### `ACTION_INCREASE_ARTIFACT_CHARGE`

路径：`res://scripts/actions/artifact_actions/ActionIncreaseArtifactCharge.gd`

增加外设计数。

参数：`artifact_id`、`artifact_charge_increase` 默认 1、`artifact_data` 可直接指定外设实例。

### `ACTION_CHANGE_ARTIFACT_ENABLED`

路径：`res://scripts/actions/artifact_actions/ActionChangeArtifactEnabled.gd`

按 `artifact_id` 修改全部同 ID 外设，或通过 `artifact_data` 修改指定实例。`artifact_disabled` 是严格 bool：true 禁用，false 启用；ID 与实例同时提供时会依次设置。

参数：`artifact_id`、`artifact_disabled` 默认 true、`artifact_data` 可直接指定外设实例。

### `ACTION_CHANGE_ARTIFACT_CHARGE`

路径：`res://scripts/actions/artifact_actions/ActionChangeArtifactCharge.gd`

绝对设置外设计数。可按 `artifact_id` 修改玩家持有的全部同 ID 实例，也可通过 `artifact_data` 精确指定一个实例；两者同时提供时会依次设置。它调用 `set_artifact_counter()`，不会触发 `ACTION_INCREASE_ARTIFACT_CHARGE` 所代表的增量副作用。

参数：`artifact_id`、`artifact_charges` 默认 1、`artifact_data`。

## Reward Actions

### `ACTION_GRANT_REWARDS`

路径：`res://scripts/actions/rewards/ActionGrantRewards.gd`

向奖励池添加奖励。

参数：`reward_group` 默认 0，`money_amount` 默认 0，`card_drafts`，`artifact_ids`，`custom_action_data`。

### `ACTION_CLEAR_REWARDS`

路径：`res://scripts/actions/rewards/ActionClearRewards.gd`

清理奖励。

参数：`reward_group` 默认 -1，-1 表示全部奖励组。

## Shop Actions

### `ACTION_SHOP_POPULATE_ITEMS`

路径：`res://scripts/actions/shop_actions/ActionShopPopulateItems.gd`

填充商店商品和价格。

参数：`shop_cards`，`shop_card_prices`，`shop_artifact_ids`，`shop_artifact_prices`，`shop_consumable_ids`，`shop_consumable_prices`。

### `ACTION_SHOP_PURCHASE_ITEMS`

路径：`res://scripts/actions/shop_actions/ActionShopPurchaseItems.gd`

购买商店物品。

参数：`card_data`、`artifact_id`、`consumable_object_id`、`consumable_slot_index`。

### `ACTION_GET_SHOP_PRICE`

路径：`res://scripts/actions/shop_actions/ActionGetShopPrice.gd`

商店价格预览/计算用哑 Action，只用于触发价格拦截器。无专用参数。

### `ACTION_GET_ENCHANT_PRICE`

路径：`res://scripts/actions/shop_actions/ActionGetEnchantPrice.gd`

附魔价格预览/计算用哑 Action，只用于触发价格拦截器。无专用参数。

## World Actions

### `ACTION_GENERATE_ACT`

路径：`res://scripts/actions/world_generation_actions/ActionGenerateActSpire.gd`

生成一章地图。

参数：`act_id`，`act_number` 默认当前 act，`rng_name` 默认 `rng_world_generation`，`location_obfuscation_rate` 默认 0.25，`location_non_combat_event_rate` 默认 0.2。

主要生成逻辑来自 `ActData.act_map_floor_templates` 和 `ActData.act_map_connection_density`。

### `ACTION_VISIT_LOCATION`

路径：`res://scripts/actions/world_interaction_actions/ActionVisitLocation.gd`

访问指定地图节点。

参数：`location_id`，`autosave_before_visit` 默认 true。

### `ACTION_START_COMBAT`

路径：`res://scripts/actions/world_interaction_actions/ActionStartCombat.gd`

开始战斗。

参数：`event_object_id` 默认 `""`。为空时由当前位置事件决定。

### `ACTION_OPEN_CHEST`

路径：`res://scripts/actions/world_interaction_actions/ActionOpenChest.gd`

生成宝箱奖励，并内部调用 `ACTION_GRANT_REWARDS`。

运行时参数：`chest_has_money`、`chest_has_cards`、`chest_has_artifacts`、`chest_has_consumables`，`chest_generates_money`、`chest_generates_cards`、`chest_generates_artifacts`，`chest_money`，`chest_cards`，`artifact_ids`，`chest_artifact_count`，`custom_action_data`。

注意：消耗品奖励整段逻辑目前被注释；`chest_generates_consumables`、`chest_consumable_count`、`consumable_ids` 不能视为已支持参数。

### `ACTION_REST_ACTION_END`

路径：`res://scripts/actions/world_interaction_actions/ActionRestActionEnd.gd`

结束/确认一次维护点动作。Action 为 instant；`rest_action_id` 非空时发出 `Signals.rest_action_ended`，为空时记录错误并停止，不会发出无 ID 的结束信号。该 Action 通常由 `RestActionData.rest_action_auto_end` 自动追加。

参数：`rest_action_id`。

## Audio Actions

### `ACTION_PLAY_MUSIC`

路径：`res://scripts/actions/audio_actions/ActionPlayMusic.gd`

播放或停止音乐。

参数：`audio_path`，`audio_path_is_absolute` 默认 false，`audio_loops` 默认 true，`audio_crossfade_duration` 默认 1.0。`audio_path` 为空或 `FileLoader.NO_MUSIC` 时停止音乐。

### `ACTION_PLAY_SOUND`

路径：`res://scripts/actions/audio_actions/ActionPlaySound.gd`

播放 UI/效果音。

参数：`audio_path` 默认 `[]`，会从数组中随机取一个；`audio_path_is_absolute` 默认 false。

## Custom / Modding Actions

### `ACTION_CUSTOM_UI`

路径：`res://scripts/actions/custom_actions/ActionCustomUI.gd`

按目标逐个注册或注销自定义 UI。`custom_ui_object_id` 默认空字符串且必须显式提供；空值记录错误并跳过当前处理器，目标为空时不执行。两个参数都允许拦截器 shadow 改写。

参数：`custom_ui_object_id` 默认 `""`，`enable_custom_ui` 默认 true。

### `ACTION_EMIT_CUSTOM_SIGNAL`

路径：`res://scripts/actions/custom_actions/ActionEmitCustomSignal.gd`

发出数据驱动自定义信号。

参数：`custom_signal_object_id`，`custom_signal_value` 默认 0。

### `ACTION_SCHEDULE_DELAYED_ACTIONS`

路径：`res://scripts/actions/custom_actions/ActionScheduleDelayedActions.gd`

捕获选中牌和一组子 Action，把它们保存到指定状态效果的 `status_custom_values`，由兼容 `StatusEffectDelayedExecution` 的脚本在倒计时结束时恢复执行。捕获的卡牌会深复制为独立原型；原请求 `card_values` 也会深复制保存，避免延时期间被后续卡牌改写。

参数：`operation` 默认 `CardMoveOperation.TYPES.NONE`，`status_effect_id` 默认 `status_effect_delayed_execution`，`status_charges` 默认 1，`variable_name_to_export` 默认 `stored_cards`，`action_data`。

## Forge Actions

### `ACTION_ADD_TO_FORGE`

路径：`res://scripts/actions/forge_actions/ActionAddToForge.gd`

把一条 Action 数据存入 `Global.player_data.player_values["forge_actions"]`，并确保玩家拥有代码锻炉。

参数：`forge_action_data`，`forge_action_load` 默认 0，`forge_action_description` 默认 `""`。

若 `forge_action_data` 参数值是字符串，且该字符串是当前 `CardPlayRequest.card_values` 的键，会在存入时替换为实际值。

### `ACTION_TAKE_FROM_FORGE`

路径：`res://scripts/actions/forge_actions/ActionTakeFromForge.gd`

按 `TAKE_TYPES` 从锻造区取全部、第一条或最后一条代码。可选择清除原条目并同步代码锻炉计数；随后根据总负载计算费用，或者直接扣能量并把代码入栈执行，或者生成一张临时融合牌加入手牌。非法 `take_type` 会记录错误并终止本次处理。

参数：`fallback_action_data`，`take_type` 默认 `ActionTakeFromForge.TAKE_TYPES.ALL`，`clear_after_take` 默认 true，`execute_directly` 默认 false，`override_load` 默认 -1。

`take_type` 使用 `ActionTakeFromForge.TAKE_TYPES.ALL`、`FIRST`、`LAST`。

### `ACTION_CONSUME_FORGE_LOAD`

路径：`res://scripts/actions/forge_actions/ActionConsumeForgeLoad.gd`

消耗玩家本回合锻造负载状态 `status_effect_turn_forge_load`。

参数：`load_amount` 默认 0。

## Option Actions

### `ACTION_PICK_OPTIONS`

路径：`res://scripts/actions/option_actions/ActionPickOptions.gd`

弹出选项选择 UI，选择后执行各选项的 `option_sub_actions`。支持直接传 `OptionData`、按 ID 查询全局 Option，或用 Dictionary 临时构建；字典 Validator 失败时只禁用该选项。无条件调试 `print()` 已移除，不会在每次打开 UI 时污染日志。

参数：`options`。元素可为 `OptionData`、`String` option id、或 Dictionary。

Dictionary 可用字段：`option_name`、`option_description`、`option_texture_path`、`option_disabled`、`option_disabled_reason`、`option_validators`、`option_sub_actions`。

继承参数：`max_picks` 默认 1，`min_picks` 默认 1，`pick_text`，`is_quick_pick` 默认 false，`can_back_out` 默认 false。

## Debug Actions

### `ACTION_DEBUG_LOG`

路径：`res://scripts/actions/debug_actions/ActionDebugLog.gd`

输出调试日志。

参数：`log_message`，`log_message_color_html`，`log_severity`。

## 逐 Action 精确参数表

本节是前文功能索引的参数补充。为避免重复，所有 Action 都默认支持“所有 Action 通用参数”；Cardset/Pick Action 还默认支持各自的通用参数。表中的 `I`、`V`、`A`、`R`、`C` 含义见“参数读取标记”。

### Combatant 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_ATTACK_GENERATOR` | `damage` | `int` | `0` | `I` | 每段攻击的基础伤害；先与 `additional_damage` 相加，再应用随机增量和连击合并。 |
|  | `additional_damage` | `int` | `0` | `I` | 与 `damage` 直接相加的附加项，适合拦截器追加而不覆盖基础值。 |
|  | `number_of_attacks` | `int` | `1` | `I` | 生成的攻击次数。负数/0 会让循环不生成攻击；源码未显式钳制。 |
|  | `merge_attacks` | `bool` | `false` | `I` | 为 true 时将 `damage * number_of_attacks` 合并为一个 `ACTION_ATTACK`。 |
|  | `damage_random` | `int` | `0` | `I` | 仅 `> 1` 时，从闭区间 `[0, damage_random]` 抽取一次并加到每段基础伤害；所有连击共享同一次随机结果。值为 1 反而不会随机。 |
|  | `rng_damage_name` | `String` | `"rng_damage"` | `V` | `damage_random` 使用的 RNG 轨道；不能被当前生成器的 shadow 拦截器改写。 |
|  | `time_delay` | `float` | `0.25` | `I` | 写入每个子 `ACTION_ATTACK`，生成器本身是 instant。 |
|  | `target_override` | `BaseAction.TARGET_OVERRIDES` | `SELECTED_TARGETS` | `I` | 原样转交给每段攻击。 |
|  | `attack_animation_name` | `String` | `AnimationData.ANIMATION_ATTACK` | `I` | 写入第一段攻击，与第一段命中表现同时启动；`ANIMATION_NONE` 禁用。 |
|  | `per_attack_animation_name` | `String` | `AnimationData.ANIMATION_NONE` | `I` | 非空时写入每段攻击，并覆盖一次性攻击动画语义。 |
|  | `impact_vfx_animation_id` | `String` | `""` | `I` | 写入每段攻击，与伤害和音效同时启动。 |
|  | `audio_path` | `Array[String]` | `[]` | `I` | 候选音效路径，传给每个子 `ATTACK`，每段伤害结算时随机播放一个。 |
|  | `actions_on_lethal` | `Array[Dictionary]` | `[]` | `I` | 传给每个子攻击；每个被击杀目标都会用该目标作为唯一 targets 生成 payload。 |
| `ACTION_TIME_ATTACK_GENERATOR` | `time_extraction_mode` | `int` | `ActionTimeAttackGenerator.TIME_EXTRACTION_MODES.ONES_DIGIT` | `I` | 使用 `TIME_EXTRACTION_MODES`：`ONES_DIGIT` 取整数秒个位，`TOTAL_SECONDS` 取整数秒，`TOTAL_MINUTES` 取整分钟；非法值记录错误并终止该次生成。 |
|  | `time_multiplier` | `int` | `1` | `I` | 提取值乘数，乘积成为基础伤害，再加 `additional_damage`。 |
|  | 其余参数 | 同 `ATTACK_GENERATOR` | 同左 | 同左 | 完整复制普通攻击生成器的连击、合并、随机、目标、动画、音效、VFX 和击杀参数，但没有 `damage` 输入。 |
| `ACTION_ATTACK` | `damage` | `int` | `0` | `I` | 传给 `target.damage()` 的伤害值。 |
|  | `bypass_block` | `bool` | `false` | `I` | 为 true 时绕过格挡。 |
|  | `audio_path` | `Array[String]` | `[]` | `I` | 非空时通过 `ActionGenerator.play_combat_sound()` 立即播放，并加入战斗表现锁。 |
|  | `attack_animation_name` | `String` | `AnimationData.ANIMATION_NONE` | `I` | 与本段伤害同时启动的攻击者动画。 |
|  | `impact_vfx_animation_id` | `String` | `""` | `I` | 与本段伤害同时启动的目标命中特效。 |
|  | `actions_on_lethal` | `Array[Dictionary]` | `[]` | `V` | 目标在本次伤害后死亡才生成；该参数支持自动捕获但不会读取 shadow 值。 |
|  | `action_short_circuits` | `bool` | `true` | `V` | 战斗无剩余敌人时由 Handler 跳过。 |
| `ACTION_DIRECT_DAMAGE` | `damage` | `int` | `0` | `I` | 直接传给 `target.damage()`；与 Attack 使用不同脚本路径以避开攻击类拦截器。 |
|  | `bypass_block` | `bool` | `false` | `I` | 是否绕过格挡。 |
|  | `actions_on_lethal` | `Array[Dictionary]` | `[]` | `V` | 击杀后生成的 payload。 |
| `ACTION_BLOCK` | `block` | `int` | `0` | `I` | 基础格挡。 |
|  | `additional_block` | `int` | `0` | `I` | 与 `block` 相加后一次性传给 `target.add_block()`。 |
|  | `audio_path` | `Array[String]` | `[]` | `I` | 非空时立即随机播放一个格挡音效。 |
| `ACTION_ADD_HEALTH` | `health_amount` | `int` | `0` | `I` | 当前生命增量，可为负。 |
|  | `health_max_amount` | `int` | `0` | `I` | 最大生命的固定增量。 |
|  | `health_max_percent` | `float` | `0.0` | `I` | 按目标执行前最大生命计算增量，并向上取整；最终最大生命增量为固定值与百分比值之和。`0.1` 表示 10%。 |
| `ACTION_SET_HEALTH` | `health_amount` | `int` | 目标当前生命 | `I` | 设置当前生命的绝对值；省略时保持当前值。 |
|  | `health_max_amount` | `int` | 目标当前最大生命 | `I` | 设置最大生命绝对值；省略时保持当前值。 |
| `ACTION_HEAL_PERCENT` | `percentage_heal_amount` | `float` | `1.0` | `I` | 交给 `heal_percentage()`；`1.0` 表示最大生命的 100%，不是 1%。 |
| `ACTION_RESET_BLOCK` | 无专用参数 | - | - | - | 对每个有效目标调用 `reset_block()`。 |
| `ACTION_DEATH` | 无专用参数 | - | - | - | 只运行死亡拦截器链，不直接改变生命或移除节点。 |
| `ACTION_PLAY_ANIMATION` | `animation_name` | `String` | `AnimationData.ANIMATION_IDLE` | `I` | 传给每个目标的 `play_animation()`。 |
| `ACTION_CREATE_EFFECT_ANIMATION` | `impact_vfx_animation_id` | `String` | `""` | `I` | 非空时传给目标 `create_effect_animation()`；Action 为 instant。 |
| `ACTION_TALK` | `message_bbcode` | `String` | `"默认文本"` | `I` | 加入每个存活目标的气泡队列，支持 BBCode。 |

枚举/常量依赖：

- `ACTION_ATTACK_GENERATOR`、`ACTION_TIME_ATTACK_GENERATOR`：`BaseAction.TARGET_OVERRIDES`；`AnimationData.ANIMATION_ATTACK`、`ANIMATION_NONE`。
- `ACTION_PLAY_ANIMATION`：`AnimationData` 中的动画名常量；也允许目标动画播放器支持的自定义字符串。
- `ACTION_ATTACK`、`ACTION_DIRECT_DAMAGE` 的运行时输出常量键：`unblocked_damage`（穿透格挡后的总伤害，含过量）、`unblocked_damage_capped`（不含过量）、`overkill_damage`（超出致死生命的部分）。三者写入 `CardPlayRequest.card_values` 并在同一请求内累加。

### Status 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_APPLY_STATUS` | `status_effect_object_id` | `String` | `""` | `I` | `StatusEffectData.object_id`。空字符串仍会传给目标 API，调用方应保证有效。 |
|  | `status_charge_amount` | `int` | `1` | `I` | 主层数增量；可为负数。 |
|  | `status_secondary_charge_amount` | `int` | `0` | `I` | 副层数增量，具体碰撞/展示规则由状态数据决定。 |
|  | `status_force_apply_new_effect` | `bool` | `false` | `I` | false 时合并到现有状态；true 时调用 `add_new_status_effect()` 创建独立实例。 |
|  | `status_custom_values` | `Dictionary` | `{}` | `I` | 仅强制新建时传入新状态实例；普通加层分支不使用。 |
|  | `action_short_circuits` | `bool` | `true` | `V` | 战斗无剩余敌人时跳过。对只给玩家加状态的战后动作尤其要留意。 |
| `ACTION_DECAY_STATUS` | `status_effect_object_id` | `String` | `""` | `I` | 要衰减的状态 ID。 |
|  | `status_charge_delta` | `int` | `-1` | `I` | 交给 `add_status_effect_charges()` 的有符号变化量；负数衰减，正数增加。 |
|  | `action_short_circuits` | `bool` | `true` | `V` | 同上。 |
| `ACTION_MULTIPLY_STATUS` | `status_effect_object_id` | `String` | `""` | `I` | 读取目标当前主层数。 |
|  | `status_effect_multiplier_amount` | `int` | `1` | `I` | 计算增量 `(倍率 - 1) * 当前层数`，再直调 `APPLY_STATUS`；1 不变，0 清空，负数会反向越过 0，最终行为由状态 API 决定。 |
|  | `action_short_circuits` | `bool` | `true` | `V` | 战斗无剩余敌人时跳过。 |
| `ACTION_BLOCK_TO_STATUS` | `status_effect_object_id` | `String` | `""` | `I` | 将目标执行时的全部格挡作为主层数直调 `APPLY_STATUS`，随后无条件清空格挡。 |

类型依赖：上述 ID 均引用 `StatusEffectData.object_id`。状态类型、处理时点、衰减方式分别由 `StatusEffectData.STATUS_EFFECT_TYPES`、`STATUS_EFFECT_PROCESS_TIMES`、`STATUS_EFFECT_DECAY_TYPES` 定义，但这些不是 Action 参数。

### Player 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_BLOCK_BY_STATUS` | `status_effect_object_id` | `String` | `""` | `I` | 从玩家执行者读取该状态主层数。 |
|  | `block_multiplier` | `int` | `1` | `I` | 最终格挡为状态层数乘该值。 |
|  | `include_pending_status_charges` | `bool` | `false` | `I` | 为 true 时再加上同一 Action 上捕获的 `status_charge_amount`，用于“先算将要添加的层数”。 |
|  | `status_charge_amount` | 数值 | `0` | `I` | 仅上一个开关为 true 时作为待添加层数参与计算，本 Action 自己不加状态。 |
| `ACTION_ADD_ENERGY` | `energy_amount` | `int` | `0` | `I` | 当前能量增量，结果下限为 0。 |
|  | `energy_amount_max` | `int` | `0` | `I` | 最大能量永久增量，结果下限为 1。 |
| `ACTION_RESET_ENERGY` | 无专用参数 | - | - | - | 将当前能量直接设为 0，并发出 `energy_changed`。 |
| `ACTION_ADD_MONEY` | `money_amount` | `int` | `0` | `I` | 固定金币增量，可为负。 |
|  | `money_percent` | `float` | `0.0` | `I` | 按执行前当前金币计算并向上取整，再与固定值相加；`0.1` 表示 10%。 |
| `ACTION_DRAW_GENERATOR` | `draw_count` | `int` | `1` | `I` | 钳制到至少 0，生成同数量的独立 `ACTION_DRAW`。不会把其他 Action 值自动复制到子 Draw 字典，但子 Action 共享 CardPlayRequest。 |
| `ACTION_DRAW` | `hand_card_count_max` | `int` | `HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX` | `I` | 本次抽一张牌时允许的手牌上限；超出时具体去向由 `HandManager.draw_cards()` 决定。 |
| `ACTION_RESHUFFLE` | `shuffle_discard_into_draw` | `bool` | `true` | `I` | true 时先把弃牌堆并入抽牌堆再洗牌；false 时只洗现有抽牌堆。 |
| `ACTION_END_TURN` | `end_turn_immediacy_level` | `CombatEndTurn.END_TURN_QUEUE_IMMEDIACY` | `WAIT_FOR_ALL_CARD_PLAYS` | `V` | 发出 `end_turn_requested`；不同值决定等待卡牌队列、Action 队列或立即结束。 |
| `ACTION_ADD_ARTIFACT` | `artifact_id` | `String` | `""` | `I` | 从全局原型表查找并添加实例；拦截器可拒绝或 shadow 改写该 ID。无效 ID 记录错误并终止。 |
|  | `custom_values` | `Dictionary` | `{}` | `I` | 初始化新增外设实例的自定义值，也允许拦截器 shadow 改写。 |
| `ACTION_ADD_ARTIFACTS_FROM_POOL` | `artifact_count` | `int` | `1` | `I` | 从玩家外设池获取的数量。 |
|  | `artifact_rarities` | `Array[int]` | `[]` | `I` | 允许的稀有度；空数组表示不按稀有度限制。 |
|  | `use_rarity_ordering` | `bool` | `true` | `I` | true 时按数组给出的稀有度先后顺序尝试。 |
|  | `from_back` | `bool` | `false` | `I` | 是否从外设池尾部取，商店等系统可用它与正常奖励分流。 |
| `ACTION_SWAP_BOSS_ARTIFACT` | 无专用参数 | - | - | - | 移除角色定义的全部初始外设，再从 Boss 外设池取 1 件。 |
| `ACTION_ADD_CONSUMABLE` | `consumable_object_id` | `String` | `""` | `I` | 指定消耗品 ID；`random_consumable == false` 时使用。 |
|  | `fill_all_slots` | `bool` | `false` | `I` | 为 true 时尝试填满所有空槽，覆盖 `slot_count` 的常规数量意图。 |
|  | `random_consumable` | `bool` | `false` | `I` | 从可用消耗品池随机选择。 |
|  | `consumable_whitelist_ids` | `Array[String]` | `[]` | `I` | 随机候选白名单。 |
|  | `consumable_blacklist_ids` | `Array[String]` | `[]` | `I` | 随机候选黑名单；应与白名单保持无冲突。 |
|  | `slot_count` | `int` | `1` | `I` | 计划添加数量，实际受空槽数量限制。 |
|  | `rng_name` | `String` | `"rng_consumables"` | `V` | 随机消耗品轨道，不读取 shadow。 |
| `ACTION_USE_CONSUMABLE` | `consumable_slot_index` | `int` | `0` | `I` | 玩家消耗品槽索引；成功后先从槽映射中移除，再执行其 actions。 |
|  | `perform_consumable_actions_instantly` | `bool` | `false` | `I` | true 时逐个直调子 Action，只适合非异步、无需 delay 的即时效果。 |
| `ACTION_CONSUMABLE` | 无专用参数 | - | - | - | 纯消耗品预览/使用拦截钩子，本体不执行效果。 |
| `ACTION_UPDATE_CARD_DRAFTS` | `reset_to_starting_card_packs` | `bool` | `false` | `I` | 先恢复角色初始奖励卡包列表。 |
|  | `remove_all_card_packs` | `bool` | `false` | `I` | 随后清空全部卡包；若与 reset 同时为 true，清空结果优先。 |
|  | `add_card_pack_object_ids` / `remove_card_pack_object_ids` | `Array[String]` | `[]` | `I` | 依次增删奖励卡包；添加会去重。 |
|  | `whitelist_card_object_ids` / `blacklist_card_object_ids` | `Array[String]` | `[]` | `I` | 更新玩家奖励卡白/黑名单；加入一侧时尝试从另一侧移除，最后重建卡池缓存。 |
| `ACTION_UPDATE_CONSUMABLE_DRAFTS` | `reset_to_starting_consumable_packs` | `bool` | `false` | `I` | 恢复角色初始消耗品包。 |
|  | `remove_all_consumable_packs` | `bool` | `false` | `I` | 随后清空全部包。 |
|  | `add_consumable_pack_object_ids` / `remove_consumable_pack_object_ids` | `Array[String]` | `[]` | `I` | 增删可用消耗品包。 |
|  | `whitelist_consumable_object_ids` / `blacklist_consumable_object_ids` | `Array[String]` | `[]` | `I` | 更新白/黑名单，最后重建可用 ID 缓存。 |
| `ACTION_UPDATE_REST_ACTIONS` | `add_rest_action_object_ids` | `Array[String]` | `[]` | `I` | 逐个启用 RestActionData。 |
|  | `remove_rest_action_object_ids` | `Array[String]` | `[]` | `I` | 逐个禁用；同一 ID 同时出现时移除后执行，因此最终禁用。 |
| `ACTION_UPDATE_PLAYER_VALUE` | `player_value_name` | `String` | `""` | `I` | `PlayerData.player_values` 的键；空字符串会记录错误并跳过。 |
|  | `new_player_value` | `Variant` | `null` | `I` | 完整覆盖该自定义值，不执行加法或深合并。 |

枚举/常量依赖：

- `ACTION_END_TURN`：`CombatEndTurn.END_TURN_QUEUE_IMMEDIACY`：`WAIT_FOR_ALL_CARD_PLAYS`、`WAIT_FOR_ACTIONS`、`IMMEDIATE`，枚举顺序注释声明不可重排。
- `ACTION_DRAW`：`HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX`，当前为 10。
- `ACTION_ADD_ARTIFACTS_FROM_POOL`：`ArtifactData.ARTIFACT_RARITIES`：`BASIC`、`COMMON`、`UNCOMMON`、`RARE`、`BOSS`、`SHOP`、`EVENT`。
- 所有 card/artifact/consumable/rest ID 分别引用对应 Data 类的 `object_id`，不是脚本路径。

### Enemy 与 Card Play 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_CYCLE_ENEMY_INTENT` | `action_short_circuits` | `bool` | `true` | `V` | 对每个存活 Enemy 调用 `cycle_enemy_intent()`；非 Enemy 目标跳过。 |
| `ACTION_CHANGE_ENEMY_INTENT_STATE` | `new_intent_id` | `String` | `""` | `I` | 非空时强制目标 Enemy 切到对应 `EnemyIntentData.intent_id`。 |
|  | `action_short_circuits` | `bool` | `true` | `V` | 战斗无剩余敌人时跳过。 |
| `ACTION_SUMMON_ENEMIES` | `number_of_spawns` | `int` | `1` | `I` | 最多召唤数量；还受空余 `spawn_slots` 数量限制。 |
|  | `spawn_slots` | `Array[int]` | `[]` | `I` | 依次检查的敌人槽位；存活敌人占用则跳过，死亡敌人会先 `queue_free()` 后替换。 |
|  | `is_minion` | `bool` | `false` | `I` | 传给 `enemy_spawn_requested` 的召唤物标记。 |
|  | `random_enemy_object_ids` | `Array[String]` | `[]` | `I` | 每次填槽前重新洗牌并取第一个 ID；空数组会报错并终止。 |
|  | `rng_name` | `String` | `"rng_enemy_spawning"` | `V` | 召唤类型随机轨道。 |
| `ACTION_CARD_PLAY` | 无专用参数 | - | - | - | 纯卡牌打出拦截钩子，本体不会由 ActionHandler 正常执行。 |
| `ACTION_CARD_PLAY_END` | 无专用参数 | - | - | - | 执行时发出 `Signals.card_played(card_play_request)`，用于标记该次卡牌动作链结束。 |
| `ACTION_CHANGE_CARD_PLAY_DESTINATION` | `card_destination` | `String` | 请求当前 `card_destination_pile` | `I` | 覆盖当前请求结算后的目的牌堆。 |
|  | `card_destination_strategy` | `HandManager.PILE_INSERTION_STRATEGIES` | 请求当前策略 | `I` | 覆盖插入目标牌堆的位置策略。 |

枚举/常量依赖：

- `ACTION_CHANGE_CARD_PLAY_DESTINATION.card_destination`：`HandManager.HAND_PILE`、`DRAW_PILE`、`DISCARD_PILE`、`EXHAUST_PILE`、`BANISH_PILE`。
- `HandManager.PILE_INSERTION_STRATEGIES`：`TOP`、`BOTTOM`、`RANDOM`；随机插入使用 HandManager 对应 RNG 逻辑。

### Pick Card 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_PICK_CARDS` | `action_data` | `Array[Dictionary]` | `[]` | `V/C` | 选牌成功后生成的 Cardset/任意子 Action；子 Cardset 可从 parent Action 直接取得 `picked_cards`。 |
| `ACTION_PICK_UPGRADE_CARDS` | `upgrade_parent_card` | `bool` | `false` | `V` | true 时同时升级战斗卡的 `parent_card`；直接从 `HandManager.DECK` 选永久卡时应为 false。 |
|  | `upgrade_count` | `int` | `1` | `V` | 先钳制到至少 0，并同时作用于选中卡及其 parent。 |
|  | `bypass_upgrade_max` | `bool` | `false` | `V` | 允许选中卡及 parent 超过通常上限；选牌可用性检查也参考该值。 |
| `ACTION_PICK_DUPLICATE_CARDS` | 无额外参数 | - | - | - | 使用 Pick 通用参数和 `ACTION_PICK_CARDS.action_data`；每张选中牌深克隆一次并写出 `generated_cards`。必须存在 `CardPlayRequest`。 |
| `ACTION_CREATE_CARDS` | `created_card_object_id` | `String` | `""` | `I` | 每次从原型表取得一个新的 CardData 实例。 |
|  | `number_of_cards` | `int` | `1` | `I` | 创建数量；0/负数不创建。结果同时写入自身 `values.picked_cards` 与请求级 `generated_cards`。 |
|  | `action_data` | `Array[Dictionary]` | `[]` | `V/C` | 继承自 `ActionPickCards`，对生成牌执行的后续动作。 |
| `ACTION_DUPLICATE_CARDS` | `created_card_data` | `CardData` | `null` | `I` | 要克隆的已实例化卡牌；每次调用 `get_prototype(true)` 生成新 UID。 |
|  | `number_of_cards` | `int` | `1` | `I` | 克隆数量。输出契约与 Create Cards 相同。 |
|  | `action_data` | `Array[Dictionary]` | `[]` | `V/C` | 对克隆结果执行的后续动作。 |
| `ACTION_DEBUG_PICK_ANY_CARD` | 无额外参数 | - | - | - | 强制候选集为 `Global.get_all_cards()`，确认后再按 object id 克隆实例；仍支持 Pick 通用数量、UI 和 `action_data` 参数。仅建议调试使用。 |

类型/常量依赖：

- 所有 Pick Action：前文 `ActionBasePickCards.PICK_*` 与 `HandManager` 牌堆常量。
- `ACTION_PICK_UPGRADE_CARDS`：`CardData.card_upgrade_amount`、`card_upgrade_amount_max`。
- `ACTION_CREATE_CARDS.created_card_object_id`：`CardData.object_id`；`ACTION_DUPLICATE_CARDS.created_card_data` 则必须是实例，两者不可互换。

### Cardset 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_ADD_CARDS_TO_HAND` | `hand_card_count_max` | `int` | `HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX` | `I` | 将解析出的卡组加入手牌时采用的容量上限。 |
| `ACTION_ADD_CARDS_TO_DRAW` | `card_destination_strategy` | `HandManager.PILE_INSERTION_STRATEGIES` | `TOP` | `I` | 决定加入抽牌堆顶部、底部或随机位置。 |
| `ACTION_ADD_CARDS_TO_DECK` | 无额外参数 | - | - | `I` | 把每个 CardData 交给 `PlayerData.add_card_to_deck()`，影响永久牌组。 |
| `ACTION_REMOVE_CARDS_FROM_DECK` | 无额外参数 | - | - | `I` | 优先删除每张战斗卡的 `parent_card`，否则删除该实例本身。 |
| `ACTION_DISCARD_CARDS` | `is_manual_discard` | `bool` | `true` | `I` | true 计入主动弃牌并触发对应副作用；false 只按自然移动处理。旧版文档中的 false 默认值不正确。 |
| `ACTION_EXHAUST_CARDS` | 无额外参数 | - | - | `I` | 通过 `CardMoveOperation` 进入坏道区，触发消耗统计/信号。 |
| `ACTION_BANISH_CARDS` | 无额外参数 | - | - | `I` | 通过 `CardMoveOperation` 从战斗各区永久移除并计为放逐。 |
| `ACTION_MOVE_CARDS_TO_LIMBO` | 无额外参数 | - | - | `I` | 通过 `CardMoveOperation` 暂移出各牌区，但不计作真正放逐，供后续重新放置。 |
| `ACTION_RETAIN_CARDS` | 无额外参数 | - | - | `I` | 只赋予本回合临时保留；回合结束后由 HandManager 消耗该临时状态。 |
| `ACTION_SWAP_HAND_CARDS` | 无额外参数 | - | - | - | 必须恰好两张且都在当前手牌，交换数组位置后刷新手牌动画；否则记录错误并退出。 |
| `ACTION_PLAY_CARDS` | `rng_name` | `String` | `"rng_targeting"` | `I` | 每张牌独立从 `enemies` 组随机取目标；创建免费、自动 CardPlayRequest，并继承原请求的 `card_values` 副本。 |
| `ACTION_ATTACH_CARDS_ONTO_ENEMY` | 无额外参数 | - | - | - | 先把卡移入 Limbo，再为每张卡在每个目标上直接新建一层 Attached Card 状态；设计上只应给单个敌人目标。 |
| `ACTION_CHANGE_CARD_VALUES` | `new_card_values` | `Dictionary[String, Variant]` | `{}` | `I` | 覆盖/新增指定 `card_values` 键，不清除未提供的键。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | true 时除战斗实例外还修改 `parent_card`；没有 parent 时仅记录错误，仍修改当前实例。 |
| `ACTION_IMPROVE_CARD_VALUES` | `card_value_improvements` | `Dictionary[String, int]` | `{}` | `I` | 对每个键做数值加法；不存在的键按 CardData 帮助方法规则创建。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | 是否同步加到永久 parent。 |
| `ACTION_IMPROVE_CARD_VALUES_UNUSED_ENERGY` | `card_value_improvements` | `Dictionary[String, int]` | `{}` | `I` | 先把每个数值增量乘以执行时玩家剩余能量，再应用；不会消耗能量。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | 是否同步修改 parent。 |
| `ACTION_CLAMP_CARD_VALUES` | `clamped_card_values` | `Dictionary[String, Array]` | `{}` | `I` | 每项格式 `{key: [min, max]}`，交给 `CardData.clamp_card_values()`；边界数组长度和类型应由内容生成器保证。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | 是否同步钳制 parent。 |
| `ACTION_CHANGE_CARD_PROPERTIES` | `card_properties` | `Dictionary[String, Variant]` | `{}` | `I` | 通过 `CardData.set_card_properties()` 覆盖真实字段，不是 `card_values`；键必须是有效属性名。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | 是否同步覆盖 parent。 |
| `ACTION_IMPROVE_CARD_PROPERTIES` | `card_property_improvements` | `Dictionary[String, int]` | `{}` | `I` | 对指定 CardData 数值字段做加法；非 int/float 字段静默跳过。 |
|  | `card_property_min_values` | `Dictionary[String, int]` | `{}` | `I` | 每个字段的下限；未提供时下限为 0。没有对应上限参数。 |
|  | `modify_parent_card` | `bool` | `true` | `I` | parent 存在时将当前卡与 parent 都加入目标列表；不存在时只改当前卡，不报错。 |
| `ACTION_CHANGE_CARD_ENERGIES` | `card_energy_cost` | `int` | `-1` | `I` | 修改永久基础费用；`-1` 表示保持不变。 |
|  | `card_energy_cost_until_combat` | `int` | `-1` | `I` | 修改本场战斗临时费用层；`-1` 不变。 |
|  | `card_energy_cost_until_played` | `int` | `-1` | `I` | 修改打出前有效费用层；`-1` 不变。 |
|  | `card_energy_cost_until_turn` | `int` | `-1` | `I` | 修改本回合费用层；`-1` 不变。 |
| `ACTION_RANDOMIZE_CARD_ENERGIES` | `randomize_card_energy_cost` | `bool` | `false` | `I` | 是否随机永久基础费用。 |
|  | `randomize_card_energy_cost_until_combat` | `bool` | `false` | `I` | 是否随机战斗临时费用。 |
|  | `randomize_card_energy_cost_until_played` | `bool` | `false` | `I` | 是否随机打出前费用。 |
|  | `randomize_card_energy_cost_until_turn` | `bool` | `false` | `I` | 是否随机回合费用。每个开启的层、每张卡都独立抽一次。 |
|  | `card_cost_min` / `card_cost_max` | `int` | `0` / `3` | `I` | 随机闭区间。源码不校验 min <= max。 |
|  | `rng_name` | `String` | `"rng_energy_cost"` | `I` | 随机费用使用的确定性 RNG 轨道。 |
| `ACTION_UPGRADE_CARDS` | `upgrade_parent_card` | `bool` | `true` | `I` | 是否同步升级永久 parent；整个 Action 可通过统一 Cardset 拦截入口被拒绝。 |
|  | `upgrade_count` | `int` | `1` | `I` | 钳制到至少 0；选中实例、parent 与其他战斗副本均使用该升级次数。 |
|  | `bypass_upgrade_max` | `bool` | `false` | `I` | 选中实例、parent 和同步副本是否允许越过最大升级数。 |
| `ACTION_TRANSFORM_CARDS` | `transform_parent_card` | `bool` | `true` | `I` | true 时同时替换永久牌组中的 parent；战斗实例无 parent 时会报错并终止整个 Action。 |
|  | `transform_into_card_object_id` | `String` | `""` | `I` | 非空时指定变形目标；空时按筛选条件随机。 |
|  | `keep_upgrade_level` | `bool` | `false` | `I` | 变形后恢复原卡升级次数。 |
|  | `force_upgrade_level` | `int` | `-1` | `I` | `>= 0` 时覆盖 keep 的结果，强制变形后升级次数。 |
|  | `keep_rarity` / `keep_color` / `keep_type` | `bool` | `false` / `true` / `false` | `I` | 随机变形时按原卡固定相应属性；为 true 时对应 transform 数组被忽略。 |
|  | `transform_rarities` | `Array[int]` | `CardData.CARD_RARITIES.values()` | `I` | 随机候选稀有度。 |
|  | `transform_colors` | `Array[String]` | `Global._id_to_color_data.keys()` | `I` | 随机候选颜色 ID。 |
|  | `transform_types` | `Array[int]` | `CardData.STANDARD_CARD_TYPES` | `I` | 随机候选类型，默认只含 Attack/Skill/Power。 |
|  | `rng_name` | `String` | `"rng_card_transforming"` | `I` | 候选 ID 洗牌轨道。 |
| `ACTION_DECORATE_CARDS` | `decorate_parent_card` | `bool` | `true` | `I` | true 时同步装饰 parent；parent 不存在会终止 Action。 |
|  | `card_decorator_object_id` | `String` | `""` | `I` | 指定装饰器 ID；非空时优先，不使用随机表。 |
|  | `card_decorator_values` | `Dictionary` | `{}` | `I` | 指定装饰器实例值。 |
|  | `random_card_decorators` | `Dictionary[String, Dictionary]` | `{}` | `I` | `{decorator_id: values}` 候选表；每张卡选择一个尚可应用的候选，并把该候选对应的 values 应用于战斗实例及可选 parent。 |
|  | `rng_name` | `String` | `"rng_card_decoration"` | `I` | 随机候选顺序轨道。 |
| `ACTION_LOW_LEVEL_FORMAT` | `source_zones` | `Array[String]` | Hand/Draw/Discard | `I` | 扫描来源牌区并去重；不含 Exhaust/Deck，除非显式加入。 |
|  | `filter_card_types` | `Array[int]` | `[]` | `I` | 非空时只保留 `CardData.card_type` 在数组中的牌。 |
|  | `filter_card_colors` | `Array[String]` | `[]` | `I` | 非空时只保留 `CardData.card_color_id` 在数组中的牌。 |
|  | `filter_card_ids` | `Array[String]` | `[]` | `I` | 非空时只保留 object id。多个过滤器之间是 AND。 |
|  | `operation` | `int` | `CardMoveOperation.TYPES.EXHAUST` | `I` | 使用共享枚举；支持 `NONE`、`DISCARD`、`EXHAUST`、`BANISH`、`LIMBO`、`RETAIN`。 |
|  | `variable_name_to_export` | `String` | `"format_count"` | `I` | 把匹配数量注入每个一级子 Action 的该键；空字符串不注入。 |
|  | `action_data` | `Array[Dictionary]` | `[]` | `I/C` | 深复制后注入数量并生成。 |

枚举/常量依赖：

- `ACTION_ADD_CARDS_TO_DRAW`：`HandManager.PILE_INSERTION_STRATEGIES`。
- `ACTION_LOW_LEVEL_FORMAT.source_zones`：`HandManager` 牌堆常量；`filter_card_types`：`CardData.CARD_TYPES`；`operation`：`CardMoveOperation.TYPES`。
- `CardMoveOperation.TYPES` = `NONE: 0`、`DISCARD: 1`、`EXHAUST: 2`、`BANISH: 3`、`LIMBO: 4`、`RETAIN: 5`。GDScript 使用枚举名；JSON/Mod 数据写对应整数。
- `ACTION_TRANSFORM_CARDS`：`CardData.CARD_RARITIES`、`CARD_TYPES`、`STANDARD_CARD_TYPES`；颜色使用 `ColorData.object_id` 字符串，没有 `CardData.CARD_COLORS` 枚举。
- `ACTION_ATTACH_CARDS_ONTO_ENEMY`：内部硬编码 `STATUS_EFFECT_ATTACHED_CARD_ID = "status_effect_attached_card"`，并依赖对应 `StatusEffectAttachedCard` 实现。

### Meta 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_VALIDATOR` | `validator_data` | `Array[Dictionary]` | `[]` | `V` | 全部 Validator 通过才选 passed 分支；空数组通常视为通过。实现直接访问 `card_play_request.card_data`，需有请求。 |
|  | `passed_action_data` | `Array[Dictionary]` | `[]` | `V/C` | 校验成功时生成。 |
|  | `failed_action_data` | `Array[Dictionary]` | `[]` | `V/C` | 校验失败时生成。 |
| `ACTION_RANDOM_SELECTION` | `weights` | `Dictionary[Variant, int]` | `{}` | `I` | `{分支名: 权重}`；由 `Random.get_weighted_selection()` 选一个键。 |
|  | `weighted_action_data` | `Dictionary[String, Array]` | `{}` | `I/C` | `{分支名: action_data}`；键必须与 weights 完全对应。 |
|  | `rng_name` | `String` | `"rng_general"` | `I` | 分支随机轨道。 |
|  | `validator_data` | `Array[Dictionary]` | `[]` | `V` | 随机选择前运行；校验失败时不抽取分支，也不生成子 Action。没有 CardPlayRequest 时以 null CardData 参与校验。 |
| `ACTION_VARIABLE_ACTION_GENERATOR` | `action_data` | `Array[Dictionary]` | `[]` | `V/C` | 要重复的 payload。 |
|  | `action_count` | `int` | `1` | `V` | 钳制到至少 0 后把 payload 浅层顺序重复 N 次，再统一生成。 |
| `ACTION_VARIABLE_COST_MODIFIER` | `action_data` | `Array[Dictionary]` | `[]` | `I/C` | 深复制后修改指定键并生成。 |
|  | `multiplied_values` | `Array[String]` | `[]` | `I` | 要变换的子 Action 参数名。结果写入隔离的子请求快照，并递归更新 payload 中显式声明的同名参数；不改写原始请求。 |
|  | `multiplied_values_bases` | `Dictionary[String, int]` | `{}` | `I` | 每个键的固定基数，公式为 `base + original * (input_energy + offset)`。 |
|  | `multiplier_offset` | `int` | `0` | `I` | 钳制为非负，追加到 `CardPlayRequest.input_energy`。 |
| `ACTION_VARIABLE_CARDSET_MODIFIER` | `action_data` | `Array[Dictionary]` | `[]` | `I/C` | 深复制后按选中卡数量修改并生成。 |
|  | `multiplied_values` | `Array[String]` | `[]` | `I` | 每个键优先读子 Action 显式值，否则读请求级值；结果总会写入子 Action。 |
|  | `multiplied_values_bases` | `Dictionary[String, int]` | `{}` | `I` | 固定基数。 |
|  | `multiplier_offset` | `int` | `0` | `I` | 钳制非负；公式乘数为 `picked_cards.size() + offset`。 |
| `ACTION_VARIABLE_COMBAT_STATS_MODIFIER` | `action_data` | `Array[Dictionary]` | `[]` | `I/C` | 深复制后按统计值修改并生成。 |
|  | `multiplied_values` / `multiplied_values_bases` | `Array[String]` / `Dictionary` | `[]` / `{}` | `I` | 公式为 `base + original * stat_value`；结果仅写入隔离的子请求及其 payload，不污染兄弟 Action。 |
|  | `combat_stat_name` | `String` | `""` | `I` | 非空时使用字符串模式；支持 `cards_in_hand`、`attack_cards_in_hand`、`skill_cards_played_this_turn`、`target_status_effect_charges`、`player_status_effect_charges`、`block_amount`、`actions_in_forge`，未知值为 0。`skill_cards_played_this_turn` 只统计本回合已经完成的卡牌调用，在战斗开始、战斗结束和敌方回合结束时清零，不会继承上一场战斗。 |
|  | `stat_variable_name` | `String` | `""` | `I` | 两种 status charges 模式下的状态 ID。 |
|  | `stat_enum` | `CombatStatsData.STATS` | `ENEMIES_KILLED` | `I` | `combat_stat_name` 为空时使用。 |
|  | `turn_stat_type` | `int` | `0` | `I` | `-1` 全战斗总计，`0` 当前回合，`1` 上回合，N 表示前 N 回合。 |
|  | `stat_divisor` | `int` | `1` | `I` | `> 1` 时对统计值做整数除法；0、负数和 1 都不除。 |
|  | `action_types` | `Array[String]` | `[]` | `I` | 仅 `actions_in_forge` 使用；空数组计全部条目，否则只计 action path 位于数组中的条目。 |

枚举/常量依赖：

- `ACTION_VARIABLE_COMBAT_STATS_MODIFIER.stat_enum`：`CombatStatsData.STATS` 全部枚举项，见该数据类；默认 `ENEMIES_KILLED`。
- `action_types` 通常使用 `Scripts.ACTION_*` 路径常量，或复用 `ActionTypeGroups.ATTACK_ACTIONS` 等路径组。
- Cost 与 Combat Stats 两种包装器共享 `BaseVariableActionModifier`；Cardset 版本仍按“选中卡数量”提供独立语义。

### Artifact、Reward 与 Shop 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_INCREASE_ARTIFACT_CHARGE` | `artifact_id` | `String` | `""` | `I` | 非空时修改玩家持有的全部同 ID 外设实例。 |
|  | `artifact_charge_increase` | `int` | `1` | `I` | 传给 `increment_artifact_counter()` 的增量，可为负并触发计数变化副作用。 |
|  | `artifact_data` | `ArtifactData` | `null` | `I` | 直接指定实例；若同时给 ID，同一实例可能被修改两次。 |
| `ACTION_CHANGE_ARTIFACT_CHARGE` | `artifact_id` | `String` | `""` | `I` | 非空时绝对设置玩家持有的全部同 ID 外设实例计数。 |
|  | `artifact_charges` | `int` | `1` | `I` | 传给 `set_artifact_counter()` 的绝对值，不触发增量 charge actions。 |
|  | `artifact_data` | `ArtifactData` | `null` | `I` | 直接指定实例；若同时给 ID，同一实例可能被设置两次。 |
| `ACTION_CHANGE_ARTIFACT_ENABLED` | `artifact_id` | `String` | `""` | `I` | 修改全部同 ID 实例。 |
|  | `artifact_disabled` | `bool` | `true` | `I` | true 禁用，false 启用。 |
|  | `artifact_data` | `ArtifactData` | `null` | `I` | 直接指定实例；与 ID 同时提供可能重复设置。 |
| `ACTION_GRANT_REWARDS` | `reward_group` | `int` | `0` | `I` | 0 为标准组，-1 请求自动新建组，正数指定互斥奖励组。 |
|  | `money_amount` | `int` | `0` | `I` | 奖励金币值，只发给 RewardOverlay，不在此 Action 直接入账。 |
|  | `card_drafts` | `Array[Array[CardData]]` | `[]` | `I` | 每个内层数组是一组选一 draft。 |
|  | `artifact_ids` | `Array[String]` | `[]` | `I` | 外设奖励 ID。 |
|  | `custom_action_data` | `Array[Array]` | `[]` | `I` | 自定义奖励按钮 payload；具体内部 schema 由 RewardOverlay 解释。 |
| `ACTION_CLEAR_REWARDS` | `reward_group` | `int` | `-1` | `I` | -1 清全部组，其他值清指定组。 |
| `ACTION_SHOP_POPULATE_ITEMS` | `shop_cards` / `shop_card_prices` | `Array[CardData]` / `Array[int]` | `[]` | `I` | 两数组必须等长且按索引对应；长度不一致可能越界。 |
|  | `shop_artifact_ids` / `shop_artifact_prices` | `Array[String]` / `Array[int]` | `[]` | `I` | 外设与价格平行数组。 |
|  | `shop_consumable_ids` / `shop_consumable_prices` | `Array[String]` / `Array[int]` | `[]` | `I` | 消耗品与价格平行数组。 |
| `ACTION_SHOP_PURCHASE_ITEMS` | `card_data` | `CardData` | `null` | `I` | 非空时购买卡牌，优先级最高。 |
|  | `artifact_id` | `String` | `""` | `I` | card_data 为空时尝试购买外设。 |
|  | `consumable_object_id` | `String` | `""` | `I` | 前两者均未指定时尝试购买消耗品。三类参数应互斥。 |
|  | `consumable_slot_index` | `int` | `0` | `I` | 查找商店消耗品价格/移除项时使用的槽索引，不是玩家背包目标槽。 |
| `ACTION_GET_SHOP_PRICE` | 无专用参数 | - | - | - | 价格拦截查询令牌；Action 本体为空。调用方通常在预览拦截器 shadow 值后读取结果。 |
| `ACTION_GET_ENCHANT_PRICE` | 无专用参数 | - | - | - | 附魔价格拦截查询令牌；Action 本体为空。 |

### World、Audio、Custom 与 Forge 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_GENERATE_ACT` | `act_id` | `String` | `""` | `V` | 要生成的 `ActData.object_id`；无效 ID 后续访问 ActData 时会失败。 |
|  | `act_number` | `int` | 当前 `player_act` | `V` | 写回玩家当前 Act，并参与 location ID 生成。 |
|  | `rng_name` | `String` | `"rng_world_generation"` | `I` | 地图全部随机行为的轨道。 |
|  | `location_obfuscation_rate` | `float` | `0.25` | `I` | 普通战斗节点变为问号显示的概率；源码未钳制到 0..1。 |
|  | `location_non_combat_event_rate` | `float` | `0.2` | `I` | 普通战斗节点转为非战斗事件的概率；转换节点同时设为 obfuscated。 |
| `ACTION_VISIT_LOCATION` | `location_id` | `String` | `""` | `I` | 存在时更新玩家位置、标记访问、清空 shop data 并发出地图选择信号。 |
|  | `autosave_before_visit` | `bool` | `true` | `I` | 名称虽为 before_visit，实际在位置字段更新后、发信号前调用 autosave。 |
| `ACTION_START_COMBAT` | `event_object_id` | `String` | `""` | `V` | 发给 `combat_started`；空字符串由后续战斗流程按当前位置解析。虽然运行拦截器链，该值不读取 shadow。 |
| `ACTION_OPEN_CHEST` | `chest_has_money/cards/artifacts/consumables` | `bool` | `true` | `I` | 各奖励大类总开关。消耗品总开关当前不会产生奖励，因为整段实现被注释。 |
|  | `chest_generates_money` | `bool` | `true` | `I` | true 调用地点随机金币；false 才读取 `chest_money`。 |
|  | `chest_money` | `int` | `25` | `I` | 固定金币，仅上一个参数为 false 时生效。 |
|  | `chest_generates_cards` | `bool` | `true` | `I` | true 使用 `Random.get_location_card_rewards()`；false 使用 `chest_cards`。 |
|  | `chest_cards` | `Array[Array[CardData]]` | `[]` | `I` | 固定卡牌 draft，仅 generates_cards 为 false 时生效。 |
|  | 卡牌 draft 数量参数 | - | - | - | `chest_card_amount_draft`、`chest_cards_per_draft` 的读取代码目前被注释；`ActionGenerator.generate_chest_open()` 虽会写入它们，Open Chest 运行时仍忽略。 |
|  | `chest_generates_artifacts` | `bool` | `true` | `I` | true 按地点随机外设；false 使用 `artifact_ids`。 |
|  | `chest_artifact_count` | `int` | `1` | `I` | 随机外设数量。 |
|  | `artifact_ids` | `Array[String]` | `[]` | `I` | 固定外设列表。 |
|  | `custom_action_data` | `Array` | `[]` | `I` | 原样转交 Grant Rewards。 |
|  | 消耗品相关参数 | - | - | - | `chest_generates_consumables`、`chest_consumable_count`、`consumable_ids` 目前仅存在于注释代码，不是运行时支持参数。 |
| `ACTION_REST_ACTION_END` | `rest_action_id` | `String` | `""` | `V` | 非空时发出 `rest_action_ended`；空值报错。 |
| `ACTION_PLAY_MUSIC` | `audio_path` | `String` | `""` | `I` | 音乐路径；空字符串或 `FileLoader.NO_MUSIC` 会停止音乐。 |
|  | `audio_path_is_absolute` | `bool` | `false` | `I` | 是否按绝对外部路径加载。 |
|  | `audio_loops` | `bool` | `true` | `I` | 是否循环。 |
|  | `audio_crossfade_duration` | `float` | `1.0` | `I` | 切换/停止音乐的淡入淡出秒数。 |
| `ACTION_PLAY_SOUND` | `audio_path` | `Array[String]` | `[]` | `I` | 使用 `Array.pick_random()` 选一个路径；这里未使用玩家确定性 RNG，因此声音选择不保证随 run seed 重现。 |
|  | `audio_path_is_absolute` | `bool` | `false` | `I` | 是否按绝对路径加载。音效固定不循环。 |
|  | `blocks_combat_presentation` | `bool` | `false` | `I` | true 时直到音效播放结束才释放战斗表现锁；战斗音效由 `play_combat_sound()` 明确设置。 |
| `ACTION_CUSTOM_UI` | `custom_ui_object_id` | `String` | `""` | `I` | 要在目标 combatant 注册/注销的 UI ID；空字符串会记录错误并跳过。 |
|  | `enable_custom_ui` | `bool` | `true` | `I` | true 注册，false 注销。 |
| `ACTION_EMIT_CUSTOM_SIGNAL` | `custom_signal_object_id` | `String` | `""` | `I` | 在 `Signals` 注册表中定位 `CustomSignalData.object_id`。 |
|  | `custom_signal_value` | `int` | `0` | `I` | 随信号发出的数值 payload。 |
| `ACTION_SCHEDULE_DELAYED_ACTIONS` | `status_effect_id` | `String` | `"status_effect_delayed_execution"` | `I` | 承载延时数据的状态 ID；必须使用兼容 `StatusEffectDelayedExecution` 的脚本。 |
|  | `status_charges` | `int` | `1` | `I` | 倒计时初始层数；状态每次处理减 1，<= 0 时执行 payload。 |
|  | `action_data` | `Array[Dictionary]` | `[]` | `I/C` | 延时结束时生成的动作；原请求 `card_values` 会被深复制保存并恢复。 |
|  | `operation` | `int` | `CardMoveOperation.TYPES.NONE` | `I` | 使用共享 `CardMoveOperation.TYPES`；非法枚举值记录错误且不移动。 |
|  | `variable_name_to_export` | `String` | `"stored_cards"` | `I` | 到期时注入每个一级子 Action：1 张注入 CardData，多张注入数组，0 张注入 null。 |
| `ACTION_ADD_TO_FORGE` | `forge_action_data` | `Dictionary` | `{}` | `I/C` | 单个 Action 字典。保存前会把参数中“值为字符串且恰好命中 card_values 键”的项替换为快照数值。 |
|  | `forge_action_load` | `int` | `0` | `I` | 条目负载，累加代码锻炉计数；>0 时还生成 Forge Load 状态。 |
|  | `forge_action_description` | `String` | `""` | `I` | 条目展示文本，存入 forge entry。 |
| `ACTION_TAKE_FROM_FORGE` | `fallback_action_data` | `Array[Dictionary]` | `[]` | `I/C` | 锻造为空时按数组顺序生成并执行。 |
|  | `take_type` | `int` | `ActionTakeFromForge.TAKE_TYPES.ALL` | `I` | 使用 `TAKE_TYPES.ALL`、`FIRST` 或 `LAST`。 |
|  | `clear_after_take` | `bool` | `true` | `I` | 是否从 forge_actions 删除已取条目，并同步代码锻炉计数。 |
|  | `execute_directly` | `bool` | `false` | `I` | true 时按负载扣当前能量并把条目 Actions 入栈；false 时生成一张动态融合卡加入手牌。名称并非调用 `perform_action()` 直调。 |
|  | `override_load` | `int` | `-1` | `I` | `>= 0` 时仅覆盖融合卡费用计算所用负载，不改变清除时扣减的实际负载。 |
| `ACTION_CONSUME_FORGE_LOAD` | `load_amount` | `int` | `0` | `I` | `>0` 时从玩家 `status_effect_turn_forge_load` 减去不超过当前层数的值；不直接删除 forge 条目。 |

枚举/常量依赖：

- `ACTION_GENERATE_ACT` 内部使用 `LocationData.LOCATION_TYPES`；地图模板的 `pool/fixed` 值目前仍是 `easy`、`hard`、`event`、`SHOP`、`REST_SITE`、`TREASURE`、`MINIBOSS` 字符串。
- Audio：`FileLoader.NO_MUSIC`；锻造播放 `AudioConstants.SFX_GROUP_FORGE_FUSION`。
- Forge：`ActionTypeGroups.ATTACK_ACTIONS` 和 `REQUIRES_TARGET_ACTIONS` 用于推断动态融合卡类型及是否需要目标；融合卡类型/稀有度使用 `CardData.CARD_TYPES`、`CARD_RARITIES.GENERATED`，去向使用 `HandManager.BANISH_PILE`。
- Forge Take：`ActionTakeFromForge.TAKE_TYPES`；Delayed Actions 的卡牌去向：`CardMoveOperation.TYPES`。
- `ActionTakeFromForge.TAKE_TYPES` = `FIRST: 0`、`LAST: 1`、`ALL: 2`。GDScript 使用枚举名；JSON/Mod 数据写对应整数。
- Delayed Actions：默认状态 ID `status_effect_delayed_execution`；Forge Load 状态 ID `status_effect_turn_forge_load`；两者是硬编码常量语义，不是枚举。

### Option 与 Debug 参数

| Action | 参数 | 类型 | 默认值 | 读取 | 精确说明 |
|---|---|---|---|---|---|
| `ACTION_PICK_OPTIONS` | `options` | `Array` | `[]` | `V` | 元素可为 `OptionData`、Option object id 字符串或 Dictionary。字典支持 name/description/texture/disabled/reason/validators/sub_actions 字段。 |
|  | `max_picks` | `int` | `1` | `V` | UI 可选择上限。 |
|  | `min_picks` | `int` | `1` | `V` | `are_enough_options_picked()` 的下限；实际确认限制由 Option UI 调用该方法。 |
|  | `pick_text` | `String` | `"请选择一个选项"` | `V` | UI 提示文本。 |
|  | `is_quick_pick` | `bool` | `false` | `V` | UI 是否在达到选择条件时快速确认。 |
|  | `can_back_out` | `bool` | `false` | `V` | UI 是否允许取消返回。 |
| `ACTION_DEBUG_LOG` | `log_message` | `String` | `""` | `I` | 输出文本。 |
|  | `log_message_color_html` | `String` | `Color.WHITE.to_html(true)` | `I` | DebugLogger 的 HTML/RGBA 颜色字符串。 |
|  | `log_severity` | `DebugLogger.Severities` | `STANDARD` | `I` | 日志级别。 |

枚举/常量依赖：

- `ACTION_PICK_OPTIONS` 字典中的 `option_validators` 使用 `Scripts.VALIDATOR_*` 常量，`option_sub_actions` 使用 `Scripts.ACTION_*` 常量。
- `ACTION_DEBUG_LOG.log_severity`：`DebugLogger.Severities.STANDARD`、`WARNING`、`ERROR`。

## 当前 Scripts.gd 中的 Action 常量覆盖情况

所有可数据驱动使用的具体 Action 均已在 `autoload/Scripts.gd` 里注册为 `Scripts.ACTION_*`，包括绝对设置外设计数的 `ACTION_CHANGE_ARTIFACT_CHARGE`。

另外这些是基类或特殊拦截器，不应作为普通 Action 数据直接使用：

- `BaseAction.gd`
- `BaseAsyncAction.gd`
- `BaseCardsetAction.gd`
- `BaseVariableActionModifier.gd`：Cost 与 Combat Stats 数值包装器的共享实现。
- `ActionBasePickCards.gd`
- `ActionBasePickOptions.gd`
- `CardMoveOperation.gd`：卡牌去向枚举和统一移动帮助类，不是 Action。
- `scripts/actions/interceptors/InterceptorRootPrivilege.gd`

## 常见组合示例

### 造成伤害并抽牌

由于默认 `add_actions()` 逆序压栈，以下数据顺序会实际先攻击、后抽牌：

```gdscript
[
	{Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}},
	{Scripts.ACTION_ATTACK_GENERATOR: {"damage": 6}},
]
```

### 选择一张手牌并消耗

```gdscript
[
	{
		Scripts.ACTION_PICK_CARDS: {
			"card_pick_type": HandManager.HAND_PILE,
			"min_card_amount": 1,
			"max_card_amount": 1,
			"action_data": [
				{Scripts.ACTION_EXHAUST_CARDS: {}},
			],
		}
	}
]
```

### 生成卡牌并加入手牌

```gdscript
[
	{
		Scripts.ACTION_CREATE_CARDS: {
			"created_card_object_id": "card_some_generated_card",
			"number_of_cards": 2,
			"action_data": [
				{Scripts.ACTION_ADD_CARDS_TO_HAND: {}},
			],
		}
	}
]
```

### X 费攻击

```gdscript
[
	{
		Scripts.ACTION_VARIABLE_COST_MODIFIER: {
			"multiplied_values": ["damage"],
			"action_data": [
				{Scripts.ACTION_ATTACK_GENERATOR: {"damage": 4}},
			],
		}
	}
]
```

包装器会把计算后的 `damage` 写入独立的子请求；同一次包装器生成的后代 Action 都能读取该值，但包装器之后的外层兄弟 Action 仍读取原始值。

### 使用统一卡牌操作枚举

```gdscript
[
	{
		Scripts.ACTION_LOW_LEVEL_FORMAT: {
			"source_zones": [HandManager.HAND_PILE, HandManager.DISCARD_PILE],
			"operation": CardMoveOperation.TYPES.EXHAUST,
			"variable_name_to_export": "format_count",
			"action_data": [
				{Scripts.ACTION_VARIABLE_ACTION_GENERATOR: {
					"custom_key_names": {"action_count": "format_count"},
					"action_data": [
						{Scripts.ACTION_ATTACK_GENERATOR: {"damage": 5}},
					],
				}},
			],
		}
	}
]
```

JSON/Mod 数据不能写 GDScript 枚举名时，使用参数章节列出的稳定整数值；不再使用 `"exhaust"`、`"none"` 等字符串。

### 击杀后获得格挡

```gdscript
[
	{
		Scripts.ACTION_ATTACK_GENERATOR: {
			"damage": 10,
			"actions_on_lethal": [
				{
					Scripts.ACTION_BLOCK: {
						"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
						"block": 5,
					}
				}
			],
		}
	}
]
```
