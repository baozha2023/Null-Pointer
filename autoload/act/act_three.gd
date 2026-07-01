## 第三章：核心超载 — 敌人、事件池、Boss
## 主题：系统核心熔毁，混乱、过热、暴击的终局挑战
class_name GlobalProdDataGeneratorActThree
extends RefCounted

static func add_enemies() -> void:
	const DIFFICULTY_STARTING: int = 0
	const DIFFICULTY_STANDARD_ENEMIES_HARDER: int = 1
	const DIFFICULTY_MINIBOSS_ENEMIES_HARDER: int = 2
	const DIFFICULTY_BOSS_ENEMIES_HARDER: int = 3

	#region 普通敌人

	# 超频核心 — 自我增益 + 攻击
	var enemy_act_3_overclocker: EnemyData = EnemyData.new("enemy_act_3_overclocker")
	enemy_act_3_overclocker.add_health_bounds(24, 30)
	enemy_act_3_overclocker.add_health_bounds(32, 40, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_3_overclocker.enemy_name = "超频怪"
	enemy_act_3_overclocker.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_overclocker.png"
	var overclocker_buff_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	var overclocker_buff_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	enemy_act_3_overclocker.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_overclock": 1}),
		],
	)
	enemy_act_3_overclocker.add_intent_state(
		[
			EnemyIntentData.new("intent_overclock", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1}, overclocker_buff_actions_1),
			EnemyIntentData.new("intent_overclock", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 0, "", {"intent_attack": 1}, overclocker_buff_actions_2),
		],
	)
	enemy_act_3_overclocker.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 8, 2, "", 0, "", {"intent_overclock": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 11, 2, "", 0, "", {"intent_overclock": 1}),
		],
	)



	var _enemy_act_3_overclocker_anim = enemy_act_3_overclocker.add_standard_animations([enemy_act_3_overclocker.enemy_texture_path])
	Global.register_rod(enemy_act_3_overclocker)

	# 熔毁核心 — 过热施加 + 死亡爆炸
	var enemy_act_3_meltdown: EnemyData = EnemyData.new("enemy_act_3_meltdown")
	enemy_act_3_meltdown.add_health_bounds(22, 28)
	enemy_act_3_meltdown.add_health_bounds(30, 36, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_3_meltdown.enemy_name = "熔毁核心"
	enemy_act_3_meltdown.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_meltdown.png"
	enemy_act_3_meltdown.enemy_actions_on_death = [
		{
			Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 10, "status_effect_object_id": "status_effect_corrosion", "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {"status_charge_amount": 3, "status_effect_object_id": "status_effect_overheat", "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER},
		},
	]
	var meltdown_heat_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var meltdown_heat_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_meltdown.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_overheat": 1}),
		],
	)
	enemy_act_3_meltdown.add_intent_state(
		[
			EnemyIntentData.new("intent_overheat", DIFFICULTY_STARTING, 12, 1, "", 0, "", {"intent_attack": 1}, meltdown_heat_actions_1),
			EnemyIntentData.new("intent_overheat", DIFFICULTY_STANDARD_ENEMIES_HARDER, 16, 1, "", 0, "", {"intent_attack": 1}, meltdown_heat_actions_2),
		],
	)
	enemy_act_3_meltdown.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 6, 2, "", 0, "", {"intent_overheat": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 8, 2, "", 0, "", {"intent_overheat": 1}),
		],
	)



	var _enemy_act_3_meltdown_anim = enemy_act_3_meltdown.add_standard_animations([enemy_act_3_meltdown.enemy_texture_path])
	Global.register_rod(enemy_act_3_meltdown)

	# 核心卫士 — 高护盾 + 尖刺 + 脆弱
	var enemy_act_3_core_guard: EnemyData = EnemyData.new("enemy_act_3_core_guard")
	enemy_act_3_core_guard.add_health_bounds(27, 33)
	enemy_act_3_core_guard.add_health_bounds(34, 40, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_3_core_guard.enemy_name = "核卫兵"
	enemy_act_3_core_guard.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_core_guard.png"
	enemy_act_3_core_guard.enemy_initial_status_effects = {"status_effect_pointy": 3}
	var guard_vuln_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var guard_vuln_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_core_guard.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_block": 1}),
		],
	)
	enemy_act_3_core_guard.add_intent_state(
		[
			EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 0, 0, "", 10, "", {"intent_lockdown": 1}),
			EnemyIntentData.new("intent_block", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 12, "", {"intent_lockdown": 1}),
		],
	)
	enemy_act_3_core_guard.add_intent_state(
		[
			EnemyIntentData.new("intent_lockdown", DIFFICULTY_STARTING, 6, 1, "", 0, "", {"intent_block": 1}, guard_vuln_actions_1),
			EnemyIntentData.new("intent_lockdown", DIFFICULTY_STANDARD_ENEMIES_HARDER, 7, 1, "", 0, "", {"intent_block": 1}, guard_vuln_actions_2),
		],
	)



	var _enemy_act_3_core_guard_anim = enemy_act_3_core_guard.add_standard_animations([enemy_act_3_core_guard.enemy_texture_path])
	Global.register_rod(enemy_act_3_core_guard)

	# 腐化程序 — 虚弱 + 易伤 双重 debuff + 攻击
	var enemy_act_3_corruptor: EnemyData = EnemyData.new("enemy_act_3_corruptor")
	enemy_act_3_corruptor.add_health_bounds(18, 24)
	enemy_act_3_corruptor.add_health_bounds(24, 30, DIFFICULTY_STANDARD_ENEMIES_HARDER)
	enemy_act_3_corruptor.enemy_name = "腐化妖"
	enemy_act_3_corruptor.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_corruptor.png"
	var corrupt_debuff_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var corrupt_debuff_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_corruptor.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_corrupt": 1}),
		],
	)
	enemy_act_3_corruptor.add_intent_state(
		[
			EnemyIntentData.new("intent_corrupt", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_attack": 1}, corrupt_debuff_actions_1),
			EnemyIntentData.new("intent_corrupt", DIFFICULTY_STANDARD_ENEMIES_HARDER, 0, 0, "", 0, "", {"intent_attack": 1}, corrupt_debuff_actions_2),
		],
	)
	enemy_act_3_corruptor.add_intent_state(
		[
			EnemyIntentData.new("intent_attack", DIFFICULTY_STARTING, 10, 1, "", 0, "", {"intent_corrupt": 1}),
			EnemyIntentData.new("intent_attack", DIFFICULTY_STANDARD_ENEMIES_HARDER, 13, 1, "", 0, "", {"intent_corrupt": 1}),
		],
	)



	var _enemy_act_3_corruptor_anim = enemy_act_3_corruptor.add_standard_animations([enemy_act_3_corruptor.enemy_texture_path])
	Global.register_rod(enemy_act_3_corruptor)

	#endregion

	#region 精英敌人

	# 精英怪 1：暴击溢出 — 自叠暴击 + 重击
	var enemy_act_3_miniboss_1: EnemyData = EnemyData.new("enemy_act_3_miniboss_1")
	enemy_act_3_miniboss_1.add_health_bounds(115, 115)
	enemy_act_3_miniboss_1.add_health_bounds(140, 140, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_3_miniboss_1.add_health_bounds(155, 155, 4)
	enemy_act_3_miniboss_1.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_3_miniboss_1.enemy_name = "暴击兽"
	enemy_act_3_miniboss_1.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_miniboss_1.png"
	var crit_buff_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_critical", "status_charge_amount": 15, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	var crit_buff_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_critical", "status_charge_amount": 20, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	enemy_act_3_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_crit_buff": 1}),
		],
	)
	enemy_act_3_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_crit_buff", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_crit_attack": 1}, crit_buff_actions_1),
			EnemyIntentData.new("intent_crit_buff", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 0, 0, "", 0, "", {"intent_crit_attack": 1}, crit_buff_actions_2),
		],
	)
	enemy_act_3_miniboss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_crit_attack", DIFFICULTY_STARTING, 22, 1, "", 0, "", {"intent_crit_buff": 1}),
			EnemyIntentData.new("intent_crit_attack", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 28, 1, "", 0, "", {"intent_crit_buff": 1}),
		],
	)



	var _enemy_act_3_miniboss_1_anim = enemy_act_3_miniboss_1.add_standard_animations([enemy_act_3_miniboss_1.enemy_texture_path])
	Global.register_rod(enemy_act_3_miniboss_1)

	# 精英怪 2：定时炸弹 — 叠炸弹 + 护盾拖延
	var enemy_act_3_miniboss_2: EnemyData = EnemyData.new("enemy_act_3_miniboss_2")
	enemy_act_3_miniboss_2.add_health_bounds(85, 95)
	enemy_act_3_miniboss_2.add_health_bounds(105, 115, DIFFICULTY_MINIBOSS_ENEMIES_HARDER)
	enemy_act_3_miniboss_2.add_health_bounds(115, 125, 4)
	enemy_act_3_miniboss_2.enemy_type = EnemyData.ENEMY_TYPES.MINIBOSS
	enemy_act_3_miniboss_2.enemy_name = "炸弹兵"
	enemy_act_3_miniboss_2.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_miniboss_2.png"
	var bomb_plant_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_bomb", "status_charge_amount": 15, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var bomb_plant_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_bomb", "status_charge_amount": 20, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_bomb": 1}),
		],
	)
	enemy_act_3_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_bomb", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_block": 1}, bomb_plant_actions_1),
			EnemyIntentData.new("intent_bomb", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 0, 0, "", 0, "", {"intent_block": 1}, bomb_plant_actions_2),
		],
	)
	enemy_act_3_miniboss_2.add_intent_state(
		[
			EnemyIntentData.new("intent_block", DIFFICULTY_STARTING, 6, 1, "", 15, "", {"intent_bomb": 1}),
			EnemyIntentData.new("intent_block", DIFFICULTY_MINIBOSS_ENEMIES_HARDER, 8, 1, "", 18, "", {"intent_bomb": 1}),
		],
	)



	var _enemy_act_3_miniboss_2_anim = enemy_act_3_miniboss_2.add_standard_animations([enemy_act_3_miniboss_2.enemy_texture_path])
	Global.register_rod(enemy_act_3_miniboss_2)

	#endregion

	#region Boss — 核心霸主

	var enemy_act_3_boss_1: EnemyData = EnemyData.new("enemy_act_3_boss_1")
	enemy_act_3_boss_1.add_health_bounds(260, 260)
	enemy_act_3_boss_1.add_health_bounds(320, 320, DIFFICULTY_BOSS_ENEMIES_HARDER)
	enemy_act_3_boss_1.add_health_bounds(350, 350, 5)
	enemy_act_3_boss_1.enemy_type = EnemyData.ENEMY_TYPES.BOSS
	enemy_act_3_boss_1.enemy_name = "核霸主"
	enemy_act_3_boss_1.enemy_texture_path = "sprites/enemies/act3/enemy_act_3_boss_1.png"
	enemy_act_3_boss_1.enemy_initial_status_effects = {"status_effect_pointy": 3}

	# 初始 → 召唤
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new(EnemyIntentData.INTENT_INITIAL, DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_summon": 1}),
		],
	)

	# 召唤：2 只腐化程序
	var boss_3_summon_actions: Array[Dictionary] = [
		{
			Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1, 2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_act_3_corruptor", "enemy_act_3_meltdown"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT},
		},
	]
	var boss_3_summon_actions_d3: Array[Dictionary] = [
		{
			Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1, 2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_act_3_corruptor", "enemy_act_3_meltdown"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_cap_damage", "status_charge_amount": 99, "status_secondary_charge_amount": 15, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
		}
	]
	var boss_3_summon_actions_d5: Array[Dictionary] = [
		{
			Scripts.ACTION_SUMMON_ENEMIES: {"number_of_spawns": 2, "spawn_slots": [1, 2], "time_delay": 0.5, "random_enemy_object_ids": ["enemy_act_3_corruptor", "enemy_act_3_meltdown"], "target_override": BaseAction.TARGET_OVERRIDES.PARENT},
		},
		{
			Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES}
		},
		{
			Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_cap_damage", "status_charge_amount": 99, "status_secondary_charge_amount": 10, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}
		}
	]
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_summon", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_overload": 1}, boss_3_summon_actions),
			EnemyIntentData.new("intent_summon", 3, 0, 0, "", 0, "", {"intent_overload": 1}, boss_3_summon_actions_d3, [EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING], "启动核心保护模块，单次承伤不会超过 15 点"),
			EnemyIntentData.new("intent_summon", 5, 0, 0, "", 0, "", {"intent_overload": 1}, boss_3_summon_actions_d5, [EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING], "召唤并强化护卫，同时启动高级核心保护模块，单次承伤不会超过 10 点"),
		],
	)

	# 超载：给自己叠伤害提升 + 给玩家上过热
	var boss_3_overload_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var boss_3_overload_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_damage_increase", "status_charge_amount": 5, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_overheat", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_overload", DIFFICULTY_STARTING, 0, 0, "", 0, "", {"intent_system_crash": 1}, boss_3_overload_actions_1),
			EnemyIntentData.new("intent_overload", 3, 0, 0, "", 0, "", {"intent_system_crash": 1}, boss_3_overload_actions_2),
		],
	)

	# 系统崩溃：脆弱 + 多段攻击
	var boss_3_crash_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	var boss_3_crash_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_vulnerable", "status_charge_amount": 4, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_weaken", "status_charge_amount": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PLAYER}},
	]
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_system_crash", DIFFICULTY_STARTING, 4, 4, "", 0, "", {"intent_emergency": 1}, boss_3_crash_actions_1),
			EnemyIntentData.new("intent_system_crash", 3, 6, 4, "", 0, "", {"intent_emergency": 1}, boss_3_crash_actions_2),
			EnemyIntentData.new("intent_system_crash", 5, 7, 4, "", 0, "", {"intent_emergency": 1}, boss_3_crash_actions_2),
		],
	)

	# 紧急协议：加护盾 + 叠暴击（准备下一轮爆发）
	var boss_3_emergency_actions_1: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_critical", "status_charge_amount": 15, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	var boss_3_emergency_actions_2: Array[Dictionary] = [
		{Scripts.ACTION_APPLY_STATUS: {"status_effect_object_id": "status_effect_critical", "status_charge_amount": 25, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "target_override": BaseAction.TARGET_OVERRIDES.PARENT}},
	]
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_emergency", DIFFICULTY_STARTING, 0, 0, "", 15, "", {"intent_vent": 1}, boss_3_emergency_actions_1),
			EnemyIntentData.new("intent_emergency", 3, 0, 0, "", 18, "", {"intent_vent": 1}, boss_3_emergency_actions_2),
		],
	)
	
	# 强制散热：造成重击 + 洗入发热数据
	var boss_3_vent_actions: Array[Dictionary] = [
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_burn", "number_of_cards": 2, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]
	var boss_3_vent_actions_d3: Array[Dictionary] = [
		{Scripts.ACTION_CREATE_CARDS: {"created_card_object_id": "card_status_burn", "number_of_cards": 3, "time_delay": EnemyData.ENEMY_ATTACK_DELAY, "action_data": [{Scripts.ACTION_ADD_CARDS_TO_DRAW: {"shuffle_cards": true}}]}}
	]
	enemy_act_3_boss_1.add_intent_state(
		[
			EnemyIntentData.new("intent_vent", DIFFICULTY_STARTING, 15, 1, "", 0, "", {"intent_overload": 1}, boss_3_vent_actions, [], "向抽牌堆洗入 2 张过载发热"),
			EnemyIntentData.new("intent_vent", 3, 20, 1, "", 0, "", {"intent_overload": 1}, boss_3_vent_actions_d3, [], "向抽牌堆洗入 3 张过载发热"),
		],
	)

	enemy_act_3_boss_1.enemy_difficulty_to_enemy_modfiers = {
		"3": {
			"enemy_initial_status_effects": {"status_effect_pointy": 3},
		},
		"5": {
			"enemy_initial_status_effects": {"status_effect_pointy": 5},
		}
	}



	var _enemy_act_3_boss_1_anim = enemy_act_3_boss_1.add_standard_animations([enemy_act_3_boss_1.enemy_texture_path])
	Global.register_rod(enemy_act_3_boss_1)

	#endregion


static func add_events() -> void:
	## Act 3 Easy Combats
	var event_act_3_easy_combat_1: EventData = EventData.new("event_act_3_easy_combat_1")
	event_act_3_easy_combat_1.event_death_message_bbcode = "在核心超载中灰飞烟灭"
	event_act_3_easy_combat_1.event_weighted_enemy_object_ids = [
		{"enemy_act_3_overclocker": 1, "enemy_act_3_meltdown": 1, "enemy_act_3_corruptor": 1},
		{"enemy_act_3_core_guard": 1, "enemy_act_3_corruptor": 1, "enemy_act_3_meltdown": 1},
		{"enemy_4": 1, "enemy_act_3_overclocker": 1, "enemy_act_3_core_guard": 1},
	]

	Global.register_rod(event_act_3_easy_combat_1)

	var event_act_3_easy_combat_2: EventData = EventData.new("event_act_3_easy_combat_2")
	event_act_3_easy_combat_2.event_weighted_enemy_object_ids = [
		{"enemy_act_3_overclocker": 1},
		{"enemy_act_3_corruptor": 1},
	]

	Global.register_rod(event_act_3_easy_combat_2)

	var event_act_3_easy_combat_3: EventData = EventData.new("event_act_3_easy_combat_3")
	event_act_3_easy_combat_3.event_weighted_enemy_object_ids = [
		{"enemy_act_3_meltdown": 1},
		{"enemy_act_3_core_guard": 1},
	]

	Global.register_rod(event_act_3_easy_combat_3)

	var event_act_3_easy_combat_4: EventData = EventData.new("event_act_3_easy_combat_4")
	event_act_3_easy_combat_4.event_weighted_enemy_object_ids = [
		{"enemy_act_3_core_guard": 1},
		{"enemy_act_3_overclocker": 1},
	]

	Global.register_rod(event_act_3_easy_combat_4)

	## Act 3 Minibosses
	var event_act_3_miniboss_1: EventData = EventData.new("event_act_3_miniboss_1")
	event_act_3_miniboss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_3_miniboss_1": 1},
	]

	Global.register_rod(event_act_3_miniboss_1)

	var event_act_3_miniboss_2: EventData = EventData.new("event_act_3_miniboss_2")
	event_act_3_miniboss_2.event_weighted_enemy_object_ids = [
		{"enemy_act_3_miniboss_2": 1},
		{"enemy_act_3_corruptor": 1},
	]

	Global.register_rod(event_act_3_miniboss_2)

	var event_act_3_miniboss_3: EventData = EventData.new("event_act_3_miniboss_3")
	event_act_3_miniboss_3.event_weighted_enemy_object_ids = [
		{"enemy_act_3_miniboss_1": 1},
		{"enemy_act_3_core_guard": 1},
	]

	Global.register_rod(event_act_3_miniboss_3)

	## Act 3 Boss
	var event_act_3_boss_1: EventData = EventData.new("event_act_3_boss_1")
	event_act_3_boss_1.event_weighted_enemy_object_ids = [
		{"enemy_act_3_boss_1": 1},
	]
	event_act_3_boss_1.event_enemy_placement_is_automatic = false
	event_act_3_boss_1.event_enemy_placement_positions = [[0, 0], [180, 0], [360, 0]]
	event_act_3_boss_1.event_death_message_bbcode = "被核霸主的数据吞噬殆尽"

	Global.register_rod(event_act_3_boss_1)

	### Event Pools
	var event_pool_act_3_easy: EventPoolData = EventPoolData.new("event_pool_act_3_easy")
	event_pool_act_3_easy.add_events_to_pool(
		event_act_3_easy_combat_1,
		[
			event_act_3_easy_combat_1,
			event_act_3_easy_combat_2,
			event_act_3_easy_combat_3,
			event_act_3_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_3_easy)

	var event_pool_act_3_hard: EventPoolData = EventPoolData.new("event_pool_act_3_hard")
	event_pool_act_3_hard.add_events_to_pool(
		event_act_3_easy_combat_1,
		[
			event_act_3_easy_combat_1,
			event_act_3_easy_combat_2,
			event_act_3_easy_combat_3,
			event_act_3_easy_combat_4,
		],
	)

	Global.register_rod(event_pool_act_3_hard)

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

	# act 3 dialogue event pool
	var event_pool_act_3_dialogue: EventPoolData = EventPoolData.new("event_pool_act_3_dialogue")
	event_pool_act_3_dialogue.add_events_to_pool(
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

	Global.register_rod(event_pool_act_3_dialogue)

	var event_pool_act_3_miniboss: EventPoolData = EventPoolData.new("event_pool_act_3_miniboss")
	event_pool_act_3_miniboss.add_events_to_pool(
		event_act_3_miniboss_1,
		[
			event_act_3_miniboss_1,
			event_act_3_miniboss_2,
		],
	)
	Global.register_rod(event_pool_act_3_miniboss)

	var event_pool_act_3_boss: EventPoolData = EventPoolData.new("event_pool_act_3_boss")
	event_pool_act_3_boss.add_events_to_pool(
		event_act_3_boss_1,
		[
			event_act_3_boss_1,
		],
	)

	Global.register_rod(event_pool_act_3_boss)


static func add_act() -> void:
	var act_3: ActData = ActData.new("act_3")
	act_3.act_name = "第三章：核心超载"
	act_3.act_codex_number = 3
	act_3.act_next_act_ids = ["act_1"]
	act_3.act_action_script_path = Scripts.ACTION_GENERATE_ACT
	act_3.act_map_floor_templates = ActData.default_floor_templates()
	
	act_3.act_music_ambient_file_path = "res://sounds/bgm/bgm_act_3.mp3"
	act_3.act_music_combat_file_path = "res://sounds/bgm/bgm_act_3.mp3"
	act_3.act_music_miniboss_file_path = "res://sounds/bgm/bgm_act_3.mp3"
	act_3.act_music_boss_file_path = "res://sounds/bgm/bgm_boss.mp3"
	
	act_3.act_easy_combat_event_pool_object_id = "event_pool_act_3_easy"
	act_3.act_hard_combat_event_pool_object_id = "event_pool_act_3_hard"
	act_3.act_miniboss_event_pool_object_id = "event_pool_act_3_miniboss"
	act_3.act_non_combat_event_pool_object_id = "event_pool_act_3_dialogue"
	act_3.act_boss_event_pool_object_id = "event_pool_act_3_boss"
	act_3.act_background_texture_path = "sprites/act/3/bg_act_3_overload.png"
	Global.register_rod(act_3)
