extends BaseArtifact

func connect_signals() -> void:
	# override
	Signals.combat_started.connect(_on_combat_started)

func _on_combat_started(_event_id: String) -> void:
	var player: Player = Global.get_player()
	if player != null:
		player.set_health(999, 999)
		Signals.artifact_proc.emit(artifact_data)

func get_artifact_description() -> String:
	return artifact_data.artifact_description
