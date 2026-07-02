extends BaseAction
class_name ActionConsumeForgeLoad

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var load_amount: int = action_interceptor_processor.get_shadowed_action_values("load_amount", 0)

		if load_amount <= 0:
			continue

		var artifacts: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge")
		if not artifacts.is_empty():
			var forge: ArtifactData = artifacts[0]
			var new_load: int = max(0, forge.artifact_counter - load_amount)
			forge.set_artifact_counter(new_load)

func _to_string():
	return "Action Consume Forge Load"
