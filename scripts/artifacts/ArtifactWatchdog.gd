## 进程看门狗：每场战斗中，当完整度首次降至50%以下时，恢复30%最大完整度，随后此外设被移除。
extends BaseArtifact

var triggered_this_combat: bool = false

func connect_signals() -> void:
	super()
	Signals.combatant_damaged.connect(_on_combatant_damaged)

func _on_combatant_damaged(base_combatant: BaseCombatant, _unblocked_damage: int, _zero_capped_damage: int, _overkill_damage: int) -> void:
	if triggered_this_combat:
		return
	if base_combatant != Global.get_player():
		return
	var player: Player = Global.get_player()
	if player.get_combatant_health() >= player.get_combatant_health_max() * 0.5:
		return

	triggered_this_combat = true

	# 恢复30%最大完整度
	var heal_action: Array[Dictionary] = [{
		Scripts.ACTION_HEAL_PERCENT: {
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER,
			"percentage_heal_amount": 0.30,
		},
	}]
	var generated_heal_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], heal_action, null)
	ActionHandler.add_actions(generated_heal_actions)

	Signals.artifact_proc.emit(artifact_data)

	# 移除自身
	Global.player_data.remove_artifact(artifact_data.object_id)
