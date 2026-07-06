extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.combat_started.connect(_on_combat_started)

func _on_combat_started(_event_id: String) -> void:
	var apply_status_action: Array[Dictionary] = [{
		Scripts.ACTION_APPLY_STATUS: {
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			"status_effect_object_id": "status_effect_negate_damage",
			"status_charge_amount": artifact_data.artifact_counter,
		},
	}]
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], apply_status_action, null)
	ActionHandler.add_actions(generated_actions)
	Signals.artifact_proc.emit(artifact_data)
