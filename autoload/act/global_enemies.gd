## 全局通用敌人定义 — 所有章节共享
class_name GlobalProdDataGeneratorGlobalEnemies
extends RefCounted

static func add_enemies() -> void:
	const DIFFICULTY_STARTING: int = 0
	const DIFFICULTY_STANDARD_ENEMIES_HARDER: int = 1

	# 异常拦截器：免疫首次伤害（类似 try-catch 拦截第一个异常）
	var enemy_1: EnemyData = EnemyData.new("enemy_1")
	enemy_1.enemy_name = "拦截魔"
	enemy_1.add_health_bounds(17, 20)
	enemy_1.add_health_bounds(25, 30, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_1.enemy_initial_status_effects = {"status_effect_negate_damage": 1}
	enemy_1.enemy_texture_path = "sprites/enemies/act1/enemy_interceptor.png"
	enemy_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_1.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_1.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 4, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)

	var _enemy_1_anim: AnimationData = enemy_1.add_standard_animations(
		["sprites/enemies/act1/enemy_interceptor.png"],
		[
			"sprites/enemies/act1/enemy_interceptor/attack/1.png",
			"sprites/enemies/act1/enemy_interceptor/attack/2.png",
			"sprites/enemies/act1/enemy_interceptor/attack/3.png",
			"sprites/enemies/act1/enemy_interceptor/attack/4.png",
			"sprites/enemies/act1/enemy_interceptor/attack/5.png",
			"sprites/enemies/act1/enemy_interceptor/attack/6.png",
		],
	)

	Global.register_rod(enemy_1)

	# 沙箱探针：免疫首次减益（隔离环境中拒绝异常输入）
	var enemy_2: EnemyData = EnemyData.new("enemy_2")
	enemy_2.enemy_name = "沙箱探针"
	enemy_2.add_health_bounds(5, 7)
	enemy_2.add_health_bounds(8, 12, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_2.enemy_initial_status_effects = {"status_effect_negate_debuff": 1}
	enemy_2.enemy_texture_path = "sprites/enemies/act1/enemy_sandbox_probe.png"
	enemy_2.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_2.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_2.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 4, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)

	var _enemy_2_anim: AnimationData = enemy_2.add_standard_animations(
		["sprites/enemies/act1/enemy_sandbox_probe.png"],
	)

	Global.register_rod(enemy_2)

	# 内存泄漏：死亡时向所有战斗单位施加腐蚀（泄漏的内存污染整个系统）
	var enemy_3: EnemyData = EnemyData.new("enemy_3")
	enemy_3.add_health_bounds(15, 25)
	enemy_3.add_health_bounds(25, 35, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_3.enemy_name = "毒漏鬼"
	enemy_3.enemy_texture_path = "sprites/enemies/act1/enemy_memory_leak.png"
	enemy_3.enemy_actions_on_death = [
		{
			Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 5, "status_effect_object_id": "status_effect_corrosion", "time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS},
		},
	]
	enemy_3.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_3.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STARTING, 5, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_1", DIFFICULTY_STANDARD_ENEMIES_HARDER, 7, 1, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)
	enemy_3.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STARTING, 3, 2, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
			EnemyIntentData.new("intent_attack_2", DIFFICULTY_STANDARD_ENEMIES_HARDER, 3, 3, "", 0, "", {"intent_attack_1": 1, "intent_attack_2": 1}),
		],
	)

	var _enemy_3_anim: AnimationData = enemy_3.add_standard_animations(
		["sprites/enemies/act1/enemy_memory_leak.png"],
	)

	Global.register_rod(enemy_3)

	# 缓冲区溢出：给玩家施加脆弱状态 + 重击（数据越界导致防御崩溃）
	var enemy_4: EnemyData = EnemyData.new("enemy_4")
	enemy_4.add_health_bounds(37, 43)
	enemy_4.add_health_bounds(47, 53, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_4.enemy_name = "溢出魔"
	enemy_4.enemy_texture_path = "sprites/enemies/act1/enemy_overflow.png"
	enemy_4.enemy_actions_on_death = [
		{
			Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 5, "status_effect_object_id": "status_effect_corrosion", "time_delay": 0.5, "target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS},
		},
	]
	enemy_4.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack_vulnerable": 1}),
		],
	)
	var enemy_4_status_charge_1: int = 2
	var enemy_4_status_actions_1: Array[Dictionary] = [{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": enemy_4_status_charge_1, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}]
	var enemy_4_status_charge_2: int = 4
	var enemy_4_status_actions_2: Array[Dictionary] = [{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": enemy_4_status_charge_2, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}}]
	enemy_4.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_vulnerable", DIFFICULTY_STARTING, 10, 1, "", 0, "", {"intent_attack_multi": 1}, enemy_4_status_actions_1),
			EnemyIntentData.new("intent_attack_vulnerable", DIFFICULTY_STANDARD_ENEMIES_HARDER, 12, 1, "", 0, "", {"intent_attack_multi": 1}, enemy_4_status_actions_2),
		],
	)
	enemy_4.add_intent_state(
		[
			EnemyIntentData.new("intent_attack_multi", DIFFICULTY_STARTING, 5, 2, "", 0, "", {"intent_block": 1}),
			EnemyIntentData.new("intent_attack_multi", DIFFICULTY_STANDARD_ENEMIES_HARDER, 6, 2, "", 0, "", {"intent_block": 1}),
		],
	)
	enemy_4.add_intent_state(
		[
			EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 0, 0, "", 10, "", {"intent_attack_vulnerable": 1}),
			EnemyIntentData.new("intent_block", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 12, "", {"intent_attack_vulnerable": 1}),
		],
	)

	var _enemy_4_anim: AnimationData = enemy_4.add_standard_animations(
		["sprites/enemies/act1/enemy_overflow.png"],
	)

	Global.register_rod(enemy_4)
