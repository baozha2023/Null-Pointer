# read only data for generating run start options
# Each object is a complete, self-contained run-start choice.
extends SerializableData
class_name RunStartOptionData

@export var run_start_option_bb_code: String = ""	# rich text when displaying this option

enum RUN_START_OPTION_TYPES {
	TRADEOFF,
	POSITIVE_ONLY,
}
@export var run_start_option_type: int = RUN_START_OPTION_TYPES.POSITIVE_ONLY

@export var run_start_option_actions: Array[Dictionary] = []	# the action data to use when selecting this option

## Builds display values directly from the action tree so descriptions cannot drift from effects.
func get_display_values() -> Dictionary:
	var display_values: Dictionary = {}
	var conflicting_keys: Dictionary = {}
	_collect_display_values(run_start_option_actions, _get_requested_display_keys(), display_values, conflicting_keys)
	return display_values

func get_display_bbcode() -> String:
	return TextParser.parse(run_start_option_bb_code, get_display_values())

## Returns item references in the same order as their name macros appear in the template.
## Random pool actions have no concrete ID macro, so they intentionally produce no reference.
func get_tooltip_references() -> Array[Dictionary]:
	var references: Array[Dictionary] = []
	var display_values: Dictionary = get_display_values()
	var reference_regex: RegEx = RegEx.new()
	reference_regex.compile("\\[(card_name|artifact_name):([^\\]]+)\\]")
	var seen_references: Dictionary = {}
	for regex_match: RegExMatch in reference_regex.search_all(run_start_option_bb_code):
		var reference_type: String = regex_match.get_string(1).trim_suffix("_name")
		var token: String = regex_match.get_string(2)
		var object_id: String = str(display_values.get(token, token))
		var dedupe_key: String = reference_type + ":" + object_id
		if seen_references.has(dedupe_key):
			continue
		seen_references[dedupe_key] = true
		var reference: Dictionary = {
			"type": reference_type,
			"object_id": object_id,
		}
		if reference_type == "artifact":
			reference["custom_values"] = _find_sibling_values_for_key(run_start_option_actions, "artifact_id", object_id, "custom_values")
		references.append(reference)
	return references

func _get_requested_display_keys() -> Dictionary:
	var requested_keys: Dictionary = {}
	var value_regex: RegEx = RegEx.new()
	value_regex.compile("\\[([A-Za-z_][A-Za-z0-9_]*)\\]")
	for regex_match: RegExMatch in value_regex.search_all(run_start_option_bb_code):
		requested_keys[regex_match.get_string(1)] = true
	var macro_regex: RegEx = RegEx.new()
	macro_regex.compile("\\[(percent|card_name|artifact_name):([^\\]]+)\\]")
	for regex_match: RegExMatch in macro_regex.search_all(run_start_option_bb_code):
		requested_keys[regex_match.get_string(2)] = true
	return requested_keys

func _collect_display_values(value: Variant, requested_keys: Dictionary, display_values: Dictionary, conflicting_keys: Dictionary) -> void:
	if value is Dictionary:
		for raw_key: Variant in value:
			var key: String = str(raw_key)
			var child_value: Variant = value[raw_key]
			if child_value is Dictionary:
				_collect_display_values(child_value, requested_keys, display_values, conflicting_keys)
			elif child_value is Array:
				var contains_nested_data: bool = false
				for array_value: Variant in child_value:
					if array_value is Dictionary or array_value is Array:
						contains_nested_data = true
						_collect_display_values(array_value, requested_keys, display_values, conflicting_keys)
				if not contains_nested_data and requested_keys.has(key):
					_add_display_value(key, child_value, display_values, conflicting_keys)
			elif requested_keys.has(key):
				_add_display_value(key, child_value, display_values, conflicting_keys)
	elif value is Array:
		for array_value: Variant in value:
			_collect_display_values(array_value, requested_keys, display_values, conflicting_keys)

func _add_display_value(key: String, value: Variant, display_values: Dictionary, conflicting_keys: Dictionary) -> void:
	if conflicting_keys.has(key):
		return
	if display_values.has(key) and display_values[key] != value:
		display_values.erase(key)
		conflicting_keys[key] = true
		DebugLogger.log_error("RunStartOptionData \"{0}\": Conflicting display values for key \"{1}\"".format([object_id, key]))
		return
	display_values[key] = value

func _find_sibling_values_for_key(value: Variant, id_key: String, object_id_value: String, sibling_key: String) -> Dictionary:
	if value is Dictionary:
		if str(value.get(id_key, "")) == object_id_value:
			var sibling_value: Variant = value.get(sibling_key, {})
			if sibling_value is Dictionary:
				return sibling_value.duplicate(true)
		for child_value: Variant in value.values():
			var result: Dictionary = _find_sibling_values_for_key(child_value, id_key, object_id_value, sibling_key)
			if not result.is_empty():
				return result
	elif value is Array:
		for child_value: Variant in value:
			var result: Dictionary = _find_sibling_values_for_key(child_value, id_key, object_id_value, sibling_key)
			if not result.is_empty():
				return result
	return {}
