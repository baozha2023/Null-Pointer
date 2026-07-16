## Base interface for long-lived, event-driven achievement triggers.
extends RefCounted
class_name BaseAchievementTrigger

var achievement_data: AchievementData = null
var trigger_values: Dictionary[String, Variant] = {}


func initialize(_achievement_data: AchievementData) -> void:
	achievement_data = _achievement_data
	trigger_values.assign(achievement_data.achievement_trigger_values)
	_connect_triggers()


## Override to connect game or custom signals.
func _connect_triggers() -> void:
	pass


func request_unlock() -> bool:
	if achievement_data == null:
		return false
	return AchievementManager.unlock_achievement(achievement_data.object_id)


func shutdown() -> void:
	for connection: Dictionary in get_incoming_connections():
		var connected_signal: Signal = connection["signal"]
		var callable: Callable = connection["callable"]
		if connected_signal.is_connected(callable):
			connected_signal.disconnect(callable)
