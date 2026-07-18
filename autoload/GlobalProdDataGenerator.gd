## Singleton for data generation in actual production.
## This is used to make content programmatically instead of messing with more fragile external JSON files.
extends Node

## Wrapper method used to generate all data used in production.
## After running this you can use Fileloader.export_read_only_data() to output to json files.
func generate_production_data() -> void:
	add_rest_actions()
	add_consumables()

	add_status_effects() # must be defined before enemies
	add_action_interceptors()

	add_enemies()
	add_dialogue()
	add_events()
	add_acts()

	add_colors()
	add_keywords()

	add_combat_vfx_animations()

	add_characters()
	add_player_data()

	add_run_modifiers()
	add_run_start_options()

	add_custom_ui()
	add_custom_signals()
	add_achievements()

	GlobalProdArtifactsGenerator.generate_artifacts()
	GlobalProdDecoratorsGenerator.generate_decorators()

	add_cards()
	add_card_packs()
	add_consumable_packs()


#region Achievements
func add_achievements() -> void:
	var definitions: Array[Dictionary] = [
		{
			"id": "achievement_first_kill",
			"name": "首次回收",
			"description": "击败一个敌方进程。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [{"event": AchievementManager.EVENT_ENEMY_KILLED}],
		},
		{
			"id": "achievement_first_miniboss",
			"name": "权限提升",
			"description": "击败一个精英进程。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [{"event": AchievementManager.EVENT_COMBAT_COMPLETED, "conditions": [
				["values.combat_victory", AchievementConditionData.OPERATORS.IS_TRUE, null],
				["values.location_type", AchievementConditionData.OPERATORS.EQUAL, LocationData.LOCATION_TYPES.MINIBOSS],
			]}],
		},
		{
			"id": "achievement_first_boss",
			"name": "突破防火墙",
			"description": "击败一个 Boss 进程。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [{"event": AchievementManager.EVENT_COMBAT_COMPLETED, "conditions": [
				["values.combat_victory", AchievementConditionData.OPERATORS.IS_TRUE, null],
				["values.location_type", AchievementConditionData.OPERATORS.EQUAL, LocationData.LOCATION_TYPES.BOSS],
			]}],
		},
		{
			"id": "achievement_first_victory",
			"name": "空指针",
			"description": "获得一次胜利。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [_achievement_victory_trigger()],
		},
		{
			"id": "achievement_victory_red",
			"name": "代码即武器",
			"description": "使用码农获得一次胜利。",
			"category": ["character", "角色专精", 1],
			"triggers": [_achievement_victory_trigger([
				["values.run_character_id", AchievementConditionData.OPERATORS.EQUAL, "character_red"],
			])],
		},
		{
			"id": "achievement_victory_blue",
			"name": "无痕渗透",
			"description": "使用渗透专家获得一次胜利。",
			"category": ["character", "角色专精", 1],
			"triggers": [_achievement_victory_trigger([
				["values.run_character_id", AchievementConditionData.OPERATORS.EQUAL, "character_blue"],
			])],
		},
		{
			"id": "achievement_victory_green",
			"name": "野蛮生长",
			"description": "使用赛博植物学家获得一次胜利。",
			"category": ["character", "角色专精", 1],
			"triggers": [_achievement_victory_trigger([
				["values.run_character_id", AchievementConditionData.OPERATORS.EQUAL, "character_green"],
			])],
		},
		{
			"id": "achievement_victory_orange",
			"name": "重构完成",
			"description": "使用重构工匠获得一次胜利。",
			"category": ["character", "角色专精", 1],
			"triggers": [_achievement_victory_trigger([
				["values.run_character_id", AchievementConditionData.OPERATORS.EQUAL, "character_orange"],
			])],
		},
		{
			"id": "achievement_victory_difficulty_0",
			"name": "难度0",
			"description": "在难度 0 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 0],
			])],
		},
		{
			"id": "achievement_victory_difficulty_1",
			"name": "难度1",
			"description": "在难度 1 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 1],
			])],
		},
		{
			"id": "achievement_victory_difficulty_2",
			"name": "难度2",
			"description": "在难度 2 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 2],
			])],
		},
		{
			"id": "achievement_victory_difficulty_3",
			"name": "难度3",
			"description": "在难度 3 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 3],
			])],
		},
		{
			"id": "achievement_victory_difficulty_4",
			"name": "难度4",
			"description": "在难度 4 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 4],
			])],
		},
		{
			"id": "achievement_victory_difficulty_5",
			"name": "难度5",
			"description": "在难度 5 获得一次标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_difficulty_level", AchievementConditionData.OPERATORS.EQUAL, 5],
			])],
		},
		{
			"id": "achievement_all_characters",
			"name": "全栈执行",
			"description": "使用全部四个原生角色分别获得一次胜利。",
			"category": ["character", "角色专精", 1],
			"hidden_policy": AchievementPresentationData.HIDDEN_POLICIES.HIDE_ALL,
			"triggers": [{
				"event": AchievementManager.EVENT_RUN_COMPLETED,
				"conditions": [
					["values.run_victory", AchievementConditionData.OPERATORS.IS_TRUE, null],
					["values.run_character_id", AchievementConditionData.OPERATORS.IN, ["character_red", "character_blue", "character_green", "character_orange"]],
				],
				"unique_field": "values.run_character_id",
			}],
			"progress": [4, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.UNIQUE_COUNT, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_enemy_kills_100", "name": "垃圾回收器",
			"description": "在标准局中累计击败 100 个敌方进程。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [{"event": AchievementManager.EVENT_RUN_COMPLETED, "progress_field": "values.enemies_killed"}],
			"progress": [100, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.SUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_victories_10", "name": "十次上线",
			"description": "累计获得 10 次标准局胜利。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [_achievement_victory_trigger()],
			"progress": [10, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.COUNT, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_minibosses_25", "name": "精英猎手",
			"description": "在标准局中累计击败 25 个精英进程。",
			"category": ["milestone", "里程碑", 0],
			"triggers": [{"event": AchievementManager.EVENT_RUN_COMPLETED, "progress_field": "values.minibosses_defeated"}],
			"progress": [25, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.SUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_flawless_combat", "name": "无损握手",
			"description": "在一场战斗中不受到生命伤害并获胜。",
			"category": ["combat", "战斗挑战", 2],
			"triggers": [{"event": AchievementManager.EVENT_COMBAT_COMPLETED, "conditions": [
				["values.combat_victory", AchievementConditionData.OPERATORS.IS_TRUE, null],
				["values.player_damage", AchievementConditionData.OPERATORS.EQUAL, 0],
			]}],
		},
		{
			"id": "achievement_cards_played_turn_10", "name": "线程风暴",
			"description": "在一个回合内打出至少 10 张牌。",
			"category": ["combat", "战斗挑战", 2],
			"triggers": [_achievement_combat_stat_trigger("CARDS_PLAYED", "turn_value")],
			"progress": [10, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.TURN, 5],
		},
		{
			"id": "achievement_damage_blocked_turn_50", "name": "绝对防御",
			"description": "在一个回合内用格挡抵消至少 50 点伤害。",
			"category": ["combat", "战斗挑战", 2],
			"triggers": [_achievement_combat_stat_trigger("PLAYER_BLOCKED_AMOUNT", "turn_value")],
			"progress": [50, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.TURN, 5],
		},
		{
			"id": "achievement_damage_dealt_turn_100", "name": "带宽压制",
			"description": "在一个回合内对敌人造成至少 100 点有效生命伤害。",
			"category": ["combat", "战斗挑战", 2],
			"triggers": [_achievement_combat_stat_trigger("ENEMY_DAMAGED_CAPPED_AMOUNT", "turn_value")],
			"progress": [100, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.TURN, 5],
		},
		{
			"id": "achievement_cards_exhausted_combat_10", "name": "内存清理",
			"description": "在一场战斗中消耗至少 10 张牌。",
			"category": ["combat", "战斗挑战", 2],
			"triggers": [_achievement_combat_stat_trigger("CARDS_EXHAUSTED", "combat_value")],
			"progress": [10, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.COMBAT, 5],
		},
		{
			"id": "achievement_victory_small_deck", "name": "最小化构建",
			"description": "以不超过 7 张牌的牌组获得标准局胜利。",
			"category": ["build", "构筑挑战", 3],
			"triggers": [_achievement_victory_trigger([], "values.run_deck_size")],
			"progress": [7, AchievementProgressData.COMPARISONS.LESS_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MINIMUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_victory_artifacts_10", "name": "插件生态",
			"description": "持有至少 10 件遗物并获得标准局胜利。",
			"category": ["build", "构筑挑战", 3],
			"triggers": [_achievement_victory_trigger([], "values.run_artifact_count")],
			"progress": [10, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_victory_money_500", "name": "资源囤积",
			"description": "持有至少 500 数据币并获得标准局胜利。",
			"category": ["build", "构筑挑战", 3],
			"triggers": [_achievement_victory_trigger([], "values.run_player_money")],
			"progress": [500, AchievementProgressData.COMPARISONS.GREATER_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MAXIMUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_victory_full_health", "name": "完整镜像",
			"description": "以满生命值获得标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.run_player_health", AchievementConditionData.OPERATORS.EQUAL, {"field": "values.run_player_health_max"}],
			])],
		},
		{
			"id": "achievement_victory_under_45_minutes", "name": "极速部署",
			"description": "在 45 分钟内获得标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"format": AchievementPresentationData.VALUE_FORMATS.DURATION,
			"triggers": [_achievement_victory_trigger([], "values.run_completion_time_ms")],
			"progress": [2700000, AchievementProgressData.COMPARISONS.LESS_OR_EQUAL, AchievementProgressData.AGGREGATIONS.MINIMUM, AchievementProgressData.SCOPES.LIFETIME, 5],
		},
		{
			"id": "achievement_victory_no_shop", "name": "离线部署",
			"description": "整局不选择任何商店地图节点并获得标准局胜利。",
			"category": ["challenge", "运行挑战", 4],
			"triggers": [_achievement_victory_trigger([
				["values.shop_locations_entered", AchievementConditionData.OPERATORS.EQUAL, 0],
			])],
		},
	]

	for index: int in definitions.size():
		var definition: Dictionary = definitions[index]
		var achievement_data: AchievementData = _build_achievement_data(definition, index)
		achievement_data.mark_as_vanilla()
		Global.register_rod(achievement_data)


func _build_achievement_data(definition: Dictionary, display_order: int) -> AchievementData:
	var achievement_data := AchievementData.new(str(definition["id"]))
	var presentation := AchievementPresentationData.new()
	presentation.achievement_name = str(definition["name"])
	presentation.achievement_description = str(definition["description"])
	presentation.achievement_icon_texture_path = "sprites/achievements/%s.png" % achievement_data.object_id
	var category: Array = definition.get("category", ["general", "通用", 0])
	presentation.achievement_category_id = str(category[0])
	presentation.achievement_category_name = str(category[1])
	presentation.achievement_category_order = int(category[2])
	presentation.achievement_display_order = display_order
	presentation.achievement_hidden_policy = int(definition.get("hidden_policy", AchievementPresentationData.HIDDEN_POLICIES.VISIBLE))
	presentation.achievement_value_format = int(definition.get("format", AchievementPresentationData.VALUE_FORMATS.INTEGER))
	presentation.achievement_value_suffix = str(definition.get("suffix", ""))
	presentation.achievement_show_recent_values = bool(definition.get("show_recent", false))
	achievement_data.achievement_presentation = presentation
	achievement_data.achievement_run_policy = AchievementData.RUN_POLICIES.STANDARD_ONLY
	achievement_data.achievement_record_after_unlock = bool(definition.get("record_after_unlock", false))
	for trigger_definition: Dictionary in definition["triggers"]:
		var trigger := AchievementTriggerData.new()
		trigger.achievement_event_id = str(trigger_definition["event"])
		trigger.achievement_progress_field_path = str(trigger_definition.get("progress_field", "value"))
		trigger.achievement_unique_value_field_path = str(trigger_definition.get("unique_field", ""))
		trigger.achievement_custom_evaluator_script_path = str(trigger_definition.get("evaluator", ""))
		for condition_definition: Array in trigger_definition.get("conditions", []):
			var condition := AchievementConditionData.new()
			condition.achievement_condition_field_path = str(condition_definition[0])
			condition.achievement_condition_operator = int(condition_definition[1])
			condition.achievement_condition_value = condition_definition[2]
			trigger.achievement_conditions.append(condition)
		achievement_data.achievement_triggers.append(trigger)
	if definition.has("progress"):
		var progress_definition: Array = definition["progress"]
		var progress := AchievementProgressData.new()
		progress.achievement_target_value = float(progress_definition[0])
		progress.achievement_unlock_comparison = int(progress_definition[1])
		progress.achievement_aggregation = int(progress_definition[2])
		progress.achievement_scope = int(progress_definition[3])
		progress.achievement_recent_history_limit = int(progress_definition[4])
		achievement_data.achievement_progress = progress
	return achievement_data


func _achievement_victory_trigger(extra_conditions: Array = [], progress_field: String = "value") -> Dictionary:
	var conditions: Array = [["values.run_victory", AchievementConditionData.OPERATORS.IS_TRUE, null]]
	conditions.append_array(extra_conditions)
	return {
		"event": AchievementManager.EVENT_RUN_COMPLETED,
		"conditions": conditions,
		"progress_field": progress_field,
	}


func _achievement_combat_stat_trigger(stat_name: String, value_field: String) -> Dictionary:
	return {
		"event": AchievementManager.EVENT_COMBAT_STAT_CHANGED,
		"conditions": [["values.stat_name", AchievementConditionData.OPERATORS.EQUAL, stat_name]],
		"progress_field": "values.%s" % value_field,
	}
#endregion


#region Consumables
func add_consumables() -> void:
	# health consumable
	var consumable_heal: ConsumableData = ConsumableData.new("consumable_heal")
	consumable_heal.consumable_name = "治疗道具"
	consumable_heal.consumable_color_id = "color_white"
	consumable_heal.consumable_description = "回复20%最大完整度"
	consumable_heal.consumable_use_text = "饮用"
	consumable_heal.consumable_requires_target = false
	consumable_heal.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_heal.consumable_texture_path = "sprites/consumables/consumable_heal.png"
	consumable_heal.consumable_values = {
		"percentage_heal_amount": 0.20,
	}
	consumable_heal.consumable_actions = [
		{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_heal)

	# block consumable
	var consumable_block: ConsumableData = ConsumableData.new("consumable_block")
	consumable_block.consumable_name = "防火墙道具"
	consumable_block.consumable_color_id = "color_white"
	consumable_block.consumable_description = "获得10点防火墙"
	consumable_block.consumable_use_text = "饮用"
	consumable_block.consumable_requires_target = false
	consumable_block.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_block.consumable_texture_path = "sprites/consumables/consumable_block.png"
	consumable_block.consumable_values = {
		"block": 10,
	}
	consumable_block.consumable_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]
	Global.register_rod(consumable_block)

	# damaging consumable
	var consumable_damaging: ConsumableData = ConsumableData.new("consumable_damaging")
	consumable_damaging.consumable_name = "伤害道具"
	consumable_damaging.consumable_color_id = "color_white"
	consumable_damaging.consumable_description = "对一个目标造成10点伤害"
	consumable_damaging.consumable_use_text = "投掷"
	consumable_damaging.consumable_requires_target = true
	consumable_damaging.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_damaging.consumable_texture_path = "sprites/consumables/consumable_damaging.png"
	consumable_damaging.consumable_values = {
		"damage": 10,
		"bypass_block": false,
	}
	consumable_damaging.consumable_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS,
			},
		},
	]
	Global.register_rod(consumable_damaging)

	# multi enemy damaging consumable
	var consumable_multi_damaging: ConsumableData = ConsumableData.new("consumable_multi_damaging")
	consumable_multi_damaging.consumable_name = "群体伤害道具"
	consumable_multi_damaging.consumable_color_id = "color_white"
	consumable_multi_damaging.consumable_use_text = "投掷"
	consumable_multi_damaging.consumable_description = "对所有敌人造成10点伤害"
	consumable_multi_damaging.consumable_requires_target = false
	consumable_multi_damaging.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.UNCOMMON
	consumable_multi_damaging.consumable_texture_path = "sprites/consumables/consumable_multi_damaging.png"
	consumable_multi_damaging.consumable_values = {
		"damage": 10,
		"bypass_block": false,
	}
	consumable_multi_damaging.consumable_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]
	Global.register_rod(consumable_multi_damaging)

	# 算力注射剂 — 获得 2 点算力
	var consumable_energy: ConsumableData = ConsumableData.new("consumable_energy")
	consumable_energy.consumable_name = "算力注射剂"
	consumable_energy.consumable_color_id = "color_white"
	consumable_energy.consumable_description = "获得2点算力"
	consumable_energy.consumable_use_text = "饮用"
	consumable_energy.consumable_requires_target = false
	consumable_energy.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_energy.consumable_texture_path = "sprites/consumables/consumable_energy.png"
	consumable_energy.consumable_values = {
		"energy_amount": 2,
	}
	consumable_energy.consumable_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_energy)

	# 数据币钱包 — 获得 50 数据币
	var consumable_money: ConsumableData = ConsumableData.new("consumable_money")
	consumable_money.consumable_name = "数据币钱包"
	consumable_money.consumable_color_id = "color_white"
	consumable_money.consumable_description = "获得50数据币"
	consumable_money.consumable_use_text = "使用"
	consumable_money.consumable_requires_target = false
	consumable_money.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.COMMON
	consumable_money.consumable_texture_path = "sprites/consumables/consumable_money.png"
	consumable_money.consumable_values = {
		"money_amount": 50,
	}
	consumable_money.consumable_actions = [
		{
			Scripts.ACTION_ADD_MONEY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_money)

	# 内存扩容模块 — 读取 3 个脚本
	var consumable_draw: ConsumableData = ConsumableData.new("consumable_draw")
	consumable_draw.consumable_name = "内存扩容模块"
	consumable_draw.consumable_color_id = "color_white"
	consumable_draw.consumable_description = "读取3个脚本"
	consumable_draw.consumable_use_text = "使用"
	consumable_draw.consumable_requires_target = false
	consumable_draw.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.UNCOMMON
	consumable_draw.consumable_texture_path = "sprites/consumables/consumable_draw.png"
	consumable_draw.consumable_values = {
		"draw_count": 3,
	}
	consumable_draw.consumable_actions = [
		{
			Scripts.ACTION_DRAW_GENERATOR: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_draw)

	# 碎片整理器 — 回收站洗入抽牌堆
	var consumable_reshuffle: ConsumableData = ConsumableData.new("consumable_reshuffle")
	consumable_reshuffle.consumable_name = "碎片整理器"
	consumable_reshuffle.consumable_color_id = "color_white"
	consumable_reshuffle.consumable_description = "将回收站所有脚本洗入内存队列"
	consumable_reshuffle.consumable_use_text = "使用"
	consumable_reshuffle.consumable_requires_target = false
	consumable_reshuffle.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.UNCOMMON
	consumable_reshuffle.consumable_texture_path = "sprites/consumables/consumable_reshuffle.png"
	consumable_reshuffle.consumable_values = {
		"shuffle_discard_into_draw": true,
	}
	consumable_reshuffle.consumable_actions = [
		{
			Scripts.ACTION_RESHUFFLE: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_reshuffle)

	# 防火墙渗透器 — 清除目标防火墙
	var consumable_reset_block: ConsumableData = ConsumableData.new("consumable_reset_block")
	consumable_reset_block.consumable_name = "防火墙渗透器"
	consumable_reset_block.consumable_color_id = "color_white"
	consumable_reset_block.consumable_description = "清除目标敌人的防火墙"
	consumable_reset_block.consumable_use_text = "执行"
	consumable_reset_block.consumable_requires_target = true
	consumable_reset_block.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.UNCOMMON
	consumable_reset_block.consumable_texture_path = "sprites/consumables/consumable_reset_block.png"
	consumable_reset_block.consumable_actions = [
		{
			Scripts.ACTION_RESET_BLOCK: {},
		},
	]
	Global.register_rod(consumable_reset_block)

	# 漏洞扫描器 — 全体敌人 3 层漏洞暴露
	var consumable_vulnerable: ConsumableData = ConsumableData.new("consumable_vulnerable")
	consumable_vulnerable.consumable_name = "漏洞扫描器"
	consumable_vulnerable.consumable_color_id = "color_white"
	consumable_vulnerable.consumable_description = "对所有敌人施加3层漏洞暴露"
	consumable_vulnerable.consumable_use_text = "执行"
	consumable_vulnerable.consumable_requires_target = false
	consumable_vulnerable.consumable_energy_cost = 1
	consumable_vulnerable.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.RARE
	consumable_vulnerable.consumable_texture_path = "sprites/consumables/consumable_vulnerable.png"
	consumable_vulnerable.consumable_values = {
		"status_effect_object_id": "status_effect_vulnerable",
		"status_charge_amount": 3,
	}
	consumable_vulnerable.consumable_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			},
		},
	]
	Global.register_rod(consumable_vulnerable)

	# 超频核心 — 获得 5 层算力增幅
	var consumable_damage_boost: ConsumableData = ConsumableData.new("consumable_damage_boost")
	consumable_damage_boost.consumable_name = "超频核心"
	consumable_damage_boost.consumable_color_id = "color_white"
	consumable_damage_boost.consumable_description = "获得5层算力增幅"
	consumable_damage_boost.consumable_use_text = "使用"
	consumable_damage_boost.consumable_requires_target = false
	consumable_damage_boost.consumable_energy_cost = 1
	consumable_damage_boost.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.RARE
	consumable_damage_boost.consumable_texture_path = "sprites/consumables/consumable_damage_boost.png"
	consumable_damage_boost.consumable_values = {
		"status_effect_object_id": "status_effect_damage_increase",
		"status_charge_amount": 5,
	}
	consumable_damage_boost.consumable_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			},
		},
	]
	Global.register_rod(consumable_damage_boost)

	# 内存泄漏协议 — 全体单位 15 层内核腐蚀
	var consumable_corrosion: ConsumableData = ConsumableData.new("consumable_corrosion")
	consumable_corrosion.consumable_name = "内存泄漏协议"
	consumable_corrosion.consumable_color_id = "color_white"
	consumable_corrosion.consumable_description = "对所有战斗单位施加15层内核腐蚀"
	consumable_corrosion.consumable_use_text = "执行"
	consumable_corrosion.consumable_requires_target = false
	consumable_corrosion.consumable_energy_cost = 2
	consumable_corrosion.consumable_rarity = ConsumableData.CONSUMABLE_RARITIES.LEGENDARY
	consumable_corrosion.consumable_texture_path = "sprites/consumables/consumable_corrosion.png"
	consumable_corrosion.consumable_values = {
		"status_effect_object_id": "status_effect_corrosion",
		"status_charge_amount": 15,
	}
	consumable_corrosion.consumable_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS,
			},
		},
	]
	Global.register_rod(consumable_corrosion)

#endregion

#region Rest Actions
func add_rest_actions() -> void:
	# rest action
	var rest_action_rest: RestActionData = RestActionData.new("rest_action_rest")
	rest_action_rest.rest_action_name = "碎片整理"
	rest_action_rest.rest_action_stat_name = "REST_REST_COUNT"
	rest_action_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_rest.rest_actions = [
		{
			Scripts.ACTION_HEAL_PERCENT: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"percentage_heal_amount": 0.40,
			},
		},
	]

	Global.register_rod(rest_action_rest)

	# upgrade card rest action
	# example of a cancelable rest action
	var rest_action_upgrade_card: RestActionData = RestActionData.new("rest_action_upgrade_card")
	rest_action_upgrade_card.rest_action_name = "升级"
	rest_action_upgrade_card.rest_action_stat_name = "REST_UPGRADE_CARDS_COUNT"
	rest_action_upgrade_card.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE
	rest_action_upgrade_card.rest_action_auto_end = false # allows canceling
	rest_action_upgrade_card.rest_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"min_card_amount": 1,
				"max_card_amount": 1,
				"card_pick_type": HandManager.UPGRADE_DECK,
				"card_pick_text": "选择至多 {0} 个脚本升级。已选 {1} 个",
				"min_cards_are_required_for_action": true, # won't fire if you cancel it
				"quick_pick": false,
				"can_back_out": true, # allows rest action to be canceled
				"random_selection": false,
				# only upgradeable cards allowed
				"validator_data": [
					{ Scripts.VALIDATOR_CARD_UPGRADEABLE: { } },
				],
				"action_data": [
					# embed the rest action end in the pick card action payload
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_upgrade_card" } },
					{ Scripts.ACTION_UPGRADE_CARDS: { "upgrade_parent_card": true } },
				],
			},
		},
	]

	rest_action_upgrade_card.rest_action_validators = [
		{
			Scripts.VALIDATOR_DECK_HAS_UPGRADEABLE_CARD: { },
		},
	]

	Global.register_rod(rest_action_upgrade_card)

	# remove cards action
	# example of a cancelable rest action
	var rest_action_remove_cards: RestActionData = RestActionData.new("rest_action_remove_cards")
	rest_action_remove_cards.rest_action_name = "移除脚本"
	rest_action_remove_cards.rest_action_stat_name = "REST_REMOVE_CARDS_COUNT"
	rest_action_remove_cards.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.INCLUSIVE
	rest_action_remove_cards.rest_action_auto_end = false # can be cancelled
	rest_action_remove_cards.rest_actions = [
		{
			Scripts.ACTION_PICK_CARDS: {
				"use_parent_card": false,
				"min_card_amount": 1,
				"max_card_amount": 2,
				"min_cards_are_required_for_action": true,
				"quick_pick": false,
				"can_back_out": true, # allows rest action to be canceled
				"random_selection": false,
				"card_pick_text": "选择 {0} 个脚本移除。已选 {1} 个",
				"card_pick_type": HandManager.DECK,
				"action_data": [
					# embed the rest action end in the pick card action payload
					{ Scripts.ACTION_REST_ACTION_END: { "rest_action_id": "rest_action_remove_cards" } },
					{ Scripts.ACTION_REMOVE_CARDS_FROM_DECK: { } },
				],
			},
		},
	]
	rest_action_remove_cards.rest_action_validators = [
		{
			Scripts.VALIDATOR_PILE_SIZE: {
				"card_pick_type": HandManager.DECK,
				"card_type_maximum": 4,
				"card_types": CardData.CARD_TYPES.values(), # any card
				"invert_validation": false,
			},
		},
	]

	Global.register_rod(rest_action_remove_cards)

	# add random consumable action
	var rest_action_add_random_consumable: RestActionData = RestActionData.new("rest_action_add_random_consumable")
	rest_action_add_random_consumable.rest_action_name = "随机物理删除品"
	rest_action_add_random_consumable.rest_action_stat_name = "REST_GAIN_CONSUMABLE_COUNT"
	rest_action_add_random_consumable.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_add_random_consumable.rest_actions = [
		{ Scripts.ACTION_ADD_CONSUMABLE: { "random_consumable": true } },
	]

	Global.register_rod(rest_action_add_random_consumable)

	# increase damage artifact action
	# paired with corresponding artifact
	var rest_action_increase_attack_on_rest: RestActionData = RestActionData.new("rest_action_increase_attack_on_rest")
	rest_action_increase_attack_on_rest.rest_action_name = "提升伤害"
	rest_action_increase_attack_on_rest.rest_action_stat_name = "REST_INCREASE_DAMAGE_COUNT"
	rest_action_increase_attack_on_rest.rest_action_cost_type = RestActionData.REST_ACTION_COST_TYPES.EXCLUSIVE
	rest_action_increase_attack_on_rest.rest_actions = [
		{ Scripts.ACTION_INCREASE_ARTIFACT_CHARGE: { "artifact_id": "artifact_increase_attack_on_rest" } },
	]

	Global.register_rod(rest_action_increase_attack_on_rest)

#endregion

#region Status Effects
func add_status_effects() -> void:
	var status_effect_damage_threshold: StatusEffectData = StatusEffectData.new("status_effect_damage_threshold")
	status_effect_damage_threshold.status_effect_name = "过载阈值"
	status_effect_damage_threshold.status_effect_description = "累积受到的伤害。若累积量达到阈值，将强制切换意图或触发自定义操作。"
	status_effect_damage_threshold.status_effect_tooltip = "累积受到的伤害。若累积量达到阈值，将强制切换意图或触发自定义操作。\n当前已累计受到 [color=yellow][secondary_charges]/[charge_amount][/color] 点伤害。"
	status_effect_damage_threshold.status_effect_texture_path = "sprites/status_effects/icon_damage_threshold.png"
	status_effect_damage_threshold.status_effect_decay_rate = 0
	status_effect_damage_threshold.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_damage_threshold.status_effect_interceptor_ids = ["interceptor_damage_threshold"]
	Global.register_rod(status_effect_damage_threshold)

	# ==============================
	# Custom Status Effects (New Cards)
	# ==============================
	var status_effect_delayed_execution: StatusEffectData = StatusEffectData.new("status_effect_delayed_execution")
	status_effect_delayed_execution.status_effect_name = "挂起"
	status_effect_delayed_execution.status_effect_description = "目标动作已被挂起（暂存），倒计时归零后将被自动触发。"
	status_effect_delayed_execution.status_effect_tooltip = "此动作将在 [color=yellow][charge_amount][/color] 个时钟周期后自动触发。\n暂存的脚本：[stored_cards]"
	status_effect_delayed_execution.status_effect_texture_path = "sprites/status_effects/icon_delayed_execution.png"
	status_effect_delayed_execution.status_effect_decay_rate = 0
	status_effect_delayed_execution.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_delayed_execution.status_effect_allows_multiples = true
	status_effect_delayed_execution.status_effect_script_path = "res://scripts/status_effects/custom_status_effects/StatusEffectDelayedExecution.gd"
	status_effect_delayed_execution.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN]
	Global.register_rod(status_effect_delayed_execution)

	var status_effect_delayed_action_execution: StatusEffectData = StatusEffectData.new("status_effect_delayed_action_execution")
	status_effect_delayed_action_execution.status_effect_name = "指令挂起"
	status_effect_delayed_action_execution.status_effect_texture_path = "sprites/status_effects/icon_delayed_action_execution.png"
	status_effect_delayed_action_execution.status_effect_description = "动作指令已被挂起，倒计时归零后将被自动触发。"
	status_effect_delayed_action_execution.status_effect_tooltip = "这些指令将在 [color=yellow][charge_amount][/color] 个时钟周期后自动触发。\n延迟效果：\n[delayed_actions_text]"
	status_effect_delayed_action_execution.status_effect_decay_rate = 0
	status_effect_delayed_action_execution.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_delayed_action_execution.status_effect_allows_multiples = true
	status_effect_delayed_action_execution.status_effect_script_path = "res://scripts/status_effects/custom_status_effects/StatusEffectDelayedActionExecution.gd"
	status_effect_delayed_action_execution.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN]
	Global.register_rod(status_effect_delayed_action_execution)

	var status_effect_mycelial_network: StatusEffectData = StatusEffectData.new("status_effect_mycelial_network")
	status_effect_mycelial_network.status_effect_name = "【系统专用】菌丝网络监听进程"
	status_effect_mycelial_network.status_effect_description = "监听脚本物理删除事件，并将回收物转化为过载防火墙。"
	status_effect_mycelial_network.status_effect_script_path = "res://scripts/status_effects/StatusEffectMycelialNetwork.gd"
	status_effect_mycelial_network.status_effect_is_visible = false
	status_effect_mycelial_network.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_mycelial_network.status_effect_decay_rate = 0
	status_effect_mycelial_network.status_effect_action_process_times = []
	status_effect_mycelial_network.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	Global.register_rod(status_effect_mycelial_network)

	var status_effect_root_privilege: StatusEffectData = StatusEffectData.new("status_effect_root_privilege")
	status_effect_root_privilege.status_effect_name = "Root 提权"
	status_effect_root_privilege.status_effect_description = "可以无视算力限制打出脚本。如果算力不足，每透支等同于主层数的算力，将受到等同于副层数的伤害。"
	status_effect_root_privilege.status_effect_tooltip = "可以无视算力限制打出脚本。如果打出的脚本费用超过当前剩余算力，每额外透支 [color=yellow][charge_amount][/color] 点算力，将受到 [color=red][secondary_charges][/color] 点伤害。"
	status_effect_root_privilege.status_effect_texture_path = "sprites/status_effects/icon_root_privilege.png"
	status_effect_root_privilege.status_effect_decay_rate = 0
	status_effect_root_privilege.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_root_privilege.status_effect_secondary_charge_collision_strategy = StatusEffectData.STATUS_EFFECT_SECONDARY_CHARGE_COLLISION_STRATEGIES.KEEP
	status_effect_root_privilege.status_effect_interceptor_ids = ["interceptor_root_privilege"]
	Global.register_rod(status_effect_root_privilege)


	var status_effect_curiosity: StatusEffectData = StatusEffectData.new("status_effect_curiosity")
	status_effect_curiosity.status_effect_name = "内存监听"
	status_effect_curiosity.status_effect_description = "当玩家打出脚本时，自身获得相应增益。"
	status_effect_curiosity.status_effect_tooltip = "每当玩家打出 [color=yellow][curiosity_trigger_threshold][/color] 张 [color=yellow][curiosity_trigger_card_types][/color] 时，自身获得 [color=yellow][curiosity_reaction_amount][/color] 层 [status_icon:[curiosity_reaction_status_id]]。\n当前已打出：[color=yellow][curiosity_current_counter] / [curiosity_trigger_threshold][/color] 张"
	status_effect_curiosity.status_effect_texture_path = "sprites/status_effects/icon_curiosity.png"
	status_effect_curiosity.status_effect_decay_rate = 0
	status_effect_curiosity.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_curiosity.status_effect_interceptor_ids = ["interceptor_card_play_reaction"]
	Global.register_rod(status_effect_curiosity)

	var status_effect_curiosity2: StatusEffectData = StatusEffectData.new("status_effect_curiosity2")
	status_effect_curiosity2.status_effect_name = "内存监听"
	status_effect_curiosity2.status_effect_description = "自身打出脚本时，获得相应增益。"
	status_effect_curiosity2.status_effect_tooltip = "每当你打出 [color=yellow][curiosity_trigger_threshold][/color] 张 [color=yellow][curiosity_trigger_card_types][/color] 时，获得 [color=yellow][curiosity_reaction_amount][/color] 层 [status_icon:[curiosity_reaction_status_id]]。\n当前已打出：[color=yellow][curiosity_current_counter] / [curiosity_trigger_threshold][/color] 张"
	status_effect_curiosity2.status_effect_texture_path = "sprites/status_effects/icon_curiosity.png"
	status_effect_curiosity2.status_effect_decay_rate = 0
	status_effect_curiosity2.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_curiosity2.status_effect_interceptor_ids = ["interceptor_card_play_reaction_self"]
	status_effect_curiosity2.status_effect_allows_multiples = true
	Global.register_rod(status_effect_curiosity2)

	var status_effect_firewall_protocol: StatusEffectData = StatusEffectData.new("status_effect_firewall_protocol")
	status_effect_firewall_protocol.status_effect_name = "【系统专用】锻造台外设被动防御监听进程"
	status_effect_firewall_protocol.status_effect_description = "专用于锻造台外设等相关机制的被动防御监听进程。"
	status_effect_firewall_protocol.status_effect_tooltip = "每当你打出 [card_name:card_forge_fusion] 时，获得 [color=yellow][charge_amount][/color] 点 防火墙。"
	status_effect_firewall_protocol.status_effect_decay_rate = 0
	status_effect_firewall_protocol.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_firewall_protocol.status_effect_is_visible = false
	status_effect_firewall_protocol.status_effect_interceptor_ids = ["interceptor_firewall_protocol"]
	status_effect_firewall_protocol.status_effect_player_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"custom_key_names": {"block": "invoking_status_effect_charges"},
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP
			}
		}
	]
	Global.register_rod(status_effect_firewall_protocol)

	var status_effect_payload_turbine: StatusEffectData = StatusEffectData.new("status_effect_payload_turbine")
	status_effect_payload_turbine.status_effect_name = "负载涡轮"
	status_effect_payload_turbine.status_effect_description = "每回合第一次获得载荷时，额外获得等同于层数的载荷。"
	status_effect_payload_turbine.status_effect_tooltip = "每回合第一次获得载荷时，额外获得 [color=yellow][charge_amount][/color] 层 载荷。"
	status_effect_payload_turbine.status_effect_decay_rate = 0
	status_effect_payload_turbine.status_effect_texture_path = "sprites/status_effects/icon_payload_turbine.png"
	status_effect_payload_turbine.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_payload_turbine.status_effect_is_visible = true
	status_effect_payload_turbine.status_effect_interceptor_ids = ["interceptor_payload_turbine"]
	status_effect_payload_turbine.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN
	]
	status_effect_payload_turbine.status_effect_player_process_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": "status_effect_payload_turbine",
				"status_charge_amount": 0,
				"status_secondary_charge_amount": 1,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}
		}
	]
	Global.register_rod(status_effect_payload_turbine)



	var status_effect_overshield: StatusEffectData = StatusEffectData.new("status_effect_overshield")
	status_effect_overshield.status_effect_name = "过载防火墙"
	status_effect_overshield.status_effect_description = "抵挡等同于层数的伤害，可跨时钟周期存在。"
	status_effect_overshield.status_effect_tooltip = "抵挡 [color=yellow][charge_amount][/color] 点伤害，可跨时钟周期存在。"
	status_effect_overshield.status_effect_texture_path = "sprites/status_effects/icon_overshield.png"
	status_effect_overshield.status_effect_decay_rate = -5
	status_effect_overshield.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_overshield.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_overshield.status_effect_interceptor_ids = ["interceptor_overshield"]
	status_effect_overshield.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_overshield.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]

	Global.register_rod(status_effect_overshield)

	# Preserve Energy
	var status_effect_preserve_energy: StatusEffectData = StatusEffectData.new("status_effect_preserve_energy")
	status_effect_preserve_energy.status_effect_name = "【系统专用】算力保留跨回合维持进程"
	status_effect_preserve_energy.status_effect_description = "专用于跨回合保留算力相关机制的系统底层后台进程。"
	status_effect_preserve_energy.status_effect_charge_upper_bound = 1
	status_effect_preserve_energy.status_effect_is_visible = false
	status_effect_preserve_energy.status_effect_decay_rate = 0
	status_effect_preserve_energy.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_preserve_energy.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_preserve_energy.status_effect_interceptor_ids = ["interceptor_preserve_energy"]
	status_effect_preserve_energy.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_preserve_energy.status_effect_action_process_times = []

	Global.register_rod(status_effect_preserve_energy)

	var status_effect_preserve_overshield: StatusEffectData = StatusEffectData.new("status_effect_preserve_overshield")
	status_effect_preserve_overshield.status_effect_name = "持久化过载"
	status_effect_preserve_overshield.status_effect_description = "过载防火墙不再每回合衰减。"
	status_effect_preserve_overshield.status_effect_texture_path = "sprites/status_effects/icon_preserve_overshield.png"
	status_effect_preserve_overshield.status_effect_decay_rate = 0
	status_effect_preserve_overshield.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_preserve_overshield.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_preserve_overshield.status_effect_interceptor_ids = ["interceptor_preserve_overshield"]
	status_effect_preserve_overshield.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_preserve_overshield.status_effect_action_process_times = []

	Global.register_rod(status_effect_preserve_overshield)

	var status_effect_pointy: StatusEffectData = StatusEffectData.new("status_effect_pointy")
	status_effect_pointy.status_effect_name = "反伤模块"
	status_effect_pointy.status_effect_description = "受到攻击时，对攻击者造成等同于层数的伤害。"
	status_effect_pointy.status_effect_tooltip = "受到攻击时，对攻击者造成 [color=yellow][charge_amount][/color] 点伤害。"
	status_effect_pointy.status_effect_texture_path = "sprites/status_effects/icon_pointy.png"
	status_effect_pointy.status_effect_decay_rate = -1
	status_effect_pointy.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_pointy.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_pointy.status_effect_interceptor_ids = ["interceptor_pointy"]
	status_effect_pointy.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_pointy.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]

	Global.register_rod(status_effect_pointy)

	# damages the player at the start of their turn and increases number of cards drawn
	var status_effect_pollen: StatusEffectData = StatusEffectData.new("status_effect_pollen")
	status_effect_pollen.status_effect_name = "数据污染"
	status_effect_pollen.status_effect_description = "每时钟周期触发时，失去等同于层数的完整度，并读取等同于副层数个脚本。"
	status_effect_pollen.status_effect_tooltip = "每时钟周期触发时，失去 [color=yellow][charge_amount][/color] 点完整度，并读取 [color=yellow][secondary_charges][/color] 个脚本。"
	status_effect_pollen.status_effect_texture_path = "sprites/status_effects/icon_pollen.png"
	status_effect_pollen.status_effect_decay_rate = 0
	status_effect_pollen.status_effect_priority = 10
	status_effect_pollen.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_pollen.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_pollen.status_effect_interceptor_ids = []
	status_effect_pollen.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.ZERO
	status_effect_pollen.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN]
	status_effect_pollen.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DRAW_GENERATOR: {
				"custom_key_names": {
					# convert the secondary status charges, passed in from BaseStatusEffect, into card draw
					"draw_count": "invoking_status_effect_secondary_charges",
				},
				"time_delay": 0.0,
				"is_start_of_turn_draw": false,
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the status charges, passed in from BaseStatusEffect, into poison damage
					"damage": "invoking_status_effect_charges",
				},
				"time_delay": 0.2,
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]

	Global.register_rod(status_effect_pollen)

	# poison like effect
	# example of status effect that reserves health bar
	var status_effect_corrosion: StatusEffectData = StatusEffectData.new("status_effect_corrosion")
	status_effect_corrosion.status_effect_name = "底层腐蚀"
	status_effect_corrosion.status_effect_description = "每时钟周期结束时，失去等同于层数的完整度（无视防火墙）。"
	status_effect_corrosion.status_effect_tooltip = "每时钟周期结束时，失去 [color=yellow][charge_amount][/color] 点完整度（无视防火墙）。"
	status_effect_corrosion.status_effect_texture_path = "sprites/status_effects/icon_corrosion.png"
	status_effect_corrosion.status_effect_decay_rate = -2
	# status_effect_corrosion.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.HALF_LIFE_ROUND_UP # uncomment to change to half life decay
	status_effect_corrosion.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_corrosion.status_effect_interceptor_ids = []
	status_effect_corrosion.status_effect_healthbar_layer_color = Color.DARK_GREEN.to_html(false)
	status_effect_corrosion.status_effect_healthbar_reserve_type = StatusEffectData.STATUS_EFFECT_HEALTHBAR_RESERVE_TYPES.STATUS_CHARGES
	status_effect_corrosion.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_TURN,
	]
	status_effect_corrosion.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the status charges, passed in from BaseStatusEffect, into poison damage
					"damage": "invoking_status_effect_charges",
				},
				"time_delay": 0.5,
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	status_effect_corrosion.status_effect_enemy_process_actions = status_effect_corrosion.status_effect_player_process_actions.duplicate()

	Global.register_rod(status_effect_corrosion)

	# status effect that grants overheat each turn
	var status_effect_critical: StatusEffectData = StatusEffectData.new("status_effect_critical")
	status_effect_critical.status_effect_name = "临界"
	status_effect_critical.status_effect_description = "每时钟周期开始时，获得等同于层数的内核过热。"
	status_effect_critical.status_effect_tooltip = "每时钟周期开始时，获得 [color=yellow][charge_amount][/color] 层内核过热。"
	status_effect_critical.status_effect_texture_path = "sprites/status_effects/icon_critical.png"
	status_effect_critical.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.LINEAR
	status_effect_critical.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_critical.status_effect_charge_upper_bound = 100
	status_effect_critical.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_INTENT,
	]
	status_effect_critical.status_effect_player_process_actions = [
		{
			Scripts.ACTION_APPLY_STATUS: {
				"custom_key_names": {
					"status_charge_amount": "invoking_status_effect_charges",
				},
				"time_delay": 0.1,
				"status_effect_object_id": "status_effect_overheat",
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	status_effect_critical.status_effect_enemy_process_actions = []
	status_effect_critical.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_critical)

	# status effect that damages all combatants when overflowed
	var status_effect_overheat: StatusEffectData = StatusEffectData.new("status_effect_overheat")
	status_effect_overheat.status_effect_name = "内核过热"
	status_effect_overheat.status_effect_description = "当层数达到或超过 10 层时触发爆裂，对全场所有单位造成 10 点伤害，随后层数减半。"
	status_effect_overheat.status_effect_tooltip = "当层数达到或超过 10 层时触发爆裂，对全场所有单位造成 10 点伤害，随后层数减半。当前层数：[color=yellow][charge_amount][/color]/10。"
	status_effect_overheat.status_effect_texture_path = "sprites/status_effects/icon_overheat.png"
	status_effect_overheat.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.HALF_LIFE_ROUND_UP
	status_effect_overheat.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_overheat.status_effect_charge_upper_bound = 10
	status_effect_overheat.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_overheat.status_effect_charge_overflows = true
	status_effect_overheat.status_effect_player_flow_actions = [
		{
			Scripts.ACTION_EMIT_CUSTOM_SIGNAL: {
				"custom_signal_object_id": "custom_signal_overheated",
				"custom_signal_value": 1,
			},
		},
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"damage": 10,
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS,
			},
		},
	]
	status_effect_overheat.status_effect_enemy_process_actions = []
	status_effect_overheat.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_overheat)

	# grants energy on overheat
	var status_effect_feedback_loop: StatusEffectData = StatusEffectData.new("status_effect_feedback_loop")
	status_effect_feedback_loop.status_effect_name = "反馈循环"
	status_effect_feedback_loop.status_effect_description = "每当内核过热触发爆裂时，获得等同于层数的算力。"
	status_effect_feedback_loop.status_effect_tooltip = "每当内核过热触发爆裂时，获得 [color=yellow][charge_amount][/color] 点算力。"
	status_effect_feedback_loop.status_effect_texture_path = "sprites/status_effects/icon_feedback_loop.png"
	status_effect_feedback_loop.status_effect_script_path = "res://scripts/status_effects/StatusEffectFeedbackLoop.gd"
	status_effect_feedback_loop.status_effect_decay_rate = 0
	status_effect_feedback_loop.status_effect_allows_multiples = false
	status_effect_feedback_loop.status_effect_action_process_times = [] # does not process or decay normally. See status script
	status_effect_feedback_loop.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_feedback_loop.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_feedback_loop)

	# bomb effect that counts down and damages all enemies
	# uses unique status logic
	var status_effect_bomb: StatusEffectData = StatusEffectData.new("status_effect_bomb")
	status_effect_bomb.status_effect_name = "逻辑炸弹"
	status_effect_bomb.status_effect_description = "当主层数衰减至 0 时，对非自己的其他目标造成等同于副层数的伤害。"
	status_effect_bomb.status_effect_tooltip = "当主层数衰减至 0 时，对非自己的其他目标造成 [color=yellow][secondary_charges][/color] 点伤害。剩余主层数：[color=yellow][charge_amount][/color] 层。"
	status_effect_bomb.status_effect_texture_path = "sprites/status_effects/icon_bomb.png"
	status_effect_bomb.status_effect_script_path = "res://scripts/status_effects/StatusEffectTimedStatus.gd"
	status_effect_bomb.status_effect_decay_rate = -1
	status_effect_bomb.status_effect_allows_multiples = true
	status_effect_bomb.status_effect_secondary_charge_collision_strategy = StatusEffectData.STATUS_EFFECT_SECONDARY_CHARGE_COLLISION_STRATEGIES.KEEP
	status_effect_bomb.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_bomb.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
					"damage": "invoking_status_effect_secondary_charges",
				},
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES, # player bombs hit all enemies
			},
		},
	]
	status_effect_bomb.status_effect_enemy_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					# convert the bomb's status secondary charges, passed in from BaseStatusEffect, into bomb damage
					"damage": "invoking_status_effect_secondary_charges",
				},
				"bypass_block": false,
				"time_delay": 0.5,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, # enemy bombs hit player
			},
		},
	]
	status_effect_bomb.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_bomb.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_bomb)

	# increases attack damage by charge amount
	# uses an interceptor
	var status_effect_damage_increase: StatusEffectData = StatusEffectData.new("status_effect_damage_increase")
	status_effect_damage_increase.status_effect_name = "算力增幅"
	status_effect_damage_increase.status_effect_description = "造成的攻击伤害增加等同于层数的数值。"
	status_effect_damage_increase.status_effect_tooltip = "造成的攻击伤害增加 [color=yellow][charge_amount][/color] 点。"
	status_effect_damage_increase.status_effect_texture_path = "sprites/status_effects/icon_damage_increase.png"
	status_effect_damage_increase.status_effect_decay_rate = 0
	status_effect_damage_increase.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_damage_increase.status_effect_interceptor_ids = ["interceptor_damage_increase"]

	Global.register_rod(status_effect_damage_increase)

	# decreases damage done by attackers
	# uses an interceptor
	var status_effect_weaken: StatusEffectData = StatusEffectData.new("status_effect_weaken")
	status_effect_weaken.status_effect_name = "输出降级"
	status_effect_weaken.status_effect_description = "造成的攻击伤害降低 25%。"
	status_effect_weaken.status_effect_tooltip = "造成的攻击伤害降低 25%。剩余 [color=yellow][charge_amount][/color] 个时钟周期。"
	status_effect_weaken.status_effect_texture_path = "sprites/status_effects/icon_weaken.png"
	status_effect_weaken.status_effect_decay_rate = -1
	status_effect_weaken.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weaken.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_weaken.status_effect_interceptor_ids = ["interceptor_weaken"]

	Global.register_rod(status_effect_weaken)

	# increases attack damage on attacked combatant
	# uses an interceptor
	var status_effect_vulnerable: StatusEffectData = StatusEffectData.new("status_effect_vulnerable")
	status_effect_vulnerable.status_effect_name = "漏洞暴露"
	status_effect_vulnerable.status_effect_description = "受到的攻击伤害增加 50%。"
	status_effect_vulnerable.status_effect_tooltip = "受到的攻击伤害增加 50%。剩余 [color=yellow][charge_amount][/color] 个时钟周期。"
	status_effect_vulnerable.status_effect_texture_path = "sprites/status_effects/icon_vulnerable.png"
	status_effect_vulnerable.status_effect_decay_rate = -1
	status_effect_vulnerable.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_weaken.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_vulnerable.status_effect_interceptor_ids = ["interceptor_vulnerable"]

	Global.register_rod(status_effect_vulnerable)

	# gain block at the end of the turn
	# doesn't use an interceptor
	var status_effect_block_on_turn_end: StatusEffectData = StatusEffectData.new("status_effect_block_on_turn_end")
	status_effect_block_on_turn_end.status_effect_name = "周期防御"
	status_effect_block_on_turn_end.status_effect_description = "时钟周期结束时，获得等同于层数的防火墙。"
	status_effect_block_on_turn_end.status_effect_tooltip = "时钟周期结束时，获得 [color=yellow][charge_amount][/color] 点防火墙。"
	status_effect_block_on_turn_end.status_effect_texture_path = "sprites/status_effects/icon_block_on_turn_end.png"
	status_effect_block_on_turn_end.status_effect_decay_rate = 0
	status_effect_block_on_turn_end.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_block_on_turn_end.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_block_on_turn_end.status_effect_player_process_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "block": "invoking_status_effect_charges" },
				"time_delay": 0.5,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]
	status_effect_block_on_turn_end.status_effect_enemy_process_actions = [
		{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "block": "invoking_status_effect_charges" },
				"time_delay": 0.5,
				"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
			},
		},
	]
	status_effect_block_on_turn_end.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_block_on_turn_end)

	# gain energy at the start of next turn
	# doesn't use an interceptor
	var status_effect_energy_next_turn: StatusEffectData = StatusEffectData.new("status_effect_energy_next_turn")
	status_effect_energy_next_turn.status_effect_name = "算力预分配"
	status_effect_energy_next_turn.status_effect_description = "下个时钟周期开始时，额外获得等同于层数的算力。"
	status_effect_energy_next_turn.status_effect_tooltip = "下个时钟周期开始时，额外获得 [color=yellow][charge_amount][/color] 点算力。"
	status_effect_energy_next_turn.status_effect_texture_path = "sprites/status_effects/icon_energy_next_turn.png"
	status_effect_energy_next_turn.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_energy_next_turn.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_energy_next_turn.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_energy_next_turn.status_effect_player_process_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "energy_amount": "invoking_status_effect_charges" },
				"time_delay": 0.5,
			},
		},
	]
	status_effect_energy_next_turn.status_effect_enemy_process_actions = []
	status_effect_energy_next_turn.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_energy_next_turn)

	# gain energy at the start of each turn
	# doesn't use an interceptor
	var status_effect_bonus_energy_per_turn: StatusEffectData = StatusEffectData.new("status_effect_bonus_energy_per_turn")
	status_effect_bonus_energy_per_turn.status_effect_name = "算力提升"
	status_effect_bonus_energy_per_turn.status_effect_description = "每个时钟周期开始时，额外获得等同于层数的算力。"
	status_effect_bonus_energy_per_turn.status_effect_tooltip = "每个时钟周期开始时，额外获得 [color=yellow][charge_amount][/color] 点算力。"
	status_effect_bonus_energy_per_turn.status_effect_texture_path = "sprites/status_effects/icon_bonus_energy_per_turn.png"
	status_effect_bonus_energy_per_turn.status_effect_is_visible = true
	status_effect_bonus_energy_per_turn.status_effect_decay_rate = 0
	status_effect_bonus_energy_per_turn.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_bonus_energy_per_turn.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_ENEMY_INTENT,
	]
	status_effect_bonus_energy_per_turn.status_effect_player_process_actions = [
		{
			Scripts.ACTION_ADD_ENERGY: {
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"custom_key_names": { "energy_amount": "invoking_status_effect_charges" },
				"time_delay": 0.5,
			},
		},
	]
	status_effect_bonus_energy_per_turn.status_effect_enemy_process_actions = []
	status_effect_bonus_energy_per_turn.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_bonus_energy_per_turn)

	# draws extra cards next turn
	# uses an interceptor
	# this status does not decay naturally. It is removed after turn draw
	var status_effect_increase_turn_draw: StatusEffectData = StatusEffectData.new("status_effect_increase_turn_draw")
	status_effect_increase_turn_draw.status_effect_name = "扩容内存队列"
	status_effect_increase_turn_draw.status_effect_description = "每个时钟周期开始时，额外抽取等同于层数的脚本。"
	status_effect_increase_turn_draw.status_effect_tooltip = "每个时钟周期开始时，额外抽取 [color=yellow][charge_amount][/color] 个脚本。"
	status_effect_increase_turn_draw.status_effect_texture_path = "sprites/status_effects/icon_increase_turn_draw.png"
	status_effect_increase_turn_draw.status_effect_decay_rate = 0
	status_effect_increase_turn_draw.status_effect_allows_multiples = false
	status_effect_increase_turn_draw.status_effect_charge_upper_bound = 10
	status_effect_increase_turn_draw.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_increase_turn_draw.status_effect_action_process_times = []
	status_effect_increase_turn_draw.status_effect_interceptor_ids = ["interceptor_increase_turn_draw"]

	Global.register_rod(status_effect_increase_turn_draw)

	# status that binds a card to an enemy, adding it to the player's hand when killed
	var status_effect_attached_card: StatusEffectData = StatusEffectData.new("status_effect_attached_card")
	status_effect_attached_card.status_effect_name = "捆绑进程"
	status_effect_attached_card.status_effect_description = "当前携带着一个或多个后台附着脚本，将在特定条件下被触发。"
	status_effect_attached_card.status_effect_tooltip = "当前携带着 [color=yellow][charge_amount][/color] 个后台附着脚本，将在特定条件下被触发。"
	status_effect_attached_card.status_effect_texture_path = "sprites/status_effects/icon_attached_card.png"
	status_effect_attached_card.status_effect_script_path = "res://scripts/status_effects/StatusEffectAttachedCard.gd"
	status_effect_attached_card.status_effect_decay_rate = 0
	status_effect_attached_card.status_effect_allows_multiples = true
	status_effect_attached_card.status_effect_charge_upper_bound = 1
	status_effect_attached_card.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_attached_card.status_effect_interceptor_ids = []

	Global.register_rod(status_effect_attached_card)

	# uses an interceptor to stop an attack from processing
	var status_effect_negate_damage: StatusEffectData = StatusEffectData.new("status_effect_negate_damage")
	status_effect_negate_damage.status_effect_name = "伤害阻断"
	status_effect_negate_damage.status_effect_description = "完全抵消下一次受到的伤害。"
	status_effect_negate_damage.status_effect_tooltip = "完全抵消接下来的 [color=yellow][charge_amount][/color] 次受到的伤害。"
	status_effect_negate_damage.status_effect_texture_path = "sprites/status_effects/icon_negate_damage.png"
	status_effect_negate_damage.status_effect_decay_rate = 0
	status_effect_negate_damage.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_negate_damage.status_effect_interceptor_ids = ["interceptor_negate_damage"]

	Global.register_rod(status_effect_negate_damage)

	# uses an interceptor to cap incoming damage
	var status_effect_cap_damage: StatusEffectData = StatusEffectData.new("status_effect_cap_damage")
	status_effect_cap_damage.status_effect_name = "硬件承伤上限"
	status_effect_cap_damage.status_effect_description = "单次受到的完整度扣除（无视防火墙阻挡）最多不会超过等同于副层数的点数。"
	status_effect_cap_damage.status_effect_tooltip = "单次受到的完整度扣除（无视防火墙阻挡）最多不会超过 [color=yellow][secondary_charges][/color] 点。剩余生效次数：[color=yellow][charge_amount][/color]。"
	status_effect_cap_damage.status_effect_texture_path = "sprites/status_effects/icon_cap_damage.png"
	status_effect_cap_damage.status_effect_decay_rate = -1
	status_effect_cap_damage.status_effect_allows_multiples = false
	status_effect_cap_damage.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_cap_damage.status_effect_secondary_charge_collision_strategy = StatusEffectData.STATUS_EFFECT_SECONDARY_CHARGE_COLLISION_STRATEGIES.KEEP
	status_effect_cap_damage.status_effect_interceptor_ids = ["interceptor_cap_damage"]

	Global.register_rod(status_effect_cap_damage)

	# uses an interceptor to prevent block from resetting
	var status_effect_temp_preserve_block: StatusEffectData = StatusEffectData.new("status_effect_temp_preserve_block")
	status_effect_temp_preserve_block.status_effect_name = "缓存防御"
	status_effect_temp_preserve_block.status_effect_description = "回合结束时防火墙不会被清除。每回合衰减 1 层。"
	status_effect_temp_preserve_block.status_effect_tooltip = "回合结束时防火墙不会被清除。剩余生效次数：[color=yellow][charge_amount][/color]。每回合衰减 1 层。"
	status_effect_temp_preserve_block.status_effect_texture_path = "sprites/status_effects/icon_temp_preserve_block.png"
	status_effect_temp_preserve_block.status_effect_decay_rate = -1
	status_effect_temp_preserve_block.status_effect_interceptor_ids = ["interceptor_temp_preserve_block"]

	Global.register_rod(status_effect_temp_preserve_block)

	# uses an interceptor to prevent block from resetting
	var status_effect_preserve_block: StatusEffectData = StatusEffectData.new("status_effect_preserve_block")
	status_effect_preserve_block.status_effect_name = "持久化防御"
	status_effect_preserve_block.status_effect_description = "每个时钟周期结束时，所有防火墙都不会被清除。"
	status_effect_preserve_block.status_effect_texture_path = "sprites/status_effects/icon_preserve_block.png"
	status_effect_preserve_block.status_effect_decay_rate = 0
	status_effect_preserve_block.status_effect_charge_upper_bound = 1
	status_effect_preserve_block.status_effect_interceptor_ids = ["interceptor_preserve_block"]

	Global.register_rod(status_effect_preserve_block)

	# uses an interceptor to stop a debuff from happening
	var status_effect_negate_debuff: StatusEffectData = StatusEffectData.new("status_effect_negate_debuff")
	status_effect_negate_debuff.status_effect_name = "异常阻断"
	status_effect_negate_debuff.status_effect_description = "完全抵消下一次受到的减益效果。"
	status_effect_negate_debuff.status_effect_tooltip = "完全抵消接下来的 [color=yellow][charge_amount][/color] 次受到的减益效果。"
	status_effect_negate_debuff.status_effect_texture_path = "sprites/status_effects/icon_negate_debuff.png"
	status_effect_negate_debuff.status_effect_decay_rate = 0
	status_effect_negate_debuff.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_negate_debuff.status_effect_interceptor_ids = ["interceptor_negate_debuff"]

	Global.register_rod(status_effect_negate_debuff)

	# uses an interceptor to rebound card plays to draw pile
	var status_effect_rebound_card_plays: StatusEffectData = StatusEffectData.new("status_effect_rebound_card_plays")
	status_effect_rebound_card_plays.status_effect_name = "回调执行"
	status_effect_rebound_card_plays.status_effect_description = "下一次打出的脚本将直接返回脚本库顶部。"
	status_effect_rebound_card_plays.status_effect_tooltip = "接下来的 [color=yellow][charge_amount][/color] 次打出的脚本将直接返回脚本库顶部。"
	status_effect_rebound_card_plays.status_effect_texture_path = "sprites/status_effects/icon_rebound_card_plays.png"
	status_effect_rebound_card_plays.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_rebound_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_rebound_card_plays.status_effect_action_process_times = [
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DISCARD_PLAYER_END_TURN,
		StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_ENEMY_TURN,
	]
	status_effect_rebound_card_plays.status_effect_interceptor_ids = ["interceptor_rebound_card_plays"]

	Global.register_rod(status_effect_rebound_card_plays)

	# rebounds incoming card plays to the draw pile
	var interceptor_rebound_card_plays: ActionInterceptorData = ActionInterceptorData.new("interceptor_rebound_card_plays")
	interceptor_rebound_card_plays.action_interceptor_priority = 10000
	interceptor_rebound_card_plays.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_rebound_card_plays.action_interceptor_script_path = Scripts.INTERCEPTOR_REBOUND_CARD_PLAYS
	interceptor_rebound_card_plays.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_rebound_card_plays)

	# uses an interceptor to duplicate the first card play each turn
	var status_effect_duplicate_card_plays: StatusEffectData = StatusEffectData.new("status_effect_duplicate_card_plays")
	status_effect_duplicate_card_plays.status_effect_name = "多线程执行"
	status_effect_duplicate_card_plays.status_effect_description = "下一次打出的脚本将被立刻额外执行一次。"
	status_effect_duplicate_card_plays.status_effect_tooltip = "接下来的 [color=yellow][charge_amount][/color] 次打出的脚本将被立刻额外执行一次。"
	status_effect_duplicate_card_plays.status_effect_texture_path = "sprites/status_effects/icon_duplicate_card_plays.png"
	status_effect_duplicate_card_plays.status_effect_script_path = "res://scripts/status_effects/StatusEffectDuplicateCardPlays.gd"
	status_effect_duplicate_card_plays.status_effect_decay_rate = 0
	status_effect_duplicate_card_plays.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_card_plays.status_effect_interceptor_ids = ["interceptor_duplicate_card_plays"]

	Global.register_rod(status_effect_duplicate_card_plays)

	# uses an interceptor to duplicate attack card plays
	var status_effect_duplicate_attacks: StatusEffectData = StatusEffectData.new("status_effect_duplicate_attacks")
	status_effect_duplicate_attacks.status_effect_name = "多线程攻击"
	status_effect_duplicate_attacks.status_effect_description = "下一次打出的攻击脚本将被立刻额外执行一次。"
	status_effect_duplicate_attacks.status_effect_tooltip = "接下来的 [color=yellow][charge_amount][/color] 次打出的攻击脚本将被立刻额外执行一次。"
	status_effect_duplicate_attacks.status_effect_texture_path = "sprites/status_effects/icon_duplicate_attacks.png"
	status_effect_duplicate_attacks.status_effect_decay_rate = -999
	status_effect_duplicate_attacks.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_duplicate_attacks.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]

	Global.register_rod(status_effect_duplicate_attacks)

	# uses an interceptor to duplicate attack card plays
	var status_effect_block_on_special_discard: StatusEffectData = StatusEffectData.new("status_effect_block_on_special_discard")
	status_effect_block_on_special_discard.status_effect_name = "缓存回收"
	status_effect_block_on_special_discard.status_effect_description = "被其他效果强制丢弃进入回收站时，获得等同于层数的防火墙。"
	status_effect_block_on_special_discard.status_effect_tooltip = "被其他效果强制丢弃进入回收站时，获得 [color=yellow][charge_amount][/color] 点防火墙。"
	status_effect_block_on_special_discard.status_effect_texture_path = "sprites/status_effects/icon_block_on_special_discard.png"
	status_effect_block_on_special_discard.status_effect_decay_rate = 0
	status_effect_block_on_special_discard.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_block_on_special_discard.status_effect_interceptor_ids = ["interceptor_duplicate_attacks"]

	Global.register_rod(status_effect_block_on_special_discard)

	var status_effect_high_latency: StatusEffectData = StatusEffectData.new("status_effect_high_latency")
	status_effect_high_latency.status_effect_name = "【系统专用】高延迟异常状态挂载核心进程"
	status_effect_high_latency.status_effect_description = "专用于处理高延迟debuff计算及伤害延后结算机制的系统底层进程。"
	status_effect_high_latency.status_effect_is_visible = false
	status_effect_high_latency.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_high_latency.status_effect_decay_rate = 0
	status_effect_high_latency.status_effect_charge_upper_bound = 999
	status_effect_high_latency.status_effect_interceptor_ids = ["interceptor_high_latency"]
	Global.register_rod(status_effect_high_latency)

	var status_effect_memory_leak: StatusEffectData = StatusEffectData.new("status_effect_memory_leak")
	status_effect_memory_leak.status_effect_name = "【系统专用】内存泄漏延迟伤害结算进程"
	status_effect_memory_leak.status_effect_description = "专用于处理内存泄漏触发的每回合延迟自我伤害计算的系统底层进程。"
	status_effect_memory_leak.status_effect_is_visible = false
	status_effect_memory_leak.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_memory_leak.status_effect_decay_rate = 0
	status_effect_memory_leak.status_effect_charge_upper_bound = 999
	status_effect_memory_leak.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DRAW_PLAYER_START_TURN]
	status_effect_memory_leak.status_effect_player_process_actions = [
		{
			Scripts.ACTION_DIRECT_DAMAGE: {
				"custom_key_names": {
					"damage": "invoking_status_effect_charges",
				},
				"bypass_block": true,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
			},
		},
	]
	Global.register_rod(status_effect_memory_leak)

	var status_effect_turn_forge_load: StatusEffectData = StatusEffectData.new("status_effect_turn_forge_load")
	status_effect_turn_forge_load.status_effect_name = "载荷"
	status_effect_turn_forge_load.status_effect_description = "记录本回合内被加入锻造台的所有代码的总负载。"
	status_effect_turn_forge_load.status_effect_texture_path = "sprites/status_effects/icon_turn_forge_load.png"
	status_effect_turn_forge_load.status_effect_is_visible = true
	status_effect_turn_forge_load.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL
	status_effect_turn_forge_load.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.PRE_DRAW_PLAYER_START_TURN]
	status_effect_turn_forge_load.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	status_effect_turn_forge_load.status_effect_charge_upper_bound = 999
	Global.register_rod(status_effect_turn_forge_load)

	var status_effect_timestamp_spoofing: StatusEffectData = StatusEffectData.new("status_effect_timestamp_spoofing")
	status_effect_timestamp_spoofing.status_effect_name = "时间戳伪造"
	status_effect_timestamp_spoofing.status_effect_description = "锁定真实时间 5 秒，期间所有卡牌 0 费。5 秒后直接强制结束当前时钟周期。"
	status_effect_timestamp_spoofing.status_effect_tooltip = "锁定真实时间 5 秒，期间所有卡牌 0 费。5 秒后直接强制结束当前时钟周期。"
	status_effect_timestamp_spoofing.status_effect_decay_rate = 0
	status_effect_timestamp_spoofing.status_effect_is_visible = false
	status_effect_timestamp_spoofing.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.BUFF
	status_effect_timestamp_spoofing.status_effect_script_path = "res://scripts/status_effects/player_status_effects/StatusTimestampSpoofing.gd"
	status_effect_timestamp_spoofing.status_effect_action_process_times = [StatusEffectData.STATUS_EFFECT_PROCESS_TIMES.POST_DISCARD_PLAYER_END_TURN]
	status_effect_timestamp_spoofing.status_effect_decay_type = StatusEffectData.STATUS_EFFECT_DECAY_TYPES.ZERO_OUT
	Global.register_rod(status_effect_timestamp_spoofing)

	var status_effect_deadlock: StatusEffectData = StatusEffectData.new("status_effect_deadlock")
	status_effect_deadlock.status_effect_name = "死锁"
	status_effect_deadlock.status_effect_description = "限制你的权限，无法打出任何脚本。"
	status_effect_deadlock.status_effect_tooltip = "由于系统死锁，你无法打出任何脚本。剩余 [color=yellow][charge_amount][/color] 个回合。"
	status_effect_deadlock.status_effect_texture_path = "sprites/status_effects/icon_deadlock.png"
	status_effect_deadlock.status_effect_decay_rate = -1
	status_effect_deadlock.status_effect_type = StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF
	status_effect_deadlock.status_effect_interceptor_ids = ["interceptor_deadlock"]
	Global.register_rod(status_effect_deadlock)

#endregion

#region Acts
func add_acts() -> void:
	GlobalProdDataGeneratorActOne.add_act()
	GlobalProdDataGeneratorActTwo.add_act()
	GlobalProdDataGeneratorActThree.add_act()

#endregion

#region Events and Event Pools
func add_events() -> void:
	GlobalProdDataGeneratorActOne.add_events()
	GlobalProdDataGeneratorActTwo.add_events()
	GlobalProdDataGeneratorActThree.add_events()

#endregion

#region Dialogue

## Adds test DialogueData, and their embedded DialogueStateData and DialogueOptionData payloads
func add_dialogue() -> void:
	GlobalDialogueGenerator.add_dialogues()

#endregion

#region Action Interceptors
func add_action_interceptors() -> void:
	# boss mechanics
	var interceptor_root_privilege: ActionInterceptorData = ActionInterceptorData.new("interceptor_root_privilege")
	interceptor_root_privilege.action_interceptor_priority = 0
	interceptor_root_privilege.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_root_privilege.action_interceptor_script_path = Scripts.INTERCEPTOR_ROOT_PRIVILEGE
	interceptor_root_privilege.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	Global.register_rod(interceptor_root_privilege)

	var interceptor_damage_threshold: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_threshold")
	interceptor_damage_threshold.action_interceptor_priority = 0
	interceptor_damage_threshold.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_damage_threshold.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_THRESHOLD
	interceptor_damage_threshold.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]
	Global.register_rod(interceptor_damage_threshold)

	var interceptor_card_play_reaction: ActionInterceptorData = ActionInterceptorData.new("interceptor_card_play_reaction")
	interceptor_card_play_reaction.action_interceptor_priority = 0
	interceptor_card_play_reaction.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_card_play_reaction.action_interceptor_script_path = Scripts.INTERCEPTOR_CARD_PLAY_REACTION
	interceptor_card_play_reaction.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	Global.register_rod(interceptor_card_play_reaction)

	var interceptor_card_play_reaction_self: ActionInterceptorData = ActionInterceptorData.new("interceptor_card_play_reaction_self")
	interceptor_card_play_reaction_self.action_interceptor_priority = 0
	interceptor_card_play_reaction_self.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_card_play_reaction_self.action_interceptor_script_path = Scripts.INTERCEPTOR_CARD_PLAY_REACTION_SELF
	interceptor_card_play_reaction_self.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	Global.register_rod(interceptor_card_play_reaction_self)

	var interceptor_firewall_protocol: ActionInterceptorData = ActionInterceptorData.new("interceptor_firewall_protocol")
	interceptor_firewall_protocol.action_interceptor_priority = 0
	interceptor_firewall_protocol.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_firewall_protocol.action_interceptor_script_path = Scripts.INTERCEPTOR_FIREWALL_PROTOCOL
	interceptor_firewall_protocol.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	Global.register_rod(interceptor_firewall_protocol)

	var interceptor_payload_turbine: ActionInterceptorData = ActionInterceptorData.new("interceptor_payload_turbine")
	interceptor_payload_turbine.action_interceptor_priority = 0
	interceptor_payload_turbine.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_payload_turbine.action_interceptor_script_path = "res://scripts/action_interceptors/InterceptorPayloadTurbine.gd"
	interceptor_payload_turbine.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]
	Global.register_rod(interceptor_payload_turbine)

	# increases damage done by attackers
	var interceptor_damage_increase: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_increase")
	interceptor_damage_increase.action_interceptor_priority = 10000
	interceptor_damage_increase.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_damage_increase.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_INCREASE
	interceptor_damage_increase.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_increase)

	# decreases damage done by attackers
	var interceptor_weaken: ActionInterceptorData = ActionInterceptorData.new("interceptor_weaken")
	interceptor_weaken.action_interceptor_priority = 9500
	interceptor_weaken.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_weaken.action_interceptor_script_path = Scripts.INTERCEPTOR_WEAKEN
	interceptor_weaken.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_weaken)

	# increases damage done to the attacked
	var interceptor_vulnerable: ActionInterceptorData = ActionInterceptorData.new("interceptor_vulnerable")
	interceptor_vulnerable.action_interceptor_priority = 9000
	interceptor_vulnerable.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_vulnerable.action_interceptor_script_path = Scripts.INTERCEPTOR_VULNERABLE
	interceptor_vulnerable.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_vulnerable)

	# increases number of cards drawn
	var interceptor_increase_turn_draw: ActionInterceptorData = ActionInterceptorData.new("interceptor_increase_turn_draw")
	interceptor_increase_turn_draw.action_interceptor_priority = 9000
	interceptor_increase_turn_draw.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_increase_turn_draw.action_interceptor_script_path = Scripts.INTERCEPTOR_INCREASE_TURN_DRAW
	interceptor_increase_turn_draw.action_intercepted_action_paths = [Scripts.ACTION_DRAW_GENERATOR]

	Global.register_rod(interceptor_increase_turn_draw)

	# provides extra health
	var interceptor_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_overshield")
	interceptor_overshield.action_interceptor_priority = 8000
	interceptor_overshield.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_OVERSHIELD
	interceptor_overshield.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_overshield)

	# prevents energy from reseting
	var interceptor_preserve_energy: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_energy")
	interceptor_preserve_energy.action_interceptor_priority = 10000
	interceptor_preserve_energy.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_preserve_energy.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_ENERGY
	interceptor_preserve_energy.action_intercepted_action_paths = [Scripts.ACTION_RESET_ENERGY]

	Global.register_rod(interceptor_preserve_energy)

	# prevents overshield from decaying
	var interceptor_preserve_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_overshield")
	interceptor_preserve_overshield.action_interceptor_priority = 10000
	interceptor_preserve_overshield.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_preserve_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_OVERSHIELD
	interceptor_preserve_overshield.action_intercepted_action_paths = [Scripts.ACTION_DECAY_STATUS]

	Global.register_rod(interceptor_preserve_overshield)

	# damages attackers
	var interceptor_pointy: ActionInterceptorData = ActionInterceptorData.new("interceptor_pointy")
	interceptor_pointy.action_interceptor_priority = 0
	interceptor_pointy.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_pointy.action_interceptor_script_path = Scripts.INTERCEPTOR_POINTY
	interceptor_pointy.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_pointy)

	# increases attack power from overshield charges
	# typically a forced interceptor
	var interceptor_damage_from_overshield: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_from_overshield")
	interceptor_damage_from_overshield.action_interceptor_priority = 10000
	interceptor_damage_from_overshield.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_damage_from_overshield.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_FROM_OVERSHIELD
	interceptor_damage_from_overshield.action_intercepted_action_paths = [Scripts.ACTION_ATTACK_GENERATOR, Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_from_overshield)

	# increases attack power from block
	# typically a forced interceptor
	var interceptor_damage_from_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_damage_from_block")
	interceptor_damage_from_block.action_interceptor_priority = 10000
	interceptor_damage_from_block.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_damage_from_block.action_interceptor_script_path = Scripts.INTERCEPTOR_DAMAGE_FROM_BLOCK
	interceptor_damage_from_block.action_intercepted_action_paths = [Scripts.ACTION_ATTACK_GENERATOR, Scripts.ACTION_ATTACK]

	Global.register_rod(interceptor_damage_from_block)

	# negates incoming non zero damage actions
	var interceptor_negate_damage: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_damage")
	interceptor_negate_damage.action_interceptor_priority = -10000
	interceptor_negate_damage.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_negate_damage.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DAMAGE
	interceptor_negate_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_negate_damage)

	# caps incoming damage to status effect secondary charges
	var interceptor_cap_damage: ActionInterceptorData = ActionInterceptorData.new("interceptor_cap_damage")
	interceptor_cap_damage.action_interceptor_priority = -9000
	interceptor_cap_damage.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_cap_damage.action_interceptor_script_path = Scripts.INTERCEPTOR_CAP_DAMAGE
	interceptor_cap_damage.action_intercepted_action_paths = [Scripts.ACTION_ATTACK, Scripts.ACTION_DIRECT_DAMAGE]

	Global.register_rod(interceptor_cap_damage)

	# rejects block reset actions
	var interceptor_temp_preserve_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_temp_preserve_block")
	interceptor_temp_preserve_block.action_interceptor_priority = 10000
	interceptor_temp_preserve_block.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_temp_preserve_block.action_interceptor_script_path = Scripts.INTERCEPTOR_TEMP_PRESERVE_BLOCK
	interceptor_temp_preserve_block.action_intercepted_action_paths = [Scripts.ACTION_RESET_BLOCK]

	Global.register_rod(interceptor_temp_preserve_block)

	# rejects block reset actions
	var interceptor_preserve_block: ActionInterceptorData = ActionInterceptorData.new("interceptor_preserve_block")
	interceptor_preserve_block.action_interceptor_priority = 10000
	interceptor_preserve_block.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_preserve_block.action_interceptor_script_path = Scripts.INTERCEPTOR_PRESERVE_BLOCK
	interceptor_preserve_block.action_intercepted_action_paths = [Scripts.ACTION_RESET_BLOCK]

	Global.register_rod(interceptor_preserve_block)

	# rejects debuffing status actions
	var interceptor_negate_debuff: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_debuff")
	interceptor_negate_debuff.action_interceptor_priority = 10000
	interceptor_negate_debuff.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_negate_debuff.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_DEBUFF
	interceptor_negate_debuff.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]

	Global.register_rod(interceptor_negate_debuff)

	# duplicates incoming card plays
	var interceptor_duplicate_card_plays: ActionInterceptorData = ActionInterceptorData.new("interceptor_duplicate_card_plays")
	interceptor_duplicate_card_plays.action_interceptor_priority = 10000
	interceptor_duplicate_card_plays.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_duplicate_card_plays.action_interceptor_script_path = Scripts.INTERCEPTOR_DUPLICATE_CARD_PLAYS
	interceptor_duplicate_card_plays.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_duplicate_card_plays)

	# duplicates incoming attack card plays
	var interceptor_duplicate_attacks: ActionInterceptorData = ActionInterceptorData.new("interceptor_duplicate_attacks")
	interceptor_duplicate_attacks.action_interceptor_priority = 10000
	interceptor_duplicate_attacks.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_duplicate_attacks.action_interceptor_script_path = Scripts.INTERCEPTOR_DUPLICATE_ATTACKS
	interceptor_duplicate_attacks.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]

	Global.register_rod(interceptor_duplicate_attacks)

	# uses a consumable to prevent player death
	var interceptor_consumable_auto_revive: ActionInterceptorData = ActionInterceptorData.new("interceptor_consumable_auto_revive")
	interceptor_consumable_auto_revive.action_interceptor_priority = 10000
	interceptor_consumable_auto_revive.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_consumable_auto_revive.action_interceptor_script_path = Scripts.INTERCEPTOR_CONSUMABLE_AUTO_REVIVE
	interceptor_consumable_auto_revive.action_intercepted_action_paths = [Scripts.ACTION_DEATH]

	Global.register_rod(interceptor_consumable_auto_revive)

	# prevents gaining money
	var interceptor_negate_add_money: ActionInterceptorData = ActionInterceptorData.new("interceptor_negate_add_money")
	interceptor_negate_add_money.action_interceptor_priority = 10000
	interceptor_negate_add_money.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_negate_add_money.action_interceptor_script_path = Scripts.INTERCEPTOR_NEGATE_ADD_MONEY
	interceptor_negate_add_money.action_intercepted_action_paths = [Scripts.ACTION_ADD_MONEY]

	Global.register_rod(interceptor_negate_add_money)

	var interceptor_reduce_add_money: ActionInterceptorData = ActionInterceptorData.new("interceptor_reduce_add_money")
	interceptor_reduce_add_money.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_reduce_add_money.action_interceptor_script_path = Scripts.INTERCEPTOR_REDUCE_ADD_MONEY
	interceptor_reduce_add_money.action_intercepted_action_paths = [Scripts.ACTION_ADD_MONEY]
	Global.register_rod(interceptor_reduce_add_money)

	var interceptor_increase_add_money: ActionInterceptorData = ActionInterceptorData.new("interceptor_increase_add_money")
	interceptor_increase_add_money.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_increase_add_money.action_interceptor_script_path = Scripts.INTERCEPTOR_INCREASE_ADD_MONEY
	interceptor_increase_add_money.action_intercepted_action_paths = [Scripts.ACTION_ADD_MONEY]
	Global.register_rod(interceptor_increase_add_money)

	var interceptor_increase_shop_price: ActionInterceptorData = ActionInterceptorData.new("interceptor_increase_shop_price")
	interceptor_increase_shop_price.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_increase_shop_price.action_interceptor_script_path = Scripts.INTERCEPTOR_INCREASE_SHOP_PRICE
	interceptor_increase_shop_price.action_intercepted_action_paths = [Scripts.ACTION_GET_SHOP_PRICE, Scripts.ACTION_GET_ENCHANT_PRICE]
	Global.register_rod(interceptor_increase_shop_price)

	var interceptor_decrease_shop_price: ActionInterceptorData = ActionInterceptorData.new("interceptor_decrease_shop_price")
	interceptor_decrease_shop_price.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_decrease_shop_price.action_interceptor_script_path = Scripts.INTERCEPTOR_DECREASE_SHOP_PRICE
	interceptor_decrease_shop_price.action_intercepted_action_paths = [Scripts.ACTION_GET_SHOP_PRICE, Scripts.ACTION_GET_ENCHANT_PRICE]
	Global.register_rod(interceptor_decrease_shop_price)

	var interceptor_high_latency: ActionInterceptorData = ActionInterceptorData.new("interceptor_high_latency")
	interceptor_high_latency.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_high_latency.action_interceptor_script_path = Scripts.INTERCEPTOR_HIGH_LATENCY
	interceptor_high_latency.action_intercepted_action_paths = [Scripts.ACTION_DRAW_GENERATOR]
	Global.register_rod(interceptor_high_latency)

	var interceptor_brute_force_attack: ActionInterceptorData = ActionInterceptorData.new("interceptor_brute_force_attack")
	interceptor_brute_force_attack.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_brute_force_attack.action_interceptor_script_path = Scripts.INTERCEPTOR_BRUTE_FORCE_ATTACK
	interceptor_brute_force_attack.action_intercepted_action_paths = [Scripts.ACTION_ATTACK]
	Global.register_rod(interceptor_brute_force_attack)

	var interceptor_brute_force_draw: ActionInterceptorData = ActionInterceptorData.new("interceptor_brute_force_draw")
	interceptor_brute_force_draw.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_brute_force_draw.action_interceptor_script_path = Scripts.INTERCEPTOR_BRUTE_FORCE_DRAW
	interceptor_brute_force_draw.action_intercepted_action_paths = [Scripts.ACTION_DRAW_GENERATOR]
	Global.register_rod(interceptor_brute_force_draw)

	var interceptor_zero_day_db: ActionInterceptorData = ActionInterceptorData.new("interceptor_zero_day_db")
	interceptor_zero_day_db.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_zero_day_db.action_interceptor_script_path = Scripts.INTERCEPTOR_ZERO_DAY_DB
	interceptor_zero_day_db.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]
	Global.register_rod(interceptor_zero_day_db)

	var interceptor_overflow_stack: ActionInterceptorData = ActionInterceptorData.new("interceptor_overflow_stack")
	interceptor_overflow_stack.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET
	interceptor_overflow_stack.action_interceptor_script_path = Scripts.INTERCEPTOR_OVERFLOW_STACK
	interceptor_overflow_stack.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]
	Global.register_rod(interceptor_overflow_stack)

	var interceptor_packet_sniffer: ActionInterceptorData = ActionInterceptorData.new("interceptor_packet_sniffer")
	interceptor_packet_sniffer.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_PER_TARGET
	interceptor_packet_sniffer.action_interceptor_script_path = Scripts.INTERCEPTOR_PACKET_SNIFFER
	interceptor_packet_sniffer.action_intercepted_action_paths = [Scripts.ACTION_APPLY_STATUS]
	Global.register_rod(interceptor_packet_sniffer)


	var interceptor_deadlock: ActionInterceptorData = ActionInterceptorData.new("interceptor_deadlock")
	interceptor_deadlock.action_interceptor_scope = ActionInterceptorData.INTERCEPTOR_SCOPES.PARENT_ONCE
	interceptor_deadlock.action_interceptor_script_path = Scripts.INTERCEPTOR_CARD_PLAY_DEADLOCK
	interceptor_deadlock.action_intercepted_action_paths = [Scripts.ACTION_CARD_PLAY]
	Global.register_rod(interceptor_deadlock)

#endregion

#region Colors

func add_colors() -> void:
	var color_green: ColorData = ColorData.new("color_green")
	color_green.color = Color.WEB_GREEN
	color_green.color_name = "青绿"
	color_green.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_green)

	var color_orange: ColorData = ColorData.new("color_orange")
	color_orange.color = Color.CORAL
	color_orange.color_name = "亮橙"
	color_orange.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_orange)

	var color_red: ColorData = ColorData.new("color_red")
	color_red.color = Color.FIREBRICK
	color_red.color_name = "猩红"
	color_red.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_red)

	var color_blue: ColorData = ColorData.new("color_blue")
	color_blue.color = Color.ROYAL_BLUE
	color_blue.color_name = "深蓝"
	color_blue.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_blue)

	var color_white: ColorData = ColorData.new("color_white")
	color_white.color = Color.WHITE_SMOKE
	color_white.color_name = "纯白"
	color_white.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_white)

	var color_purple: ColorData = ColorData.new("color_purple")
	color_purple.color = Color.REBECCA_PURPLE
	color_purple.color_name = "暗紫"
	color_purple.color_energy_icon_texture_path = "sprites/ui/icon_energy.png"
	Global.register_rod(color_purple)

#endregion

#region Keywords
func add_keywords() -> void:
	var keyword_block: KeywordData = KeywordData.new("keyword_block")
	keyword_block.keyword_name = "防火墙"
	keyword_block.keyword_text_bb_code = "抵消等量的伤害。在时钟周期结束时消失。"
	Global.register_rod(keyword_block)



	### These are automatically added to cards based on flags
	var keyword_top_deck: KeywordData = KeywordData.new("keyword_top_deck")
	keyword_top_deck.keyword_name = "置顶"
	keyword_top_deck.keyword_prefix = "[前置] "
	keyword_top_deck.keyword_text_bb_code = "必定出现在第一回合的初始线程中（若具有此词条的脚本过多，则优先置于内存队列最顶部）。"
	Global.register_rod(keyword_top_deck)

	var keyword_bottom_deck: KeywordData = KeywordData.new("keyword_bottom_deck")
	keyword_bottom_deck.keyword_name = "置底"
	keyword_bottom_deck.keyword_prefix = "[前置] "
	keyword_bottom_deck.keyword_text_bb_code = "战斗开始时强制沉底，必定处于内存队列的最底层。"
	Global.register_rod(keyword_bottom_deck)

	var keyword_rebound: KeywordData = KeywordData.new("keyword_rebound")
	keyword_rebound.keyword_name = "回弹"
	keyword_rebound.keyword_prefix = "[后置] "
	keyword_rebound.keyword_text_bb_code = "打出该脚本后，将其置于内存队列顶部。对不会进入回收站的脚本无效。"
	Global.register_rod(keyword_rebound)

	var keyword_discard: KeywordData = KeywordData.new("keyword_discard")
	keyword_discard.keyword_name = "丢弃"
	keyword_discard.keyword_prefix = "[后置] "
	keyword_discard.keyword_text_bb_code = "将脚本直接放入回收站。"
	Global.register_rod(keyword_discard)

	var keyword_retain: KeywordData = KeywordData.new("keyword_retain")
	keyword_retain.keyword_name = "保留"
	keyword_retain.keyword_prefix = "[前置] "
	keyword_retain.keyword_text_bb_code = "时钟周期结束时，该脚本不会被丢弃到回收站。"
	Global.register_rod(keyword_retain)

	var keyword_exhaust: KeywordData = KeywordData.new("keyword_exhaust")
	keyword_exhaust.keyword_name = "物理删除"
	keyword_exhaust.keyword_prefix = "[后置] "
	keyword_exhaust.keyword_text_bb_code = "使用后进入【坏道区】，本场战斗内无法再次抽取。"
	Global.register_rod(keyword_exhaust)

	var keyword_ethereal: KeywordData = KeywordData.new("keyword_ethereal")
	keyword_ethereal.keyword_name = "虚无"
	keyword_ethereal.keyword_prefix = "[前置] "
	keyword_ethereal.keyword_text_bb_code = "时钟周期结束时，若仍在当前线程中，则会被物理删除。"
	keyword_ethereal.keyword_child_keyword_object_ids = ["keyword_exhaust"]
	Global.register_rod(keyword_ethereal)

	var keyword_banish: KeywordData = KeywordData.new("keyword_banish")
	keyword_banish.keyword_name = "放逐"
	keyword_banish.keyword_prefix = "[后置] "
	keyword_banish.keyword_text_bb_code = "打出后，该脚本从本场战斗中彻底抹除，不再进入任何卡池（包括回收站或坏道区）。"
	keyword_banish.keyword_child_keyword_object_ids = []
	Global.register_rod(keyword_banish)

	var keyword_fleeting: KeywordData = KeywordData.new("keyword_fleeting")
	keyword_fleeting.keyword_name = "瞬态"
	keyword_fleeting.keyword_prefix = "[前置] "
	keyword_fleeting.keyword_text_bb_code = "时钟周期结束时，若仍在当前线程中，则会被放逐。"
	keyword_fleeting.keyword_child_keyword_object_ids = ["keyword_banish"]
	Global.register_rod(keyword_fleeting)

	var keyword_consumable: KeywordData = KeywordData.new("keyword_consumable")
	keyword_consumable.keyword_name = "消耗"
	keyword_consumable.keyword_prefix = "[后置] "
	keyword_consumable.keyword_text_bb_code = "打出后，该脚本将从你的脚本库中永久删除。"
	keyword_consumable.keyword_child_keyword_object_ids = []
	Global.register_rod(keyword_consumable)

	var keyword_unplayable: KeywordData = KeywordData.new("keyword_unplayable")
	keyword_unplayable.keyword_name = "不可打出"
	keyword_unplayable.keyword_prefix = "[前置] "
	keyword_unplayable.keyword_text_bb_code = "该脚本无法被主动打出。"
	Global.register_rod(keyword_unplayable)

#endregion

#region VFX Animations
func add_combat_vfx_animations() -> void:
	CombatVFXAnimations.register_all()
#endregion

#region Characters

func add_characters() -> void:
	var character_color: String = "" # used to make writing boilerplate colors faster

	# green character
	character_color = "green"
	var character_green: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_green.character_player_id = "player_{0}".format([character_color])
	character_green.character_name = "赛博植物学家"
	character_green.character_description = "一个觉醒了仿生逻辑的流氓进程。它将计算机病毒伪装成植物的生态系统，用‘数据花粉’和‘反伤木马’感染防火墙，通过‘光电合成’窃取系统算力。它不仅是播种者，也是这台冰冷机器的毁灭者。"
	character_green.character_color_id = "color_{0}".format([character_color])
	character_green.character_icon_texture_path = "sprites/characters/character_green/character_green_idle.png"
	character_green.character_background_texture_path = "sprites/characters/character_green/character_green_poster.png"
	character_green.character_starting_health = 75
	character_green.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_green.character_starting_artifact_ids = ["artifact_draw_on_combat_start"]
	character_green.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_green.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_green.character_starting_card_object_ids = [
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_attack_green",
		"card_basic_block_green",
		"card_basic_block_green",
		"card_basic_block_green",
		"card_basic_block_green",
		"card_energy_injection"
	]

	# green character animations
	var animation_character_green: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_green.character_animation_id = animation_character_green.object_id
	animation_character_green.add_combatant_animations(
		["sprites/characters/character_green/character_green_idle.png"],
		[
			"sprites/characters/character_green/attack/character_green_attack_1.png",
			"sprites/characters/character_green/attack/character_green_attack_2.png",
			"sprites/characters/character_green/attack/character_green_attack_3.png",
			"sprites/characters/character_green/attack/character_green_attack_4.png",
			"sprites/characters/character_green/attack/character_green_attack_5.png",
			"sprites/characters/character_green/attack/character_green_attack_6.png",
		],
		[
			"sprites/characters/character_green/death/character_green_death_1.png",
			"sprites/characters/character_green/death/character_green_death_2.png",
			"sprites/characters/character_green/death/character_green_death_3.png",
			"sprites/characters/character_green/death/character_green_death_4.png",
			"sprites/characters/character_green/death/character_green_death_5.png",
			"sprites/characters/character_green/death/character_green_death_6.png",
		],
	)

	Global.register_rod(animation_character_green)
	Global.register_rod(character_green)

	# red character - 码农 / 程序员
	character_color = "red"
	var character_red: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_red.character_player_id = "player_{0}".format([character_color])
	character_red.character_name = "码农"
	character_red.character_description = "一个平凡的程序员，在数字世界中用代码对抗混乱。他擅长简洁的逻辑复用，能将有限的资源转化为可观战力。"
	character_red.character_color_id = "color_{0}".format([character_color])
	character_red.character_icon_texture_path = "sprites/characters/character_red/character_red_idle.png"
	character_red.character_background_texture_path = "sprites/characters/character_red/character_red_poster.png"
	character_red.character_starting_health = 65
	character_red.character_starting_artifact_ids = ["artifact_block_on_attacks"]
	character_red.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_red.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_red.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_red.character_starting_card_object_ids = [
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_attack_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_basic_block_red",
		"card_energy_injection"
	]

	var animation_character_red: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_red.character_animation_id = animation_character_red.object_id
	animation_character_red.add_combatant_animations(
		["sprites/characters/character_red/character_red_idle.png"],
		[
			"sprites/characters/character_red/attack/character_red_attack_1.png",
			"sprites/characters/character_red/attack/character_red_attack_2.png",
			"sprites/characters/character_red/attack/character_red_attack_3.png",
			"sprites/characters/character_red/attack/character_red_attack_4.png",
			"sprites/characters/character_red/attack/character_red_attack_5.png",
			"sprites/characters/character_red/attack/character_red_attack_6.png",
		],
		[
			"sprites/characters/character_red/death/character_red_death_1.png",
			"sprites/characters/character_red/death/character_red_death_2.png",
			"sprites/characters/character_red/death/character_red_death_3.png",
			"sprites/characters/character_red/death/character_red_death_4.png",
			"sprites/characters/character_red/death/character_red_death_5.png",
			"sprites/characters/character_red/death/character_red_death_6.png",
		],
	)

	Global.register_rod(animation_character_red)
	Global.register_rod(character_red)

	# blue character - 渗透专家 / 白帽黑客
	character_color = "blue"
	var character_blue: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_blue.character_player_id = "player_{0}".format([character_color])
	character_blue.character_name = "渗透专家"
	character_blue.character_description = "一名游走于暗网与内核之间的白帽黑客。他不是在破坏，而是在渗透——窃取情报、混淆视听、将敌人的算力玩弄于股掌之间。在他的字典里，'防御'永远是过时的概念。"
	character_blue.character_color_id = "color_{0}".format([character_color])
	character_blue.character_icon_texture_path = "sprites/characters/character_{0}/character_{0}_idle.png".format([character_color])
	character_blue.character_background_texture_path = "sprites/characters/character_{0}/character_{0}_poster.png".format([character_color])
	character_blue.character_starting_health = 75
	character_blue.character_starting_artifact_ids = ["artifact_see_top_of_draw_pile"]
	character_blue.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_blue.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_blue.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_blue.character_starting_card_object_ids = [
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_attack_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
		"card_basic_block_blue",
		"card_energy_injection"
	]

	# 动画资源接入
	var animation_character_blue: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_blue.character_animation_id = animation_character_blue.object_id
	animation_character_blue.add_combatant_animations(
		[
			"sprites/characters/character_{0}/character_{0}_idle.png".format([character_color])
		],
		[
			"sprites/characters/character_{0}/attack/character_{0}_attack_1.png".format([character_color]),
			"sprites/characters/character_{0}/attack/character_{0}_attack_2.png".format([character_color]),
			"sprites/characters/character_{0}/attack/character_{0}_attack_3.png".format([character_color]),
			"sprites/characters/character_{0}/attack/character_{0}_attack_4.png".format([character_color]),
			"sprites/characters/character_{0}/attack/character_{0}_attack_5.png".format([character_color]),
			"sprites/characters/character_{0}/attack/character_{0}_attack_6.png".format([character_color]),
		],
		[
			"sprites/characters/character_{0}/death/character_{0}_death_1.png".format([character_color]),
			"sprites/characters/character_{0}/death/character_{0}_death_2.png".format([character_color]),
			"sprites/characters/character_{0}/death/character_{0}_death_3.png".format([character_color]),
			"sprites/characters/character_{0}/death/character_{0}_death_4.png".format([character_color]),
			"sprites/characters/character_{0}/death/character_{0}_death_5.png".format([character_color]),
			"sprites/characters/character_{0}/death/character_{0}_death_6.png".format([character_color]),
		]
	)

	Global.register_rod(animation_character_blue)
	Global.register_rod(character_blue)

	# orange character
	character_color = "orange"
	var character_orange: CharacterData = CharacterData.new("character_{0}".format([character_color]))
	character_orange.character_player_id = "player_{0}".format([character_color])
	character_orange.character_name = "重构工匠"
	character_orange.character_description = "一个痴迷于重组底层数据的硬件极客。随身携带的微型锻造台是它的核心驱动力。它擅长将杂乱无章的散碎指令丢进高温熔炉，重新编译并锻造成极具破坏力的融合协议。在它的操作台上，一切冗余代码都将迎来新生。"
	character_orange.character_color_id = "color_{0}".format([character_color])
	character_orange.character_icon_texture_path = "sprites/characters/character_{0}/character_{0}_idle.png".format([character_color])
	character_orange.character_background_texture_path = "sprites/characters/character_{0}/character_{0}_poster.png".format([character_color])
	character_orange.character_starting_health = 70
	character_orange.character_starting_artifact_ids = ["artifact_forge"]
	character_orange.character_starting_card_draft_card_pack_ids = ["card_pack_{0}".format([character_color])]
	character_orange.character_starting_artifact_pack_ids = ["artifact_pack_white", "artifact_pack_{0}".format([character_color])]
	character_orange.character_starting_consumable_pack_ids = ["consumable_pack_white", "consumable_pack_{0}".format([character_color])]
	character_orange.character_starting_card_object_ids = [
		  "card_basic_attack_orange",
		  "card_basic_attack_orange",
		  "card_basic_attack_orange",
		  "card_basic_attack_orange",
		  "card_basic_block_orange",
		  "card_basic_block_orange",
		  "card_basic_block_orange",
		  "card_basic_block_orange",
		"card_energy_injection"
	]

	# 动画资源接入
	var animation_character_orange: AnimationData = AnimationData.new("animation_character_{0}".format([character_color]))
	character_orange.character_animation_id = animation_character_orange.object_id
	animation_character_orange.add_combatant_animations(
		[
			"sprites/characters/character_{0}/character_{0}_idle.png".format([character_color])
		],
		[
			"sprites/characters/character_{0}/character_{0}_idle.png".format([character_color]),
		],
		[
			"sprites/characters/character_{0}/character_{0}_idle.png".format([character_color]),
		]
	)

	Global.register_rod(animation_character_orange)
	Global.register_rod(character_orange)

#endregion

#region Run Modifiers

func add_run_modifiers() -> void:
	### Standard Difficulty Run Modifiers
	var run_modifier_difficulty_0: RunModifierData = RunModifierData.new("run_modifier_difficulty_0")
	run_modifier_difficulty_0.run_modifier_name = "基础难度：正常执行"
	run_modifier_difficulty_0.run_modifier_modifier_script_path = ""

	Global.register_rod(run_modifier_difficulty_0)

	var run_modifier_difficulty_1: RunModifierData = RunModifierData.new("run_modifier_difficulty_1")
	run_modifier_difficulty_1.run_modifier_name = "难度 1：强化敌方进程"
	run_modifier_difficulty_1.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_1

	Global.register_rod(run_modifier_difficulty_1)

	var run_modifier_difficulty_2: RunModifierData = RunModifierData.new("run_modifier_difficulty_2")
	run_modifier_difficulty_2.run_modifier_name = "难度 2：强化精英怪"
	run_modifier_difficulty_2.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_2

	Global.register_rod(run_modifier_difficulty_2)

	var run_modifier_difficulty_3: RunModifierData = RunModifierData.new("run_modifier_difficulty_3")
	run_modifier_difficulty_3.run_modifier_name = "难度 3：强化Boss"
	run_modifier_difficulty_3.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_3

	Global.register_rod(run_modifier_difficulty_3)

	var run_modifier_difficulty_4: RunModifierData = RunModifierData.new("run_modifier_difficulty_4")
	run_modifier_difficulty_4.run_modifier_name = "难度 4：内存压缩"
	run_modifier_difficulty_4.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_4

	Global.register_rod(run_modifier_difficulty_4)

	var run_modifier_difficulty_5: RunModifierData = RunModifierData.new("run_modifier_difficulty_5")
	run_modifier_difficulty_5.run_modifier_name = "难度 5：内核级危机"
	run_modifier_difficulty_5.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_DIFFICULTY_5

	Global.register_rod(run_modifier_difficulty_5)

	# register the modifiers as standard difficulty
	Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS.append_array(
		[
			run_modifier_difficulty_0.object_id,
			run_modifier_difficulty_1.object_id,
			run_modifier_difficulty_2.object_id,
			run_modifier_difficulty_3.object_id,
			run_modifier_difficulty_4.object_id,
			run_modifier_difficulty_5.object_id,
		],
	)

	### Custom Run Modifiers
	var run_modifier_custom_easy_mode: RunModifierData = RunModifierData.new("run_modifier_custom_easy_mode")
	run_modifier_custom_easy_mode.run_modifier_name = "安全模式"
	run_modifier_custom_easy_mode.run_modifier_description = "[作弊] 将最大能量上限修改为99。并在首个时钟周期，强制将遭遇的所有敌方进程的最大完整度锁定为1。"
	run_modifier_custom_easy_mode.run_modifier_is_custom = true
	run_modifier_custom_easy_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_custom_easy_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_EASYMODE

	Global.register_rod(run_modifier_custom_easy_mode)

	var run_modifier_endless_mode: RunModifierData = RunModifierData.new("run_modifier_endless_mode")
	run_modifier_endless_mode.run_modifier_name = "死循环模式"
	run_modifier_endless_mode.run_modifier_description = "突破系统防线，通关第3节点后游戏不会结束，您将带着现有配置继续深入，直至核心被摧毁。"
	run_modifier_endless_mode.run_modifier_is_custom = true
	run_modifier_endless_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_endless_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_ENDLESS_MODE

	Global.register_rod(run_modifier_endless_mode)

	var run_modifier_draft_all_colors: RunModifierData = RunModifierData.new("run_modifier_draft_all_colors")
	run_modifier_draft_all_colors.run_modifier_name = "跨域授权"
	run_modifier_draft_all_colors.run_modifier_description = "解除隔离协议。在挑选脚本奖励时，系统将无视您的当前角色权限，提供来自所有角色的脚本。"
	run_modifier_draft_all_colors.run_modifier_is_custom = true
	run_modifier_draft_all_colors.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_draft_all_colors.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_DRAFT_ALL_COLORS

	Global.register_rod(run_modifier_draft_all_colors)

	var run_modifier_test_mode: RunModifierData = RunModifierData.new("run_modifier_test_mode")
	run_modifier_test_mode.run_modifier_name = "测试模式"
	run_modifier_test_mode.run_modifier_description = "初始自带万能调试仪和算力调试仪，方便测试卡牌和逻辑。"
	run_modifier_test_mode.run_modifier_is_custom = true
	run_modifier_test_mode.run_modifier_exclusive_to_modifier_ids = []
	run_modifier_test_mode.run_modifier_modifier_script_path = Scripts.RUN_MODIFIER_CUSTOM_TEST_MODE

	Global.register_rod(run_modifier_test_mode)

	### Automatic Modifiers

	# this allows for auto revive consumables to work each run
	var run_modifier_consumable_auto_revive: RunModifierData = RunModifierData.new("run_modifier_consumable_auto_revive")
	run_modifier_consumable_auto_revive.run_modifier_name = "自动重启"
	run_modifier_consumable_auto_revive.run_modifier_description = "包含自动重启外设"
	run_modifier_consumable_auto_revive.run_modifier_is_automatic = true # registered regardless of difficulty
	run_modifier_consumable_auto_revive.run_modifier_modifier_script_path = Scripts.BASE_RUN_MODIFIER # does nothing
	run_modifier_consumable_auto_revive.run_modifier_interceptor_ids = ["interceptor_consumable_auto_revive"] # ensures auto revive always active

	Global.register_rod(run_modifier_consumable_auto_revive)

#endregion

#region Run Start Options

func add_run_start_options() -> void:
	GlobalRunStartOptionsGenerator.add_run_start_options()

#endregion

#region Custom UI

func add_custom_ui() -> void:
	var custom_ui_see_top_of_draw_pile: CustomUIData = CustomUIData.new("custom_ui_see_top_of_draw_pile")
	custom_ui_see_top_of_draw_pile.custom_ui_asset_path = "res://scenes/ui/custom/CustomUISeeTopOfDrawPile.tscn"
	# custom_ui_see_top_of_draw_pile.custom_ui_requires_target = true
	Global.register_rod(custom_ui_see_top_of_draw_pile)

#endregion

#region Custom UI

func add_custom_signals() -> void:
	var custom_signal_special_discard: CustomSignalData = CustomSignalData.new("custom_signal_special_discard")
	custom_signal_special_discard.custom_signal_is_stat = true
	custom_signal_special_discard.custom_signal_stat_name = "CUSTOM_STAT_SPECIAL_DISCARD"
	Global.register_rod(custom_signal_special_discard)

	var custom_signal_overheated: CustomSignalData = CustomSignalData.new("custom_signal_overheated")
	custom_signal_overheated.custom_signal_is_stat = true
	custom_signal_overheated.custom_signal_stat_name = "CUSTOM_STAT_OVERHEATED"
	Global.register_rod(custom_signal_overheated)

	var custom_signal_open_see_top_ui: CustomSignalData = CustomSignalData.new("custom_signal_open_see_top_ui")
	Global.register_rod(custom_signal_open_see_top_ui)

	var custom_signal_open_forge_ui: CustomSignalData = CustomSignalData.new("custom_signal_open_forge_ui")
	Global.register_rod(custom_signal_open_forge_ui)

#endregion

#region Enemies
func add_enemies() -> void:
	GlobalProdDataGeneratorGlobalEnemies.add_enemies()
	GlobalProdDataGeneratorActOne.add_enemies()
	GlobalProdDataGeneratorActTwo.add_enemies()
	GlobalProdDataGeneratorActThree.add_enemies()

#endregion

#region Player Data Prototypes

func add_player_data() -> void:
	var player_red: PlayerData = PlayerData.new("player_red")
	player_red.player_character_object_id = "character_red"

	Global.register_rod(player_red)

	var player_blue: PlayerData = PlayerData.new("player_blue")
	player_blue.player_character_object_id = "character_blue"

	Global.register_rod(player_blue)

	var player_green: PlayerData = PlayerData.new("player_green")
	player_green.player_character_object_id = "character_green"

	Global.register_rod(player_green)

	var player_orange: PlayerData = PlayerData.new("player_orange")
	player_orange.player_character_object_id = "character_orange"

	Global.register_rod(player_orange)

#endregion


#region Cards

func add_cards() -> void:
	add_card_basics()
	add_cards_misc()
	add_cards_red()
	add_cards_blue()
	add_cards_green()
	add_cards_orange()


func add_card_basics() -> void:
	var colors: Array[String] = []

	for character_data: CharacterData in Global._id_to_character_data.values():
		colors.append(character_data.character_color_id.replace("color_", ""))

	for i: int in len(colors):
		# Basic attack card
		var card_basic_attack: CardData = CardData.new("card_basic_attack_{0}".format([colors[i]]))
		card_basic_attack.card_name = "基础攻击"
		card_basic_attack.card_color_id = "color_{0}".format([colors[i]])
		card_basic_attack.card_description = "造成 [damage] 点伤害。"
		card_basic_attack.card_texture_path = "sprites/card/{0}/card_basic_attack_{0}.png".format([colors[i]])
		card_basic_attack.card_hint = "这是最基础的攻击指令。虽然伤害不高，但在游戏前期是主要输出手段。"
		card_basic_attack.card_type = CardData.CARD_TYPES.ATTACK
		card_basic_attack.card_rarity = CardData.CARD_RARITIES.BASIC
		card_basic_attack.card_keyword_object_ids = []
		card_basic_attack.card_values = { "damage": 7, "number_of_attacks": 1, "impact_vfx_animation_id": "animation_vfx_impact_default" }
		card_basic_attack.card_upgrade_value_improvements = { "damage": 3 }
		card_basic_attack.card_play_actions = [
			{
				Scripts.ACTION_ATTACK_GENERATOR: { "time_delay": 0.0, "audio_path": AudioConstants.SFX_GROUP_SWORD_SLASH, "actions_on_lethal": [] },
			},
		]

		Global.register_rod(card_basic_attack)

		# Basic block card
		var card_basic_block: CardData = CardData.new("card_basic_block_{0}".format([colors[i]]))
		card_basic_block.card_name = "基础防火墙"
		card_basic_block.card_color_id = "color_{0}".format([colors[i]])
		card_basic_block.card_description = "获得 [block] 点防火墙"
		card_basic_block.card_texture_path = "sprites/card/{0}/card_basic_block_{0}.png".format([colors[i]])
		card_basic_block.card_hint = "这是最基础的防御指令。保持健康状态是走得更远的关键，不要忽略防御。"
		card_basic_block.card_type = CardData.CARD_TYPES.SKILL
		card_basic_block.card_rarity = CardData.CARD_RARITIES.BASIC
		card_basic_block.card_requires_target = false
		card_basic_block.card_keyword_object_ids = ["keyword_block"]
		card_basic_block.card_values = { "block": 5 }
		card_basic_block.card_upgrade_value_improvements = { "block": 3 }
		card_basic_block.card_play_actions = [
			{
				Scripts.ACTION_BLOCK: {
					"time_delay": 0.2,
					"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
					"audio_path": AudioConstants.SFX_GROUP_SHIELD_UP,
				},
			},
		]

		Global.register_rod(card_basic_block)


## Adds cards that have not yet been sorted into a color
func add_cards_misc() -> void:
	GlobalProdDataGeneratorWhiteCards.add_cards_white()


func add_cards_green() -> void:
	GlobalProdDataGeneratorGreenCards.add_cards_green()


func add_cards_orange() -> void:
	GlobalProdDataGeneratorOrangeCards.add_cards_orange()

func add_cards_red() -> void:
	GlobalProdDataGeneratorRedCards.add_cards_red()


func add_cards_blue() -> void:
	GlobalProdDataGeneratorBlueCards.add_cards_blue()

#region Card Packs

func add_card_packs() -> void:
	# all cards in game, with no filtering
	var card_pack_all: CardPackData = CardPackData.new("card_pack_all")
	card_pack_all.exclude_non_standard_rarities = false
	card_pack_all.exclude_non_standard_types = false
	card_pack_all.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_all)

	# all draftable cards, ignoring non-standard types and rarities
	var card_pack_prismatic: CardPackData = CardPackData.new("card_pack_prismatic")
	Global.register_rod(card_pack_prismatic)

	var card_pack_red: CardPackData = CardPackData.new("card_pack_red")
	card_pack_red.card_pack_color_id = "color_red"
	card_pack_red.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_red)

	var card_pack_blue: CardPackData = CardPackData.new("card_pack_blue")
	card_pack_blue.card_pack_color_id = "color_blue"
	card_pack_blue.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_blue)

	var card_pack_green: CardPackData = CardPackData.new("card_pack_green")
	card_pack_green.card_pack_color_id = "color_green"
	card_pack_green.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_green)

	var card_pack_orange: CardPackData = CardPackData.new("card_pack_orange")
	card_pack_orange.card_pack_color_id = "color_orange"
	card_pack_orange.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_orange)

	# 物理删除卡牌池，供"持久运行"附魔等使用
	var card_pack_exhaust_cards: CardPackData = CardPackData.new("card_pack_exhaust_cards")
	card_pack_exhaust_cards.card_pack_displays_in_codex = false
	card_pack_exhaust_cards.card_pack_validators = [
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "card_play_destination",
				"operator": "==",
				"comparison_value": HandManager.EXHAUST_PILE,
			},
		},
	]
	Global.register_rod(card_pack_exhaust_cards)

	# 非物理删除卡牌池，供"系统维护"附魔等使用
	var card_pack_non_exhaust_cards: CardPackData = CardPackData.new("card_pack_non_exhaust_cards")
	card_pack_non_exhaust_cards.card_pack_displays_in_codex = false
	card_pack_non_exhaust_cards.card_pack_validators = [
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "card_play_destination",
				"operator": "==",
				"comparison_value": HandManager.DISCARD_PILE,
			},
		},
	]
	Global.register_rod(card_pack_non_exhaust_cards)

	# 必须有目标卡牌池，供"算力爆发"附魔等使用
	var card_pack_requires_target_cards: CardPackData = CardPackData.new("card_pack_requires_target_cards")
	card_pack_requires_target_cards.card_pack_displays_in_codex = false
	card_pack_requires_target_cards.card_pack_validators = [
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "card_requires_target",
				"operator": "==",
				"comparison_value": true,
			},
		},
	]
	Global.register_rod(card_pack_requires_target_cards)

	# 必须是非保留属性的卡牌池，供"静态寄存"附魔使用
	var card_pack_non_retained_cards: CardPackData = CardPackData.new("card_pack_non_retained_cards")
	card_pack_non_retained_cards.card_pack_displays_in_codex = false
	card_pack_non_retained_cards.card_pack_validators = [
		{
			Scripts.VALIDATOR_CARD_PROPERTIES: {
				"card_property_name": "card_is_retained",
				"operator": "==",
				"comparison_value": false,
			},
		},
	]
	Global.register_rod(card_pack_non_retained_cards)

	var card_pack_white: CardPackData = CardPackData.new("card_pack_white")
	card_pack_white.card_pack_color_id = "color_white"
	card_pack_white.card_pack_displays_in_codex = true
	Global.register_rod(card_pack_white)

#endregion
#region Artifact Packs


#region Consumable Packs
func add_consumable_packs() -> void:
	# all consumables in game, with no filtering
	var consumable_pack_all: ConsumablePackData = ConsumablePackData.new("consumable_pack_all")
	Global.register_rod(consumable_pack_all)

	# common pool consumables, ignoring non-standard types and rarities
	# all characters should have this and their color by default
	var consumable_pack_white: ConsumablePackData = ConsumablePackData.new("consumable_pack_white")
	consumable_pack_white.consumable_pack_color_id = "color_white"
	Global.register_rod(consumable_pack_white)

	var consumable_pack_red: ConsumablePackData = ConsumablePackData.new("consumable_pack_red")
	consumable_pack_red.consumable_pack_color_id = "color_red"
	Global.register_rod(consumable_pack_red)

	var consumable_pack_blue: ConsumablePackData = ConsumablePackData.new("consumable_pack_blue")
	consumable_pack_blue.consumable_pack_color_id = "color_blue"
	Global.register_rod(consumable_pack_blue)

	var consumable_pack_green: ConsumablePackData = ConsumablePackData.new("consumable_pack_green")
	consumable_pack_green.consumable_pack_color_id = "color_green"
	Global.register_rod(consumable_pack_green)

	var consumable_pack_orange: ConsumablePackData = ConsumablePackData.new("consumable_pack_orange")
	consumable_pack_orange.consumable_pack_color_id = "color_orange"
	Global.register_rod(consumable_pack_orange)

#endregion
