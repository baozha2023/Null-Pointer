# applies a turn of temporary retain to cards that wears off end of turn
extends BaseCardsetAction

func perform_action() -> void:
	for action_interceptor_processor: ActionInterceptorProcessor in _intercept_cardset_action():
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		CardMoveOperation.apply(picked_cards, CardMoveOperation.TYPES.RETAIN)
