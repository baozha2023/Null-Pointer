# Action to apply a unique status effect to an enemy
# NOTE: This action should be restricted to only a single target enemy at a time, or it may produce weird results
# See also: StatusEffectAttachedCard
extends BaseCardsetAction

const STATUS_EFFECT_ATTACHED_CARD_ID: String = "status_effect_attached_card"

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_cardset_action(get_adjusted_action_targets())
	if action_interceptor_processors.size() != 1:
		DebugLogger.log_error("ActionAttachCardsOntoEnemy: Requires exactly one accepted target")
		return

	var action_interceptor_processor: ActionInterceptorProcessor = action_interceptor_processors[0]
	var target: BaseCombatant = action_interceptor_processor.target
	if target == null:
		return
	var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
	CardMoveOperation.apply(picked_cards, CardMoveOperation.TYPES.LIMBO)
	# iterate over the cards, generating a status for each that includes the card
	for card_data: CardData in picked_cards:
		target.add_new_status_effect(STATUS_EFFECT_ATTACHED_CARD_ID, 1, 0, {"card_data": card_data})
