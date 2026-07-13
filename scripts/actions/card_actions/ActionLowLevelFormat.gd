extends BaseAction
class_name ActionLowLevelFormat

# source_zones: Array[String] (e.g. HandManager.HAND_PILE)
# filter_card_types: Array[int] (e.g. CardData.CARD_TYPES.ATTACK)
# filter_card_colors: Array[String] (e.g. "color_blue")
# filter_card_ids: Array[String] (e.g. "card_strike")
# operation: CardMoveOperation.TYPES
# variable_name_to_export: String ("format_count")

func is_instant_action() -> bool:
	return true

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action(targets)

	for action_interceptor_processor in action_interceptor_processors:
		var source_zones: Array = action_interceptor_processor.get_shadowed_action_values("source_zones", [HandManager.HAND_PILE, HandManager.DRAW_PILE, HandManager.DISCARD_PILE])
		var filter_card_types: Array = action_interceptor_processor.get_shadowed_action_values("filter_card_types", [])
		var filter_card_colors: Array = action_interceptor_processor.get_shadowed_action_values("filter_card_colors", [])
		var filter_card_ids: Array = action_interceptor_processor.get_shadowed_action_values("filter_card_ids", [])
		var operation: int = action_interceptor_processor.get_shadowed_action_values("operation", CardMoveOperation.TYPES.EXHAUST)
		var variable_name_to_export: String = action_interceptor_processor.get_shadowed_action_values("variable_name_to_export", "format_count")

		var action_data: Array = []
		action_data.assign(action_interceptor_processor.get_shadowed_action_values("action_data", []))

		var matched_cards: Array[CardData] = []

		# 1. Collect
		for zone_name in source_zones:
			var zone_array: Array[CardData] = HandManager.get_pile(zone_name)
			for card in zone_array:
				# Type filter
				if len(filter_card_types) > 0 and not filter_card_types.has(card.card_type):
					continue
				# Color filter
				if len(filter_card_colors) > 0 and not filter_card_colors.has(card.card_color_id):
					continue
				# ID filter
				if len(filter_card_ids) > 0 and not filter_card_ids.has(card.object_id):
					continue

				if not matched_cards.has(card):
					matched_cards.append(card)

		var N: int = len(matched_cards)

		# 2. Operate
		CardMoveOperation.apply(matched_cards, operation)

		# 3. Export & Generate Child Actions
		var exported_data: Array[Dictionary] = []

		# Deep copy to inject dynamic variable
		for action_dict in action_data:
			var dup_action = action_dict.duplicate(true)
			if variable_name_to_export != "":
				for script_path in dup_action:
					dup_action[script_path][variable_name_to_export] = N
			exported_data.append(dup_action)

		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, targets, exported_data, self)
		ActionHandler.add_actions(generated_actions)
