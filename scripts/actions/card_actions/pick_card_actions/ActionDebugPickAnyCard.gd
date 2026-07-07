extends ActionPickCards

func get_card_pick_type() -> String:
	return HandManager.DECK

func get_pickable_cards() -> Array[CardData]:
	return Global.get_all_cards()

func perform_async_action() -> void:
	var cloned_cards: Array[CardData] = []
	for card in picked_cards:
		cloned_cards.append(Global.get_card_data_from_prototype(card.object_id))
	picked_cards = cloned_cards
	super.perform_async_action()

func _to_string():
	return "Action Debug Pick Any Card"
