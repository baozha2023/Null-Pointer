## Owns achievement triggers, profile unlock state, and BZ-Games synchronization.
extends Node

var _achievement_id_to_trigger: Dictionary[String, BaseAchievementTrigger] = {}
var _pending_platform_achievement_ids: Dictionary[String, bool] = {}
var _platform_achievement_ids_in_flight: Dictionary[String, bool] = {}


func _ready() -> void:
	_initialize_triggers()
	Platform.platform_authenticated.connect(_on_platform_authenticated)
	Platform.platform_disconnected.connect(_on_platform_disconnected)
	if Platform.is_authenticated:
		_on_platform_authenticated()


func _exit_tree() -> void:
	for trigger: BaseAchievementTrigger in _achievement_id_to_trigger.values():
		trigger.shutdown()
	_achievement_id_to_trigger.clear()


func _initialize_triggers() -> void:
	for achievement_data: AchievementData in Global.get_all_achievement_data():
		var script_path: String = achievement_data.achievement_trigger_script_path
		if script_path == "":
			continue
		var full_script_path: String = FileLoader._get_modified_filepath(script_path)
		var trigger_script: Script = load(full_script_path)
		if trigger_script == null:
			DebugLogger.log_error("AchievementManager: 无法加载触发脚本 %s" % full_script_path)
			continue
		var trigger_instance: Variant = trigger_script.new()
		if not trigger_instance is BaseAchievementTrigger:
			DebugLogger.log_error("AchievementManager: 触发脚本必须继承 BaseAchievementTrigger: %s" % full_script_path)
			continue
		var trigger: BaseAchievementTrigger = trigger_instance
		trigger.initialize(achievement_data)
		_achievement_id_to_trigger[achievement_data.object_id] = trigger


func unlock_achievement(achievement_id: String) -> bool:
	var achievement_data: AchievementData = Global.get_achievement_data(achievement_id)
	if achievement_data == null:
		DebugLogger.log_error("AchievementManager: 未找到成就 %s" % achievement_id)
		return false
	if is_achievement_unlocked(achievement_id):
		return false
	if achievement_data.achievement_disallows_custom_runs and _current_run_uses_custom_modifier():
		return false

	var write_result: int = ProfileStore.unlock_achievement(
		achievement_id,
		int(Time.get_unix_time_from_system()),
	)
	if write_result != ProfileStore.WriteResult.INSERTED:
		if write_result == ProfileStore.WriteResult.FAILED:
			DebugLogger.log_error("AchievementManager: 成就写入数据库失败 %s" % achievement_id)
		return false
	_queue_platform_sync(achievement_data)
	Signals.achievement_unlocked.emit(achievement_data)
	return true


func is_achievement_unlocked(achievement_id: String) -> bool:
	return ProfileStore.is_achievement_unlocked(achievement_id)


func get_unlock_timestamp(achievement_id: String) -> int:
	return ProfileStore.get_unlock_timestamp(achievement_id)


func _current_run_uses_custom_modifier() -> bool:
	if Global.player_data == null:
		return false
	for modifier_id: String in Global.player_data.player_run_modifier_object_ids:
		var modifier_data: RunModifierData = Global.get_run_modifier_data(modifier_id)
		if modifier_data != null and modifier_data.run_modifier_is_custom:
			return true
	return false


func _queue_platform_sync(achievement_data: AchievementData) -> void:
	if not GameConfig.REQUIRE_BZ_GAMES_LAUNCH or not achievement_data.achievement_is_vanilla:
		return
	_pending_platform_achievement_ids[achievement_data.object_id] = true
	_flush_platform_sync()


func _on_platform_authenticated() -> void:
	if not GameConfig.REQUIRE_BZ_GAMES_LAUNCH:
		return
	var unlock_timestamps: Dictionary[String, int] = ProfileStore.get_unlocked_achievement_timestamps()
	for achievement_id: String in unlock_timestamps:
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
