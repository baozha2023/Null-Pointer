# Action add given cards to your permanent deck
extends BaseCardsetAction

func perform_action() -> void:
	for action_interceptor_processor: ActionInterceptorProcessor in _intercept_cardset_action():
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		for card_data: CardData in picked_cards:
			Global.player_data.add_card_to_deck(card_data)
