## 第一章：初始化 — 关卡、事件池、专属敌人定义
class_name GlobalProdDataGeneratorActOne
extends RefCounted

static func add_enemies() -> void:
	const DIFFICULTY_STARTING: int = 0
	const DIFFICULTY_MINIBOSS_ENEMIES_HARDER: int = 2
	const DIFFICULTY_BOSS_ENEMIES_HARDER: int = 3

	# 递归风暴 — 重击型精英（无限递归导致栈溢出般的伤害）
	var enemy_act_1_miniboss_1: EnemyData = EnemyData.new("enemy_act_1_miniboss_1")
	enemy_act_1_miniboss_1.add_health_bounds(100, 100)
	enemy_act_1_miniboss_1.add_health_bounds(120, 120, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_1_miniboss_1.add_health_bounds(135, 135, 4)
	enemy_act_1_miniboss_1.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_1_miniboss_1.enemy_name = "递归妖"
	enemy_act_1_miniboss_1.enemy_texture_path = "sprites/enemies/act1/enemy_recursion.png"
	enemy_act_1_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_act_1_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 18, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 22, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_act_1_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 8, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 10, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)

	var _enemy_act_1_miniboss_1_anim: AnimationData = enemy_act_1_miniboss_1.add_standard_animations(
		["sprites/enemies/act1/enemy_recursion.png"],
	)

	Global.register_rod(enemy_act_1_miniboss_1)

	# 竞态条件 — 双体精英（两个进程竞争资源，交替攻击）
	var enemy_act_1_miniboss_2: EnemyData = EnemyData.new("enemy_act_1_miniboss_2")
	enemy_act_1_miniboss_2.add_health_bounds(45, 55)
	enemy_act_1_miniboss_2.add_health_bounds(70, 80, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_1_miniboss_2.add_health_bounds(85, 95, 4)
	enemy_act_1_miniboss_2.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_1_miniboss_2.enemy_name = "竞态鬼"
	enemy_act_1_miniboss_2.enemy_texture_path = "sprites/enemies/act1/enemy_race_condition.png"
	enemy_act_1_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_act_1_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 8, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 10, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_act_1_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 4, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 5, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)

	var _enemy_act_1_miniboss_2_anim: AnimationData = enemy_act_1_miniboss_2.add_standard_animations(
		["sprites/enemies/act1/enemy_race_condition.png"],
	)

	Global.register_rod(enemy_act_1_miniboss_2)

	# INITIALIZE CORE GUARDIAN PROGRAM - Overheat Engine Boss
	var enemy_act_1_boss_1: EnemyData = EnemyData.new("enemy_act_1_boss_1")
	enemy_act_1_boss_1.enemy_name = "核心守护程序"
	enemy_act_1_boss_1.add_health_bounds(200, 200)
	enemy_act_1_boss_1.add_health_bounds(250, 250, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_act_1_boss_1.add_health_bounds(280, 280, 5)
	enemy_act_1_boss_1.enemy_type = EnemyData.ENEMY_TYPES.BOSS
	enemy_act_1_boss_1.enemy_texture_path = "sprites/enemies/act1/boss_guardian.png"
	
	# Initial status effects: threshold starts at 40
	enemy_act_1_boss_1.enemy_initial_status_effects["status_effect_damage_threshold"] = 40
	# Curiosity - memory monitor (gain 1 str per card play if configured for skill/power)
	enemy_act_1_boss_1.enemy_initial_status_effects["status_effect_curiosity"] = 1
	enemy_act_1_boss_1.enemy_initial_status_custom_values["status_effect_curiosity"] = {
		"curiosity_trigger_card_types": [CardData.CARD_TYPES.SKILL],
		"curiosity_reaction_status_id": "status_effect_damage_increase",
		"curiosity_reaction_amount": 1,
		"curiosity_trigger_threshold": 6,
		"curiosity_current_counter": 0
	}
	enemy_act_1_boss_1.enemy_initial_status_custom_values["status_effect_damage_threshold"] = {
		"damage_threshold_increase_amount": 20,
		"damage_threshold_target_intent": "intent_overheat"
	}
	
	# Phase 1: Suppression (Attack and deck pollution)
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_suppress": 1}),
		]
	)
	var boss_1_pollute_actions: Array[Dictionary] = [
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_status_burn",
				"number_of_cards": 1,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY,
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"shuffle_cards": true
						}
					}
				]
			}
		}
	]
	var boss_1_pollute_actions_d3: Array[Dictionary] = [
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_status_burn",
				"number_of_cards": 1,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY,
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"shuffle_cards": true
						}
					}
				]
			}
		},
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_status_dazed",
				"number_of_cards": 1,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY,
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"shuffle_cards": true
						}
					}
				]
			}
		}
	]
	
	var boss_1_repair_actions_d3: Array[Dictionary] = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"status_charge_amount": 10,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY
			}
		}
	]
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_suppress", DIFFICULTY_STARTING, 3, 2, "", 5, "", {"intent_pollute": 1}),
			EnemyIntentData.new("intent_suppress", DIFFICULTY_BOSS_ENEMIES_HARDER, 4, 2, "", 5, "", {"intent_pollute": 1}),
		]
	)
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_pollute", DIFFICULTY_STARTING, 5, 1, "", 10, "", {"intent_suppress": 1}, boss_1_pollute_actions, [], "向抽牌堆洗入 1 张过载发热"),
			EnemyIntentData.new("intent_pollute", 3, 5, 1, "", 10, "", {"intent_repair": 1}, boss_1_pollute_actions_d3, [], "向抽牌堆洗入发热与垃圾数据"),
		]
	)
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_repair", 3, 0, 0, "", 0, "", {"intent_suppress": 1}, boss_1_repair_actions_d3, [], "张开过载防火墙"),
		]
	)
	
	# Phase 2: Overheat (Stun -> System Reset)
	var boss_1_stun_actions: Array[Dictionary] = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"status_charge_amount": 2,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY
			}
		}
	]
	var boss_1_stun_actions_d5: Array[Dictionary] = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_vulnerable",
				"status_charge_amount": 2,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": 0.0
			}
		},
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_overshield",
				"status_charge_amount": 15,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY
			}
		}
	]
	
	var boss_1_system_reset_actions_d5: Array[Dictionary] = [
		{
			Scripts.ACTION_CREATE_CARDS: {
				"created_card_object_id": "card_status_burn",
				"number_of_cards": 2,
				"time_delay": EnemyData.ENEMY_ATTACK_DELAY,
				"action_data": [
					{
						Scripts.ACTION_ADD_CARDS_TO_DRAW: {
							"shuffle_cards": true
						}
					}
				]
			}
		}
	]
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_overheat", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_system_reset": 1}, boss_1_stun_actions, [EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING]),
			EnemyIntentData.new("intent_overheat", 5, 0, 0, "", 0, "", {"intent_system_reset": 1}, boss_1_stun_actions_d5, [EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING, EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING], "系统重置并激活高阶防火墙"),
		]
	)
	enemy_act_1_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_system_reset", DIFFICULTY_STARTING, 25, 1, "", 0, "", {"intent_suppress": 1}),
			EnemyIntentData.new("intent_system_reset", DIFFICULTY_BOSS_ENEMIES_HARDER, 30, 1, "", 0, "", {"intent_suppress": 1}),
			EnemyIntentData.new("intent_system_reset", 5, 35, 1, "", 0, "", {"intent_suppress": 1}, boss_1_system_reset_actions_d5, [], "向抽牌堆洗入 2 张过载发热"),
		]
	)
	
	enemy_act_1_boss_1.enemy_difficulty_to_enemy_modfiers = {
		"3": {
			"enemy_initial_status_effects": {"status_effect_damage_threshold": 50},
			"enemy_initial_status_custom_values": {
				"status_effect_damage_threshold": { "damage_threshold_increase_amount": 25 },
				"status_effect_curiosity": { "curiosity_trigger_threshold": 5 }
			}
		},
		"5": {
			"enemy_initial_status_effects": {"status_effect_damage_threshold": 50},
			"enemy_initial_status_custom_values": {
				"status_effect_damage_threshold": { "damage_threshold_increase_amount": 25 },
				"status_effect_curiosity": {
					"curiosity_trigger_card_types": [CardData.CARD_TYPES.SKILL, CardData.CARD_TYPES.ATTACK],
					"curiosity_trigger_threshold": 4
				}
			}
		}
	}

	var _enemy_act_1_boss_1_anim: AnimationData = enemy_act_1_boss_1.add_standard_animations(
		["sprites/enemies/act1/boss_guardian.png"],
		[
			"sprites/enemies/act1/boss_guardian/attack/1.png",
			"sprites/enemies/act1/boss_guardian/attack/2.png",
			"sprites/enemies/act1/boss_guardian/attack/3.png",
			"sprites/enemies/act1/boss_guardian/attack/4.png",
			"sprites/enemies/act1/boss_guardian/attack/5.png",
			"sprites/enemies/act1/boss_guardian/attack/6.png",
		],
		[
			"sprites/enemies/act1/boss_guardian/death/1.png",
			"sprites/enemies/act1/boss_guardian/death/2.png",
			"sprites/enemies/act1/boss_guardian/death/3.png",
			"sprites/enemies/act1/boss_guardian/death/4.png",
			"sprites/enemies/act1/boss_guardian/death/5.png",
			"sprites/enemies/act1/boss_guardian/death/6.png",
		],
	)

	Global.register_rod(enemy_act_1_boss_1)

	# 堆栈碎片 — 被 Boss 召唤的爪牙（栈内存中残留的碎片代码）
	var enemy_minion_1: EnemyData = EnemyData.new("enemy_minion_1")
	enemy_minion_1.add_health_bounds(4, 4)
	enemy_minion_1.add_health_bounds(7, 7, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_minion_1.enemy_name = "碎码兵"
	enemy_minion_1.enemy_texture_path = "sprites/enemies/act1/minion_code_fragment.png"
	enemy_minion_1.enemy_is_minion = true
	enemy_minion_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1}),
		],
	)
	enemy_minion_1.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER, 8, 1, "", 5, "", {"intent_attack": 1}),
		],
	)

	var _enemy_minion_1_anim: AnimationData = enemy_minion_1.add_standard_animations(
		["sprites/enemies/act1/minion_code_fragment.png"],
	)

	Global.register_rod(enemy_minion_1)

	# 指针残骸 — 被 Boss 召唤的爪牙（野指针指向的垃圾数据）
	var enemy_minion_2: EnemyData = EnemyData.new("enemy_minion_2")
	enemy_minion_2.add_health_bounds(3, 5)
	enemy_minion_2.add_health_bounds(6, 8, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_minion_2.enemy_name = "残骸怪"
	enemy_minion_2.enemy_texture_path = "sprites/enemies/act1/minion_pointer_remnant.png"
	enemy_minion_2.enemy_is_minion = true
	enemy_minion_2.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1}),
		],
	)
	enemy_minion_2.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 3, 1, "", 5, "", {"intent_attack": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_BOSS_ENEMIES_HARDER, 5, 1, "", 5, "", {"intent_attack": 1}),
		],
	)

	var _enemy_minion_2_anim: AnimationData = enemy_minion_2.add_standard_animations(
		["sprites/enemies/act1/minion_pointer_remnant.png"],
	)

	Global.register_rod(enemy_minion_2)


static func add_events() -> void:
	## Act 1 Combat
	var event_act_1_easy_combat_1: EventData = EventData.new("event_act_1_easy_combat_1")
	event_act_1_easy_combat_1.event_death_message_bbcode = "被系统初始化进程中断"
	event_act_1_easy_combat_1.event_weighted_enemy_object_ids = [
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
	]

	Global.register_rod(event_act_1_easy_combat_1)

	var event_act_1_easy_combat_2: EventData = EventData.new("event_act_1_easy_combat_2")
	event_act_1_easy_combat_2.event_weighted_enemy_object_ids = [
		{"enemy_3": 1},
	]

	Global.register_rod(event_act_1_easy_combat_2)

	var event_act_1_easy_combat_3: EventData = EventData.new("event_act_1_easy_combat_3")
	event_act_1_easy_combat_3.event_weighted_enemy_object_ids = [
		{"enemy_1": 1},
		{"enemy_2": 1},
	]

	Global.register_rod(event_act_1_easy_combat_3)

	var event_act_1_easy_combat_4: EventData = EventData.new("event_act_1_easy_combat_4")
	event_act_1_easy_combat_4.event_weighted_enemy_object_ids = [
		{"enemy_4": 1},
	]

	Global.register_rod(event_act_1_easy_combat_4)

	var event_act_1_miniboss_1: EventData = EventData.new("event_act_1_miniboss_1")
	event_act_1_miniboss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_1": 1},
	]

	Global.register_rod(event_act_1_miniboss_1)

	var event_act_1_miniboss_2: EventData = EventData.new("event_act_1_miniboss_2")
	event_act_1_miniboss_2.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_2": 1},
		{"enemy_act_1_miniboss_2": 1},
	]

	Global.register_rod(event_act_1_miniboss_2)

	var event_act_1_miniboss_3: EventData = EventData.new("event_act_1_miniboss_3")
	event_act_1_miniboss_3.event_weighted_enemy_object_ids = [
		{"enemy_act_1_miniboss_1": 1},
	]

	Global.register_rod(event_act_1_miniboss_3)

	var event_act_1_boss_1: EventData = EventData.new("event_act_1_boss_1")
	event_act_1_boss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_1_boss_1": 1},
	]
	event_act_1_boss_1.event_enemy_placement_is_automatic = false
	event_act_1_boss_1.event_enemy_placement_positions = [[0, 0], [180, 0], [360, 0]]
	event_act_1_boss_1.event_death_message_bbcode = "被守护兽彻底抹除"

	Global.register_rod(event_act_1_boss_1)

	## Act 1 Dialogue Events

	### Event Pools
	# act 1 easy pool
	var event_pool_act_1_easy: EventPoolData = EventPoolData.new("event_pool_act_1_easy")
	event_pool_act_1_easy.add_events_to_pool(
		event_act_1_easy_combat_1,
		[
			event_act_1_easy_combat_1,
			event_act_1_easy_combat_2,
			event_act_1_easy_combat_3,
			event_act_1_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_1_easy)

	# act 1 hard pool
	var event_pool_act_1_hard: EventPoolData = EventPoolData.new("event_pool_act_1_hard")
	event_pool_act_1_hard.add_events_to_pool(
		event_act_1_easy_combat_1,
		[
			event_act_1_easy_combat_1,
			event_act_1_easy_combat_2,
			event_act_1_easy_combat_3,
			event_act_1_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_1_hard)

	var event_abandoned_server: EventData = Global.get_event_data("event_abandoned_server")
	var event_darkweb_market: EventData = Global.get_event_data("event_darkweb_market")
	var event_trojan_trap: EventData = Global.get_event_data("event_trojan_trap")
	var event_wandering_ai: EventData = Global.get_event_data("event_wandering_ai")
	
	var event_product_manager: EventData = Global.get_event_data("event_product_manager")
	var event_rm_rf: EventData = Global.get_event_data("event_rm_rf")
	var event_996_blessing: EventData = Global.get_event_data("event_996_blessing")
	var event_code_review: EventData = Global.get_event_data("event_code_review")
	var event_open_source: EventData = Global.get_event_data("event_open_source")
	var event_equity: EventData = Global.get_event_data("event_equity")
	var event_spaghetti_code: EventData = Global.get_event_data("event_spaghetti_code")
	var event_test_env_crash: EventData = Global.get_event_data("event_test_env_crash")
	var event_paid_pooping: EventData = Global.get_event_data("event_paid_pooping")
	var event_outsourcing: EventData = Global.get_event_data("event_outsourcing")

	# act 1 dialogue event pool
	var event_pool_act_1_dialogue: EventPoolData = EventPoolData.new("event_pool_act_1_dialogue")
	event_pool_act_1_dialogue.add_events_to_pool(
		event_abandoned_server,
		[
			 event_abandoned_server,
			 event_darkweb_market,
			 event_trojan_trap,
			 event_wandering_ai,
			 event_product_manager,
			 event_rm_rf,
			 event_996_blessing,
			 event_code_review,
			 event_open_source,
			 event_equity,
			 event_spaghetti_code,
			 event_test_env_crash,
			 event_paid_pooping,
			 event_outsourcing,
		],
	)

	Global.register_rod(event_pool_act_1_dialogue)

	# act 1 miniboss pool
	var event_pool_act_1_miniboss: EventPoolData = EventPoolData.new("event_pool_act_1_miniboss")
	event_pool_act_1_miniboss.add_events_to_pool(
		event_act_1_miniboss_1,
		[
			event_act_1_miniboss_1,
			event_act_1_miniboss_2,
		],
	)
	Global.register_rod(event_pool_act_1_miniboss)

	# act 1 boss pool
	var event_pool_act_1_boss: EventPoolData = EventPoolData.new("event_pool_act_1_boss")
	event_pool_act_1_boss.add_events_to_pool(
		event_act_1_boss_1,
		[
			event_act_1_boss_1,
		],
	)

	Global.register_rod(event_pool_act_1_boss)


static func add_act() -> void:
	var act_1: ActData = ActData.new("act_1")
	act_1.act_name = "第一章：初始化"
	act_1.act_codex_number = 1
	act_1.act_next_act_ids = ["act_2"]
	act_1.act_action_script_path = Scripts.ACTION_GENERATE_ACT
	act_1.act_map_floor_templates = ActData.default_floor_templates()
	
	act_1.act_music_ambient_file_path = "res://sounds/bgm/bgm_act_1.mp3"
	act_1.act_music_combat_file_path = "res://sounds/bgm/bgm_act_1.mp3"
	act_1.act_music_miniboss_file_path = "res://sounds/bgm/bgm_act_1.mp3"
	act_1.act_music_boss_file_path = "res://sounds/bgm/bgm_boss.mp3"
	
	act_1.act_easy_combat_event_pool_object_id = "event_pool_act_1_easy"
	act_1.act_hard_combat_event_pool_object_id = "event_pool_act_1_hard"
	act_1.act_miniboss_event_pool_object_id = "event_pool_act_1_miniboss"
	act_1.act_non_combat_event_pool_object_id = "event_pool_act_1_dialogue"
	act_1.act_boss_event_pool_object_id = "event_pool_act_1_boss"
	act_1.act_background_texture_path = "sprites/act/1/bg_act_1_init.png"
	Global.register_rod(act_1)
