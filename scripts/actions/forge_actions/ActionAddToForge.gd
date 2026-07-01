## Adds an action dictionary entry into the forge (stored in PlayerData.player_values["forge_actions"]).
## Values:
##   forge_action_data: Dictionary - the action config dict to store (e.g. {Scripts.ACTION_ATTACK: {"damage": 1}})
##   forge_action_cost: int - the energy cost contribution of this entry (default 0)
extends BaseAction

func perform_action() -> void:
	if Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge").is_empty():
		Global.player_data.add_artifact("artifact_forge")

	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var forge_action_data: Dictionary = action_interceptor_processor.get_shadowed_action_values("forge_action_data", {})
		var forge_action_cost: int = action_interceptor_processor.get_shadowed_action_values("forge_action_cost", 0)
		var forge_action_description: String = action_interceptor_processor.get_shadowed_action_values("forge_action_description", "")

		if forge_action_data.is_empty():
			DebugLogger.log_error("ActionAddToForge: No forge_action_data provided")
			continue

		var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
		forge_actions.append({
			"action_data": forge_action_data,
			"cost": forge_action_cost,
			"description": forge_action_description
		})
		Global.player_data.player_values["forge_actions"] = forge_actions
		Signals.forge_actions_changed.emit()

func _to_string():
	return "Action Add To Forge"
