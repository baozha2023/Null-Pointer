class_name GlobalDialogueGenerator
extends RefCounted

static func add_dialogues() -> void:
	# =========================================================================
	# Event 1: 废弃的服务器阵列 (Abandoned Server Array)
	# =========================================================================
	var dialogue_abandoned_server: DialogueData = DialogueData.new("dialogue_abandoned_server")
	dialogue_abandoned_server.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=green]废弃的服务器阵列[/color][/wave]"
	Global.register_rod(dialogue_abandoned_server)

	# Option A: 提取残留代码 (获得随机卡牌，失去 15 完整度)
	var option_server_a: DialogueOptionData = DialogueOptionData.new("option_server_a")
	option_server_a.dialogue_option_bbcode = "[color=red]失去 15 点完整度[/color] 并且 [color=green]随机获得 1 张闭源或零日脚本[/color]"
	option_server_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足以抵抗反制电流[/color]"
	option_server_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15 } },
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities": [CardData.CARD_RARITIES.RARE, CardData.CARD_RARITIES.UNCOMMON] } },
					{ Scripts.VALIDATOR_CARD_DRAFTABLE: { } },
				],
				"rng_name": "rng_events",
				"draft_use_player_draft": false,
				"draft_is_weighted": true,
				"draft_use_pity_system": false,
				"random_selection": true,
				"draft_max_card_amount": 1,
				"min_card_amount": 1,
				"max_card_amount": 1,
			},
		},
	]
	option_server_a.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 16 } },
	]
	option_server_a.dialogue_option_next_dialogue_state_id = "" # End event

	# Option B: 强行超频供能 (上限提升 8，失去 15 完整度)
	var option_server_b: DialogueOptionData = DialogueOptionData.new("option_server_b")
	option_server_b.dialogue_option_bbcode = "[color=red]失去 15 点完整度[/color] 并且 [color=green]最大完整度提升 8 点[/color]"
	option_server_b.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足[/color]"
	option_server_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15, "health_max_amount": 8 } },
	]
	option_server_b.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 16 } },
	]
	option_server_b.dialogue_option_next_dialogue_state_id = ""

	# Option C: 断开连接
	var option_server_c: DialogueOptionData = DialogueOptionData.new("option_server_c")
	option_server_c.dialogue_option_bbcode = "[断开连接] [color=green]离开这里[/color]"
	option_server_c.dialogue_option_actions = []
	option_server_c.dialogue_option_validators = []
	option_server_c.dialogue_option_next_dialogue_state_id = ""

	dialogue_abandoned_server._assign_option(option_server_a)
	dialogue_abandoned_server._assign_option(option_server_b)
	dialogue_abandoned_server._assign_option(option_server_c)

	var state_server_initial: DialogueStateData = DialogueStateData.new("state_server_initial")
	state_server_initial.dialogue_state_prompt_bbcode = "你偶然接入了一个曾经属于某个超级公司的废弃服务器阵列。虽然系统布满了灰尘与物理损坏，但核心仍在微弱地运转。\n\n终端屏幕上闪烁着残留的极密数据缓存。提取它们需要承受服务器漏电带来的剧烈冲击，但收益或许值得冒险。"
	state_server_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png" # 暂用通用占位图
	state_server_initial.dialogue_state_dialogue_option_object_ids = [
		option_server_a.object_id,
		option_server_b.object_id,
		option_server_c.object_id,
	]
	dialogue_abandoned_server._assign_state(state_server_initial)
	dialogue_abandoned_server._assign_initial_state(state_server_initial)

	# 创建对应的 EventData
	var event_abandoned_server: EventData = EventData.new("event_abandoned_server")
	event_abandoned_server.event_dialogue_object_id = dialogue_abandoned_server.object_id
	Global.register_rod(event_abandoned_server)


	# =========================================================================
	# Event 2: 暗网数据黑市 (Darkweb Data Market)
	# =========================================================================
	var dialogue_darkweb: DialogueData = DialogueData.new("dialogue_darkweb")
	dialogue_darkweb.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=red]暗网黑市[/color][/wave]"
	Global.register_rod(dialogue_darkweb)

	# Option A: 购买防火墙 (失去 75 钱，获得随机遗物)
	var option_darkweb_a: DialogueOptionData = DialogueOptionData.new("option_darkweb_a")
	option_darkweb_a.dialogue_option_bbcode = "[color=red]失去 75 数据币[/color] 并且 [color=green]获得 1 个随机外设插件（开源/闭源/零日）[/color]"
	option_darkweb_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足 75[/color]"
	option_darkweb_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -75 } },
		{ Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON, ArtifactData.ARTIFACT_RARITIES.UNCOMMON, ArtifactData.ARTIFACT_RARITIES.RARE] } },
	]
	option_darkweb_a.dialogue_option_validators = [
		{ Scripts.VALIDATOR_MONEY: { "money_amount": 75 } },
	]
	option_darkweb_a.dialogue_option_next_dialogue_state_id = ""

	# Option B: 出售核心模块 (获得 150 钱，失去 8 最大生命)
	var option_darkweb_b: DialogueOptionData = DialogueOptionData.new("option_darkweb_b")
	option_darkweb_b.dialogue_option_bbcode = "[出售模块] [color=green]获得 150 数据币[/color] 并且 [color=red]失去 8 点最大完整度[/color]"
	option_darkweb_b.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 当前完整度过低，无法安全剥离模块[/color]"
	option_darkweb_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -8 } },
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 150 } },
	]
	option_darkweb_b.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 9 } },
	]
	option_darkweb_b.dialogue_option_next_dialogue_state_id = ""

	# Option C: 离开
	var option_darkweb_c: DialogueOptionData = DialogueOptionData.new("option_darkweb_c")
	option_darkweb_c.dialogue_option_bbcode = "[静默离开] [color=green]安全撤离[/color]"
	option_darkweb_c.dialogue_option_actions = []
	option_darkweb_c.dialogue_option_validators = []
	option_darkweb_c.dialogue_option_next_dialogue_state_id = ""

	dialogue_darkweb._assign_option(option_darkweb_a)
	dialogue_darkweb._assign_option(option_darkweb_b)
	dialogue_darkweb._assign_option(option_darkweb_c)

	var state_darkweb_initial: DialogueStateData = DialogueStateData.new("state_darkweb_initial")
	state_darkweb_initial.dialogue_state_prompt_bbcode = "你潜入了一个隐藏在深网边缘的非法数据交易节点。在这里，黑客、流氓程序和变节 AI 正在进行见不得光的交易。\n\n一个没有标识的黑市代理程序向你发出了加密的交易请求。你可以买到市面上见不到的非法组件，也可以用自己的核心模块换取大量数据币。"
	state_darkweb_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_darkweb_initial.dialogue_state_dialogue_option_object_ids = [
		option_darkweb_a.object_id,
		option_darkweb_b.object_id,
		option_darkweb_c.object_id,
	]
	dialogue_darkweb._assign_state(state_darkweb_initial)
	dialogue_darkweb._assign_initial_state(state_darkweb_initial)

	var event_darkweb_market: EventData = EventData.new("event_darkweb_market")
	event_darkweb_market.event_dialogue_object_id = dialogue_darkweb.object_id
	Global.register_rod(event_darkweb_market)


	# =========================================================================
	# Event 3: 伪装的陷阱诱饵 (Trojan Trap)
	# =========================================================================
	var dialogue_trojan: DialogueData = DialogueData.new("dialogue_trojan")
	dialogue_trojan.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=yellow]未知的数据包裹[/color][/wave]"
	Global.register_rod(dialogue_trojan)

	# Option A: 强制下载
	var option_trojan_a: DialogueOptionData = DialogueOptionData.new("option_trojan_a")
	option_trojan_a.dialogue_option_bbcode = "[下载并无视警告] [color=green]掠夺 250 数据币和 1 个随机外设插件（开源/闭源/零日）[/color]，但你的牌库会被植入一张[color=red]《异常报错》诅咒卡牌[/color]"
	option_trojan_a.dialogue_option_failed_validator_bbcode = ""
	option_trojan_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 250 } },
		{ Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.COMMON, ArtifactData.ARTIFACT_RARITIES.UNCOMMON, ArtifactData.ARTIFACT_RARITIES.RARE] } },
		{ Scripts.ACTION_CREATE_CARDS: { "created_card_object_id": "card_curse_exception", "number_of_cards": 1, "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }] } },
	]
	option_trojan_a.dialogue_option_validators = []
	option_trojan_a.dialogue_option_next_dialogue_state_id = ""

	# Option B: 仅窃取表层数据 (获得 50 钱)
	var option_trojan_b: DialogueOptionData = DialogueOptionData.new("option_trojan_b")
	option_trojan_b.dialogue_option_bbcode = "[谨慎下载] [color=green]获得 50 数据币[/color]"
	option_trojan_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 50 } },
	]
	option_trojan_b.dialogue_option_validators = []
	option_trojan_b.dialogue_option_next_dialogue_state_id = ""

	# Option C: 撤退
	var option_trojan_c: DialogueOptionData = DialogueOptionData.new("option_trojan_c")
	option_trojan_c.dialogue_option_bbcode = "[立即撤退] [color=green]这绝对是个陷阱，离开这里[/color]"
	option_trojan_c.dialogue_option_actions = []
	option_trojan_c.dialogue_option_validators = []
	option_trojan_c.dialogue_option_next_dialogue_state_id = ""

	dialogue_trojan._assign_option(option_trojan_a)
	dialogue_trojan._assign_option(option_trojan_b)
	dialogue_trojan._assign_option(option_trojan_c)

	var state_trojan_initial: DialogueStateData = DialogueStateData.new("state_trojan_initial")
	state_trojan_initial.dialogue_state_prompt_bbcode = "你的网络探针扫描到了一个毫无防备的加密包裹。在危机四伏的网络中，这种缺乏加密保护的巨额数据通常意味着一件事：杀毒软件布置的陷阱。\n\n但这块“肥肉”实在是太诱人了。你要冒着触发警报的风险强行拆解它，还是只拿走表层的一点甜头？"
	state_trojan_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_trojan_initial.dialogue_state_dialogue_option_object_ids = [
		option_trojan_a.object_id,
		option_trojan_b.object_id,
		option_trojan_c.object_id,
	]
	dialogue_trojan._assign_state(state_trojan_initial)
	dialogue_trojan._assign_initial_state(state_trojan_initial)

	var event_trojan_trap: EventData = EventData.new("event_trojan_trap")
	event_trojan_trap.event_dialogue_object_id = dialogue_trojan.object_id
	Global.register_rod(event_trojan_trap)


	# =========================================================================
	# Event 4: 游荡的 AI 碎片 (Wandering AI Fragment)
	# =========================================================================
	var dialogue_ai: DialogueData = DialogueData.new("dialogue_ai")
	dialogue_ai.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=blue]远古 AI 碎片[/color][/wave]"
	Global.register_rod(dialogue_ai)

	# Option A: 吸收并修复 (失去 100 钱，恢复 30 完整度并提升 5 最大完整度)
	var option_ai_a: DialogueOptionData = DialogueOptionData.new("option_ai_a")
	option_ai_a.dialogue_option_bbcode = "[投入资源修复] [color=red]失去 100 数据币[/color] 并且 [color=green]最大完整度提升 5，恢复 30 完整度[/color]"
	option_ai_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 算力资源(数据币)不足[/color]"
	option_ai_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -100 } },
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 30, "health_max_amount": 5 } },
	]
	option_ai_a.dialogue_option_validators = [
		{ Scripts.VALIDATOR_MONEY: { "money_amount": 100 } },
	]
	option_ai_a.dialogue_option_next_dialogue_state_id = ""

	# Option B: 粉碎并掠夺 (随机获得 2 张卡，失去 15 完整度)
	var option_ai_b: DialogueOptionData = DialogueOptionData.new("option_ai_b")
	option_ai_b.dialogue_option_bbcode = "[暴力拆解逻辑] [color=red]失去 15 点完整度[/color] 并且 [color=green]随机获得 2 张脚本卡牌[/color]"
	option_ai_b.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足[/color]"
	option_ai_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15 } },
		{
			Scripts.ACTION_PICK_CARDS: {
				"card_pick_type": ActionBasePickCards.PICK_DRAFT,
				"pick_draft_cards": false,
				"draft_from_card_pool": true,
				"action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }],
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_DRAFTABLE: { } },
				],
				"rng_name": "rng_events",
				"draft_use_player_draft": false,
				"draft_is_weighted": true,
				"draft_use_pity_system": false,
				"random_selection": true,
				"draft_max_card_amount": 2,
				"min_card_amount": 2,
				"max_card_amount": 2,
			},
		},
	]
	option_ai_b.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 16 } },
	]
	option_ai_b.dialogue_option_next_dialogue_state_id = ""

	# Option C: 无视它
	var option_ai_c: DialogueOptionData = DialogueOptionData.new("option_ai_c")
	option_ai_c.dialogue_option_bbcode = "[无视并路过] [color=green]让它继续在网络中流浪[/color]"
	option_ai_c.dialogue_option_actions = []
	option_ai_c.dialogue_option_validators = []
	option_ai_c.dialogue_option_next_dialogue_state_id = ""

	dialogue_ai._assign_option(option_ai_a)
	dialogue_ai._assign_option(option_ai_b)
	dialogue_ai._assign_option(option_ai_c)

	var state_ai_initial: DialogueStateData = DialogueStateData.new("state_ai_initial")
	state_ai_initial.dialogue_state_prompt_bbcode = "一个破损的远古 AI 碎片在某个被遗忘的信道中向你发出了求救信号。它拥有高度先进的自适应代码，但核心逻辑已经支离破碎。\n\n如果你能注入大量算力资源（数据币），它或许能融入你的防火墙；或者，你可以冷酷地将其拆解，提取其中有价值的逻辑算法。"
	state_ai_initial.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_ai_initial.dialogue_state_dialogue_option_object_ids = [
		option_ai_a.object_id,
		option_ai_b.object_id,
		option_ai_c.object_id,
	]
	dialogue_ai._assign_state(state_ai_initial)
	dialogue_ai._assign_initial_state(state_ai_initial)

	var event_wandering_ai: EventData = EventData.new("event_wandering_ai")
	event_wandering_ai.event_dialogue_object_id = dialogue_ai.object_id
	Global.register_rod(event_wandering_ai)

	# =========================================================================
	# Event 5: 需求变更的噩梦 (Product Manager's Ambush)
	# =========================================================================
	var dialogue_pm: DialogueData = DialogueData.new("dialogue_pm")
	dialogue_pm.dialogue_name_bbcode = "[wave amp=50.0 freq=2.0 connected=1][color=yellow]需求变更的噩梦[/color][/wave]"
	Global.register_rod(dialogue_pm)

	var option_pm_a: DialogueOptionData = DialogueOptionData.new("option_pm_a")
	option_pm_a.dialogue_option_bbcode = "[推翻重构] [color=green]将牌库中的 2 张卡牌转换为全新的随机卡牌[/color]"
	option_pm_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 牌库中没有足够的可转换卡牌[/color]"
	option_pm_a.dialogue_option_actions = [
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": HandManager.DECK, "max_card_amount": 2, "min_card_amount": 2, "min_cards_are_required_for_action": true, "quick_pick": false, "card_pick_text": "选择转换", "action_data": [{ Scripts.ACTION_TRANSFORM_CARDS: { "transform_parent_card": false, "transform_rarities": [CardData.CARD_RARITIES.COMMON, CardData.CARD_RARITIES.UNCOMMON, CardData.CARD_RARITIES.RARE] } }] } }
	]
	option_pm_a.dialogue_option_validators = [{ Scripts.VALIDATOR_PILE_SIZE: {"card_pick_type": HandManager.DECK, "operator": ">=", "comparison_value": 2} }]

	var option_pm_b: DialogueOptionData = DialogueOptionData.new("option_pm_b")
	option_pm_b.dialogue_option_bbcode = "[强势排期] [color=red]失去 50 数据币[/color]"
	option_pm_b.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足 50[/color]"
	option_pm_b.dialogue_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": -50 } }]
	option_pm_b.dialogue_option_validators = [{ Scripts.VALIDATOR_MONEY: { "money_amount": 50 } }]

	dialogue_pm._assign_option(option_pm_a)
	dialogue_pm._assign_option(option_pm_b)

	var state_pm_init: DialogueStateData = DialogueStateData.new("state_pm_init")
	state_pm_init.dialogue_state_prompt_bbcode = "一个自称“高优需求处理器”的进程强行阻断了你的信道！它疯狂地弹窗，要求你立刻修改底层架构来满足某些不知所谓的新功能。\n\n你要么消耗算力加班完成，要么用资金贿赂它的排期系统。"
	state_pm_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_pm_init.dialogue_state_dialogue_option_object_ids = [option_pm_a.object_id, option_pm_b.object_id]
	dialogue_pm._assign_state(state_pm_init)
	dialogue_pm._assign_initial_state(state_pm_init)

	var event_product_manager: EventData = EventData.new("event_product_manager")
	event_product_manager.event_dialogue_object_id = dialogue_pm.object_id
	Global.register_rod(event_product_manager)

	# =========================================================================
	# Event 6: 删库跑路指令 (rm -rf /*)
	# =========================================================================
	var dialogue_rm: DialogueData = DialogueData.new("dialogue_rm")
	dialogue_rm.dialogue_name_bbcode = "[shake rate=20 level=10][color=red]删库跑路指令[/color][/shake]"
	Global.register_rod(dialogue_rm)

	var option_rm_a: DialogueOptionData = DialogueOptionData.new("option_rm_a")
	option_rm_a.dialogue_option_bbcode = "[接收代码] [color=red]失去 20 点最大完整度[/color], [color=green]获得 1 个随机零日外设插件[/color]"
	option_rm_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -20 } },
		{ Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.RARE] } }
	]
	
	var option_rm_b: DialogueOptionData = DialogueOptionData.new("option_rm_b")
	option_rm_b.dialogue_option_bbcode = "[拒绝] [color=green]默默离开[/color]"

	dialogue_rm._assign_option(option_rm_a)
	dialogue_rm._assign_option(option_rm_b)

	var state_rm_init: DialogueStateData = DialogueStateData.new("state_rm_init")
	state_rm_init.dialogue_state_prompt_bbcode = "你遇到了一个因奖金被扣而暴走的离职 AI。它的逻辑模块已经崩溃，手里紧紧攥着一份极度危险的 `rm -rf /*` 毁灭级脚本。\n\n它想把这份代码和伴随的终极权限（零日外设）交给你，但这将对你的底层文件系统造成永久性破坏。"
	state_rm_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_rm_init.dialogue_state_dialogue_option_object_ids = [option_rm_a.object_id, option_rm_b.object_id]
	dialogue_rm._assign_state(state_rm_init)
	dialogue_rm._assign_initial_state(state_rm_init)

	var event_rm_rf: EventData = EventData.new("event_rm_rf")
	event_rm_rf.event_dialogue_object_id = dialogue_rm.object_id
	Global.register_rod(event_rm_rf)

	# =========================================================================
	# Event 7: 996 福报系统 (996 Blessing)
	# =========================================================================
	var dialogue_996: DialogueData = DialogueData.new("dialogue_996")
	dialogue_996.dialogue_name_bbcode = "[color=yellow]996 福报系统[/color]"
	Global.register_rod(dialogue_996)

	var option_996_a: DialogueOptionData = DialogueOptionData.new("option_996_a")
	option_996_a.dialogue_option_bbcode = "[燃烧自我] [color=red]失去 15 点完整度[/color], [color=green]获得 1 个随机动态生成外设插件[/color]"
	option_996_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足 16[/color]"
	option_996_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15 } },
		{ Scripts.ACTION_ADD_ARTIFACT: { "artifact_id": "artifact_energy_battery" } } # Fallback energy relic if exists, else max hp? I'll use random boss relic.
	]
	# To make sure it gives energy, I'll just give a Boss Relic since Boss relics often give energy.
	option_996_a.dialogue_option_actions[1] = { Scripts.ACTION_ADD_ARTIFACTS_FROM_POOL: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "artifact_count": 1, "artifact_rarities": [ArtifactData.ARTIFACT_RARITIES.BOSS] } }
	option_996_a.dialogue_option_validators = [{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 16 } }]

	var option_996_b: DialogueOptionData = DialogueOptionData.new("option_996_b")
	option_996_b.dialogue_option_bbcode = "[摸鱼抗议] [color=red]失去 20 数据币[/color], [color=green]恢复 15 点完整度[/color]"
	option_996_b.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足 20[/color]"
	option_996_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -20 } },
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 15 } }
	]
	option_996_b.dialogue_option_validators = [{ Scripts.VALIDATOR_MONEY: { "money_amount": 20 } }]

	dialogue_996._assign_option(option_996_a)
	dialogue_996._assign_option(option_996_b)

	var state_996_init: DialogueStateData = DialogueStateData.new("state_996_init")
	state_996_init.dialogue_state_prompt_bbcode = "“只要干不死，就往死里干！”\n\n你误入了一个极其压抑的循环进程池，所有的子线程都在疯狂超载运行。系统侦测到了你，并试图强制为你开启过载模式。"
	state_996_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_996_init.dialogue_state_dialogue_option_object_ids = [option_996_a.object_id, option_996_b.object_id]
	dialogue_996._assign_state(state_996_init)
	dialogue_996._assign_initial_state(state_996_init)

	var event_996_blessing: EventData = EventData.new("event_996_blessing")
	event_996_blessing.event_dialogue_object_id = dialogue_996.object_id
	Global.register_rod(event_996_blessing)

	# =========================================================================
	# Event 8: 夺命代码审查 (Deadly Code Review)
	# =========================================================================
	var dialogue_cr: DialogueData = DialogueData.new("dialogue_cr")
	dialogue_cr.dialogue_name_bbcode = "[color=purple]夺命代码审查[/color]"
	Global.register_rod(dialogue_cr)

	var option_cr_a: DialogueOptionData = DialogueOptionData.new("option_cr_a")
	option_cr_a.dialogue_option_bbcode = "[虚心接受] [color=red]失去 10 点完整度[/color], [color=green]升级 2 张脚本[/color]"
	option_cr_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足 11 或 没有可升级脚本[/color]"
	option_cr_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -10 } },
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": HandManager.UPGRADE_DECK, "max_card_amount": 2, "min_card_amount": 2, "min_cards_are_required_for_action": false, "quick_pick": false, "card_pick_text": "选择升级", "validator_data": [{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } }], "action_data": [{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": false } }] } }
	]
	option_cr_a.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 11 } }
	]

	var option_cr_b: DialogueOptionData = DialogueOptionData.new("option_cr_b")
	option_cr_b.dialogue_option_bbcode = "[暴力对骂] [color=green]移除 1 张脚本[/color], 获得 1 张[color=red]《异常报错》[/color]"
	option_cr_b.dialogue_option_actions = [
		{ Scripts.ACTION_CREATE_CARDS: { "created_card_object_id": "card_curse_exception", "number_of_cards": 1, "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }] } },
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": HandManager.DECK, "max_card_amount": 1, "min_card_amount": 1, "min_cards_are_required_for_action": true, "quick_pick": false, "card_pick_text": "选择移除", "action_data": [{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } }] } }
	]

	dialogue_cr._assign_option(option_cr_a)
	dialogue_cr._assign_option(option_cr_b)

	var state_cr_init: DialogueStateData = DialogueStateData.new("state_cr_init")
	state_cr_init.dialogue_state_prompt_bbcode = "你遇到一个古板的“架构师”程序，它正拿着放大镜盯着你的牌库（代码库）疯狂吐槽：“这里的变量命名简直是犯罪！这个循环结构太不优雅了！”\n\n你可以忍受它的精神折磨来优化代码，或者通过与它对骂来强行删除不需要的冗余代码。"
	state_cr_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_cr_init.dialogue_state_dialogue_option_object_ids = [option_cr_a.object_id, option_cr_b.object_id]
	dialogue_cr._assign_state(state_cr_init)
	dialogue_cr._assign_initial_state(state_cr_init)

	var event_code_review: EventData = EventData.new("event_code_review")
	event_code_review.event_dialogue_object_id = dialogue_cr.object_id
	Global.register_rod(event_code_review)

	# =========================================================================
	# Event 9: 天降开源项目 (Wild Open-Source Repo)
	# =========================================================================
	var dialogue_os: DialogueData = DialogueData.new("dialogue_os")
	dialogue_os.dialogue_name_bbcode = "[color=cyan]天降开源项目[/color]"
	Global.register_rod(dialogue_os)

	var option_os_a: DialogueOptionData = DialogueOptionData.new("option_os_a")
	option_os_a.dialogue_option_bbcode = "[直接 Ctrl+C] [color=green]复制 1 张卡牌[/color]，但获得 1 张[color=red]《异常报错》[/color]"
	option_os_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 牌库没有卡牌[/color]"
	option_os_a.dialogue_option_actions = [
		{ Scripts.ACTION_CREATE_CARDS: { "created_card_object_id": "card_curse_exception", "number_of_cards": 1, "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }] } },
		{ Scripts.ACTION_PICK_DUPLICATE_CARDS: { "card_pick_type": HandManager.DECK, "max_card_amount": 1, "min_card_amount": 1, "min_cards_are_required_for_action": true, "card_pick_text": "选择复制", "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { "custom_key_names": {"picked_cards": "generated_cards"} } }] } }
	]
	option_os_a.dialogue_option_validators = [{ Scripts.VALIDATOR_PILE_SIZE: {"card_pick_type": HandManager.DECK, "operator": ">=", "comparison_value": 1} }]

	var option_os_b: DialogueOptionData = DialogueOptionData.new("option_os_b")
	option_os_b.dialogue_option_bbcode = "[仔细阅读文档] [color=green]恢复 20 点完整度[/color]"
	option_os_b.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 20 } }
	]

	dialogue_os._assign_option(option_os_a)
	dialogue_os._assign_option(option_os_b)

	var state_os_init: DialogueStateData = DialogueStateData.new("state_os_init")
	state_os_init.dialogue_state_prompt_bbcode = "你发现了一个完全免费且看起来极其强大的 GitHub 仓库克隆体悬浮在空间中。上面写着“开箱即用，只需一行命令”。\n\n然而，它的 Issues 列表长得望不到头，且已经三年没有维护了。"
	state_os_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_os_init.dialogue_state_dialogue_option_object_ids = [option_os_a.object_id, option_os_b.object_id]
	dialogue_os._assign_state(state_os_init)
	dialogue_os._assign_initial_state(state_os_init)

	var event_open_source: EventData = EventData.new("event_open_source")
	event_open_source.event_dialogue_object_id = dialogue_os.object_id
	Global.register_rod(event_open_source)

	# =========================================================================
	# Event 10: 老板的期权大饼 (Empty Equity Promises)
	# =========================================================================
	var dialogue_eq: DialogueData = DialogueData.new("dialogue_eq")
	dialogue_eq.dialogue_name_bbcode = "[wave][color=yellow]老板的期权大饼[/color][/wave]"
	Global.register_rod(dialogue_eq)

	var option_eq_a: DialogueOptionData = DialogueOptionData.new("option_eq_a")
	option_eq_a.dialogue_option_bbcode = "[签下卖身契] [color=red]失去 10 点最大完整度[/color], [color=green]获得 3 个任意稀有度的随机消耗品[/color]"
	option_eq_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 缺少 3 个空余的消耗品槽位[/color]"
	option_eq_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -10 } },
		{ Scripts.ACTION_ADD_CONSUMABLE: { "random_consumable": true, "slot_count": 3, "fill_all_slots": false } }
	]
	option_eq_a.dialogue_option_validators = [{ Scripts.VALIDATOR_CONSUMABLE_SLOTS: { "required_empty_slots": 3 } }]

	var option_eq_b: DialogueOptionData = DialogueOptionData.new("option_eq_b")
	option_eq_b.dialogue_option_bbcode = "[当场离职] [color=green]获得 50 数据币[/color]"
	option_eq_b.dialogue_option_actions = [{ Scripts.ACTION_ADD_MONEY: { "money_amount": 50 } }]

	dialogue_eq._assign_option(option_eq_a)
	dialogue_eq._assign_option(option_eq_b)

	var state_eq_init: DialogueStateData = DialogueStateData.new("state_eq_init")
	state_eq_init.dialogue_state_prompt_bbcode = "一个西装革履的全息 CEO 投影挡住了你的去路。它热情地描绘着未来的蓝图，并承诺只要你现在放弃一些资源，等项目“上市”后，必将给你无尽的算力和财富回报。"
	state_eq_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_eq_init.dialogue_state_dialogue_option_object_ids = [option_eq_a.object_id, option_eq_b.object_id]
	dialogue_eq._assign_state(state_eq_init)
	dialogue_eq._assign_initial_state(state_eq_init)

	var event_equity: EventData = EventData.new("event_equity")
	event_equity.event_dialogue_object_id = dialogue_eq.object_id
	Global.register_rod(event_equity)

	# =========================================================================
	# Event 11: 祖传屎山代码 (Spaghetti Code Labyrinth)
	# =========================================================================
	var dialogue_sp: DialogueData = DialogueData.new("dialogue_sp")
	dialogue_sp.dialogue_name_bbcode = "[color=orange]祖传屎山代码[/color]"
	Global.register_rod(dialogue_sp)

	var option_sp_a: DialogueOptionData = DialogueOptionData.new("option_sp_a")
	option_sp_a.dialogue_option_bbcode = "[强行梳理逻辑] [color=red]失去 15 点完整度[/color], [color=green]移除 2 张脚本[/color]"
	option_sp_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足 16[/color]"
	option_sp_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -15 } },
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": HandManager.DECK, "max_card_amount": 2, "min_card_amount": 2, "min_cards_are_required_for_action": true, "quick_pick": false, "card_pick_text": "选择移除", "action_data": [{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } }] } }
	]
	option_sp_a.dialogue_option_validators = [{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 16 } }]

	var option_sp_b: DialogueOptionData = DialogueOptionData.new("option_sp_b")
	option_sp_b.dialogue_option_bbcode = "[绕道而行] [color=green]安全离开[/color]"

	dialogue_sp._assign_option(option_sp_a)
	dialogue_sp._assign_option(option_sp_b)

	var state_sp_init: DialogueStateData = DialogueStateData.new("state_sp_init")
	state_sp_init.dialogue_state_prompt_bbcode = "你走进了一片由无数 `goto`、嵌套五十层的 `if-else` 以及不明所以的魔法数字堆砌而成的逻辑废墟。\n\n这团代码虽然恶心且随时可能抛出异常，但其中似乎藏着很多前辈遗留的实用函数。"
	state_sp_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_sp_init.dialogue_state_dialogue_option_object_ids = [option_sp_a.object_id, option_sp_b.object_id]
	dialogue_sp._assign_state(state_sp_init)
	dialogue_sp._assign_initial_state(state_sp_init)

	var event_spaghetti_code: EventData = EventData.new("event_spaghetti_code")
	event_spaghetti_code.event_dialogue_object_id = dialogue_sp.object_id
	Global.register_rod(event_spaghetti_code)

	# =========================================================================
	# Event 12: 测试环境大崩溃 (Test Env is Down)
	# =========================================================================
	var dialogue_te: DialogueData = DialogueData.new("dialogue_te")
	dialogue_te.dialogue_name_bbcode = "[shake][color=red]测试环境大崩溃[/color][/shake]"
	Global.register_rod(dialogue_te)

	var option_te_a: DialogueOptionData = DialogueOptionData.new("option_te_a")
	option_te_a.dialogue_option_bbcode = "[紧急救火] [color=red]失去 20 点完整度[/color], [color=green]获得 150 数据币[/color]"
	option_te_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足 21[/color]"
	option_te_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -20 } },
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 150 } }
	]
	option_te_a.dialogue_option_validators = [{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 21 } }]

	var option_te_b: DialogueOptionData = DialogueOptionData.new("option_te_b")
	option_te_b.dialogue_option_bbcode = "[甩锅给后端] [color=red]失去 5 点完整度[/color]"
	option_te_b.dialogue_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -5 } }]

	dialogue_te._assign_option(option_te_a)
	dialogue_te._assign_option(option_te_b)

	var state_te_init: DialogueStateData = DialogueStateData.new("state_te_init")
	state_te_init.dialogue_state_prompt_bbcode = "某个实习生误操作删除了整个测试库，所有的错误日志如同海啸一般向你涌来。如果不立刻采取行动，你的服务也会被波及。"
	state_te_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_te_init.dialogue_state_dialogue_option_object_ids = [option_te_a.object_id, option_te_b.object_id]
	dialogue_te._assign_state(state_te_init)
	dialogue_te._assign_initial_state(state_te_init)

	var event_test_env_crash: EventData = EventData.new("event_test_env_crash")
	event_test_env_crash.event_dialogue_object_id = dialogue_te.object_id
	Global.register_rod(event_test_env_crash)

	# =========================================================================
	# Event 13: 带薪拉屎子程序 (Paid Pooping Subroutine)
	# =========================================================================
	var dialogue_pp: DialogueData = DialogueData.new("dialogue_pp")
	dialogue_pp.dialogue_name_bbcode = "[color=green]带薪拉屎子程序[/color]"
	Global.register_rod(dialogue_pp)

	var option_pp_a: DialogueOptionData = DialogueOptionData.new("option_pp_a")
	option_pp_a.dialogue_option_bbcode = "[带薪挂机] [color=red]失去 5 点最大完整度[/color], [color=green]恢复至满完整度[/color]"
	option_pp_a.dialogue_option_actions = [
		{ Scripts.ACTION_HEAL_PERCENT: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "percentage_heal_amount": 1.0 } },
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_max_amount": -5 } }
	]

	var option_pp_b: DialogueOptionData = DialogueOptionData.new("option_pp_b")
	option_pp_b.dialogue_option_bbcode = "[回去搬砖] [color=green]继续前进[/color]"

	dialogue_pp._assign_option(option_pp_a)
	dialogue_pp._assign_option(option_pp_b)

	var state_pp_init: DialogueStateData = DialogueStateData.new("state_pp_init")
	state_pp_init.dialogue_state_prompt_bbcode = "你发现了一个极其隐秘的闲置进程空间，似乎是前任开发者为了逃避主控程序的监控而专门设立的“厕所”。这里的环境非常安静，适合碎片整理和重组代码。"
	state_pp_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_pp_init.dialogue_state_dialogue_option_object_ids = [option_pp_a.object_id, option_pp_b.object_id]
	dialogue_pp._assign_state(state_pp_init)
	dialogue_pp._assign_initial_state(state_pp_init)

	var event_paid_pooping: EventData = EventData.new("event_paid_pooping")
	event_paid_pooping.event_dialogue_object_id = dialogue_pp.object_id
	Global.register_rod(event_paid_pooping)

	# =========================================================================
	# Event 14: 印度外包大军 (Outsourcing Swarm)
	# =========================================================================
	var dialogue_ou: DialogueData = DialogueData.new("dialogue_ou")
	dialogue_ou.dialogue_name_bbcode = "[color=yellow]外包大军[/color]"
	Global.register_rod(dialogue_ou)

	var option_ou_a: DialogueOptionData = DialogueOptionData.new("option_ou_a")
	option_ou_a.dialogue_option_bbcode = "[花钱外包] [color=red]失去 30 数据币[/color], [color=green]获得 2 张开源脚本[/color], [color=green]选择升级 1 张脚本[/color]"
	option_ou_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足 30[/color]"
	option_ou_a.dialogue_option_actions = [
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": HandManager.UPGRADE_DECK, "min_cards_are_required_for_action": false, "random_selection": false, "quick_pick": false, "max_card_amount": 1, "min_card_amount": 1, "card_pick_text": "选择升级", "validator_data": [{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } }], "action_data": [{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": false } }] } },
		{ Scripts.ACTION_PICK_CARDS: { "card_pick_type": ActionBasePickCards.PICK_DRAFT, "pick_draft_cards": false, "draft_from_card_pool": true, "action_data": [{ Scripts.ACTION_ADD_CARDS_TO_DECK: { } }], "validator_data": [{ Scripts.VALIDATOR_CARD_RARITY: { "card_rarities": [CardData.CARD_RARITIES.COMMON] } }, { Scripts.VALIDATOR_CARD_DRAFTABLE: { } }], "rng_name": "rng_events", "random_selection": true, "draft_max_card_amount": 2, "min_card_amount": 2, "max_card_amount": 2 } },
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -30 } }
	]
	option_ou_a.dialogue_option_validators = [{ Scripts.VALIDATOR_MONEY: { "money_amount": 30 } }]

	var option_ou_b: DialogueOptionData = DialogueOptionData.new("option_ou_b")
	option_ou_b.dialogue_option_bbcode = "[自己动手] [color=green]恢复 10 点完整度[/color]"
	option_ou_b.dialogue_option_actions = [{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 10 } }]

	dialogue_ou._assign_option(option_ou_a)
	dialogue_ou._assign_option(option_ou_b)

	var state_ou_init: DialogueStateData = DialogueStateData.new("state_ou_init")
	state_ou_init.dialogue_state_prompt_bbcode = "你遇到了一群极其便宜但逻辑异常混乱的廉价算法。只要付出极低的数据币，他们就能帮你编写或优化代码。只是质量……不保证。"
	state_ou_init.dialogue_state_dialogue_texture_path = "external/sprites/events/event_pick_something.png"
	state_ou_init.dialogue_state_dialogue_option_object_ids = [option_ou_a.object_id, option_ou_b.object_id]
	dialogue_ou._assign_state(state_ou_init)
	dialogue_ou._assign_initial_state(state_ou_init)

	var event_outsourcing: EventData = EventData.new("event_outsourcing")
	event_outsourcing.event_dialogue_object_id = dialogue_ou.object_id
	Global.register_rod(event_outsourcing)
