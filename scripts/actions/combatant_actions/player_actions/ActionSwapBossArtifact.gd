## Swaps the player's starting artifact(s) for the next available boss artifact.
extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor: ActionInterceptorProcessor in action_interceptor_processors:
		var player_character_data: CharacterData = Global.get_player_character_data()
		for starting_artifact_id: String in player_character_data.character_starting_artifact_ids:
			Global.player_data.remove_artifact(starting_artifact_id)

		var artifact_count: int = action_interceptor_processor.get_shadowed_action_values("artifact_count", 1)
		var artifact_ids: Array[String] = Global.player_data.get_next_boss_artifacts_from_pool(artifact_count, true)
		for artifact_id: String in artifact_ids:
			Global.player_data.add_artifact(artifact_id)
