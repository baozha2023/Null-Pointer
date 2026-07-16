extends BaseAchievementTrigger


func _connect_triggers() -> void:
	Signals.combat_ended.connect(_on_combat_ended)


func _on_combat_ended() -> void:
	var location_data: LocationData = Global.get_player_location_data()
	if location_data == null:
		return
	var requested_location_type: int = int(trigger_values.get("location_type", -1))
	if location_data.location_type == requested_location_type:
		request_unlock()
