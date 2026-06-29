## Decreases all shop prices by 25%.
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	var multiplier: float = action_interceptor_processor.get_shadowed_action_values("money_amount_multiplier", 1.0)
	multiplier -= 0.25
	action_interceptor_processor.set_shadowed_action_values("money_amount_multiplier", multiplier)
	
	var original_amount: int = action_interceptor_processor.get_shadowed_action_values("base_money_amount", action_interceptor_processor.get_shadowed_action_values("money_amount", 0))
	action_interceptor_processor.set_shadowed_action_values("base_money_amount", original_amount)
	
	if original_amount > 0:
		action_interceptor_processor.set_shadowed_action_values("money_amount", int(original_amount * multiplier))
	
	return ACTION_ACCEPTENCES.CONTINUE
