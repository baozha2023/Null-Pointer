extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.player_turn_ended.connect(_on_turn_ended)

func _on_turn_ended() -> void:
	var current_energy: int = Global.player_data.player_energy
	if current_energy > 0:
		var block_amount: int = current_energy * artifact_data.artifact_counter
		var block_action: Array[Dictionary] = [{
			Scripts.ACTION_BLOCK: {
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
				"block": block_amount,
			},
		}]
		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], block_action, null)
		ActionHandler.add_actions(generated_actions)
		Signals.artifact_proc.emit(artifact_data)
