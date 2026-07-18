## Interceptable instant action that populates things into the shop at the player's location.
## NOTE: This does not generate the inventory of the shop, it only adds things to the shop in a way
## that can be intercepted.
## See: ShopData.visit_shop() and ActionGenerator.generate_populate_shop_items() 
extends BaseAction

func _get_paired_item_count(item_type: String, item_count: int, price_count: int) -> int:
	if item_count != price_count:
		DebugLogger.log_error(
			"ActionShopPopulateItems: {0} count ({1}) does not match price count ({2}); only valid pairs will be added."
			.format([item_type, item_count, price_count])
		)
	return mini(item_count, price_count)

func perform_action():
	# check if shop at player location
	var shop_data: ShopData = Global.get_shop_at_player_location()
	if shop_data == null:
		breakpoint
		return
	
	# intercept the action
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var shop_cards: Array[CardData] = action_interceptor_processor.get_shadowed_action_values("shop_cards", [] as Array[CardData])
		var shop_card_prices: Array[int] = action_interceptor_processor.get_shadowed_action_values("shop_card_prices", [] as Array[int])
		
		var shop_artifact_ids: Array[String] = action_interceptor_processor.get_shadowed_action_values("shop_artifact_ids", [] as Array[String])
		var shop_artifact_prices: Array[int] = action_interceptor_processor.get_shadowed_action_values("shop_artifact_prices", [] as Array[int])

		var shop_consumable_ids: Array[String] = action_interceptor_processor.get_shadowed_action_values("shop_consumable_ids", [] as Array[String])
		var shop_consumable_prices: Array[int] = action_interceptor_processor.get_shadowed_action_values("shop_consumable_prices", [] as Array[int])
		
		# add cards
		var card_count: int = _get_paired_item_count("card", len(shop_cards), len(shop_card_prices))
		for i: int in card_count:
			var card_data: CardData = shop_cards[i]
			var card_price: int = shop_card_prices[i]
			shop_data.add_shop_card(card_data, card_price)
		# add artifacts
		var artifact_count: int = _get_paired_item_count("artifact", len(shop_artifact_ids), len(shop_artifact_prices))
		for i: int in artifact_count:
			var shop_artifact_id: String = shop_artifact_ids[i]
			var shop_artifact_price: int = shop_artifact_prices[i]
			shop_data.add_shop_artifact(shop_artifact_id, shop_artifact_price)
		# add consumables
		var consumable_count: int = _get_paired_item_count("consumable", len(shop_consumable_ids), len(shop_consumable_prices))
		for i: int in consumable_count:
			var shop_consumable_id: String = shop_consumable_ids[i]
			var shop_consumable_price: int = shop_consumable_prices[i]
			shop_data.add_shop_consumable(shop_consumable_id, shop_consumable_price)

func is_instant_action() -> bool:
	return true
