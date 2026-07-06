extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var parent_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if parent_combatant == null or not parent_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
		
	var is_start_of_turn: bool = action_interceptor_processor.get_shadowed_action_values("is_start_of_turn_draw", false)
	if is_start_of_turn:
		var draw_count: int = action_interceptor_processor.get_shadowed_action_values("draw_count", 1)
		action_interceptor_processor.set_shadowed_action_values("draw_count", max(0, draw_count - 1))
	
	return ACTION_ACCEPTENCES.CONTINUE
