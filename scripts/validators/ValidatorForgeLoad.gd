extends BaseValidator
class_name ValidatorForgeLoad

func _validation(_card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var load_required: int = _get_validator_value("load_required", values, action, 0)
	var player: BaseCombatant = Global.get_player()
	if player != null:
		return player.get_status_charges("status_effect_turn_forge_load") >= load_required
	return false

func _to_string():
	return "Validator Forge Load"
