extends BaseAchievementTrigger

func _connect_triggers() -> void:
	Signals.run_completed.connect(_on_run_completed)


func _on_run_completed(run_stats: RunStatsData) -> void:
	if not run_stats.run_victory:
		return
	var required_character_id: String = str(trigger_values.get("character_id", ""))
	if required_character_id != "" and run_stats.run_character_id != required_character_id:
		return
	var minimum_difficulty: int = int(trigger_values.get("minimum_difficulty", 0))
	if run_stats.run_difficulty_level < minimum_difficulty:
		return
	request_unlock()
