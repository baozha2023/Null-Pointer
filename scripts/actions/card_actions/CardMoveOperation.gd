## Shared destinations for Actions that resolve an existing set of combat cards.
extends RefCounted
class_name CardMoveOperation

enum TYPES {
	NONE,
	DISCARD,
	EXHAUST,
	BANISH,
	LIMBO,
	RETAIN,
}

static func apply(cards: Array[CardData], operation: int) -> void:
	match operation:
		TYPES.NONE:
			pass
		TYPES.DISCARD:
			HandManager.discard_cards(cards, false)
		TYPES.EXHAUST:
			HandManager.exhaust_cards(cards)
		TYPES.BANISH:
			HandManager.banish_cards(cards, false)
		TYPES.LIMBO:
			HandManager.banish_cards(cards, true)
		TYPES.RETAIN:
			HandManager.retain_cards_this_turn(cards)
		_:
			DebugLogger.log_error("CardMoveOperation: Unsupported operation {0}".format([operation]))
