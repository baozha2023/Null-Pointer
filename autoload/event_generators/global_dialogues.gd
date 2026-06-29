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
	option_server_a.dialogue_option_bbcode = "[color=red]失去 15 点完整度[/color] 并且 [color=green]随机获得 1 张高阶卡牌[/color]"
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
	option_darkweb_a.dialogue_option_bbcode = "[color=red]失去 75 数据币[/color] 并且 [color=green]获得一个随机组件（遗物）[/color]"
	option_darkweb_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 数据币不足 75[/color]"
	option_darkweb_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": -75 } },
		{ Scripts.ACTION_ADD_ARTIFACT: { "random_artifact": true } },
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

	# Option A: 暴力破解 (获得 250 钱，失去 25 完整度)
	var option_trojan_a: DialogueOptionData = DialogueOptionData.new("option_trojan_a")
	option_trojan_a.dialogue_option_bbcode = "[暴力破解] [color=red]失去 25 点完整度[/color] 并且 [color=green]掠夺 250 数据币[/color]"
	option_trojan_a.dialogue_option_failed_validator_bbcode = "[color=grey][锁定]: 完整度不足以承受反噬[/color]"
	option_trojan_a.dialogue_option_actions = [
		{ Scripts.ACTION_ADD_HEALTH: { "target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": -25 } },
		{ Scripts.ACTION_ADD_MONEY: { "money_amount": 250 } },
	]
	option_trojan_a.dialogue_option_validators = [
		{ Scripts.VALIDATOR_PLAYER_HEALTH: { "health_amount": 26 } },
	]
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
	option_ai_a.dialogue_option_bbcode = "[投入资源修复] [color=red]失去 100 数据币[/color] 并且 [color=green]恢复 30 完整度，最大完整度提升 5[/color]"
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
