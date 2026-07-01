extends BaseArtifact

func connect_signals() -> void:
	# override
	Signals.player_turn_started.connect(_on_player_turn_started)

func _on_player_turn_started() -> void:
	var player: Player = Global.get_player()
	if player != null:
		var amount = artifact_data.artifact_counter
		var new_max = player.get_combatant_health_max() + amount
		var heal_amount = new_max - player.get_combatant_health()
		player.add_health(heal_amount, amount)
		
		Signals.artifact_proc.emit(artifact_data)

func get_artifact_description() -> String:
	return artifact_data.artifact_description
