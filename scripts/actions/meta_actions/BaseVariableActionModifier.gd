## Shared implementation for runtime value wrappers that generate modified child actions.
extends BaseAction
class_name BaseVariableActionModifier

func _create_modified_child_actions(
	action_interceptor_processor: ActionInterceptorProcessor,
	multiplier: int
) -> Array[BaseAction]:
	var action_data: Array = action_interceptor_processor.get_shadowed_action_values("action_data", [])
	var multiplied_values: Array[String] = []
	multiplied_values.assign(action_interceptor_processor.get_shadowed_action_values("multiplied_values", []))
	var multiplied_values_bases: Dictionary = action_interceptor_processor.get_shadowed_action_values("multiplied_values_bases", {})
	var modified_action_data: Array[Dictionary] = []
	modified_action_data.assign(action_data.duplicate(true))

	_multiply_explicit_action_values(modified_action_data, multiplied_values, multiplied_values_bases, multiplier)

	var child_card_play_request: CardPlayRequest = (
		card_play_request.duplicate_for_child_actions()
		if card_play_request != null
		else CardPlayRequest.new()
	)
	for value_key: String in multiplied_values:
		var source_value: Variant = action_interceptor_processor.get_shadowed_action_values(value_key, 0)
		var base_value: Variant = multiplied_values_bases.get(value_key, 0)
		if not _is_numeric(source_value) or not _is_numeric(base_value):
			DebugLogger.log_error("BaseVariableActionModifier: '{0}' and its base must be numeric".format([value_key]))
			continue
		child_card_play_request.card_values[value_key] = base_value + (source_value * multiplier)

	return ActionGenerator.create_actions(
		parent_combatant,
		child_card_play_request,
		targets,
		modified_action_data,
		self
	)

func _multiply_explicit_action_values(
	value: Variant,
	multiplied_values: Array[String],
	multiplied_values_bases: Dictionary,
	multiplier: int
) -> void:
	if value is Array:
		for nested_value: Variant in value:
			_multiply_explicit_action_values(nested_value, multiplied_values, multiplied_values_bases, multiplier)
		return
	if not value is Dictionary:
		return

	var value_dictionary: Dictionary = value
	for key: Variant in value_dictionary.keys():
		var nested_value: Variant = value_dictionary[key]
		if key is String and String(key).begins_with("res://") and nested_value is Dictionary:
			var action_values: Dictionary = nested_value
			for value_key: String in multiplied_values:
				if not action_values.has(value_key):
					continue
				var source_value: Variant = action_values[value_key]
				var base_value: Variant = multiplied_values_bases.get(value_key, 0)
				if _is_numeric(source_value) and _is_numeric(base_value):
					action_values[value_key] = base_value + (source_value * multiplier)
			_multiply_explicit_action_values(action_values, multiplied_values, multiplied_values_bases, multiplier)
		else:
			_multiply_explicit_action_values(nested_value, multiplied_values, multiplied_values_bases, multiplier)

func _is_numeric(value: Variant) -> bool:
	return value is int or value is float
