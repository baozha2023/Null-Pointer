# Upgrades all cards that can be upgraded in given cardset
# This can target a list of cards, or their parent cards (making it permanent if in player's deck)
extends BaseCardsetAction

func perform_action():
	for action_interceptor_processor: ActionInterceptorProcessor in _intercept_cardset_action():
		var upgrade_parent_card: bool = action_interceptor_processor.get_shadowed_action_values("upgrade_parent_card", true)
		var upgrade_count: int = max(0, action_interceptor_processor.get_shadowed_action_values("upgrade_count", 1))
		var bypass_upgrade_max: bool = action_interceptor_processor.get_shadowed_action_values("bypass_upgrade_max", false)
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		_upgrade_cards(picked_cards, upgrade_parent_card, upgrade_count, bypass_upgrade_max)

func _upgrade_cards(picked_cards: Array[CardData], upgrade_parent_card: bool, upgrade_count: int, bypass_upgrade_max: bool) -> void:
	for card_data: CardData in picked_cards:
		card_data.upgrade_card(upgrade_count, bypass_upgrade_max)
		# potentially upgrade parent if it exists
		if upgrade_parent_card and card_data.parent_card != null:
			card_data.parent_card.upgrade_card(upgrade_count, bypass_upgrade_max)
		
		# Synchronize the upgrade to any combat clones (so UI updates immediately in combat)
		var master_card: CardData = card_data.parent_card if card_data.parent_card != null else card_data
		var combat_cards: Array[CardData] = []
		combat_cards.append_array(HandManager.player_hand)
		combat_cards.append_array(HandManager.player_draw)
		combat_cards.append_array(HandManager.player_discard)
		combat_cards.append_array(HandManager.player_exhaust)
		
		for combat_card in combat_cards:
			if combat_card.parent_card == master_card and combat_card != card_data:
				combat_card.upgrade_card(upgrade_count, bypass_upgrade_max)

func _to_string():
	return "Upgrade Card Action"
