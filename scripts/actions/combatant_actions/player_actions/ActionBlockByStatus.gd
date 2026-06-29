extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	
	for action_interceptor_processor in action_interceptor_processors:
		var target: BaseCombatant = action_interceptor_processor.target
		if target == null:
			return

		var status_effect_object_id: String = action_interceptor_processor.get_shadowed_action_values("status_effect_object_id", "")
		var block_multiplier: int = action_interceptor_processor.get_shadowed_action_values("block_multiplier", 1)
		
		if status_effect_object_id == "":
			return
			
		var charges: int = target.get_status_charges(status_effect_object_id)
		
		var include_pending: bool = action_interceptor_processor.get_shadowed_action_values("include_pending_status_charges", false)
		if include_pending:
			charges += action_interceptor_processor.get_shadowed_action_values("status_charge_amount", 0)
			
		var block_amount: int = charges * block_multiplier
		
		if block_amount > 0:
			target.add_block(block_amount)

func _to_string():
	var status_effect_object_id: String = get_action_value("status_effect_object_id", "")
	var block_multiplier: int = get_action_value("block_multiplier", 1)
	return "Block By Status Action: " + status_effect_object_id + " x" + str(block_multiplier)

