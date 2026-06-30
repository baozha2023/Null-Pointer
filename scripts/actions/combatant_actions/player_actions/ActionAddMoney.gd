extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		var money_amount: int = action_interceptor_processor.get_shadowed_action_values("money_amount", 0)
		var money_percent: float = action_interceptor_processor.get_shadowed_action_values("money_percent", 0.0)
		
		var final_amount: int = money_amount
		if money_percent != 0.0:
			final_amount += int(ceil(float(Global.player_data.player_money) * money_percent))
			
		Global.player_data.add_money(final_amount)

func _to_string():
	var money_amount: int = get_action_value("money_amount", 0)
	var money_percent: float = get_action_value("money_percent", 0.0)
	
	var string_desc = "Add Money Action: " + str(money_amount)
	if money_percent != 0.0:
		string_desc += " (" + str(money_percent * 100) + "%)"
	return string_desc
