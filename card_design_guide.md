# 《Null Pointer》卡牌设计指南

本指南详细说明了在当前游戏架构（基于 `CardData.gd`）下，我们可以为卡牌设计的属性、机制、附魔（Decorators）以及升级机制。本设计指南可作为后续卡牌开发的查阅手册。

---

## 1. 卡牌基础属性设计

卡牌的属性定义了它的基本面貌、类型及可用性：

### 1.1 基础信息
- **内部ID (object_id)**: 卡牌唯一内部标识（必须具有唯一性，如 `card_strike`）。这是从底层的 `SerializableData` 继承而来的最核心标识。
- **名称 (card_name)**: 卡牌显示名称。
- **描述 (card_description)**: 支持 BBCode，并支持动态数值绑定。
  - `[damage]` 会动态替换为 `card_values` 中的伤害数值。
  - `[energy_icon]` 会被直接渲染为 1 个算力图标。
  - `[damage_energy_icons]` 会被动态渲染为与当前 `damage` 数值同等数量的算力图标。
  - **动态预览截获 (`card_description_preview_overrides`)**: 类型为 `Array[Array]`（格式如 `[["damage", "res://path/to/ActionAttack.gd"]]`）。用于在打出前，提前截获某个挂载了拦截器的动态值的最终变化并在卡面上以红/绿色字预览显示。
- **图片 (card_texture_path)**: 卡牌封面。
- **颜色/角色 (card_color_id)**: 比如 `color_red`, `color_blue`，决定卡牌边框和专属卡池。
- **关键词 (card_keyword_object_ids)**: 为卡牌附加带有 Tooltip 的特定机制词条（如“脆弱”、“护盾”）。
- **状态提示词 (card_status_effect_object_ids)**: 为卡牌显式绑定需要显示在 Tooltip 中的特定状态 Buff 提示。
- **提示词 (card_hint)**: 用于新手引导的一句话解释。
- **标签 (card_tags)**: 为卡牌附带隐藏标签（如 `["tag_strike"]`），可供验证器过滤时专用。

### 1.2 类型、稀有度与卡池
- **卡牌类型 (card_type)**: 
  - `ATTACK` (攻击脚本)、`SKILL` (辅助脚本)、`POWER` (守护进程)、`STATUS` (状态码)、`CURSE` (病毒)。
- **稀有度 (card_rarity)**: `BASIC` (内置), `COMMON` (开源), `UNCOMMON` (闭源), `RARE` (零日), `GENERATED` (动态生成，不出现在常规卡包)。
- **是否在卡包中掉落 (card_appears_in_card_packs)**: 设为 `false` 可强制该卡牌哪怕符合稀有度和颜色要求，也不会在随机掉落的卡包中出现。

### 1.3 算力消耗 (Energy Cost)
- **基础耗能 (card_energy_cost)**: 打出该牌消耗的基础算力。
- **X 费卡 (card_energy_cost_is_variable)**: 设为 `true` 后，打出会消耗当前所有算力。可以通过 `card_energy_cost_variable_upper_bound` 设定消耗上限（`-1` 为无上限）。
- **临时减费 (Shadow Cost)**: 
  - `card_energy_cost_until_played`：直到打出前的改变（优先级最高）。
  - `card_energy_cost_until_turn`：直到本回合结束的改变。
  - `card_energy_cost_until_combat`：直到本场战斗结束的改变（优先级最低）。

### 1.4 洗牌优先级 (Shuffle Rules)
- **首次洗牌优先级 (card_first_shuffle_priority)**: 战斗开始时该卡进入牌库的优先级。正数(如1)必定被抽在最前面，负数(如-1)沉底，0 为正常洗牌。
- **重新洗牌优先级 (card_reshuffle_priority)**: 牌库抽空重新洗牌时的优先级逻辑，同上。
- **洗牌权重 (card_shuffle_weighting)**: 改变同级优先级中该牌被抽到的概率权重，默认为 1.0（不能为负或0）。

### 1.5 内置附魔 (Innate Decorators)
- **自带附魔配置 (card_decorators)**: `Dictionary[String, Dictionary]`。你可以直接在卡牌的原型数据中预设附魔字典（如 `{"card_decorator_block_on_play": {"param": "value"}}`），让这张卡在原型阶段就天生自带指定的附魔，而无需在游戏中途获取。

---

## 2. 卡牌机制设计

我们可以将复杂的 Action (行为树) 挂载到卡牌的不同生命周期事件上。这赋予了卡牌极其丰富的触发机制：

### 2.1 行为触发时机 (Action Hooks)
可以为卡牌设计在不同时机触发的操作（挂载钩子）：
- **打出时 (card_play_actions)**: 最常规的触发方式，打出卡牌时生效。
- **抽到时 (card_draw_actions)**: 被抽进手牌时立即触发的效果。
- **保留时 (card_retain_actions)**: 回合结束时如果留在手牌未打出，触发的效果。
- **消耗时 (card_exhaust_actions)**: 卡牌被物理删除（Exhaust）时触发的效果。
- **手动丢弃时 (card_discard_actions)**: 被其它效果或手动丢弃时触发。
- **右键点击 (card_right_click_actions)**: 允许在手牌中直接右键点击触发的特殊效果。
- **战斗开始 (card_initial_combat_actions)**: 只要卡牌在牌库中，战斗开始时就会自动触发（比如“固有”或开局送增益）。
- **局外机制**: `card_add_to_deck_actions`, `card_remove_from_deck_actions`, `card_transform_in_deck_actions`。

### 2.2 支持挂载的具体行为 (Available Actions)
在上述任意一个时机（Hooks）中，你可以配置以下底层行为脚本（定义在 `Scripts.gd` 中）：
- **战斗动作 (Combat)**：`ACTION_ATTACK` / `ACTION_ATTACK_GENERATOR` (攻击/多次攻击)、`ACTION_BLOCK` (叠甲)、`ACTION_ADD_HEALTH` (回血)、`ACTION_DIRECT_DAMAGE` (穿甲真伤)。
- **状态/Buff (Status)**：`ACTION_APPLY_STATUS` (挂 Buff 或 Debuff)、`ACTION_BLOCK_TO_STATUS` (将护盾转化为Buff层数)。
- **抽牌与算力 (Resources)**：`ACTION_DRAW` / `ACTION_DRAW_GENERATOR` (抽牌)、`ACTION_ADD_ENERGY` (回复算力)。
- **卡牌操作 (Card Manipulation)**：
  - `ACTION_ADD_CARDS_TO_HAND` (印卡到手牌)、`ACTION_ADD_CARDS_TO_DRAW` / `ACTION_ADD_CARDS_TO_DECK` (洗入抽牌堆/牌库)。
  - `ACTION_DISCARD_CARDS` (强制弃牌)、`ACTION_EXHAUST_CARDS` (强制消耗手牌)。
  - `ACTION_CHANGE_CARD_VALUES` / `ACTION_IMPROVE_CARD_VALUES` (动态改变某张卡的属性)。
  - `ACTION_DECORATE_CARDS` (在战斗中给某张卡上附魔)。
- **元操作与系统 (Meta / System)**：`ACTION_VALIDATOR` (前置条件检验，如“连击”判断)、`ACTION_PLAY_AUDIO` (播放特效音)。

### 2.3 去向与状态机制
- **是否可打出 (card_is_playable)**: 默认为 `true`。设为 `false` 则不管满不满足算力与目标条件都无法打出（通常用于状态牌或诅咒）。
- **是否需要目标 (card_requires_target)**: `true` 表示需要指定敌人，`false` 表示对全局或自身释放。
- **不可删除/不可变化 (card_unremovable_from_deck / card_untransformable_from_deck)**: 用于肉鸽局外机制，防止特殊诅咒牌/核心牌被玩家在商店或事件中删掉或变化掉。
- **打出后去向 (card_play_destination)**: 
  - `DISCARD_PILE`: 进入弃牌堆。
  - `EXHAUST_PILE`: 物理删除（消耗）。
  - `BANISH_PILE`: 彻底放逐（本局不可见）。
- **打出插入策略 (card_play_destination_strategy)**: 指定进入上述去向时的排列策略，如 `TOP` (顶端)、`BOTTOM` (底端)、`RANDOM` (随机) 或 `SHUFFLE` (洗入)。
- **回合结束去向 (card_end_of_turn_destination)**:
  - `DISCARD_PILE`: 常规弃牌。
  - `EXHAUST_PILE` (配合 `card_is_ethereal = true`): 虚无属性，回合结束没打出就销毁。
  - `HAND_PILE` (配合 `card_is_retained = true`): 保留属性，回合结束不弃牌。
- **回合结束插入策略 (card_end_of_turn_destination_strategy)**: 类似打出插入策略，决定回合结束丢弃时在弃牌堆中的位置。

### 2.4 验证器 (Validators)
- **打出条件 (card_play_validators)**: 必须满足特定条件才能打出（例如：仅当敌人没有护盾时可用）。
- **发光条件 (card_glow_validators)**: 满足条件时手牌会发光提示（例如：打出此牌会触发额外伤害时的连击提示）。

### 2.5 通用行为参数 (Common Action Parameters)
在向生命周期钩子挂载任何动作（如攻击、叠甲）时，都有一些由 `BaseAction.gd` 底层提供的通用参数，你可以直接写入动作的 Dictionary 中：
- `time_delay`: (float) 控制该动作执行后，距离下一个动作开始前的等待时间，设为 `0.0` 即为瞬间执行完毕。
- `action_tags`: (Array[String]) 动作的自定义隐藏标签，便于特定的行为拦截器（Interceptor）精细区分特定的动作分支。
- `target_override`: (整型/枚举) 极其强大，强行无视外层的卡牌目标设定，硬性指定当前动作的独立作用对象。
  - 支持强制选择 `PARENT` (自身), `PLAYER` (玩家), `ALL_COMBATANTS` (全场), `ALL_ENEMIES` (全场敌人), `LEFTMOST_ENEMY` (最左侧敌人), `ENEMY_ID` (结合 `enemy_ids` 使用), `RANDOM_ENEMY` (结合 `rng_name` 使用)。
  - *应用场景*：配合外层的 `card_requires_target=true`，实现“指定打一个单体怪，但同时触发给自身回血”。
- `force_dead_targets`: (bool) 是否允许强行对已死亡的目标执行动作（常规动作会自动过滤死者）。
- `action_short_circuits`: (bool) 控制在战斗胜利（没有活着的敌人）时，是否短路跳过该动作。部分动作（如 `ActionAttack`）默认为 `true` 会自动跳过以防止“鞭尸”和浪费时间，但你可以显式修改此值（比如强制在胜利后仍然触发摸牌或回血）。
- `custom_key_names`: (Dictionary) 如果一张牌里配了多个同类动作，可以通过映射去读取不同的动态数值。如 `{"damage": "damage_2"}`。

---

## 3. 卡牌数值与升级设计

《Slay-The-Robot》采用键值对字典（Dictionary）来管理卡牌数值，这让升级变得非常灵活：

### 3.1 动态数值 (card_values)
在 Slay-The-Robot 中，`card_values` 字典是没有任何硬编码限制的！你可以随意命名键值（Key）。因为任何 Action 都可以通过配置 `custom_key_names` 来读取 `card_values` 里的自定义键。
但在常规设计中，为了规范和方便替换描述，我们通常使用以下内置约定速成的数值参数：
- **`damage`**: 伤害值（供 `ACTION_ATTACK` 读取）
- **`number_of_attacks`**: 攻击次数（供 `ACTION_ATTACK_GENERATOR` 读取实现连击）
- **`block`**: 防火墙/护盾值（供 `ACTION_BLOCK` 读取）
- **`draw_count`**: 抽牌数（供 `ACTION_DRAW` 读取）
- **`status_stacks`**: 施加的状态/Buff 层数（供 `ACTION_APPLY_STATUS` 读取）
- **`energy_amount` / `money_amount`**: 回复的算力值或获取的金钱数
- **`heal_amount`**: 恢复的生命值
- **动态衍生存储**: 比如 `unblocked_damage` (未被格挡的伤害)、`overkill_damage` (溢出伤害)，动作脚本执行后可以反写回 `card_values` 中，供后续 Action 触发吸血等机制。

### 3.2 升级机制 (Upgrades)
通过以下四个核心属性，你可以自由设计卡牌的升级路线（不仅仅是数值强化，甚至可以改变卡牌机制）：

1. **`card_upgrade_amount_max` (升级次数上限)**: 
   控制卡牌可以被升级几次。默认为 1。如果设为大于 1（比如 3 次，或者 999 次无限升级），卡牌的名称后缀会发生自动改变：
   - 第 1 次升级：名字附加 `+`。
   - 第 2 次升级及以后：名字附加 `+1`, `+2` 等。

2. **`card_upgrade_value_improvements` (每次升级线性数值提升)**:
   这是最常用的升级，每次升级时，把这里的数值**累加**到 `card_values` 上。
   - 例：`{"damage": 3, "block": 2}` -> 每次升级伤害+3，护盾+2。

3. **`card_first_upgrade_value_changes` (首次升级数值质变)**:
   在第一次升级时，直接**覆盖替换** `card_values` 的指定数值，而不是累加。
   - 例：将原本随机波动的数值上限覆盖为一个固定值。

4. **`card_first_upgrade_property_changes` (首次升级底层属性质变)**:
   这是极其强大的机制！它会在第一次升级时，通过引擎的 `set()` 方法强行覆盖卡牌的底层属性配置（详见第1、2节的属性）。可用它实现：
   - **减费**: `{"card_energy_cost": 0}` (1费变0费)
   - **改变去向 (去掉消耗)**: `{"card_play_destination": "discard_pile"}` (打出后不再物理删除)
   - **获得保留**: `{"card_is_retained": true}` (回合结束不弃牌)
   - **失去虚无**: `{"card_is_ethereal": false}` (回合结束没打出也不销毁)
   - **改变目标**: `{"card_requires_target": false}` (原本打单体，升级后变成群体AE)
   - **甚至可以改变图片/文字**: `{"card_texture_path": "new_art.png", "card_description": "升级后的船新描述"}`

---

## 4. 附魔设计 (Card Decorators)

附魔（Decorators）是动态附着在卡牌上的插件模块，会改变卡牌的UI（显示边框、增加标签数值）并深度介入卡牌的行为。

### 4.1 附魔全属性配置 (CardDecoratorData)
设计一个附魔时，支持配置以下所有参数：

**UI 与文本配置：**
- **名称与图标 (`card_decorator_name`, `card_decorator_texture_path`)**: 控制附魔本身的 Tooltip 标题和在卡牌上显示的 UI 外框。
- **数值角标 (`card_decorator_label_value_name`)**: 传入一个 `card_values` 中的键名（如 `decorator_value_block`），可以将该数值直接渲染到附魔图标上（例如显示层数）。
- **说明文字 (`card_decorator_description`)**: 鼠标悬浮在附魔图标上时，独立弹出的文字说明。
- **卡牌文本覆写 (`card_decorator_pre_description` / `card_decorator_post_description`)**: 在被附魔的卡牌原本的描述之前/之后，硬插入额外的 bbcode 文本。

**卡牌属性突变机制：**
- **基础数值与属性覆写**: `card_decorator_value_changes` / `card_decorator_value_improvements` / `card_decorator_property_changes`。这与卡牌的升级机制逻辑完全一致，可以瞬间把卡牌减费、变为虚无、或提升伤害。
- **关键词控制**: `card_decorator_add_keyword_ids` (强行塞入新的 Tooltip 词条)，`card_decorator_remove_keyword_ids` (强行抹除卡牌原有的 Tooltip 词条)。

**行为事件拦截钩子 (Action Hooks)：**
- **获取附魔时 (`card_decorator_add_to_card_actions`)**: 当附魔第一次“装载”到卡牌上时立即执行一次动作。
- **卡牌生命周期前后拦截**: 针对卡牌的 打出(play)、丢弃(discard)、回合结束(end_of_turn)、消耗(exhaust)、抽到(draw)、保留(retain)、右键点击(right_click)、战斗开始(initial_combat) **8 大生命周期事件**，附魔都分别提供了 `pre_..._actions` (前置执行) 和 `post_..._actions` (后置执行) 的配置数组。这构成了**堆栈顺序（First-In-First-Out）拦截逻辑**。
- **独立逻辑脚本 (`card_decorator_script_path`)**: 你还可以直接挂载自定义的 `BaseCardDecorator` 继承脚本来写硬编码的系统级监听逻辑。

### 4.2 目前可用的底层附魔实例
在当前原型的 `GlobalProdDataGenerator.gd` 中，已实装以下附魔组件：

| 附魔内部ID | 游戏内名称 | 具体效果 |
| :--- | :--- | :--- |
| `card_decorator_block_on_play` | **防御固化** | 打出时，除了卡牌本身效果外，额外提供防火墙（通过 `pre_play_actions` 实现）。 |
| `card_decorator_remove_exhaust`| **持久运行** | 失去“物理删除”属性（通过 `property_changes` 修改 `play_destination` 为 `DISCARD_PILE`）。 |
| `card_decorator_extra_draw` | **初始加载** | 本局游戏中首次抽到此牌时，额外抽牌（通过 `post_draw_actions` 结合校验器实现）。 |
| `card_decorator_dynamic_cost_modifier` | (动态费用) | 根据战斗状态动态改变本卡的费用。 |
| `card_decorator_dynamic_value_modifier`| (动态数值) | 根据战斗状态动态改变卡牌基础数值（例如每受一次伤，攻击力+1）。 |

*(注：一张卡牌默认的最大可见附魔槽位 `CARD_MAX_DECORATOR_SLOTS` 为 1。)*

### 4.3 编写自定义附魔脚本 (Custom Decorator Scripts)
虽然你可以通过 `CardDecoratorData` 配置很多纯数据的事件钩子，但如果你的附魔需要**监听其他系统的状态变化**（例如：“每当你打出一张其它牌，此牌伤害+1”），你就需要编写专属的 GDScript 并填入 `card_decorator_script_path` 中。

**编写规范与可用 API**：
你的自定义脚本必须继承自 `BaseCardDecorator`。它会在卡牌处于手牌中时生效。
1. **可用成员变量**:
   - `parent_card`: 附魔所在的底层 UI 节点 (`Card`)。
   - `card_data`: 被附魔的卡牌数据，可随时读取或修改 `card_data.card_values`。
   - `decorator_values`: 专门为附魔准备的数值字典，从 `card_data.card_decorators` 获取（如 `{ "bonus_damage": 5 }`），方便你在脚本里做变量控制，避免硬编码。
2. **信号监听与注销 (`_connect_signals`)**:
   - 这是一个可重写（Override）的方法。引擎会在**卡牌进入手牌时**自动调用它。
   - 在这里挂载各种全局信号（如监听其他牌被打出、监听玩家受击）。**切记**由于父类自动管理生命周期，你不需要手动注销这些挂在卡牌上的信号。
   - **设计准则**：在信号回调中**绝对不要直接修改游戏状态**，而是使用 `ActionGenerator` 生成一个 `BaseAction`，然后再扔进 `ActionHandler` 中排队执行。
3. **视觉魔改 (`apply_card_visual_modifications`)**:
   - 这是一个可重写的方法。当附魔需要改变卡牌自身外观（例如根据层数给卡牌上发红光）时，可以在脚本内调用该方法并覆写逻辑。

### 4.4 附魔池机制设计 (Decorator Pools & Filters)
《Slay-The-Robot》的附魔系统支持一套**多对多的动态匹配池化系统**，使得类似“花费金币随机给卡牌附魔”的肉鸽事件得以实现。设计者应当通过这两套池子来控制附魔的发放：

#### ① 随机附魔池 (Random Decorator Pool)
在设计为卡牌添加附魔的行为事件（如 `ActionDecorateCards`）时，可以通过传入 `random_card_decorators` 字典来定义一个池子。
- **机制**：触发动作时，底层逻辑会把池子中的附魔**打乱（Shuffle）**，然后依次拿出来检验是否能打在该卡牌上。**只要碰到第一个合法的附魔，就会成功附魔并结束流程**。
- **作用**：实现了肉鸽游戏里安全又可控的随机附魔体验，且自带保底防错机制。

#### ② 反向池/卡包过滤器 (Card Pack Filter)
给特定的附魔限制适用范围，防止附魔被打在无效卡牌上（如：防止“耐久运行”打在原本就不消耗的卡上）。
在 `CardDecoratorData` 的定义中，可以使用 `card_decorator_card_pack_id` 来限制可以接纳该附魔的卡牌池。

**可用参数（内置卡包 IDs）：**
- `"card_pack_all"`：所有卡牌
- `"card_pack_prismatic"`：所有可抓取的常规卡牌（自动过滤特殊牌、状态、诅咒）
- `"card_pack_red"` / `"card_pack_blue"` / `"card_pack_green"` / `"card_pack_orange"`：限定某一阵营专属牌
- `"card_pack_white"`：限定无色/中立牌

---

## 5. 卡包与过滤器体系 (Card Packs & Filters)

在《Slay-The-Robot》中，卡包（CardPackData）**本质上是一个卡牌过滤器**，用于控制卡牌掉落、生成以及附魔范围。

### 5.1 附魔的“双向池化”匹配机制
这是实现类似“花费金币给卡牌进行肉鸽随机附魔”的核心底层原理：
1. **正向随机池 (Random Decorator Pool)**: 在执行附魔动作（`ActionDecorateCards`）时，系统会收到一个随机池。它会把池子里的附魔**打乱（Shuffle）**，然后依次拿出来检验。**只要碰到第一个合法的附魔，就会成功附魔并结束流程**。
2. **反向过滤器 (`card_decorator_card_pack_id`)**: 给附魔指定一个反向 Card Pack ID（比如限定只能附魔在攻击牌上）。如果是普通辅助牌试图获取这个附魔，哪怕从上面的池子里抽中了，系统也会判定为非法并跳过。

### 5.2 CardPackData 全属性配置参数
当你需要自定义一个过滤卡包时，可以通过配置 `CardPackData.gd` 下的参数实现精确制导：
- **白名单指定 (`card_pack_card_ids`)**: 直接填入字符串数组，强制包含指定的几张牌。
- **颜色过滤 (`card_pack_color_id`)**: 只接纳特定颜色/角色的牌（如 `"color_red"`）。
- **排除非标属性 (`exclude_non_standard_rarities` & `exclude_non_standard_types`)**: 设为 `true`（默认）会自动把“诅咒”、“状态牌”以及“零日(RARE)”等非标卡过滤掉，保证池子干净。
- **全栈式验证器 (`card_pack_validators`)**: 终极过滤手段，可以填入数组字典，使用引擎内所有的 `ValidatorCard...`。比如要求“必定是攻击牌且耗能>=2”。
- **在图鉴中独立展示 (`card_pack_displays_in_codex`)**: 是否作为一个独立的大卡包在玩家的总图鉴菜单中显示。

### 5.3 当前内置的通用卡包 ID
- `"card_pack_all"`：所有卡牌（不过滤任何东西）。
- `"card_pack_prismatic"`：所有可被玩家常规抓取的牌（自动过滤了状态、诅咒等衍生卡）。
- `"card_pack_red" / "blue" / "green" / "orange" / "white"`：各阵营的独立卡牌池。

---

### 结语
设计新卡牌与新机制时，最核心的原则是：**解耦与复用**。
1. **纯数值修改**：使用 `card_values` 和 `card_upgrade_value_improvements`。
2. **特殊条件限制**：使用极其强大的 `validators` 验证器矩阵。
3. **时机触发**：利用丰富的 `_actions` 生命钩子。
4. **机制叠加**：熟练利用 Decorators（附魔）系统及其 Card Pack “双向池化过滤器”进行安全合法的词缀叠加。
