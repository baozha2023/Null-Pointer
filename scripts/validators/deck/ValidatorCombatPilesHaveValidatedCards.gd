## Checks cards across one or more combat piles with the standard card Validator pipeline.
## This includes temporary combat cards that do not exist in the player's permanent deck.
extends BaseValidator

func _validation(card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var source_zones: Array = _get_validator_value(
		"source_zones",
		values,
		action,
		[HandManager.HAND_PILE, HandManager.DRAW_PILE, HandManager.DISCARD_PILE]
	)
	var validator_data: Array[Dictionary] = []
	validator_data.assign(_get_validator_value("validator_data", values, action, []))
	var exclude_validated_card: bool = _get_validator_value("exclude_validated_card", values, action, false)
	var operator: String = _get_validator_value("operator", values, action, ">=")
	var comparison_value: int = _get_validator_value("comparison_value", values, action, 1)

	var cards: Array[CardData] = []
	for source_zone: String in source_zones:
		for pile_card: CardData in HandManager.get_pile(source_zone):
			if exclude_validated_card and pile_card == card_data:
				continue
			if not cards.has(pile_card):
				cards.append(pile_card)

	var filtered_cards: Array[CardData] = CardFilter.new(cards).filter_card_validators(validator_data).filtered_cards
	return _compare(filtered_cards.size(), comparison_value, operator)
