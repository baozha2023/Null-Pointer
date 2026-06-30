## Adds health and max health to the combatant
extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	for action_interceptor_processor: ActionInterceptorProcessor in action_interceptor_processors:
		var target: BaseCombatant = action_interceptor_processor.target
		if target == null:
			continue
			
		var health_amount: int = action_interceptor_processor.get_shadowed_action_values("health_amount", 0)
		var health_max_amount: int = action_interceptor_processor.get_shadowed_action_values("health_max_amount", 0)
		var health_max_percent: float = action_interceptor_processor.get_shadowed_action_values("health_max_percent", 0.0)
		
		var final_health_max_amount: int = health_max_amount
		if health_max_percent != 0.0:
			final_health_max_amount += int(ceil(float(target.get_combatant_health_max()) * health_max_percent))
		
		target.add_health(health_amount, final_health_max_amount)
	

func _to_string():
	var health_amount: int = get_action_value("health_amount", 0)
	var health_max_amount: int = get_action_value("health_max_amount", 0)
	var health_max_percent: float = get_action_value("health_max_percent", 0.0)
	
	var string_desc = "Add Health Action: %s %s" % [health_amount, health_max_amount]
	if health_max_percent != 0.0:
		string_desc += " (%s%% MAX HP)" % (health_max_percent * 100)
	return string_desc
