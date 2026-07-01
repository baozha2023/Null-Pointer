## Action that forces targeted enemies to switch to a specific intent state ID.
extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	
	for action_interceptor_processor in action_interceptor_processors:
		var target: BaseCombatant = action_interceptor_processor.target
		if target == null:
			continue
		if not target.is_alive():
			continue
		if not target is Enemy:
			continue
			
		var enemy: Enemy = target # typecast
		var new_intent_id: String = action_interceptor_processor.get_shadowed_action_values("new_intent_id", "")
		if new_intent_id != "":
			enemy.force_set_enemy_intent(new_intent_id)

func is_action_short_circuited():
	return get_action_value("action_short_circuits", true)

func _to_string():
	return "Change Enemy Intent State Action"
