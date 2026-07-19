## 第二章：渗透 — 敌人、事件池、Boss
## 主题：突破防火墙，面对扫描器、守护进程等安全系统
class_name GlobalProdDataGeneratorActTwo
extends RefCounted

static func add_enemies() -> void:
	const DIFFICULTY_STARTING: int = 0
	const DIFFICULTY_STANDARD_ENEMIES_HARDER: int = 1
	const DIFFICULTY_MINIBOSS_ENEMIES_HARDER: int = 2
	const DIFFICULTY_BOSS_ENEMIES_HARDER: int = 3
	const DIFFICULTY_MINIBOSS_ENEMIES_HARDER_2: int = 4
	const DIFFICULTY_BOSS_ENEMIES_HARDER_2: int = 5

	#region 普通敌人

	# 防火墙 — 高护盾 + 尖刺（反伤）
	var enemy_act_2_firewall: EnemyData = EnemyData.new("enemy_act_2_firewall")
	enemy_act_2_firewall.add_health_bounds(18, 22)
	enemy_act_2_firewall.add_health_bounds(25, 30, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_2_firewall.enemy_name = "火墙兵"
	enemy_act_2_firewall.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_firewall.png"
	enemy_act_2_firewall.enemy_initial_status_effects = {"status_effect_pointy": 3}
	enemy_act_2_firewall.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_block": 2, "intent_attack": 1}),
		],
	)
	enemy_act_2_firewall.add_intent_state(
		[
			EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 0, 0, "", 8, "", {"intent_block": 1, "intent_attack": 1}),
			EnemyIntentData.new("intent_block", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 10, "", {"intent_block": 1, "intent_attack": 1}),
		],
	)
	enemy_act_2_firewall.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_block": 2, "intent_attack": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 7, 1, "", 0, "", {"intent_block": 2, "intent_attack": 1}),
		],
	)



	var _enemy_act_2_firewall_anim = enemy_act_2_firewall.add_standard_animations([enemy_act_2_firewall.enemy_texture_path])
	Global.register_rod(enemy_act_2_firewall)

	# 扫描器 — 标记脆弱 + 攻击
	var enemy_act_2_scanner: EnemyData = EnemyData.new("enemy_act_2_scanner")
	enemy_act_2_scanner.add_health_bounds(12, 16)
	enemy_act_2_scanner.add_health_bounds(15, 19, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_2_scanner.enemy_name = "扫描兵"
	enemy_act_2_scanner.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_scanner.png"
	var scanner_vuln_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var scanner_vuln_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_2_scanner.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_scan": 1}),
		],
	)
	enemy_act_2_scanner.add_intent_state(
		[
			EnemyIntentData.new("intent_scan", DIFFICULTY_STARTING, 7, 1, "", 0, "", {"intent_attack": 1}, scanner_vuln_actions_1),
			EnemyIntentData.new("intent_scan", DIFFICULTY_STANDARD_ENEMIES_HARDER, 9, 1, "", 0, "", {"intent_attack": 1}, scanner_vuln_actions_2),
		],
	)
	enemy_act_2_scanner.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 5, 2, "", 0, "", {"intent_scan": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 2, "", 0, "", {"intent_scan": 1}),
		],
	)



	var _enemy_act_2_scanner_anim = enemy_act_2_scanner.add_standard_animations([enemy_act_2_scanner.enemy_texture_path])
	Global.register_rod(enemy_act_2_scanner)

	# 守护进程 — 混合型：虚弱 + 攻击
	var enemy_act_2_warden: EnemyData = EnemyData.new("enemy_act_2_warden")
	enemy_act_2_warden.add_health_bounds(20, 25)
	enemy_act_2_warden.add_health_bounds(26, 32, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_2_warden.enemy_name = "监守者"
	enemy_act_2_warden.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_warden.png"
	var warden_weaken_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var warden_weaken_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_2_warden.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_debuff": 1, "intent_attack": 1}),
		],
	)
	enemy_act_2_warden.add_intent_state(
		[
			EnemyIntentData.new("intent_debuff", DIFFICULTY_STARTING, 6, 1, "", 0, "", {"intent_attack": 1}, warden_weaken_actions_1),
			EnemyIntentData.new("intent_debuff", DIFFICULTY_STANDARD_ENEMIES_HARDER, 8, 1, "", 0, "", {"intent_attack": 1}, warden_weaken_actions_2),
		],
	)
	enemy_act_2_warden.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 6, 1, "", 0, "", {"intent_debuff": 1, "intent_attack": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 8, 1, "", 0, "", {"intent_debuff": 1, "intent_attack": 1}),
		],
	)



	var _enemy_act_2_warden_anim = enemy_act_2_warden.add_standard_animations([enemy_act_2_warden.enemy_texture_path])
	Global.register_rod(enemy_act_2_warden)

	# 特洛伊木马 — 重击型 + 死亡腐蚀
	var enemy_act_2_trojan: EnemyData = EnemyData.new("enemy_act_2_trojan")
	enemy_act_2_trojan.add_health_bounds(35, 42)
	enemy_act_2_trojan.add_health_bounds(45, 55, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_2_trojan.enemy_name = "特洛伊木马"
	enemy_act_2_trojan.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_trojan.png"
	enemy_act_2_trojan.enemy_actions_on_death = [
		{
			Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 8, "status_effect_object_id": "status_effect_corrosion", "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER},
		},
	]
	enemy_act_2_trojan.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1, "intent_block": 1}),
		],
	)
	enemy_act_2_trojan.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 8, 1, "", 0, "", {"intent_block": 1, "intent_attack": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 13, 1, "", 0, "", {"intent_block": 1, "intent_attack": 1}),
		],
	)
	enemy_act_2_trojan.add_intent_state(
		[
			EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 0, 0, "", 8, "", {"intent_attack": 1}),
			EnemyIntentData.new("intent_block", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 10, "", {"intent_attack": 1}),
		],
	)



	var _enemy_act_2_trojan_anim = enemy_act_2_trojan.add_standard_animations([enemy_act_2_trojan.enemy_texture_path])
	Global.register_rod(enemy_act_2_trojan)

	#endregion

	#region 精英敌人

	# 精英怪 1：数据风暴 — 过热 + 高伤 + 自增益
	var enemy_act_2_miniboss_1: EnemyData = EnemyData.new("enemy_act_2_miniboss_1")
	enemy_act_2_miniboss_1.add_health_bounds(110, 110)
	enemy_act_2_miniboss_1.add_health_bounds(135, 135, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_2_miniboss_1.add_health_bounds(150, 150, DIFFICULTY_MINIBOSS_ENEMIES_HARDER_2)
	enemy_act_2_miniboss_1.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_2_miniboss_1.enemy_name = "风暴王"
	enemy_act_2_miniboss_1.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_miniboss_1.png"
	var storm_overheat_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var storm_overheat_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_2_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_burn": 1}),
		],
	)
	enemy_act_2_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_burn", DIFFICULTY_STARTING, 18, 1, "", 0, "", {"intent_heavy": 1}, storm_overheat_actions_1),
			EnemyIntentData.new("intent_burn", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 22, 1, "", 0, "", {"intent_heavy": 1}, storm_overheat_actions_2),
		],
	)
	enemy_act_2_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_heavy", DIFFICULTY_STARTING, 6, 3, "", 0, "", {"intent_burn": 1}),
			EnemyIntentData.new("intent_heavy", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 8, 3, "", 0, "", {"intent_burn": 1}),
		],
	)



	var _enemy_act_2_miniboss_1_anim = enemy_act_2_miniboss_1.add_standard_animations([enemy_act_2_miniboss_1.enemy_texture_path])
	Global.register_rod(enemy_act_2_miniboss_1)

	# 精英怪 2：双重验证 — 脆弱 + 多重攻击
	var enemy_act_2_miniboss_2: EnemyData = EnemyData.new("enemy_act_2_miniboss_2")
	enemy_act_2_miniboss_2.add_health_bounds(65, 75)
	enemy_act_2_miniboss_2.add_health_bounds(85, 95, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_2_miniboss_2.add_health_bounds(95, 105, DIFFICULTY_MINIBOSS_ENEMIES_HARDER_2)
	enemy_act_2_miniboss_2.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_2_miniboss_2.enemy_name = "验证者"
	enemy_act_2_miniboss_2.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_miniboss_2.png"
	var auth_vuln_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var auth_vuln_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_2_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_mark": 1}),
		],
	)
	enemy_act_2_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_mark", DIFFICULTY_STARTING, 9, 1, "", 0, "", {"intent_strike": 1}, auth_vuln_actions_1),
			EnemyIntentData.new("intent_mark", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 12, 1, "", 0, "", {"intent_strike": 1}, auth_vuln_actions_2),
		],
	)
	enemy_act_2_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_strike", DIFFICULTY_STARTING, 5, 3, "", 0, "", {"intent_mark": 1}),
			EnemyIntentData.new("intent_strike", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 7, 3, "", 0, "", {"intent_mark": 1}),
		],
	)



	var _enemy_act_2_miniboss_2_anim = enemy_act_2_miniboss_2.add_standard_animations([enemy_act_2_miniboss_2.enemy_texture_path])
	Global.register_rod(enemy_act_2_miniboss_2)

	#endregion

	#region Boss — 防火墙守护者

	var enemy_act_2_boss_1: EnemyData = EnemyData.new("enemy_act_2_boss_1")
	enemy_act_2_boss_1.add_health_bounds(210, 210)
	enemy_act_2_boss_1.add_health_bounds(260, 260, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_act_2_boss_1.add_health_bounds(290, 290, DIFFICULTY_BOSS_ENEMIES_HARDER_2)
	enemy_act_2_boss_1.enemy_type = EnemyData.ENEMY_TYPES.BOSS
	enemy_act_2_boss_1.enemy_combat_scale = 1.55
	enemy_act_2_boss_1.enemy_name = "火墙守将"
	enemy_act_2_boss_1.enemy_texture_path = "sprites/enemies/act2/enemy_act_2_boss_1.png"

	# 初始 → 召唤
	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_summon": 1}),
		],
	)

	# 召唤 2 只防火墙
	var boss_2_summon_actions: Array[Dictionary] = [
		{
			Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1, 2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_act_2_firewall", "enemy_act_2_firewall"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "is_minion": true},
		},
	]
	var boss_2_summon_actions_d5: Array[Dictionary] = [
		{
			Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1, 2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_act_2_firewall", "enemy_act_2_firewall"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT, "is_minion": true},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_pointy", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES}
		}
	]

	# 防御：加护盾 + 给自己上尖刺
	var boss_2_fortify_actions: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_pointy", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	var boss_2_fortify_actions_d3: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_pointy", "status_charge_amount": 5, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]

	# 扫描：易伤 + 虚弱
	var boss_2_scan_actions: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 2, "time_delay": 0.0, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var boss_2_scan_actions_d3: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 2, "time_delay": 0.0, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_dazed", "number_of_cards": 1, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]
	var boss_2_scan_actions_d5: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": 0.0, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_burn", "number_of_cards": 1, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]
	
	# 污染：轻微伤害 + 洗入垃圾数据
	var boss_2_pollute_actions: Array[Dictionary] = [
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_dazed", "number_of_cards": 1, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]
	var boss_2_pollute_actions_d3: Array[Dictionary] = [
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_dazed", "number_of_cards": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]

	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_summon", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_fortify": 1}, boss_2_summon_actions),
			EnemyIntentData.new("intent_summon", 5, 0, 0, "", 0, "", {"intent_fortify": 1}, boss_2_summon_actions_d5, [EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING]),
		],
	)

	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_fortify", DIFFICULTY_STARTING, 0, 0, "", 12, "", {"intent_scan": 1}, boss_2_fortify_actions),
			EnemyIntentData.new("intent_fortify", 3, 0, 0, "", 15, "", {"intent_scan": 1}, boss_2_fortify_actions_d3),
		],
	)

	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_scan", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_breach": 1}, boss_2_scan_actions, [EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING]),
			EnemyIntentData.new("intent_scan", 3, 0, 0, "", 0, "", {"intent_breach": 1}, boss_2_scan_actions_d3, [EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING]),
			EnemyIntentData.new("intent_scan", 5, 0, 0, "", 0, "", {"intent_breach": 1}, boss_2_scan_actions_d5, [EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING]),
		],
	)
	
	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_breach", DIFFICULTY_STARTING, 4, 3, "", 0, "", {"intent_pollute": 1}),
			EnemyIntentData.new("intent_breach", 3, 6, 3, "", 0, "", {"intent_pollute": 1}),
			EnemyIntentData.new("intent_breach", 5, 7, 3, "", 0, "", {"intent_pollute": 1}),
		],
	)
	
	enemy_act_2_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_pollute", DIFFICULTY_STARTING, 6, 1, "", 0, "", {"intent_fortify": 1}, boss_2_pollute_actions),
			EnemyIntentData.new("intent_pollute", 3, 6, 1, "", 0, "", {"intent_fortify": 1}, boss_2_pollute_actions_d3),
		],
	)

	enemy_act_2_boss_1.enemy_difficulty_to_enemy_modfiers = {
		"3": {
			"enemy_initial_status_effects": {"status_effect_damage_threshold": 60},
			"meta": {
				"damage_threshold_target_intent": "intent_breach",
				"damage_threshold_increase_amount": 30
			}
		},
		"5": {
			"enemy_initial_status_effects": {"status_effect_damage_threshold": 45},
			"meta": {
				"damage_threshold_target_intent": "intent_breach",
				"damage_threshold_increase_amount": 20
			}
		}
	}



	var _enemy_act_2_boss_1_anim = enemy_act_2_boss_1.add_standard_animations([enemy_act_2_boss_1.enemy_texture_path])
	Global.register_rod(enemy_act_2_boss_1)

	#endregion


static func add_events() -> void:
	## Act 2 Easy Combats
	var event_act_2_easy_combat_1: EventData = EventData.new("event_act_2_easy_combat_1")
	event_act_2_easy_combat_1.event_death_message_bbcode = "被渗透系统的安全协议拦截"
	event_act_2_easy_combat_1.event_weighted_enemy_object_ids = [
		{"enemy_act_2_scanner": 1, "enemy_act_2_firewall": 1, "enemy_act_2_warden": 1},
		{"enemy_1": 1, "enemy_2": 1, "enemy_3": 1},
		{"enemy_act_2_scanner": 1, "enemy_act_2_firewall": 1, "enemy_4": 1},
	]

	Global.register_rod(event_act_2_easy_combat_1)

	var event_act_2_easy_combat_2: EventData = EventData.new("event_act_2_easy_combat_2")
	event_act_2_easy_combat_2.event_weighted_enemy_object_ids = [
		{"enemy_act_2_firewall": 1},
		{"enemy_act_2_scanner": 1},
	]

	Global.register_rod(event_act_2_easy_combat_2)

	var event_act_2_easy_combat_3: EventData = EventData.new("event_act_2_easy_combat_3")
	event_act_2_easy_combat_3.event_weighted_enemy_object_ids = [
		{"enemy_act_2_warden": 1},
		{"enemy_act_2_warden": 1},
	]

	Global.register_rod(event_act_2_easy_combat_3)

	var event_act_2_easy_combat_4: EventData = EventData.new("event_act_2_easy_combat_4")
	event_act_2_easy_combat_4.event_weighted_enemy_object_ids = [
		{"enemy_act_2_trojan": 1},
		{"enemy_act_2_scanner": 1},
	]

	Global.register_rod(event_act_2_easy_combat_4)

	## Act 2 Minibosses
	var event_act_2_miniboss_1: EventData = EventData.new("event_act_2_miniboss_1")
	event_act_2_miniboss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_2_miniboss_1": 1},
	]

	Global.register_rod(event_act_2_miniboss_1)

	var event_act_2_miniboss_2: EventData = EventData.new("event_act_2_miniboss_2")
	event_act_2_miniboss_2.event_weighted_enemy_object_ids = [
		{"enemy_act_2_miniboss_2": 1},
		{"enemy_act_2_miniboss_2": 1},
	]

	Global.register_rod(event_act_2_miniboss_2)

	var event_act_2_miniboss_3: EventData = EventData.new("event_act_2_miniboss_3")
	event_act_2_miniboss_3.event_weighted_enemy_object_ids = [
		{"enemy_act_2_miniboss_1": 1},
		{"enemy_act_2_firewall": 1},
	]

	Global.register_rod(event_act_2_miniboss_3)

	## Act 2 Boss
	var event_act_2_boss_1: EventData = EventData.new("event_act_2_boss_1")
	event_act_2_boss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_2_boss_1": 1},
	]
	event_act_2_boss_1.event_enemy_slot_ids = [0]
	event_act_2_boss_1.event_death_message_bbcode = "被火墙守将彻底清除"

	Global.register_rod(event_act_2_boss_1)

	### Event Pools
	var event_pool_act_2_easy: EventPoolData = EventPoolData.new("event_pool_act_2_easy")
	event_pool_act_2_easy.add_events_to_pool(
		event_act_2_easy_combat_1,
		[
			event_act_2_easy_combat_1,
			event_act_2_easy_combat_2,
			event_act_2_easy_combat_3,
			event_act_2_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_2_easy)

	var event_pool_act_2_hard: EventPoolData = EventPoolData.new("event_pool_act_2_hard")
	event_pool_act_2_hard.add_events_to_pool(
		event_act_2_easy_combat_1,
		[
			event_act_2_easy_combat_1,
			event_act_2_easy_combat_2,
			event_act_2_easy_combat_3,
			event_act_2_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_2_hard)

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

	# act 2 dialogue event pool
	var event_pool_act_2_dialogue: EventPoolData = EventPoolData.new("event_pool_act_2_dialogue")
	event_pool_act_2_dialogue.add_events_to_pool(
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

	Global.register_rod(event_pool_act_2_dialogue)

	var event_pool_act_2_miniboss: EventPoolData = EventPoolData.new("event_pool_act_2_miniboss")
	event_pool_act_2_miniboss.add_events_to_pool(
		event_act_2_miniboss_1,
		[
			event_act_2_miniboss_1,
			event_act_2_miniboss_2,
		],
	)
	Global.register_rod(event_pool_act_2_miniboss)

	var event_pool_act_2_boss: EventPoolData = EventPoolData.new("event_pool_act_2_boss")
	event_pool_act_2_boss.add_events_to_pool(
		event_act_2_boss_1,
		[
			event_act_2_boss_1,
		],
	)

	Global.register_rod(event_pool_act_2_boss)


static func add_act() -> void:
	var act_2: ActData = ActData.new("act_2")
	act_2.act_name = "第二章：渗透"
	act_2.act_codex_number = 2
	act_2.act_next_act_ids = ["act_3"]
	act_2.act_action_script_path = Scripts.ACTION_GENERATE_ACT
	act_2.act_map_floor_templates = [
		{"min": 4, "max": 6, "pool": "hard", "fixed": []},                                # 1
		{"min": 4, "max": 6, "pool": "hard", "fixed": []},                                # 2
		{"min": 3, "max": 4, "pool": "hard", "fixed": []},                                # 3: 无保底
		{"min": 4, "max": 6, "pool": "hard", "fixed": ["TREASURE"]},                      # 4: 1 宝箱
		{"min": 4, "max": 6, "pool": "hard", "fixed": ["SHOP"]},                          # 5: 1 商店
		{"min": 3, "max": 4, "pool": "hard", "fixed": ["MINIBOSS", "REST_SITE"]},         # 6: 1 精英, 1 休息处
		{"min": 2, "max": 3, "pool": "hard", "fixed": []},                                # 7: 无保底
		{"min": 4, "max": 6, "pool": "hard", "fixed": ["MINIBOSS"]},                      # 8: 1 精英
		{"min": 4, "max": 6, "pool": "hard", "fixed": []},                                # 9: 无保底
		{"min": 3, "max": 4, "pool": "hard", "fixed": ["TREASURE", "SHOP"]},              # 10: 1 宝箱, 1 商店
		{"min": 3, "max": 5, "pool": "hard", "fixed": ["REST_SITE"]},                     # 11: 1 休息处
		{"min": 3, "max": 5, "pool": "hard", "fixed": []},                                # 12: 无保底
	]
	
	act_2.act_music_ambient_file_path = "res://sounds/bgm/bgm_act_2.mp3"
	act_2.act_music_combat_file_path = "res://sounds/bgm/bgm_act_2.mp3"
	act_2.act_music_miniboss_file_path = "res://sounds/bgm/bgm_act_2.mp3"
	act_2.act_music_boss_file_path = "res://sounds/bgm/bgm_boss.mp3"
	
	act_2.act_easy_combat_event_pool_object_id = "event_pool_act_2_easy"
	act_2.act_hard_combat_event_pool_object_id = "event_pool_act_2_hard"
	act_2.act_miniboss_event_pool_object_id = "event_pool_act_2_miniboss"
	act_2.act_non_combat_event_pool_object_id = "event_pool_act_2_dialogue"
	act_2.act_boss_event_pool_object_id = "event_pool_act_2_boss"
	act_2.act_background_texture_path = "sprites/act/2/bg_act_2_infiltration.png"
	Global.register_rod(act_2)
