extends RefCounted
class_name AchievementStateData

var achievement_id: String = ""
var current_value: float = 0.0
var latest_value: float = 0.0
var best_value: float = 0.0
var update_count: int = 0
var scope_update_count: int = 0
var scope_key: String = ""
var updated_at: int = 0
var unlocked_at: int = 0


func duplicate_data() -> AchievementStateData:
	var result := AchievementStateData.new()
	result.achievement_id = achievement_id
	result.current_value = current_value
	result.latest_value = latest_value
	result.best_value = best_value
	result.update_count = update_count
	result.scope_update_count = scope_update_count
	result.scope_key = scope_key
	result.updated_at = updated_at
	result.unlocked_at = unlocked_at
	return result
