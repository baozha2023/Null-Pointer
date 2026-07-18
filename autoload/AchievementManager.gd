## Data-driven achievement event router, evaluator, persistence facade, and platform sync owner.
extends Node

const EVENT_ENEMY_KILLED: String = "enemy_killed"
const EVENT_COMBAT_STAT_CHANGED: String = "combat_stat_changed"
const EVENT_TURN_COMPLETED: String = "turn_completed"
const EVENT_COMBAT_COMPLETED: String = "combat_completed"
const EVENT_RUN_COMPLETED: String = "run_completed"
const EVENT_LOCATION_ENTERED: String = "location_entered"
const EVENT_ACHIEVEMENT_UNLOCKED: String = "achievement_unlocked"
const CUSTOM_SIGNAL_EVENT_PREFIX: String = "custom_signal:"

var _event_id_to_achievements: Dictionary[String, Array] = {}
var _custom_evaluator_cache: Dictionary[String, BaseAchievementEvaluator] = {}
var _pending_platform_achievement_ids: Dictionary[String, bool] = {}
var _platform_achievement_ids_in_flight: Dictionary[String, bool] = {}
var _run_scope_key: String = ""
var _combat_scope_key: String = ""
var _turn_scope_key: String = ""


func _ready() -> void:
	_build_event_index()
	_validate_platform_manifest()
	_connect_event_bridge()
	Platform.platform_authenticated.connect(_on_platform_authenticated)
	Platform.platform_disconnected.connect(_on_platform_disconnected)
	if Platform.is_authenticated:
		_on_platform_authenticated()


func _build_event_index() -> void:
	_event_id_to_achievements.clear()
	for achievement_data: AchievementData in Global.get_all_achievement_data():
		if not _validate_achievement(achievement_data):
			continue
		for trigger_data: AchievementTriggerData in achievement_data.achievement_triggers:
			if not _event_id_to_achievements.has(trigger_data.achievement_event_id):
				_event_id_to_achievements[trigger_data.achievement_event_id] = []
			var event_achievements: Array = _event_id_to_achievements[trigger_data.achievement_event_id]
			if not event_achievements.has(achievement_data):
				event_achievements.append(achievement_data)


func _validate_achievement(achievement_data: AchievementData) -> bool:
	if achievement_data.object_id == "" or achievement_data.achievement_presentation == null:
		_log_invalid_definition(achievement_data, "缺少 ID 或展示数据")
		return false
	if achievement_data.achievement_triggers.is_empty():
		_log_invalid_definition(achievement_data, "至少需要一个触发器")
		return false
	if achievement_data.achievement_run_policy < 0 or achievement_data.achievement_run_policy >= AchievementData.RUN_POLICIES.size():
		_log_invalid_definition(achievement_data, "运行策略无效")
		return false
	var presentation: AchievementPresentationData = achievement_data.achievement_presentation
	if presentation.achievement_category_id == "" or presentation.achievement_category_name == "":
		_log_invalid_definition(achievement_data, "分类配置为空")
		return false
	if presentation.achievement_hidden_policy < 0 or presentation.achievement_hidden_policy >= AchievementPresentationData.HIDDEN_POLICIES.size():
		_log_invalid_definition(achievement_data, "隐藏策略无效")
		return false
	if presentation.achievement_value_format < 0 or presentation.achievement_value_format >= AchievementPresentationData.VALUE_FORMATS.size():
		_log_invalid_definition(achievement_data, "进度显示格式无效")
		return false
	if achievement_data.achievement_progress != null:
		var progress: AchievementProgressData = achievement_data.achievement_progress
		if progress.achievement_recent_history_limit < 0:
			_log_invalid_definition(achievement_data, "最近记录数量不能为负数")
			return false
		if progress.achievement_aggregation < 0 or progress.achievement_aggregation >= AchievementProgressData.AGGREGATIONS.size():
			_log_invalid_definition(achievement_data, "聚合方式无效")
			return false
		if progress.achievement_unlock_comparison < 0 or progress.achievement_unlock_comparison >= AchievementProgressData.COMPARISONS.size():
			_log_invalid_definition(achievement_data, "解锁比较方式无效")
			return false
		if progress.achievement_scope < 0 or progress.achievement_scope >= AchievementProgressData.SCOPES.size():
			_log_invalid_definition(achievement_data, "统计范围无效")
			return false
		if not is_finite(progress.achievement_target_value):
			_log_invalid_definition(achievement_data, "目标值不是有限数值")
			return false
	for trigger_data: AchievementTriggerData in achievement_data.achievement_triggers:
		if trigger_data.achievement_event_id == "":
			_log_invalid_definition(achievement_data, "触发事件 ID 为空")
			return false
		for condition_data: AchievementConditionData in trigger_data.achievement_conditions:
			if condition_data.achievement_condition_field_path == "":
				_log_invalid_definition(achievement_data, "条件字段路径为空")
				return false
			if condition_data.achievement_condition_operator < 0 or condition_data.achievement_condition_operator >= AchievementConditionData.OPERATORS.size():
				_log_invalid_definition(achievement_data, "条件运算符无效")
				return false
		if trigger_data.achievement_custom_evaluator_script_path != "" and _get_custom_evaluator(trigger_data.achievement_custom_evaluator_script_path) == null:
			_log_invalid_definition(achievement_data, "自定义评估器无效")
			return false
		if achievement_data.achievement_progress != null:
			var aggregation: int = achievement_data.achievement_progress.achievement_aggregation
			if aggregation != AchievementProgressData.AGGREGATIONS.COUNT and aggregation != AchievementProgressData.AGGREGATIONS.UNIQUE_COUNT and trigger_data.achievement_progress_field_path == "":
				_log_invalid_definition(achievement_data, "聚合进度字段为空")
				return false
			if aggregation == AchievementProgressData.AGGREGATIONS.UNIQUE_COUNT and trigger_data.achievement_unique_value_field_path == "":
				_log_invalid_definition(achievement_data, "唯一值字段为空")
				return false
	return true


func _validate_platform_manifest() -> void:
	var file := FileAccess.open("res://game.json", FileAccess.READ)
	if file == null:
		DebugLogger.log_error("AchievementManager: 无法读取平台清单 game.json")
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		DebugLogger.log_error("AchievementManager: 平台清单 game.json 不是有效对象")
		return
	var manifest_ids: Dictionary[String, bool] = {}
	for entry: Variant in parsed.get("achievements", []):
		if entry is Dictionary:
			manifest_ids[str(entry.get("id", ""))] = true
	var vanilla_ids: Dictionary[String, bool] = {}
	for achievement_data: AchievementData in Global.get_all_achievement_data():
		if achievement_data.achievement_is_vanilla:
			vanilla_ids[achievement_data.object_id] = true
	if manifest_ids != vanilla_ids:
		DebugLogger.log_error("AchievementManager: game.json 平台成就 ID 与原生成就定义不一致")


func _log_invalid_definition(achievement_data: AchievementData, reason: String) -> void:
	var achievement_id: String = achievement_data.object_id if achievement_data != null else "<null>"
	var source_name: String = achievement_data.achievement_source_name if achievement_data != null else "未知来源"
	DebugLogger.log_error("AchievementManager: 忽略无效成就 %s（%s）：%s" % [achievement_id, source_name, reason])


func _connect_event_bridge() -> void:
	Signals.enemy_killed.connect(_on_enemy_killed)
	Signals.combat_stat_changed.connect(_on_combat_stat_changed)
	Signals.achievement_turn_completed.connect(_on_turn_completed)
	Signals.achievement_combat_completed.connect(_on_combat_completed)
	Signals.run_completed.connect(_on_run_completed)
	Signals.map_location_selected.connect(_on_location_entered)
	Signals.run_started.connect(_on_run_started)
	Signals.combat_started.connect(_on_combat_started)
	Signals.player_turn_started.connect(_on_player_turn_started)
	for custom_signal_id: String in Global._id_to_custom_signal_data.keys():
		var custom_signal: CustomSignal = Signals.get_custom_signal(custom_signal_id)
		custom_signal.custom_signal.connect(_on_custom_signal)


func submit_event(event_id: String, values: Dictionary[String, Variant] = {}) -> void:
	if event_id == "" or not _event_id_to_achievements.has(event_id):
		return
	if _run_scope_key == "" and Global.player_data != null:
		_run_scope_key = Global.player_data.player_achievement_run_scope_key
	var event: Dictionary[String, Variant] = _build_event(event_id, values)
	var event_achievements: Array = _event_id_to_achievements[event_id]
	for achievement_variant: Variant in event_achievements:
		var achievement_data: AchievementData = achievement_variant
		if is_achievement_unlocked(achievement_data.object_id) and not achievement_data.achievement_record_after_unlock:
			continue
		if not _event_allowed_for_achievement(achievement_data, bool(event["is_custom_run"])):
			continue
		for trigger_data: AchievementTriggerData in achievement_data.achievement_triggers:
			if trigger_data.achievement_event_id != event_id:
				continue
			var evaluation: Dictionary[String, Variant] = _evaluate_trigger(achievement_data, trigger_data, event)
			if not bool(evaluation.get("accepted", false)):
				continue
			_apply_evaluation(achievement_data, evaluation, event)
			break


func _build_event(event_id: String, values: Dictionary[String, Variant]) -> Dictionary[String, Variant]:
	var event: Dictionary[String, Variant] = {
		"event_id": event_id,
		"value": values.get("value", 1.0),
		"values": values,
		"is_custom_run": bool(values.get("is_custom_run", _current_run_is_custom())),
		"timestamp": int(Time.get_unix_time_from_system()),
		"run_scope_key": _run_scope_key,
		"combat_scope_key": _combat_scope_key,
		"turn_scope_key": _turn_scope_key,
		"character_id": Global.player_data.player_character_object_id if Global.player_data != null else "",
		"difficulty_level": Global.player_data.player_run_difficulty_level if Global.player_data != null else 0,
		"location_type": _get_current_location_type(),
		"turn_stats": StatsHandler.current_combat_stats.turn_stats.duplicate() if StatsHandler.current_combat_stats != null else {},
		"combat_stats": StatsHandler.current_combat_stats.total_stats.duplicate() if StatsHandler.current_combat_stats != null else {},
		"run_stats": StatsHandler.current_run_stats.run_total_stats.duplicate() if StatsHandler.current_run_stats != null else {},
	}
	return event


func _evaluate_trigger(
	achievement_data: AchievementData,
	trigger_data: AchievementTriggerData,
	event: Dictionary[String, Variant],
) -> Dictionary[String, Variant]:
	if trigger_data.achievement_custom_evaluator_script_path != "":
		var evaluator: BaseAchievementEvaluator = _get_custom_evaluator(trigger_data.achievement_custom_evaluator_script_path)
		return evaluator.evaluate(achievement_data, trigger_data, event) if evaluator != null else {"accepted": false}
	for condition_data: AchievementConditionData in trigger_data.achievement_conditions:
		var field_value: Variant = _get_field_path(event, condition_data.achievement_condition_field_path)
		if not _evaluate_condition(field_value, condition_data, event):
			return {"accepted": false}
	var candidate_value: float = 1.0
	if achievement_data.achievement_progress != null and achievement_data.achievement_progress.achievement_aggregation != AchievementProgressData.AGGREGATIONS.COUNT:
		var candidate_variant: Variant = _get_field_path(event, trigger_data.achievement_progress_field_path)
		if not candidate_variant is int and not candidate_variant is float:
			return {"accepted": false}
		candidate_value = float(candidate_variant)
	var unique_value: String = ""
	if achievement_data.achievement_progress != null and achievement_data.achievement_progress.achievement_aggregation == AchievementProgressData.AGGREGATIONS.UNIQUE_COUNT:
		var unique_variant: Variant = _get_field_path(event, trigger_data.achievement_unique_value_field_path)
		if unique_variant == null:
			return {"accepted": false}
		unique_value = str(unique_variant)
	return {
		"accepted": true,
		"candidate_value": candidate_value,
		"unique_value": unique_value,
	}


func _apply_evaluation(
	achievement_data: AchievementData,
	evaluation: Dictionary[String, Variant],
	event: Dictionary[String, Variant],
) -> void:
	if achievement_data.achievement_progress == null:
		unlock_achievement(achievement_data.object_id, false)
		return
	var progress: AchievementProgressData = achievement_data.achievement_progress
	var old_state: AchievementStateData = ProfileStore.get_achievement_state(achievement_data.object_id)
	var scope_key: String = _get_scope_key(progress.achievement_scope)
	var context: Dictionary[String, Variant] = _make_recent_context(event)
	var new_state: AchievementStateData = ProfileStore.apply_achievement_update(
		achievement_data.object_id,
		float(evaluation.get("candidate_value", 1.0)),
		progress.achievement_aggregation,
		scope_key,
		progress.achievement_target_value,
		progress.achievement_unlock_comparison,
		progress.achievement_recent_history_limit,
		context,
		str(evaluation.get("unique_value", "")),
		str(event["values"].get("event_key", "")),
	)
	if new_state == null:
		DebugLogger.log_error("AchievementManager: 成就进度写入失败 %s" % achievement_data.object_id)
		return
	if new_state.update_count == old_state.update_count:
		return
	Signals.achievement_progress_changed.emit(achievement_data, new_state)
	if old_state.unlocked_at <= 0 and new_state.unlocked_at > 0:
		_on_achievement_newly_unlocked(achievement_data)


func unlock_achievement(achievement_id: String, ignore_run_policy: bool = false) -> bool:
	var achievement_data: AchievementData = Global.get_achievement_data(achievement_id)
	if achievement_data == null:
		DebugLogger.log_error("AchievementManager: 未找到成就 %s" % achievement_id)
		return false
	if is_achievement_unlocked(achievement_id):
		return false
	if not ignore_run_policy and not _event_allowed_for_achievement(achievement_data, _current_run_is_custom()):
		return false
	var write_result: int = ProfileStore.unlock_achievement(achievement_id, int(Time.get_unix_time_from_system()))
	if write_result != ProfileStore.WriteResult.INSERTED:
		if write_result == ProfileStore.WriteResult.FAILED:
			DebugLogger.log_error("AchievementManager: 成就写入数据库失败 %s" % achievement_id)
		return false
	_on_achievement_newly_unlocked(achievement_data)
	return true


func _on_achievement_newly_unlocked(achievement_data: AchievementData) -> void:
	_queue_platform_sync(achievement_data)
	Signals.achievement_unlocked.emit(achievement_data)
	submit_event(EVENT_ACHIEVEMENT_UNLOCKED, {"achievement_id": achievement_data.object_id})


func is_achievement_unlocked(achievement_id: String) -> bool:
	return ProfileStore.is_achievement_unlocked(achievement_id)


func get_achievement_state(achievement_id: String) -> AchievementStateData:
	return ProfileStore.get_achievement_state(achievement_id)


func get_achievement_progress(achievement_id: String) -> float:
	return get_achievement_state(achievement_id).current_value


func get_achievement_latest_value(achievement_id: String) -> float:
	return get_achievement_state(achievement_id).latest_value


func get_achievement_best_value(achievement_id: String) -> float:
	return get_achievement_state(achievement_id).best_value


func get_achievement_recent_values(achievement_id: String) -> Array[AchievementRecentValueData]:
	var achievement_data: AchievementData = Global.get_achievement_data(achievement_id)
	if achievement_data == null or achievement_data.achievement_progress == null:
		return []
	return ProfileStore.get_achievement_recent_values(
		achievement_id,
		achievement_data.achievement_progress.achievement_recent_history_limit,
	)


func get_unlock_timestamp(achievement_id: String) -> int:
	return ProfileStore.get_unlock_timestamp(achievement_id)


func format_value(achievement_data: AchievementData, value: float) -> String:
	var presentation: AchievementPresentationData = achievement_data.achievement_presentation
	match presentation.achievement_value_format:
		AchievementPresentationData.VALUE_FORMATS.DURATION:
			return TextParser.format_duration(value / 1000.0)
		AchievementPresentationData.VALUE_FORMATS.PERCENTAGE:
			return "%0.1f%%" % value
		AchievementPresentationData.VALUE_FORMATS.CUSTOM_SUFFIX:
			return "%s%s" % [_format_number(value), presentation.achievement_value_suffix]
		_:
			return _format_number(value)


func _format_number(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, round(value)) else "%0.2f" % value


func _evaluate_condition(
	field_value: Variant,
	condition_data: AchievementConditionData,
	event: Dictionary[String, Variant],
) -> bool:
	var expected: Variant = condition_data.achievement_condition_value
	if expected is Dictionary and expected.has("field"):
		expected = _get_field_path(event, str(expected["field"]))
	match condition_data.achievement_condition_operator:
		AchievementConditionData.OPERATORS.EQUAL:
			return field_value == expected
		AchievementConditionData.OPERATORS.NOT_EQUAL:
			return field_value != expected
		AchievementConditionData.OPERATORS.GREATER:
			return _compare_numbers(field_value, expected, ">")
		AchievementConditionData.OPERATORS.GREATER_OR_EQUAL:
			return _compare_numbers(field_value, expected, ">=")
		AchievementConditionData.OPERATORS.LESS:
			return _compare_numbers(field_value, expected, "<")
		AchievementConditionData.OPERATORS.LESS_OR_EQUAL:
			return _compare_numbers(field_value, expected, "<=")
		AchievementConditionData.OPERATORS.CONTAINS:
			if field_value is Array or field_value is Dictionary:
				return expected in field_value
			if field_value is String:
				return str(expected) in field_value
		AchievementConditionData.OPERATORS.IN:
			return expected is Array and field_value in expected
		AchievementConditionData.OPERATORS.IS_TRUE:
			return bool(field_value)
		AchievementConditionData.OPERATORS.IS_FALSE:
			return not bool(field_value)
	return false


func _compare_numbers(left: Variant, right: Variant, operation: String) -> bool:
	if (not left is int and not left is float) or (not right is int and not right is float):
		return false
	var left_number: float = float(left)
	var right_number: float = float(right)
	match operation:
		">": return left_number > right_number
		">=": return left_number >= right_number
		"<": return left_number < right_number
		"<=": return left_number <= right_number
	return false


func _get_field_path(root: Variant, field_path: String) -> Variant:
	if field_path == "":
		return null
	var current: Variant = root
	for segment: String in field_path.split("."):
		if current is Dictionary:
			if not current.has(segment):
				return null
			current = current[segment]
		elif current is Object:
			current = current.get(segment)
		else:
			return null
	return current


func _event_allowed_for_achievement(achievement_data: AchievementData, is_custom_run: bool) -> bool:
	match achievement_data.achievement_run_policy:
		AchievementData.RUN_POLICIES.STANDARD_ONLY:
			return not is_custom_run
		AchievementData.RUN_POLICIES.CUSTOM_ONLY:
			return is_custom_run
		_:
			return true


func _current_run_is_custom() -> bool:
	if Global.player_data == null:
		return false
	return _modifier_ids_include_custom(Global.player_data.player_run_modifier_object_ids)


func _modifier_ids_include_custom(modifier_ids: Array[String]) -> bool:
	for modifier_id: String in modifier_ids:
		var modifier_data: RunModifierData = Global.get_run_modifier_data(modifier_id)
		if modifier_data != null and modifier_data.run_modifier_is_custom:
			return true
	return false


func _get_scope_key(scope: int) -> String:
	match scope:
		AchievementProgressData.SCOPES.RUN: return _run_scope_key
		AchievementProgressData.SCOPES.COMBAT: return _combat_scope_key
		AchievementProgressData.SCOPES.TURN: return _turn_scope_key
		_: return "lifetime"


func _get_current_location_type() -> int:
	var location_data: LocationData = Global.get_player_location_data() if Global.player_data != null else null
	return location_data.location_type if location_data != null else -1


func _reset_scope(scope: int, scope_key: String) -> void:
	for achievement_data: AchievementData in Global.get_all_achievement_data():
		if achievement_data.achievement_progress == null or achievement_data.achievement_progress.achievement_scope != scope:
			continue
		ProfileStore.reset_achievement_scope(achievement_data.object_id, scope_key)


func _make_recent_context(event: Dictionary[String, Variant]) -> Dictionary[String, Variant]:
	var values: Dictionary = event.get("values", {})
	var context: Dictionary[String, Variant] = {"event_id": event.get("event_id", "")}
	for key: String in ["run_character_id", "run_difficulty_level", "location_type", "stat_name", "turn_count", "combat_floor"]:
		if values.has(key):
			context[key] = values[key]
	return context


func _get_custom_evaluator(script_path: String) -> BaseAchievementEvaluator:
	if _custom_evaluator_cache.has(script_path):
		return _custom_evaluator_cache[script_path]
	var full_path: String = FileLoader._get_modified_filepath(script_path)
	var evaluator_script: Script = load(full_path)
	if evaluator_script == null:
		return null
	var instance: Variant = evaluator_script.new()
	if not instance is BaseAchievementEvaluator:
		return null
	_custom_evaluator_cache[script_path] = instance
	return instance


func _on_run_started() -> void:
	_run_scope_key = Global.player_data.player_achievement_run_scope_key if Global.player_data != null else ""
	_combat_scope_key = ""
	_turn_scope_key = ""
	_reset_scope(AchievementProgressData.SCOPES.RUN, _run_scope_key)


func _on_combat_started(event_id: String) -> void:
	var floor: int = Global.get_player_current_floor()
	_combat_scope_key = "%s:combat:%d:%s" % [_run_scope_key, floor, event_id]
	_turn_scope_key = "%s:turn:1" % _combat_scope_key
	_reset_scope(AchievementProgressData.SCOPES.COMBAT, _combat_scope_key)
	_reset_scope(AchievementProgressData.SCOPES.TURN, _turn_scope_key)


func _on_player_turn_started() -> void:
	var turn_count: int = StatsHandler.get_turn_count() if StatsHandler.current_combat_stats != null else 1
	_turn_scope_key = "%s:turn:%d" % [_combat_scope_key, turn_count]
	_reset_scope(AchievementProgressData.SCOPES.TURN, _turn_scope_key)


func _on_enemy_killed(_enemy: Enemy) -> void:
	submit_event(EVENT_ENEMY_KILLED, {"value": 1.0})


func _on_combat_stat_changed(stat_enum: int) -> void:
	if StatsHandler.current_combat_stats == null:
		return
	var stat_name: String = CombatStatsData.STATS.keys()[stat_enum]
	submit_event(EVENT_COMBAT_STAT_CHANGED, {
		"stat_name": stat_name,
		"value": StatsHandler.current_combat_stats.get_turn_stat(stat_name),
		"turn_value": StatsHandler.current_combat_stats.get_turn_stat(stat_name),
		"combat_value": StatsHandler.current_combat_stats.get_total_stat(stat_name),
	})


func _on_turn_completed(turn_stats: Dictionary) -> void:
	var completed_turn: int = StatsHandler.current_combat_stats.turn_count if StatsHandler.current_combat_stats != null else 0
	submit_event(EVENT_TURN_COMPLETED, {"turn_stats": turn_stats, "turn_count": completed_turn})


func _on_combat_completed(combat_stats: CombatStatsData, location_type: int, combat_victory: bool) -> void:
	submit_event(EVENT_COMBAT_COMPLETED, {
		"combat_total_stats": combat_stats.total_stats,
		"player_damage": combat_stats.get_total_stat("PLAYER_DAMAGED_AMOUNT"),
		"turn_count": combat_stats.turn_count,
		"combat_floor": combat_stats.combat_floor,
		"location_type": location_type,
		"combat_victory": combat_victory,
		"event_key": "%s:completed" % _combat_scope_key,
	})


func _on_run_completed(run_stats: RunStatsData) -> void:
	var values: Dictionary[String, Variant] = {
		"is_custom_run": _modifier_ids_include_custom(run_stats.run_modifier_ids),
		"run_victory": run_stats.run_victory,
		"run_character_id": run_stats.run_character_id,
		"run_difficulty_level": run_stats.run_difficulty_level,
		"run_player_health": run_stats.run_player_health,
		"run_player_health_max": run_stats.run_player_health_max,
		"run_player_money": run_stats.run_player_money,
		"run_deck_size": run_stats.run_deck.size(),
		"run_artifact_count": run_stats.run_artifact_ids.size(),
		"run_completion_time": run_stats.run_completion_time,
		"run_completion_time_ms": run_stats.run_completion_time * 1000.0,
		"run_total_stats": run_stats.run_total_stats,
		"enemies_killed": run_stats.get_run_total_stat("ENEMIES_KILLED"),
		"minibosses_defeated": run_stats.get_run_total_stat("COMBAT_MINIBOSS_COUNT"),
		"shop_locations_entered": run_stats.get_run_total_stat("SHOP_LOCATIONS_ENTERED"),
		"event_key": Global.player_data.player_achievement_run_scope_key if Global.player_data != null else "run:%d:%d" % [run_stats.run_seed, run_stats.run_completion_timestamp],
	}
	submit_event(EVENT_RUN_COMPLETED, values)


func _on_location_entered(location_data: LocationData) -> void:
	submit_event(EVENT_LOCATION_ENTERED, {
		"location_id": location_data.location_id,
		"location_type": location_data.location_type,
		"location_floor": location_data.location_floor,
	})


func _on_custom_signal(custom_signal_id: String, values: Dictionary[String, Variant]) -> void:
	submit_event(CUSTOM_SIGNAL_EVENT_PREFIX + custom_signal_id, values)


func _queue_platform_sync(achievement_data: AchievementData) -> void:
	if not GameConfig.REQUIRE_BZ_GAMES_LAUNCH or not achievement_data.achievement_is_vanilla:
		return
	_pending_platform_achievement_ids[achievement_data.object_id] = true
	_flush_platform_sync()


func _on_platform_authenticated() -> void:
	if not GameConfig.REQUIRE_BZ_GAMES_LAUNCH:
		return
	for achievement_id: String in ProfileStore.get_unlocked_achievement_timestamps():
		var achievement_data: AchievementData = Global.get_achievement_data(achievement_id)
		if achievement_data != null and achievement_data.achievement_is_vanilla:
			_pending_platform_achievement_ids[achievement_id] = true
	_flush_platform_sync()


func _on_platform_disconnected() -> void:
	_platform_achievement_ids_in_flight.clear()


func _flush_platform_sync() -> void:
	if not GameConfig.REQUIRE_BZ_GAMES_LAUNCH or not Platform.is_authenticated:
		return
	for achievement_id: String in _pending_platform_achievement_ids.keys():
		if _platform_achievement_ids_in_flight.has(achievement_id):
			continue
		_platform_achievement_ids_in_flight[achievement_id] = true
		Platform.unlock_achievement(achievement_id, _on_platform_unlock_response.bind(achievement_id))


func _on_platform_unlock_response(payload: Dictionary, error: Dictionary, achievement_id: String) -> void:
	_platform_achievement_ids_in_flight.erase(achievement_id)
	if not error.is_empty():
		DebugLogger.log_error("AchievementManager: BZ-Games 成就同步失败 %s: %s" % [achievement_id, JSON.stringify(error)])
		return
	if not bool(payload.get("success", false)):
		DebugLogger.log_error("AchievementManager: BZ-Games 拒绝成就 %s: %s" % [achievement_id, JSON.stringify(payload)])
		return
	_pending_platform_achievement_ids.erase(achievement_id)
