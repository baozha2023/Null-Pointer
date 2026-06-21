# CLAUDE.md

此文件用于在使用本仓库代码时为 Claude Code (claude.ai/code) 提供指南。

## 项目概览

Slay The Robot 是一款使用 **Godot 4.6** 和 GDScript 编写的 Roguelike 卡牌构建框架（类似于《杀戮尖塔》）。它使用了 `gl_compatibility`（兼容性）渲染器。游戏的主要入口场景是 `res://scenes/Root.tscn`。

本项目没有构建（Build）步骤 —— 可以直接在 Godot 编辑器中运行场景。**没有单元测试**；测试是通过运行带有自动生成数据的游戏来完成的。

## 运行游戏

- 在 Godot 4.6 中打开项目并按 F5，或通过 Godot MCP 运行。
- 主场景：`res://scenes/Root.tscn`
- 窗口尺寸：1200×700，不可调整大小。
- 测试数据在启动时由 `GlobalTestDataGenerator.generate_test_data()` 自动生成（在 `Global._ready()` 中调用）。项目不附带任何 JSON 数据文件；游戏数据完全由代码生成。
- 若要将数据导出为 JSON：取消注释 `Global._ready()` 中的 `FileLoader.export_read_only_data()`，运行一次，然后再将其重新注释。
- 若要切换至生产数据：注释掉 `GlobalTestDataGenerator.generate_test_data()`，并取消注释 `GlobalProdDataGenerator.generate_production_data()`。

## GDScript 规范

- **重度静态类型**：所有的 `@export` 属性、函数参数和返回类型都使用了明确的类型注解。数组使用 `Array[Type]`，字典使用 `Dictionary[KeyType, ValueType]`。仅在真正需要时（如序列化值）才使用 `Variant`。
- **数据类必须使用 `class_name`**：模式驱动（Schema-driven）的序列化系统（`SerializableData._build_serializable_script_cache()`）在运行时通过 `ProjectSettings.get_global_class_list()` 将类名映射到脚本。任何新的数据类型**必须**声明与文件名一致的 `class_name`。
- **文件命名**：贯穿全项目使用 PascalCase（大驼峰命名法）。Action（行动）带有 `Action` 前缀，Validator（验证器）带有 `Validator` 前缀，Interceptor（拦截器）带有 `Interceptor` 前缀，数据类带有 `Data` 后缀。文件名始终与 `class_name` 匹配。
- **自动加载（Autoloads）使用 `*` 前缀**（在 `project.godot` 中，即单例模式，在任何场景之前加载）。

## 架构

### 项目目录结构

`	ext
Slay-The-Robot/
├── .gitattributes                                                    # 辅助脚本或场景资源
├── .gitignore                                                        # 辅助脚本或场景资源
├── CLAUDE.md                                                         # 辅助脚本或场景资源
├── LICENSE                                                           # 辅助脚本或场景资源
├── README.md                                                         # 辅助脚本或场景资源
├── animations/
│   ├── Combatant.res                                                 # 辅助脚本或场景资源
│   ├── Enemy.res                                                     # 辅助脚本或场景资源
│   └── Player.res                                                    # 辅助脚本或场景资源
├── autoload/
│   ├── ActionGenerator.gd                                            # 动态工厂类，负责把静态的配置数据解析并生成具体的 Action 实例层级树
│   ├── ActionHandler.gd                                              # Action 堆栈与队列处理器（管理一切行为指令的排队、执行顺序与状态拦截）
│   ├── DebugLogger.gd                                                # 集中式控制台日志记录器，方便统一分发与追踪 Bug
│   ├── FileLoader.gd                                                 # 外部系统管理器（负责贴图音频读取、进度存档序列化、Mod 加载与数据缓存）
│   ├── Global.gd                                                     # 中央数据枢纽、状态管理与模式生成，贯穿全局的单例
│   ├── GlobalProdDataGenerator.gd                                    # 面向正式玩家的生产环境数据生成器（注入真正的设计卡牌与角色配置）
│   ├── GlobalTestDataGenerator.gd                                    # 面向开发者的测试环境数据生成器（仅供测试验证机制的白板和占位符数据）
│   ├── HandManager.gd                                                # 玩家手牌区域状态控制与打出请求管理器
│   ├── Random.gd                                                     # 全局确定性随机数生成器（通过玩家种子分为不同的 RNG 轨道，防 SL 污染）
│   ├── Scenes.gd                                                     # 全局 UI 与战斗场景 PackedScene 预加载注册表（避免重复实例化开销）
│   ├── Scripts.gd                                                    # 全局硬编码脚本路径静态变量表（确保跨文件引用时不写错路径）
│   ├── Signals.gd                                                    # 全局统一的事件总线中心，包含 CustomSignal 的动态监听分发逻辑
│   └── StatsHandler.gd                                               # 玩家数据追踪器（跟踪并持久化每回合、单局战斗、以及整个 Run 进程的统计数据）
├── data/
│   ├── CardPlayRequest.gd                                            # 辅助脚本或场景资源
│   ├── PrototypeData.gd                                              # 辅助脚本或场景资源
│   ├── SerializableData.gd                                           # 支持递归 Schema 解析与自动序列化/反序列化的终极数据底层基类
│   ├── filters/
│   │   ├── ArtifactFilter.gd                                         # 数据仓库查询过滤器（支持链式调用的规则检索引擎，用于精准抓取特定的 Artifact 列表）
│   │   ├── CardFilter.gd                                             # 数据仓库查询过滤器（支持链式调用的规则检索引擎，用于精准抓取特定的 Card 列表）
│   │   └── ConsumableFilter.gd                                       # 数据仓库查询过滤器（支持链式调用的规则检索引擎，用于精准抓取特定的 Consumable 列表）
│   ├── mutable/
│   │   ├── CombatStatsData.gd                                        # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：CombatStats）
│   │   ├── LocationData.gd                                           # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：Location）
│   │   ├── ProfileData.gd                                            # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：Profile）
│   │   ├── RunStatsData.gd                                           # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：RunStats）
│   │   ├── ShopData.gd                                               # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：Shop）
│   │   └── UserSettingsData.gd                                       # 游戏内高频读写的状态容器（承载着玩家实时的局内或局外持久化数据：UserSettings）
│   ├── prototype/
│   │   ├── ArtifactData.gd                                           # 核心只读模板数据（会被深度克隆为实例以供游戏进程独立修改的Artifact底层数据模型）
│   │   ├── CardData.gd                                               # 核心只读模板数据（会被深度克隆为实例以供游戏进程独立修改的Card底层数据模型）
│   │   ├── EnemyData.gd                                              # 核心只读模板数据（会被深度克隆为实例以供游戏进程独立修改的Enemy底层数据模型）
│   │   └── PlayerData.gd                                             # 核心只读模板数据（会被深度克隆为实例以供游戏进程独立修改的Player底层数据模型）
│   └── readonly/
│       ├── ActData.gd                                                # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Act）
│       ├── ActionInterceptorData.gd                                  # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：ActionInterceptor）
│       ├── AnimationData.gd                                          # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Animation）
│       ├── ArtifactPackData.gd                                       # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：ArtifactPack）
│       ├── CardDecoratorData.gd                                      # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：CardDecorator）
│       ├── CardPackData.gd                                           # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：CardPack）
│       ├── CharacterData.gd                                          # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Character）
│       ├── ColorData.gd                                              # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Color）
│       ├── ConsumableData.gd                                         # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Consumable）
│       ├── ConsumablePackData.gd                                     # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：ConsumablePack）
│       ├── DialogueData.gd                                           # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Dialogue）
│       ├── EventData.gd                                              # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Event）
│       ├── EventPoolData.gd                                          # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：EventPool）
│       ├── KeywordData.gd                                            # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：Keyword）
│       ├── RestActionData.gd                                         # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：RestAction）
│       ├── RunModifierData.gd                                        # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：RunModifier）
│       ├── RunStartOptionData.gd                                     # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：RunStartOption）
│       ├── StatusEffectData.gd                                       # 固化的字典型配置枚举（为游戏提供不可变的基础信息映射表：StatusEffect）
│       ├── embedded/
│       │   ├── DialogueOptionData.gd                                 # 辅助脚本或场景资源
│       │   ├── DialogueStateData.gd                                  # 辅助脚本或场景资源
│       │   └── EnemyIntentData.gd                                    # 辅助脚本或场景资源
│       └── modding/
│           ├── CustomSignal.gd                                       # 辅助脚本或场景资源
│           ├── CustomSignalData.gd                                   # 辅助脚本或场景资源
│           ├── CustomUIData.gd                                       # 辅助脚本或场景资源
│           ├── ModData.gd                                            # 辅助脚本或场景资源
│           └── ModListData.gd                                        # 辅助脚本或场景资源
├── export_presets.cfg                                                # 辅助脚本或场景资源
├── generate_commented_tree.py                                        # 辅助脚本或场景资源
├── generate_tree.py                                                  # 辅助脚本或场景资源
├── icon.svg                                                          # 辅助脚本或场景资源
├── prod_test_switch_guide.md                                         # 辅助脚本或场景资源
├── replace_tree.py                                                   # 辅助脚本或场景资源
├── scenes/
│   ├── Root.tscn                                                     # 游戏最高层级入口场景（负责挂载并切换主菜单与游戏进程主界面）
│   ├── combatants/
│   │   ├── AnimatedCombatEffect.tscn                                 # 场上战斗单位的通用控制逻辑或表现特效：AnimatedCombatEffect
│   │   ├── BaseCombatant.tscn                                        # 场上战斗单位的通用控制逻辑或表现特效：BaseCombatant
│   │   ├── Enemy.tscn                                                # 敌方实体行为框架（驱动 AI 意图判定、受击动画与生命值反馈）
│   │   ├── HealthLayer.tscn                                          # 多层血条/护盾复合渲染组件
│   │   ├── LayeredHealthBar.tscn                                     # 多层血条/护盾复合渲染组件
│   │   ├── Player.tscn                                               # 玩家实体受控框架（控制自身状态显示、拦截器注册与被击表现）
│   │   ├── SpeechBubble.tscn                                         # 场上战斗单位的通用控制逻辑或表现特效：SpeechBubble
│   │   ├── StatusEffect.tscn                                         # 场上战斗单位的通用控制逻辑或表现特效：StatusEffect
│   │   └── fades/
│   │       ├── ArtifactFade.tscn                                     # 场上战斗单位的通用控制逻辑或表现特效：ArtifactFade
│   │       ├── ImageFade.tscn                                        # 场上战斗单位的通用控制逻辑或表现特效：ImageFade
│   │       └── TextFade.tscn                                         # 场上战斗单位的通用控制逻辑或表现特效：TextFade
│   └── ui/
│       ├── Artifact.tscn                                             # 用户界面底层通用控件或逻辑绑定：Artifact
│       ├── CharacterSelectionButton.tscn                             # 用户界面底层通用控件或逻辑绑定：CharacterSelectionButton
│       ├── ConsumableButton.tscn                                     # 用户界面底层通用控件或逻辑绑定：ConsumableButton
│       ├── CustomRunModifierCheckbox.tscn                            # 用户界面底层通用控件或逻辑绑定：CustomRunModifierCheckbox
│       ├── MapLocation.tscn                                          # 探索地图渲染层（生成路径连线、高亮当前节点与控制地图卷动）
│       ├── RestActionButton.tscn                                     # 用户界面底层通用控件或逻辑绑定：RestActionButton
│       ├── card/
│       │   ├── Card.tscn                                             # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── CardDecorator.tscn                                    # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   └── CardTrail.tscn                                        # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       ├── codex/
│       │   ├── CodexActNameLabel.tscn                                # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       │   ├── CodexArtifact.tscn                                    # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       │   ├── CodexCardPackButton.tscn                              # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       │   ├── CodexConsumable.tscn                                  # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       │   ├── CodexEnemyButton.tscn                                 # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       │   └── CodexEnemyIntent.tscn                                 # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│       ├── custom/
│       │   ├── BaseCustomUI.tscn                                     # 用户界面底层通用控件或逻辑绑定：BaseCustomUI
│       │   └── CustomUISeeTopOfDrawPile.tscn                         # 用户界面底层通用控件或逻辑绑定：CustomUISeeTopOfDrawPile
│       ├── general/
│       │   ├── DialogueOption.tscn                                   # 用户界面底层通用控件或逻辑绑定：DialogueOption
│       │   └── KeywordTooltip.tscn                                   # 用户界面底层通用控件或逻辑绑定：KeywordTooltip
│       ├── profile/
│       │   └── CharacterStat.tscn                                    # 用户界面底层通用控件或逻辑绑定：CharacterStat
│       ├── rewards/
│       │   ├── ArtifactRewardButton.tscn                             # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│       │   ├── BaseRewardButton.tscn                                 # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│       │   ├── CardRewardButton.tscn                                 # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│       │   └── MoneyRewardButton.tscn                                # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│       ├── run_summary/
│       │   └── RunHistoryCard.tscn                                   # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       └── shop/
│           ├── ArtifactShopButton.tscn                               # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│           ├── BaseShopButton.tscn                                   # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│           ├── CardDraftShopButton.tscn                              # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│           ├── CardRemovalShopButton.tscn                            # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│           ├── CardShopButton.tscn                                   # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│           └── ConsumableShopButton.tscn                             # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
├── scripts/
│   ├── Root.gd                                                       # 游戏最高层级入口场景（负责挂载并切换主菜单与游戏进程主界面）
│   ├── action_interceptors/
│   │   ├── ActionInterceptorProcessor.gd                             # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── BaseActionInterceptor.gd                                  # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorCapDamage.gd                                   # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorConsumableAutoRevive.gd                        # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorDamageFromBlock.gd                             # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorDamageFromOvershield.gd                        # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorDamageIncrease.gd                              # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorDuplicateAttacks.gd                            # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorDuplicateCardPlays.gd                          # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorIncreaseTurnDraw.gd                            # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorNegateAddMoney.gd                              # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorNegateDamage.gd                                # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorNegateDebuff.gd                                # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorNextAttackFree.gd                              # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorOvershield.gd                                  # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorPointy.gd                                      # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorPreserveBlock.gd                               # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorPreserveEnergy.gd                              # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorReboundCardPlays.gd                            # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorTempPreserveBlock.gd                           # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorVulnerable.gd                                  # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   ├── InterceptorWeaken.gd                                      # 行为拦截器（用于在动作结算前动态注入状态效果、遗物带来的动作变异与劫持）
│   │   └── status_effect_decay_interceptors/
│   │       ├── InterceptorBaseNegateStatusDecay.gd                   # 辅助脚本或场景资源
│   │       └── InterceptorPreserveOvershield.gd                      # 辅助脚本或场景资源
│   ├── actions/
│   │   ├── BaseAction.gd                                             # 构成游戏生命周期的基础行动指令：Base
│   │   ├── BaseAsyncAction.gd                                        # 构成游戏生命周期的基础行动指令：BaseAsync
│   │   ├── artifact_actions/
│   │   │   ├── ActionChangeArtifactCharge.gd                         # 构成游戏生命周期的基础行动指令：ChangeArtifactCharge
│   │   │   ├── ActionChangeArtifactEnabled.gd                        # 构成游戏生命周期的基础行动指令：ChangeArtifactEnabled
│   │   │   └── ActionIncreaseArtifactCharge.gd                       # 构成游戏生命周期的基础行动指令：IncreaseArtifactCharge
│   │   ├── audio_actions/
│   │   │   ├── ActionPlayMusic.gd                                    # 构成游戏生命周期的基础行动指令：PlayMusic
│   │   │   └── ActionPlaySound.gd                                    # 构成游戏生命周期的基础行动指令：PlaySound
│   │   ├── card_actions/
│   │   │   ├── card_play_actions/
│   │   │   │   ├── ActionCardPlay.gd                                 # 辅助脚本或场景资源
│   │   │   │   ├── ActionCardPlayEnd.gd                              # 辅助脚本或场景资源
│   │   │   │   └── ActionChangeCardPlayDestination.gd                # 辅助脚本或场景资源
│   │   │   ├── cardset_actions/
│   │   │   │   ├── ActionAddCardsToDeck.gd                           # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddCardsToDraw.gd                           # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddCardsToHand.gd                           # 辅助脚本或场景资源
│   │   │   │   ├── ActionAttachCardsOntoEnemy.gd                     # 辅助脚本或场景资源
│   │   │   │   ├── ActionBanishCards.gd                              # 辅助脚本或场景资源
│   │   │   │   ├── ActionChangeCardEnergies.gd                       # 辅助脚本或场景资源
│   │   │   │   ├── ActionChangeCardProperties.gd                     # 辅助脚本或场景资源
│   │   │   │   ├── ActionChangeCardValues.gd                         # 辅助脚本或场景资源
│   │   │   │   ├── ActionClampCardValues.gd                          # 辅助脚本或场景资源
│   │   │   │   ├── ActionDecorateCards.gd                            # 辅助脚本或场景资源
│   │   │   │   ├── ActionDiscardCards.gd                             # 辅助脚本或场景资源
│   │   │   │   ├── ActionExhaustCards.gd                             # 辅助脚本或场景资源
│   │   │   │   ├── ActionImproveCardValues.gd                        # 辅助脚本或场景资源
│   │   │   │   ├── ActionImproveCardValuesUnusedEnergy.gd            # 辅助脚本或场景资源
│   │   │   │   ├── ActionMoveCardsToLimbo.gd                         # 辅助脚本或场景资源
│   │   │   │   ├── ActionPlayCards.gd                                # 辅助脚本或场景资源
│   │   │   │   ├── ActionRandomizeCardEnergies.gd                    # 辅助脚本或场景资源
│   │   │   │   ├── ActionRemoveCardsFromDeck.gd                      # 辅助脚本或场景资源
│   │   │   │   ├── ActionRetainCards.gd                              # 辅助脚本或场景资源
│   │   │   │   ├── ActionSwapHandCards.gd                            # 辅助脚本或场景资源
│   │   │   │   ├── ActionTransformCards.gd                           # 辅助脚本或场景资源
│   │   │   │   ├── ActionUpgradeCards.gd                             # 辅助脚本或场景资源
│   │   │   │   └── BaseCardsetAction.gd                              # 辅助脚本或场景资源
│   │   │   └── pick_card_actions/
│   │   │       ├── ActionBasePickCards.gd                            # 辅助脚本或场景资源
│   │   │       ├── ActionCreateCards.gd                              # 辅助脚本或场景资源
│   │   │       ├── ActionPickCards.gd                                # 辅助脚本或场景资源
│   │   │       ├── ActionPickDuplicateCards.gd                       # 辅助脚本或场景资源
│   │   │       └── ActionPickUpgradeCards.gd                         # 辅助脚本或场景资源
│   │   ├── combatant_actions/
│   │   │   ├── ActionAddHealth.gd                                    # 构成游戏生命周期的基础行动指令：AddHealth
│   │   │   ├── ActionAttack.gd                                       # 构成游戏生命周期的基础行动指令：Attack
│   │   │   ├── ActionAttackGenerator.gd                              # 构成游戏生命周期的基础行动指令：AttackGenerator
│   │   │   ├── ActionBlock.gd                                        # 构成游戏生命周期的基础行动指令：Block
│   │   │   ├── ActionCreateEffectAnimation.gd                        # 构成游戏生命周期的基础行动指令：CreateEffectAnimation
│   │   │   ├── ActionDeath.gd                                        # 构成游戏生命周期的基础行动指令：Death
│   │   │   ├── ActionDirectDamage.gd                                 # 构成游戏生命周期的基础行动指令：DirectDamage
│   │   │   ├── ActionHealPercent.gd                                  # 构成游戏生命周期的基础行动指令：HealPercent
│   │   │   ├── ActionPlayAnimation.gd                                # 构成游戏生命周期的基础行动指令：PlayAnimation
│   │   │   ├── ActionResetBlock.gd                                   # 构成游戏生命周期的基础行动指令：ResetBlock
│   │   │   ├── ActionSetHealth.gd                                    # 构成游戏生命周期的基础行动指令：SetHealth
│   │   │   ├── ActionTalk.gd                                         # 构成游戏生命周期的基础行动指令：Talk
│   │   │   ├── enemy_actions/
│   │   │   │   ├── ActionCycleEnemyIntent.gd                         # 辅助脚本或场景资源
│   │   │   │   └── ActionSummonEnemies.gd                            # 辅助脚本或场景资源
│   │   │   ├── player_actions/
│   │   │   │   ├── ActionAddArtifact.gd                              # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddArtifactsFromPool.gd                     # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddConsumable.gd                            # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddEnergy.gd                                # 辅助脚本或场景资源
│   │   │   │   ├── ActionAddMoney.gd                                 # 辅助脚本或场景资源
│   │   │   │   ├── ActionConsumable.gd                               # 辅助脚本或场景资源
│   │   │   │   ├── ActionDraw.gd                                     # 辅助脚本或场景资源
│   │   │   │   ├── ActionDrawGenerator.gd                            # 辅助脚本或场景资源
│   │   │   │   ├── ActionEndTurn.gd                                  # 辅助脚本或场景资源
│   │   │   │   ├── ActionResetEnergy.gd                              # 辅助脚本或场景资源
│   │   │   │   ├── ActionReshuffle.gd                                # 辅助脚本或场景资源
│   │   │   │   ├── ActionSwapBossArtifact.gd                         # 辅助脚本或场景资源
│   │   │   │   ├── ActionUpdateCardDrafts.gd                         # 辅助脚本或场景资源
│   │   │   │   ├── ActionUpdateConsumableDrafts.gd                   # 辅助脚本或场景资源
│   │   │   │   ├── ActionUpdatePlayerValue.gd                        # 辅助脚本或场景资源
│   │   │   │   ├── ActionUpdateRestActions.gd                        # 辅助脚本或场景资源
│   │   │   │   └── ActionUseConsumable.gd                            # 辅助脚本或场景资源
│   │   │   └── status_actions/
│   │   │       ├── ActionApplyStatus.gd                              # 辅助脚本或场景资源
│   │   │       ├── ActionBlockToStatus.gd                            # 辅助脚本或场景资源
│   │   │       ├── ActionDecayStatus.gd                              # 辅助脚本或场景资源
│   │   │       └── ActionMultiplyStatus.gd                           # 辅助脚本或场景资源
│   │   ├── custom_actions/
│   │   │   ├── ActionCustomUI.gd                                     # 构成游戏生命周期的基础行动指令：CustomUI
│   │   │   └── ActionEmitCustomSignal.gd                             # 构成游戏生命周期的基础行动指令：EmitCustomSignal
│   │   ├── debug_actions/
│   │   │   └── ActionDebugLog.gd                                     # 构成游戏生命周期的基础行动指令：DebugLog
│   │   ├── meta_actions/
│   │   │   ├── ActionRandomSelection.gd                              # 构成游戏生命周期的基础行动指令：RandomSelection
│   │   │   ├── ActionValidator.gd                                    # 构成游戏生命周期的基础行动指令：Validator
│   │   │   ├── ActionVariableActionGenerator.gd                      # 构成游戏生命周期的基础行动指令：VariableGenerator
│   │   │   ├── ActionVariableCardsetModifier.gd                      # 卡牌控制行为（执行发牌、洗牌、弃牌、烧毁或生成卡牌的操作）
│   │   │   ├── ActionVariableCombatStatsModifier.gd                  # 构成游戏生命周期的基础行动指令：VariableCombatStatsModifier
│   │   │   └── ActionVariableCostModifier.gd                         # 构成游戏生命周期的基础行动指令：VariableCostModifier
│   │   ├── rewards/
│   │   │   ├── ActionClearRewards.gd                                 # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   │   └── ActionGrantRewards.gd                                 # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   ├── shop_actions/
│   │   │   ├── ActionShopPopulateItems.gd                            # 构成游戏生命周期的基础行动指令：ShopPopulateItems
│   │   │   └── ActionShopPurchaseItems.gd                            # 构成游戏生命周期的基础行动指令：ShopPurchaseItems
│   │   ├── world_generation_actions/
│   │   │   └── ActionGenerateAct.gd                                  # 构成游戏生命周期的基础行动指令：GenerateAct
│   │   └── world_interaction_actions/
│   │       ├── ActionOpenChest.gd                                    # 构成游戏生命周期的基础行动指令：OpenChest
│   │       ├── ActionRestActionEnd.gd                                # 构成游戏生命周期的基础行动指令：RestEnd
│   │       ├── ActionStartCombat.gd                                  # 构成游戏生命周期的基础行动指令：StartCombat
│   │       └── ActionVisitLocation.gd                                # 构成游戏生命周期的基础行动指令：VisitLocation
│   ├── artifacts/
│   │   ├── ArtifactBlockOnAttacks.gd                                 # 外设插件（遗物）特性被动技能实现（处理获取后的全局效果挂载）
│   │   ├── ArtifactDrawOnKill.gd                                     # 外设插件（遗物）特性被动技能实现（处理获取后的全局效果挂载）
│   │   ├── ArtifactEasyMode.gd                                       # 外设插件（遗物）特性被动技能实现（处理获取后的全局效果挂载）
│   │   ├── ArtifactRetainHand.gd                                     # 外设插件（遗物）特性被动技能实现（处理获取后的全局效果挂载）
│   │   └── BaseArtifact.gd                                           # 外设插件（遗物）特性被动技能实现（处理获取后的全局效果挂载）
│   ├── card_decorators/
│   │   ├── BaseCardDecorator.gd                                      # 辅助脚本或场景资源
│   │   ├── CardDecoratorDynamicCostModifier.gd                       # 辅助脚本或场景资源
│   │   └── CardDecoratorDynamicValueModifier.gd                      # 辅助脚本或场景资源
│   ├── combatants/
│   │   ├── AnimatedCombatEffect.gd                                   # 场上战斗单位的通用控制逻辑或表现特效：AnimatedCombatEffect
│   │   ├── BaseCombatant.gd                                          # 场上战斗单位的通用控制逻辑或表现特效：BaseCombatant
│   │   ├── Enemy.gd                                                  # 敌方实体行为框架（驱动 AI 意图判定、受击动画与生命值反馈）
│   │   ├── HealthLayer.gd                                            # 多层血条/护盾复合渲染组件
│   │   ├── LayeredHealthBar.gd                                       # 多层血条/护盾复合渲染组件
│   │   ├── Player.gd                                                 # 玩家实体受控框架（控制自身状态显示、拦截器注册与被击表现）
│   │   ├── SpeechBubble.gd                                           # 场上战斗单位的通用控制逻辑或表现特效：SpeechBubble
│   │   ├── StatusEffect.gd                                           # 场上战斗单位的通用控制逻辑或表现特效：StatusEffect
│   │   └── fades/
│   │       ├── ArtifactFade.gd                                       # 场上战斗单位的通用控制逻辑或表现特效：ArtifactFade
│   │       ├── ImageFade.gd                                          # 场上战斗单位的通用控制逻辑或表现特效：ImageFade
│   │       └── TextFade.gd                                           # 场上战斗单位的通用控制逻辑或表现特效：TextFade
│   ├── run_modifiers/
│   │   ├── BaseRunModifier.gd                                        # 影响全局游戏进程框架的修改器基类：Base
│   │   ├── custom/
│   │   │   ├── RunModifierCustomDraftAllColors.gd                    # 用户界面底层通用控件或逻辑绑定：RunModifierCustomDraftAllColors
│   │   │   ├── RunModifierCustomEasyMode.gd                          # 用户界面底层通用控件或逻辑绑定：RunModifierCustomEasyMode
│   │   │   └── RunModifierCustomEndlessMode.gd                       # 用户界面底层通用控件或逻辑绑定：RunModifierCustomEndlessMode
│   │   └── difficulties/
│   │       ├── RunModifierDifficulty1.gd                             # 全局进阶难度设定层（全局削弱玩家或增强敌人的困难词缀）
│   │       ├── RunModifierDifficulty2.gd                             # 全局进阶难度设定层（全局削弱玩家或增强敌人的困难词缀）
│   │       ├── RunModifierDifficulty3.gd                             # 全局进阶难度设定层（全局削弱玩家或增强敌人的困难词缀）
│   │       ├── RunModifierDifficulty4.gd                             # 全局进阶难度设定层（全局削弱玩家或增强敌人的困难词缀）
│   │       └── RunModifierDifficulty5.gd                             # 全局进阶难度设定层（全局削弱玩家或增强敌人的困难词缀）
│   ├── status_effects/
│   │   ├── BaseStatusEffect.gd                                       # 战斗内异常状态处理逻辑（管理层数的叠加、衰减、以及相应的拦截器触发）
│   │   ├── StatusEffectAttachedCard.gd                               # 战斗内异常状态处理逻辑（管理层数的叠加、衰减、以及相应的拦截器触发）
│   │   ├── StatusEffectDuplicateCardPlays.gd                         # 战斗内异常状态处理逻辑（管理层数的叠加、衰减、以及相应的拦截器触发）
│   │   ├── StatusEffectFeedbackLoop.gd                               # 战斗内异常状态处理逻辑（管理层数的叠加、衰减、以及相应的拦截器触发）
│   │   └── StatusEffectTimedStatus.gd                                # 战斗内异常状态处理逻辑（管理层数的叠加、衰减、以及相应的拦截器触发）
│   ├── ui/
│   │   ├── Artifact.gd                                               # 用户界面底层通用控件或逻辑绑定：Artifact
│   │   ├── ArtifactContainer.gd                                      # 用户界面底层通用控件或逻辑绑定：ArtifactContainer
│   │   ├── CardDraftSelectionOverlay.gd                              # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   ├── CardSelectionOverlay.gd                                   # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   ├── CharacterSelectionButton.gd                               # 用户界面底层通用控件或逻辑绑定：CharacterSelectionButton
│   │   ├── Chest.gd                                                  # 用户界面底层通用控件或逻辑绑定：Chest
│   │   ├── Combat.gd                                                 # 战斗系统主状态机（纯信号驱动，控制回合交替与战斗生命周期）
│   │   ├── CombatEndTurn.gd                                          # 用户界面底层通用控件或逻辑绑定：CombatEndTurn
│   │   ├── ConsumableButton.gd                                       # 用户界面底层通用控件或逻辑绑定：ConsumableButton
│   │   ├── Consumables.gd                                            # 用户界面底层通用控件或逻辑绑定：Consumables
│   │   ├── CustomRunModifierCheckbox.gd                              # 用户界面底层通用控件或逻辑绑定：CustomRunModifierCheckbox
│   │   ├── DialogueOverlay.gd                                        # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── EnemyContainer.gd                                         # 用户界面底层通用控件或逻辑绑定：EnemyContainer
│   │   ├── Hand.gd                                                   # 用户界面底层通用控件或逻辑绑定：Hand
│   │   ├── Map.gd                                                    # 探索地图渲染层（生成路径连线、高亮当前节点与控制地图卷动）
│   │   ├── MapLocation.gd                                            # 探索地图渲染层（生成路径连线、高亮当前节点与控制地图卷动）
│   │   ├── PauseButton.gd                                            # 用户界面底层通用控件或逻辑绑定：PauseButton
│   │   ├── PauseOverlay.gd                                           # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── RestActionButton.gd                                       # 用户界面底层通用控件或逻辑绑定：RestActionButton
│   │   ├── RestOverlay.gd                                            # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── RewardOverlay.gd                                          # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   ├── RunStartOptions.gd                                        # 用户界面底层通用控件或逻辑绑定：RunStartOptions
│   │   ├── RunSummaryOverlay.gd                                      # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── RunTimer.gd                                               # 用户界面底层通用控件或逻辑绑定：RunTimer
│   │   ├── Shop.gd                                                   # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   │   ├── ShopOverlay.gd                                            # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   │   ├── Tooltips.gd                                               # 用户界面底层通用控件或逻辑绑定：Tooltips
│   │   ├── TurnOverlay.gd                                            # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── card/
│   │   │   ├── Card.gd                                               # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   │   ├── CardDecorator.gd                                      # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   │   └── CardTrail.gd                                          # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   ├── codex/
│   │   │   ├── CodexActNameLabel.gd                                  # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexArtifact.gd                                      # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexArtifactMenu.gd                                  # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexCardPackButton.gd                                # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexCardsMenu.gd                                     # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexConsumable.gd                                    # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexConsumablesMenu.gd                               # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexEnemiesMenu.gd                                   # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── CodexEnemyButton.gd                                   # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   └── CodexEnemyIntent.gd                                   # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   ├── custom/
│   │   │   ├── BaseCustomUI.gd                                       # 用户界面底层通用控件或逻辑绑定：BaseCustomUI
│   │   │   └── CustomUISeeTopOfDrawPile.gd                           # 用户界面底层通用控件或逻辑绑定：CustomUISeeTopOfDrawPile
│   │   ├── general/
│   │   │   ├── DialogueOption.gd                                     # 用户界面底层通用控件或逻辑绑定：DialogueOption
│   │   │   ├── KeywordContainer.gd                                   # 用户界面底层通用控件或逻辑绑定：KeywordContainer
│   │   │   └── KeywordTooltip.gd                                     # 用户界面底层通用控件或逻辑绑定：KeywordTooltip
│   │   ├── menus/
│   │   │   ├── BaseMenu.gd                                           # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── CodexMenu.gd                                          # 百科图鉴详情组件（支持按类别分页查阅卡牌、插件与敌人数据）
│   │   │   ├── MainMenu.gd                                           # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── NewRunMenu.gd                                         # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── ProfileStatsMenu.gd                                   # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── RunHistoryMenu.gd                                     # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── RunScreen.gd                                          # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   ├── SettingsMenu.gd                                       # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   │   └── TitleScreen.gd                                        # 全屏或半透明覆盖的 UI 面板（控制界面呼出、隐藏及基础输入拦截）
│   │   ├── outline.gdshader                                          # 用户界面底层通用控件或逻辑绑定：outlineshader
│   │   ├── profile/
│   │   │   └── CharacterStat.gd                                      # 用户界面底层通用控件或逻辑绑定：CharacterStat
│   │   ├── rewards/
│   │   │   ├── ArtifactRewardButton.gd                               # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   │   ├── BaseRewardButton.gd                                   # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   │   ├── CardRewardButton.gd                                   # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   │   └── MoneyRewardButton.gd                                  # 战后结算界面组件（控制卡牌三选一、掉落插件、资金获取的显示与选择）
│   │   ├── run_summary/
│   │   │   └── RunHistoryCard.gd                                     # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│   │   └── shop/
│   │       ├── ArtifactShopButton.gd                                 # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   │       ├── BaseShopButton.gd                                     # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   │       ├── CardShopButton.gd                                     # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   │       └── ConsumableShopButton.gd                               # 商店交易交互组件（控制商品陈列、价格计算与点击购买逻辑）
│   └── validators/
│       ├── BaseValidator.gd                                          # 执行逻辑判断的通用条件验证器：Base
│       ├── ValidatorCombatStats.gd                                   # 执行逻辑判断的通用条件验证器：CombatStats
│       ├── ValidatorEnemyAttacking.gd                                # 敌方单位状态规则（判断敌人行为意图或类别是否符合要求）
│       ├── ValidatorEnemyType.gd                                     # 敌方单位状态规则（判断敌人行为意图或类别是否符合要求）
│       ├── ValidatorHasArtifact.gd                                   # 执行逻辑判断的通用条件验证器：HasArtifact
│       ├── ValidatorInCombat.gd                                      # 执行逻辑判断的通用条件验证器：InCombat
│       ├── ValidatorLocationType.gd                                  # 执行逻辑判断的通用条件验证器：LocationType
│       ├── ValidatorMoney.gd                                         # 执行逻辑判断的通用条件验证器：Money
│       ├── ValidatorPlayerCharacter.gd                               # 玩家自身状态规则（判断完整度/血量、所属角色等）
│       ├── ValidatorPlayerHealth.gd                                  # 玩家自身状态规则（判断完整度/血量、所属角色等）
│       ├── ValidatorPlayerTurn.gd                                    # 玩家自身状态规则（判断完整度/血量、所属角色等）
│       ├── ValidatorRNG.gd                                           # 执行逻辑判断的通用条件验证器：RNG
│       ├── ValidatorRunModifier.gd                                   # 执行逻辑判断的通用条件验证器：RunModifier
│       ├── ValidatorRunStats.gd                                      # 执行逻辑判断的通用条件验证器：RunStats
│       ├── ValidatorTurnCount.gd                                     # 执行逻辑判断的通用条件验证器：TurnCount
│       ├── card/
│       │   ├── ValidatorCardColor.gd                                 # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardDraftable.gd                             # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardEnergyCost.gd                            # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardHasDecorator.gd                          # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardID.gd                                    # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardIsDecoratable.gd                         # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardLocation.gd                              # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardProperties.gd                            # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardRarity.gd                                # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardRemovableFromDeck.gd                     # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardTag.gd                                   # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardTransformableFromDeck.gd                 # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardType.gd                                  # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   ├── ValidatorCardUpgradeable.gd                           # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       │   └── ValidatorCardValues.gd                                # 卡牌视觉呈现层（处理拖拽、高亮反馈、附魔特效与轨迹绘制）
│       ├── card_plays/
│       │   ├── ValidatorCardPlayEnemyAttacking.gd                    # 卡牌打出前置规则（校验目标合法性与能量消耗）
│       │   ├── ValidatorCardPlayEnergyInput.gd                       # 卡牌打出前置规则（校验目标合法性与能量消耗）
│       │   └── ValidatorCardPlayIsDuplicated.gd                      # 卡牌打出前置规则（校验目标合法性与能量消耗）
│       ├── deck/
│       │   ├── ValidatorDeckHasDecoratableCard.gd                    # 判断牌库状态的验证规则（例如：牌库是否有可升级的卡牌）
│       │   ├── ValidatorDeckHasRemovableCard.gd                      # 判断牌库状态的验证规则（例如：牌库是否有可升级的卡牌）
│       │   ├── ValidatorDeckHasUpgradeableCard.gd                    # 判断牌库状态的验证规则（例如：牌库是否有可升级的卡牌）
│       │   ├── ValidatorDeckHasValidatedCards.gd                     # 判断牌库状态的验证规则（例如：牌库是否有可升级的卡牌）
│       │   └── ValidatorPileSize.gd                                  # 执行逻辑判断的通用条件验证器：PileSize
│       └── hand/
│           ├── ValidatorCardIDAdjacentInHand.gd                      # 玩家手牌状态规则（校验相邻卡牌的类型或 ID）
│           ├── ValidatorCardPositionInHand.gd                        # 玩家手牌状态规则（校验相邻卡牌的类型或 ID）
│           ├── ValidatorCardTypeAdjacentInHand.gd                    # 玩家手牌状态规则（校验相邻卡牌的类型或 ID）
│           └── ValidatorCardTypeInHand.gd                            # 玩家手牌状态规则（校验相邻卡牌的类型或 ID）
├── shortcuts/
├── temp_tree.txt                                                     # 辅助脚本或场景资源
├── temp_tree_commented.txt                                           # 辅助脚本或场景资源
├── themes/
└── ui/
    └── components/
        ├── resizing_grid_scroll_container/
        │   ├── ResizingGridScrollContainer.gd                        # 辅助脚本或场景资源
        │   └── ResizingGridScrollContainer.tscn                      # 辅助脚本或场景资源
        ├── tooltip/
        │   ├── Tooltip.gd                                            # 辅助脚本或场景资源
        │   └── Tooltip.tscn                                          # 辅助脚本或场景资源
        └── volume_slider/
            ├── VolumeSlider.gd                                       # 辅助脚本或场景资源
            └── VolumeSlider.tscn                                     # 辅助脚本或场景资源
`

### 自动加载单例 (Autoloads) — 完全遵循 project.godot 中的加载顺序

顺序非常重要，因为后加载的单例会依赖先加载的单例。`Global._ready()` 依赖于 `Scripts`、`Scenes`、`FileLoader` 和 `Random` 已经准备就绪。

| 编号 | 单例 | 用途 |
|---|---|---|
| 1 | `Signals` | 全局事件总线 — 这里定义了所有跨系统的信号，以及动态 `CustomSignal`（自定义信号）的管理 |
| 2 | `Scenes` | 核心注册表，存放所有 `PackedScene` 预加载资源（卡牌、敌人、UI 元素等） |
| 3 | `Scripts` | 核心注册表，存放 Action、验证器、拦截器、装饰器和 Run Modifier 的硬编码 `const String` 脚本路径 |
| 4 | `FileLoader` | 外部文件加载（贴图、音频、JSON）、保存/读取、Mod 加载与缓存 |
| 5 | `Random` | 确定性的随机数生成（RNG）工具 — 所有的随机事件都流经基于玩家种子的 RNG 轨道 |
| 6 | `Global` | 中央数据枢纽 — 模式生成、数据查找表、缓存、进程管理、验证器调度 |
| 7 | `GlobalTestDataGenerator` | 通过代码生成测试数据（卡牌、敌人、遗物等） |
| 8 | `GlobalProdDataGenerator` | 通过代码生成生产数据 |
| 9 | `ActionHandler` | Action 堆栈与队列处理器；管理 Action 的执行顺序、时间控制以及拦截 |
| 10 | `ActionGenerator` | 工厂类，用于从数据创建 Action 实例 |
| 11 | `DebugLogger` | 集中式日志记录 |
| 12 | `HandManager` | 管理玩家的手牌 |
| 13 | `SoundManager` | 音频播放（基于插件，注册为 `uid://`） |
| 14 | `StatsHandler` | 追踪每回合、每次战斗、每局游戏的统计数据；管理档案的保存/读取 |

### 数据层 (`data/`)

所有数据类都继承自 **`SerializableData`**（扩展自 Godot `Resource`）。只有带有 `@export` 注解的属性才会被序列化/加载。该系统支持递归的嵌套序列化。

- **`data/prototype/`** — 只读模板数据（CardData、ArtifactData、EnemyData、PlayerData）。使用 `.get_prototype(true)` 来创建可变的副本。
- **`data/readonly/`** — 不可变的查找数据（ActData、EventData、DialogueData、KeywordData、ColorData、StatusEffectData、RunModifierData、CustomSignalData、CharacterData、Mod 配置等）。
- **`data/mutable/`** — 运行时可变的数据（PlayerData、CombatStatsData、RunStatsData、ShopData、LocationData、ProfileData、UserSettingsData）。
- **`data/filters/`** — CardFilter、ArtifactFilter、ConsumableFilter — 内容包使用它们来查询和缓存过滤后的子集。
- **`data/SerializableData.gd`** — 基类。包含递归属性脚本缓存系统，可为所有数据类型实现自动 JSON（反）序列化。

**模式系统** (`Global.SCHEMA`)：一个中央的 `Array[Array]`，映射每个数据类型的类名、脚本、查找表属性名以及外部文件夹路径。`Global._generate_schema()` 会根据这个模式构建快速查找表。**任何新数据类型都必须添加到 SCHEMA 中**。

### 行动系统 (`scripts/actions/`)

所有的游戏行为都通过 Action（行动）流转。继承链为 `BaseAction` → `BaseAsyncAction`。

- **ActionHandler** 维护一个行动队列堆栈。通过 `add_action()`/`add_actions()` 推入行动；它们会通过 `_perform_actions()` 自动执行。
- 行动可以是 **同步的** 或 **异步的**（等待用户输入、动画、计时器）。
- 行动带有一个用于控制节奏的 `time_delay`，以及一个拦截管道（见下文）。
- **ActionGenerator** 是工厂类 — 它根据 JSON/字典的行动数据有效载荷来构建行动树。
- 关键的行动分类：
  - `card_actions/` — 出牌、选牌、变形、弃牌、升级卡牌
  - `combatant_actions/` — 攻击、格挡、治疗、施加状态（对玩家和敌人）
  - `meta_actions/` — 随机选择、验证器、行动生成/修改
  - `world_generation_actions/` — 生成 Act 地图
  - `world_interaction_actions/` — 访问地点、开始战斗、打开宝箱
  - `shop_actions/`, `rewards/`, `artifact_actions/`, `audio_actions/`, `custom_actions/`

**值层级优先级**：当 Action 通过 `get_action_value(key, default)` 查找参数时，它会按以下顺序搜索：Action 自身的 `values` → `CardPlayRequest.card_values` → `CardData.card_values` → `PlayerData.player_values` → `default`。这使得卡牌、玩家以及独立的 Action 可以覆盖不同作用域内的值。

**出牌流程**：点击手牌 → `HandManager` 创建 `CardPlayRequest`（包含卡牌数据、目标、费用） → 排入 `card_play_queue` → `_perform_card_plays()` 弹出每个请求 → `ActionGenerator.generate_card_play()` 构建行动树 → 行动通过 `ActionHandler` 执行 → 触发 `card_play_finished` 信号 → 结算下一张卡牌或结束回合。

### 行动拦截器 (`scripts/action_interceptors/`)

拦截器在 Action 执行之前动态地修改它们。它们是状态效果（易伤、虚弱）、遗物/外设插件以及其他持久化修改器背后的核心机制。通过 `ActionHandler.register_action_interceptor()` 为每个战斗对象进行注册。拦截器由数据驱动（`ActionInterceptorData`），并且可以从 JSON 加载。

每个拦截器都会返回一个 `ActionInterceptorProcessor` 链，该链会为每个目标修改 Action 的数值。拦截器的预览功能同时驱动了敌人意图的显示和卡牌描述文本 —— UI 使用了与游戏逻辑完全相同的拦截器管道，从而保证了信息的一致性。

### 验证器 (`scripts/validators/`)

验证器驱动条件逻辑：“这张牌能打出吗？”、“这个效果触发吗？”。通过 `Global.validate(validators, card_data, action)` 调用。按领域分类：卡牌属性、出牌、牌库状态、手牌状态、战斗统计、敌人状态、玩家状态。

### 内容包 (Content Packs)

CardPackData、ArtifactPackData 和 ConsumablePackData 定义了内容的过滤子集。内容包会在启动时自动生成过滤器缓存（`Global._generate_card_pack_cache()` 等）。将一张卡牌加入到某个包中，会自动使其包含在相关的选牌、商店和奖励池中。

### 过滤器/缓存系统 (`data/filters/`)

CardFilter、ArtifactFilter 和 ConsumableFilter 使用了 **方法链 (Method Chaining)** 模式。通过调用过滤器方法（例如 `.filter_type()`, `.filter_rarity()`, `.filter_colors()`）构建查询，然后调用一个终端方法（`.convert_to_card_prototypes()`, `.convert_to_unique_card_object_ids()`）。过滤器可以通过 `.cache_filter(id)` 进行缓存，并存储在 `Global._id_to_card_filter_cache` 中 — 内容包利用这一点在启动时进行缓存。被缓存的过滤器会被锁定，禁止进一步的修改。

### 确定性随机数 (Deterministic RNG)

`Random.gd` 提供了所有随机化工具。每个“进程(Run)”都会根据 `player_data.player_run_seed` 生成 RNG 轨道。不同的游戏系统从不同的命名 RNG 轨道获取随机数（如 `"rng_reward_card_drafts"`, `"rng_shop"`），这些轨道作为 `Dictionary[String, RandomNumberGenerator]` 存储在 `PlayerData.player_rng_tracks` 中。轨道是在首次访问时惰性创建的。这防止了交叉污染 —— 洗牌不会影响事件的结果。

### 保存/加载系统

由 `FileLoader` 管理。**单个存档槽** 位于 `external/saves/save.json`。核心方法：
- `save_game()` / `load_game()` — 通过 JSON 序列化/反序列化 `Global.player_data`
- `autosave()` / `autoload()` — 受 `AUTOSAVING_ENABLED` 控制的便捷包装器
- `has_save_file()` / `delete_save()` — 存档槽管理
- `save_user_settings()` / `load_user_settings()` — 持久化设置，位于 `external/user_settings.json`
- `save_profile()` / `load_profile()` — 跨局的进度文件，位于 `external/profile.json`

在导出版本中，路径会从 `res://` 切换为可执行文件的同级目录。目前尚不支持多存档槽 UI（代码中有 `TODO: Profile implementation` 注释）。

### PlayerData (`data/prototype/PlayerData.gd`)

当前“游戏进程(Run)”的核心可变数据对象。关键子系统：

- **RNG 轨道** (`player_rng_tracks`)：根据 `player_run_seed` 播种的命名 RNG 实例
- **卡牌奖励池** (`player_reward_card_filter_cache`, `reward_draft_card_pack_ids`, `player_rare_card_modifier_current`)：稀有卡牌的保底系统；根据激活的卡包构建的过滤器缓存
- **遗物池** (`player_artifact_pool`, `player_artifact_pack_ids`)：所有遗物 ID 的洗牌池；奖励从前面弹出，商店从后面弹出；按稀有度分桶
- **消耗品池**：与遗物池模式相同
- **事件池**：`get_next_event_object_id_from_pool()` 从 EventPoolData 中拉取事件，并带有失败处理策略（KEEP, APPEND, REMOVE, REINSERT, BLACKLIST）
- **地点数据**：`location_id_to_location_data` 存放完整的已生成 Act 地图
- **游戏进程配置**：`player_run_seed`, `player_run_difficulty_level`, `player_run_modifier_object_ids`

### 战斗流程

战斗是一个位于 `scripts/ui/Combat.gd` 中的 **信号驱动的状态机**（没有专属的 CombatManager 类）：

1. `combat_started` → 敌人生成，播放回合开始动画
2. `start_turn()` → 重置能量，处理抽牌前的状态效果，重置格挡，抽牌，解锁手牌
3. 玩家通过 `CardPlayRequest` 队列出牌 → Action 经由 `ActionHandler` 执行
4. `end_turn` → `CombatEndTurn` 对象管理即时性级别（WAIT_FOR_ALL_CARD_PLAYS, WAIT_FOR_ACTIONS, IMMEDIATE）
5. 玩家回合结束 → 弃牌/消耗/保留逻辑，处理回合结束后的状态效果
6. 敌人回合 → 每一个存活的敌人：执行意图前的状态处理 → 执行意图 → 意图后的状态处理
7. 循环回到步骤 2
8. 战斗在所有非召唤物敌人死亡或玩家死亡时结束

### Run Modifiers（修改器）

`RunModifierData` 驱动难度（类似于进阶模式）以及自定义修改器。有三种类型：
- **标准难度** (`run_modifier_is_custom = false`)：在 NewRunMenu 上的难度等级选择。目前难度 1-5 作为存根存在。
- **自定义** (`run_modifier_is_custom = true`)：玩家选择的开关（安全模式、死循环模式、全颜色卡池）。可以通过 `run_modifier_exclusive_to_modifier_ids` 实现互斥。
- **自动** (`run_modifier_is_automatic = true`)：始终激活（例如，消耗品的自动复活）。没有玩家选择。

修改器的工作原理是注册行动拦截器 (`run_modifier_interceptor_ids`)，或运行仅在开局时调用一次 `run_start_modification()` 的修改器脚本 (`run_modifier_modifier_script_path`)。

### 自定义信号与统计数据钩子 (Custom Signals & Stat Hooks)

`CustomSignalData`（位于 `data/readonly/modding/`）为 Mod 定义了数据驱动的信号。`Signals` 单例管理 `CustomSignal` 实例（每个实例扩展自 `RefCounted` 并携带一个 `custom_signal` 信号）。`StatsHandler` 会连接到 `custom_signal_is_stat = true` 的自定义信号，从而实现无需修改代码的数据驱动统计追踪。

### Act (章节地图) 生成

`ActionGenerateAct.perform_action()` 会构建一个基于网格的地图：
- 固定的楼层布局：0层 = 起点，1-3层 = 简单战斗，4层 = 商店，5层 = 宝箱，6层 = 休息区，7层 = 精英战，8-10层 = 困难战斗，最后一层 = Boss
- 可配置的 `floors_per_act`（默认为 10），`locations_per_floor`（默认为 5）
- 50% 的混淆率（位置显示为 "?"），30% 的几率把战斗替换为非战斗事件
- 分支连接：每个节点与其正上方、左上方和右上方相连（类似《杀戮尖塔》的连线风格）
- 基于 `rng_world_generation` 轨道生成
- 可以通过 `ActData.act_action_script_path` 插入自定义的生成脚本

### 事件系统

事件系统使用了带有权重池的 `EventPoolData`。`PlayerData.get_next_event_object_id_from_pool()` 会复制该池，洗牌，并根据其条件验证每个事件。验证失败的事件将由可配置的策略处理（KEEP, APPEND, REMOVE, REINSERT, BLACKLIST）。事件可以是战斗或非战斗，对话由状态机驱动。

### Mod 支持 (`external/`)

Mod 是从 `external/` 目录加载的。每个 Mod 都有一个 `mod_info.json` 指定文件夹和数据类型。可以从 Mod 加载脚本来注入或覆盖行为。`mod_list.json` 控制哪些 Mod 是激活的。示例 Mod 位于 `external/mods/example_mod/`。

### 编辑器插件 (`addons/`)

- **`sound_manager/`** — Nathan Hoad 开发的音频管理器插件。注册为编辑器插件 + 自动加载。提供音频播放器池、音乐/音效/环境音通道。
- **`label_font_auto_sizer/`** — 自定义的 `AutoSizeLabel` 和 `AutoSizeRichTextlabel` 节点。注册为编辑器插件。
- **`smooth_scroll_container/`** — 带有基于速度的惯性和过度拖动的 `SmoothScrollContainer`。可复用的脚本（未注册为编辑器插件）。

### 着色器 (Shaders)

唯一的着色器：`scripts/ui/outline.gdshader` — 一个 `canvas_item` 着色器，用于在精灵图（Sprites）周围绘制可配置的轮廓（宽度、颜色、亮度）。主要用于 `MapLocation` 节点，配合动画轨道实现脉冲高亮效果。

### UI 架构

所有的 UI 场景预加载都存放在 `Scenes` 单例中。UI 脚本位于 `scripts/ui/`。根场景 (`Root.tscn`) 拥有三个顶层子节点：**TitleScreen**（标题菜单）、**RunScreen**（游戏内 HUD）以及 **Tooltips**（全局工具提示层，Z 轴 1000）。关键子系统：
- **卡牌显示**：`Card.tscn` + `CardDecorator.tscn`（用于类似附魔的卡牌视觉修改）
- **图鉴 (Codex)**：可浏览的内容百科，显示所有的卡牌、外设插件、物理删除键、敌人
- **地图**：`MapLocation.tscn` 配合 `Line2D` 连接用于 Act 导航
- **奖励**：抽牌、遗物和金钱奖励屏幕
- **商店**：购买卡牌、外设插件和物理删除键
- **工具提示**：`KeywordTooltip.tscn`（单个关键词带可选的状态图标）和 `Tooltip.tscn`（带定位的富文本）；关键词支持通过广度优先搜索 (BFS) 嵌套子关键词
- **战斗**：手牌区域、敌人容器、能量显示、各牌堆、结束回合按钮、目标选择

### 战斗单位 (`scenes/combatants/`, `scripts/combatants/`)

`Player.tscn` 和 `Enemy.tscn` 是战斗单位场景。血量通过 `LayeredHealthBar` + `HealthLayer` 显示。`StatusEffect.tscn` 渲染状态图标。战斗浮动提示（文本、遗物、图像）为动作提供视觉反馈。

## 关键模式与最佳实践

- **只读 → 原型模式**：数据模板在 Global 的查找表中是只读的。要获得一个可变的实例，调用 `Global.get_card_data_from_prototype(id)`（其内部会调用 `.get_prototype(true)`）。
- **信号驱动通信**：跨系统事件需经过 `Signals` 单例。避免系统之间的直接耦合。
- **行动组合 (Action composition)**：行动可以包含子行动，从而实现嵌套行为（for 循环、条件分支、通过 meta_actions 实现的随机分支）。
- **验证器共享**：游戏逻辑（这张牌能打出吗？）和 UI（这张牌该发光吗？这段文字该高亮吗？）都使用同一套 `Global.validate()` 管道。
- **启动时缓存**：卡牌/外设插件/消耗品的过滤器缓存在启动时生成一次。不要反复查询原始数据。
- **`class_name` 要求**：序列化系统在运行时通过 Godot 全局类列表解析类名。新的数据类必须使用与其文件名匹配的 `class_name`。
- **拦截器预览**：敌人的意图和卡牌的描述文本使用与游戏逻辑完全相同的拦截器管道 —— 绝对没有单独的计算系统。

## Godot MCP 工具

本项目提供了 Godot MCP 工具。项目路径为 `F:/Godot/games/Slay-The-Robot`。使用 `mcp__godot-mcp__run_project` 启动项目，使用 `mcp__godot-mcp__stop_project` 停止。
