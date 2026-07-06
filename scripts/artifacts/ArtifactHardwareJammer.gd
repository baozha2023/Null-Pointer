extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.combat_started.connect(_on_combat_started)

func _on_combat_started(_event_id: String) -> void:
	var weaken_action: Array[Dictionary] = [{
		Scripts.ACTION_APPLY_STATUS: {
			"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			"status_effect_object_id": "status_effect_weaken",
			"status_charge_amount": artifact_data.artifact_counter,
		},
	}]
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], weaken_action, null)
	ActionHandler.add_actions(generated_actions)
	Signals.artifact_proc.emit(artifact_data)
