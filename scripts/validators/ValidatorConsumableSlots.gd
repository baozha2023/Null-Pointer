# Validator for checking if player has empty consumable slots
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var required_empty_slots: int = values.get("required_empty_slots", 1)
	return Global.player_data.get_empty_consumable_slot_count() >= required_empty_slots
