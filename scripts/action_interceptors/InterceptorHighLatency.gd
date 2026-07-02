## Modifies the number of cards drawn at the start of the turn (reduces it).
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	if _preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var is_start_of_turn_draw: bool = action_interceptor_processor.get_shadowed_action_values("is_start_of_turn_draw", false)
	if not is_start_of_turn_draw:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var draw_count: int = action_interceptor_processor.get_shadowed_action_values("draw_count", 0)
	var parent_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	var latency_charges: int = parent_combatant.get_status_charges("status_effect_high_latency")
	
	if draw_count > 0:
		var modified_draw_count: int = max(1, draw_count - latency_charges)
		action_interceptor_processor.set_shadowed_action_values("draw_count", modified_draw_count)
	
	return ACTION_ACCEPTENCES.CONTINUE
