extends BaseAchievementTrigger


func _connect_triggers() -> void:
	Signals.enemy_killed.connect(_on_enemy_killed)


func _on_enemy_killed(_enemy: Enemy) -> void:
	request_unlock()
