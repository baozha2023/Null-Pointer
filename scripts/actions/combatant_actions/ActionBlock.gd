# Standard block action
# NOTE: If action does nothing, ensure a target override of PARENT is provded
extends BaseAction

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	
	for action_interceptor_processor in action_interceptor_processors:
		var target: BaseCombatant = action_interceptor_processor.target
		if target == null:
			return

		var block_amount: int = action_interceptor_processor.get_shadowed_action_values("block", 0)
		var additional_block_amount: int = action_interceptor_processor.get_shadowed_action_values("additional_block", 0)
		target.add_block(block_amount + additional_block_amount)

		var audio_path_val: Array = action_interceptor_processor.get_shadowed_action_values("audio_path", [])
		if typeof(audio_path_val) == TYPE_ARRAY and audio_path_val.size() > 0:
			ActionGenerator.generate_sound_action(audio_path_val)

func _to_string():
	var block: int = get_action_value("block", 0)
	var additional_block: int = get_action_value("additional_block", 0)
	return "Block Action: " + str(block + additional_block)
