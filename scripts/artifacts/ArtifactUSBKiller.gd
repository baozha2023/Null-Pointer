extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_deck_shuffled.connect(_on_deck_shuffled)

func _on_deck_shuffled(_is_reshuffle: bool) -> void:
	var damage_action: Array[Dictionary] = [{
		Scripts.ACTION_ATTACK_GENERATOR: {
			"target_override": BaseAction.TARGET_OVERRIDES.ALL_ENEMIES,
			"damage": artifact_data.artifact_counter,
		},
	}]
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], damage_action, null)
	ActionHandler.add_actions(generated_actions)
	Signals.artifact_proc.emit(artifact_data)
