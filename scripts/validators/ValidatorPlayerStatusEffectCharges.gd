extends BaseValidator

func _validation(_card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var status_effect_object_id: String = _get_validator_value("status_effect_object_id", values, action, "status_effect_turn_forge_load")
	var operator: String = _get_validator_value("operator", values, action, ">=")
	var comparison_value: int = _get_validator_value("status_effect_charge_comparison_value", values, action, 1)

	var target: BaseCombatant = Global.get_player()
	if not is_instance_valid(target):
		return false

	var charges: int = target.get_status_charges(status_effect_object_id)

	return _compare(charges, comparison_value, operator)
