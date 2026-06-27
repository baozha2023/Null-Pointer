## Validator that checks the selected target's health percentage.
## Designed for use inside ActionValidator, where `action` carries targets.
## Compares target_health / target_health_max * 100 against a threshold.
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	if _action == null:
		return false
	
	var targets: Array[BaseCombatant] = _action.targets
	var target_index: int = _get_validator_value("target_index", values, _action, 0)
	var operator: String = _get_validator_value("operator", values, _action, "<=")
	var comparison_value: float = _get_validator_value("comparison_value", values, _action, 50.0)
	
	if target_index >= len(targets):
		return false
	
	var target: BaseCombatant = targets[target_index]
	if target == null:
		return false
	
	var current_health: int = target.get_combatant_health()
	var max_health: int = target.get_combatant_health_max()
	if max_health <= 0:
		return false
	
	var health_percent: float = float(current_health) / float(max_health) * 100.0
	return _compare(health_percent, comparison_value, operator)
