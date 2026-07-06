extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.combat_started.connect(_on_combat_started)

func _on_combat_started(_event_id: String) -> void:
	Global.player_data.player_values["artifact_0day_database_triggered"] = false
