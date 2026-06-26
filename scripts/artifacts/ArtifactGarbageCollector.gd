## 垃圾回收器：每当有脚本被消耗时，恢复2点完整度。
extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_exhausted.connect(_on_card_exhausted)

func _on_card_exhausted(_card: CardData) -> void:
	var action_data: Array[Dictionary] = [{
		Scripts.ACTION_ADD_HEALTH: {"target_override": BaseAction.TARGET_OVERRIDES.PLAYER, "health_amount": 2}
	}]
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], action_data, null)
	ActionHandler.add_actions(generated_actions)
	Signals.artifact_proc.emit(artifact_data)
