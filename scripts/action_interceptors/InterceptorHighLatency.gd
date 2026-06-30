## Modifies the number of cards drawn at the start of the turn (reduces it).
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	if _preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var is_start_of_turn_draw: bool = action_interceptor_processor.get_shadowed_action_values("is_start_of_turn_draw", false)
	if not is_start_of_turn_draw:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var draw_count: int = action_interceptor_processor.get_shadowed_action_values("draw_count", 0)
	var modified_draw_count: int = max(0, draw_count - 1)
	action_interceptor_processor.set_shadowed_action_values("draw_count", modified_draw_count)
	
	var high_latency_artifacts: Array = Global.player_data.get_player_artifacts_with_artifact_id("artifact_high_latency")
	if len(high_latency_artifacts) > 0:
		Signals.artifact_proc.emit(high_latency_artifacts[0])
		
	return ACTION_ACCEPTENCES.CONTINUE
