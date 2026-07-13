# Action to completely remove cards from play (hand, all piles), in effect removing the card from play
extends BaseCardsetAction

func perform_action() -> void:
	for action_interceptor_processor: ActionInterceptorProcessor in _intercept_cardset_action():
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		CardMoveOperation.apply(picked_cards, CardMoveOperation.TYPES.BANISH)
