## Adds an action dictionary entry into the forge (stored in PlayerData.player_values["forge_actions"]).
## Values:
##   forge_action_data: Dictionary - the action config dict to store (e.g. {Scripts.ACTION_ATTACK: {"damage": 1}})
##   forge_action_load: int - the load value contribution of this entry (default 0)
## Each stored entry also snapshots the originating CardPlayRequest values for description rendering.
extends BaseAction

func perform_action() -> void:
	if Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge").is_empty():
		Global.player_data.add_artifact("artifact_forge")

	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var forge_action_data: Dictionary = action_interceptor_processor.get_shadowed_action_values("forge_action_data", {})
		var forge_action_load: int = action_interceptor_processor.get_shadowed_action_values("forge_action_load", 0)
		var forge_action_description: String = action_interceptor_processor.get_shadowed_action_values("forge_action_description", "")

		if forge_action_data.is_empty():
			DebugLogger.log_error("ActionAddToForge: No forge_action_data provided")
			continue

		var evaluated_action_data = forge_action_data.duplicate(true)
		var display_values: Dictionary = {}
		if card_play_request != null:
			var card_values = card_play_request.card_values
			display_values = card_values.duplicate(true)
			for action_path in evaluated_action_data:
				var params = evaluated_action_data[action_path]
				for key in params:
					if typeof(params[key]) == TYPE_STRING and card_values.has(params[key]):
						params[key] = card_values[params[key]]

		var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
		forge_actions.append({
			"action_data": evaluated_action_data,
			"load": forge_action_load,
			"description": forge_action_description,
			"display_values": display_values
		})
		Global.player_data.player_values["forge_actions"] = forge_actions
		
		# Increment artifact_forge counter
		var artifacts: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge")
		if not artifacts.is_empty():
			artifacts[0].increment_artifact_counter(forge_action_load)

		if forge_action_load > 0:
			var player = Global.get_player()
			if player != null:
				var apply_status_actions: Array[BaseAction] = ActionGenerator.create_actions(
					player,
					card_play_request,
					[player],
					[
						{
							Scripts.ACTION_APPLY_STATUS: {
								"status_effect_object_id": "status_effect_turn_forge_load",
								"status_charge_amount": forge_action_load
							}
						}
					],
					self
				)
				ActionHandler.add_actions(apply_status_actions)

		Signals.forge_actions_changed.emit()

func _to_string():
	return "Action Add To Forge"
