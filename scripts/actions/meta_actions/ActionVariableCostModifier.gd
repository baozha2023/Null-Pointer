## Wraps child actions, modifying their values based on the card's input energy, allowing for variable (X cost) cards to work
## NOTE: You may wish to combine this with a ActionVariableActionGenerator child action modifying action_count to
## make an X cost card that does an action payload X times.
## It'll be nested as ActionVariableCostModifer(ActionVariableActionGenerator(Action Payload))
extends BaseVariableActionModifier

func is_instant_action() -> bool:
	return true

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		var multiplier_offset: int = max(0, action_interceptor_processor.get_shadowed_action_values("multiplier_offset", 0))	# an additional amount to improve the multiplier by. Eg 1 would be X + 1. Must be positive
		var input_energy: int = card_play_request.input_energy if card_play_request != null else 0
		var generated_actions: Array[BaseAction] = _create_modified_child_actions(
			action_interceptor_processor,
			input_energy + multiplier_offset
		)
		ActionHandler.add_actions(generated_actions)
