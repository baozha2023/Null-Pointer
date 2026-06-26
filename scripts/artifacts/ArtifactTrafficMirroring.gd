## 镜像流量复制：每当手动丢弃一个脚本时，额外从脚本库抽1张牌。
extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_discarded.connect(_on_card_discarded)

func _on_card_discarded(_card: CardData, is_manual_discard: bool) -> void:
	if not is_manual_discard:
		return
	var action_data: Array[Dictionary] = [{
		Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}
	}]
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], action_data, null)
	ActionHandler.add_actions(generated_actions)
	Signals.artifact_proc.emit(artifact_data)
