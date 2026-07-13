## Improves cards' @export properties by a given delta.
## Reads the current property value via get(), adds the delta, writes back via set().
## Respects a min_value per property (default 0).
## Does NOT touch card_values. For card_values, use ActionImproveCardValues.
##
## modify_parent_card = true  → 写入牌组原件 → 本次游戏永久生效
## modify_parent_card = false → 写入战斗复制品 → 仅本局战斗生效
extends BaseCardsetAction

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_cardset_action()
	for action_interceptor_processor in action_interceptor_processors:
		var modify_parent_card: bool = action_interceptor_processor.get_shadowed_action_values("modify_parent_card", true)
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		
		for card_data in picked_cards:
			var card_property_improvements: Dictionary[String, int] = {}
			card_property_improvements.assign(action_interceptor_processor.get_shadowed_action_values("card_property_improvements", {}))
			
			var card_property_min_values: Dictionary[String, int] = {}
			card_property_min_values.assign(action_interceptor_processor.get_shadowed_action_values("card_property_min_values", {}))
			
			var targets: Array[CardData] = [card_data]
			if modify_parent_card and card_data.parent_card != null:
				targets.append(card_data.parent_card)
			
			for target_card in targets:
				for prop_name: String in card_property_improvements:
					var delta: int = card_property_improvements[prop_name]
					var current_value: Variant = target_card.get(prop_name)
					if current_value is int or current_value is float:
						var min_val: int = card_property_min_values.get(prop_name, 0)
						target_card.set(prop_name, max(min_val, current_value + delta))
