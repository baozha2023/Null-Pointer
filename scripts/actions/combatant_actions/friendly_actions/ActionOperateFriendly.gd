## Ensures an optional artifact exists, then runs arbitrary data-defined Actions
## against one or more friendly prototype IDs.
##
## This wrapper only owns friendly_ids, force_dead_targets, friendly_action_data,
## and artifact_id. Operation-specific values remain on
## each child Action, preventing this wrapper from accidentally auto-reading
## unrelated card fields such as health_amount or status_charge_amount.
extends BaseAction
class_name ActionOperateFriendly

func perform_action() -> void:
	for processor: ActionInterceptorProcessor in _intercept_action([]):
		var friendly_ids: Array[String] = []
		friendly_ids.assign(processor.get_shadowed_action_values("friendly_ids", []))
		if friendly_ids.is_empty():
			DebugLogger.log_error("ActionOperateFriendly: No friendly prototype ID specified")
			continue
		var has_invalid_friendly_id: bool = false
		for id: String in friendly_ids:
			if Global.get_friendly_data(id) == null:
				DebugLogger.log_error("ActionOperateFriendly: Undefined friendly prototype %s" % id)
				has_invalid_friendly_id = true
		if has_invalid_friendly_id:
			continue

		var force_dead_targets: bool = processor.get_shadowed_action_values("force_dead_targets", false)
		var configured_action_data: Array[Dictionary] = []
		configured_action_data.assign(processor.get_shadowed_action_values("friendly_action_data", []))
		var action_data: Array[Dictionary] = []
		action_data.assign(configured_action_data.duplicate(true))
		var has_invalid_child_action: bool = false
		for child_action: Dictionary in action_data:
			for action_script_path: Variant in child_action.keys():
				var raw_child_values: Variant = child_action.get(action_script_path)
				if not raw_child_values is Dictionary:
					DebugLogger.log_error("ActionOperateFriendly: Child Action values must be a Dictionary")
					has_invalid_child_action = true
					break
				var child_values: Dictionary = raw_child_values
				child_values["target_override"] = BaseAction.TARGET_OVERRIDES.FRIENDLY_ID
				child_values["friendly_ids"] = friendly_ids
				child_values["force_dead_targets"] = force_dead_targets
			if has_invalid_child_action:
				break
		if has_invalid_child_action:
			continue

		var artifact_id: String = processor.get_shadowed_action_values("artifact_id", "")
		if not artifact_id.is_empty():
			if Global.get_artifact_data(artifact_id) == null:
				DebugLogger.log_error("ActionOperateFriendly: Undefined artifact %s" % artifact_id)
				continue
			if Global.player_data.get_player_artifacts_with_artifact_id(artifact_id).is_empty():
				action_data.append({Scripts.ACTION_ADD_ARTIFACT: {
					"artifact_id": artifact_id,
					"custom_values": {},
				}})
		if action_data.is_empty():
			continue

		# ActionHandler is stack-based: the optional artifact Action is appended last
		# so it executes first. Child Actions execute in reverse declaration order.
		var actions: Array[BaseAction] = ActionGenerator.create_actions(
			parent_combatant,
			card_play_request,
			[],
			action_data,
			self,
		)
		ActionHandler.add_actions(actions)

func _to_string() -> String:
	return "Operate Friendly Action"
