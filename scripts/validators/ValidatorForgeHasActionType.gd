extends BaseValidator
class_name ValidatorForgeHasActionType

func _validation(_card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var action_types: Array = _get_validator_value("action_types", values, action, [])
	var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
	
	for entry in forge_actions:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var action_data: Dictionary = entry.get("action_data", {})
		for key in action_data:
			if key in action_types:
				return true
				
	return false

func _to_string():
	return "Validator Forge Has Action Type"
