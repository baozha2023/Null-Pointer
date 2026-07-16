extends BaseAchievementTrigger


func _connect_triggers() -> void:
	Signals.achievement_unlocked.connect(_on_achievement_unlocked)


func _on_achievement_unlocked(_unlocked_achievement: AchievementData) -> void:
	var required_achievement_ids: Array = trigger_values.get("required_achievement_ids", [])
	for achievement_id: Variant in required_achievement_ids:
		if not AchievementManager.is_achievement_unlocked(str(achievement_id)):
			return
	request_unlock()
