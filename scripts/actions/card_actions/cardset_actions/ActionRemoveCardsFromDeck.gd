# Action remove given cards from your permanent deck
extends BaseCardsetAction

func perform_action() -> void:
	var picked_cards: Array[CardData] = _get_picked_cards()
	for card_data in picked_cards:
		if card_data.parent_card != null:
			Global.player_data.remove_card_from_deck(card_data.parent_card)
		else:
			Global.player_data.remove_card_from_deck(card_data)
