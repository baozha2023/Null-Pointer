## Generates duplicates of an existing instantiated card data.
## Functions like an ActionPickCards that generates the cards rather than have the user pick them
## Make sure to have child BaseCardSetAction(s) to actually do something such as add to hand
extends ActionPickCards
class_name ActionDuplicateCards

func perform_action():
	# overrides user card selection with generated cards
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var created_card_data: CardData = action_interceptor_processor.get_shadowed_action_values("created_card_data", null)
		var number_of_cards: int = action_interceptor_processor.get_shadowed_action_values("number_of_cards", 1)

		if created_card_data != null:
			for i in number_of_cards:
				picked_cards.append(created_card_data.get_prototype(true))

	# overwrite picked_cards action value with the generated cards, for child cardset actions
	# as this action doesn't require user input, "picked_cards" action value and picked_cards are the same
	values["picked_cards"] = picked_cards
	# also add as a property to the CardPlayRequest if one exists
	if card_play_request != null:
		card_play_request.card_values["generated_cards"] = picked_cards

	await Global.get_tree().process_frame # add a delay to allow ActionHandler to catch up with async to avoid infinite hang
	perform_async_action()

	# emit signals for each created card
	for card_data: CardData in picked_cards:
		Signals.card_created.emit(card_data)
