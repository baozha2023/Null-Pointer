# Action to completely remove cards from play (hand, all piles), usually with the intention of re-adding them somewhere else
# May be useful for certain mechanics, so exposed as an action
# re-uses banishment logic (see ActionBanishCards), but not counted as a "true" card banishment mechanically
extends BaseCardsetAction

func perform_action() -> void:
	for action_interceptor_processor: ActionInterceptorProcessor in _intercept_cardset_action():
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		CardMoveOperation.apply(picked_cards, CardMoveOperation.TYPES.LIMBO)
