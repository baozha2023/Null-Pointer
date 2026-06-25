# Validator for checking if a target combatant has a given amount of a status effect
extends BaseValidator

func _validation(_card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var status_effect_object_id: String = _get_validator_value("status_effect_object_id", values, action, "status_effect_vulnerable")
	var operator: String = _get_validator_value("operator", values, action, ">=")
	var comparison_value: int = _get_validator_value("status_effect_charge_comparison_value", values, action, 1)

	var targets: Array[BaseCombatant] = action.targets
	if len(targets) == 0:
		return false

	var target: BaseCombatant = targets[0]
	var charges: int = target.get_status_charges(status_effect_object_id)

	return _compare(charges, comparison_value, operator)
