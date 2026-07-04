# tooltip component which can display a list of keywords via KeywordTooltip
# attached to objects as a ui component; not dynamically instantiated
extends VBoxContainer
class_name KeywordContainer

func populate_card_keywords(card_data: CardData) -> void:
	# wrapper function to call keywords on a card
	# automatically adds keywords to the list based on card flags
	var card_keyword_object_ids: Array[String] = card_data.card_keyword_object_ids.duplicate()
	var card_status_effect_object_ids: Array[String] = card_data.card_status_effect_object_ids.duplicate()
	
	if card_data.card_first_shuffle_priority > 0:
		if not card_keyword_object_ids.has("keyword_top_deck"):
			card_keyword_object_ids.append("keyword_top_deck")
	if card_data.card_first_shuffle_priority < 0:
		if not card_keyword_object_ids.has("keyword_bottom_deck"):
			card_keyword_object_ids.append("keyword_bottom_deck")
	if not card_data.card_is_playable:
		if not card_keyword_object_ids.has("keyword_unplayable"):
			card_keyword_object_ids.append("keyword_unplayable")
	
	if card_data.card_is_retained:
		if not card_keyword_object_ids.has("keyword_retain"):
			card_keyword_object_ids.append("keyword_retain")
	if card_data.card_end_of_turn_destination == HandManager.EXHAUST_PILE:
		if not card_keyword_object_ids.has("keyword_ethereal"):
			card_keyword_object_ids.append("keyword_ethereal")
	if card_data.card_play_destination == HandManager.EXHAUST_PILE:
		if not card_keyword_object_ids.has("keyword_exhaust"):
			card_keyword_object_ids.append("keyword_exhaust")
	if card_data.card_play_destination == HandManager.BANISH_PILE:
		if not card_keyword_object_ids.has("keyword_banish"):
			card_keyword_object_ids.append("keyword_banish")
	if card_data.card_play_destination == HandManager.DRAW_PILE:
		if not card_keyword_object_ids.has("keyword_rebound"):
			card_keyword_object_ids.append("keyword_rebound")
			
	# parse actions for status effects across all action hooks
	var all_action_lists: Array[Array] = [
		card_data.card_play_actions,
		card_data.card_draw_actions,
		card_data.card_discard_actions,
		card_data.card_exhaust_actions,
		card_data.card_retain_actions,
		card_data.card_end_of_turn_actions,
		card_data.card_initial_combat_actions,
		card_data.card_right_click_actions,
		card_data.card_add_to_deck_actions,
		card_data.card_remove_from_deck_actions,
		card_data.card_transform_in_deck_actions,
	]
	var card_created_card_object_ids: Array[String] = []
	for action_list in all_action_lists:
		for action in action_list:
			_parse_action_recursively(action, card_data, card_status_effect_object_ids, card_created_card_object_ids)
			
	# Extract explicitly mentioned cards from the description (e.g. [card_name:card_waste])
	for m in TextParser.card_name_regex.search_all(card_data.card_description):
		var card_id = m.get_string(1)
		if not card_created_card_object_ids.has(card_id):
			card_created_card_object_ids.append(card_id)
	
	clear_tooltips()
	
	if Global.user_settings_data.settings_enable_card_keywords:
		var all_child_keywords: Array[String] = _get_all_recursive_child_keywords(card_keyword_object_ids)
		for keyword_object_id in all_child_keywords:
			var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
			add_child(keyword_tooltip)
			keyword_tooltip.init(keyword_object_id)
	
	if Global.user_settings_data.settings_enable_card_status_effects:
		for status_id in card_status_effect_object_ids:
			var status_data: StatusEffectData = Global.get_status_effect_data(status_id)
			if status_data != null and status_data.status_effect_is_visible:
				var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
				add_child(keyword_tooltip)
				keyword_tooltip.init_status_effect(status_id)
				
		for created_card_id in card_created_card_object_ids:
			var created_card_data: CardData = Global.get_card_data(created_card_id)
			if created_card_data != null:
				var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
				add_child(keyword_tooltip)
				keyword_tooltip.init_card(created_card_id)
	
	if Global.user_settings_data.settings_enable_card_hints and card_data.card_hint != "":
		var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
		add_child(keyword_tooltip)
		keyword_tooltip.init_custom("小tips", card_data.card_hint, card_data.card_values)

func populate_keywords(keyword_object_ids: Array[String]) -> void:
	clear_tooltips()
	var all_child_keywords: Array[String] = _get_all_recursive_child_keywords(keyword_object_ids)
	for keyword_object_id in all_child_keywords:
		var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
		add_child(keyword_tooltip)
		keyword_tooltip.init(keyword_object_id)

func _get_all_recursive_child_keywords(keyword_object_ids: Array[String]) -> Array[String]:
	var all_child_keywords: Array[String] = keyword_object_ids.duplicate()
	for keyword_object_id in keyword_object_ids:
		var keyword_data: KeywordData = Global.get_keyword_data(keyword_object_id)
		if keyword_data != null:
			var recursive_children: Array[String] = _get_all_recursive_child_keywords(keyword_data.keyword_child_keyword_object_ids)
			for child in recursive_children:
				if not all_child_keywords.has(child):
					all_child_keywords.append(child)
					
	return all_child_keywords

func _parse_action_recursively(action: Dictionary, card_data: CardData, status_ids: Array[String], card_ids: Array[String]) -> void:
	for action_key in action.keys():
		var action_params = action[action_key]
		if typeof(action_params) != TYPE_DICTIONARY:
			continue
			
		if action_key == Scripts.ACTION_APPLY_STATUS or action_key == Scripts.ACTION_BLOCK_TO_STATUS:
			var status_id = action_params.get("status_effect_object_id", "")
			if status_id == "":
				status_id = card_data.card_values.get("status_effect_object_id", "")
			if status_id != "" and not status_ids.has(status_id):
				status_ids.append(status_id)
				
		if action_key == Scripts.ACTION_CREATE_CARDS:
			var created_card_id = action_params.get("created_card_object_id", "")
			if created_card_id == "":
				created_card_id = card_data.card_values.get("created_card_object_id", "")
			if created_card_id != "" and not card_ids.has(created_card_id):
				card_ids.append(created_card_id)
				
		if action_params.has("action_data"):
			var nested_actions = action_params["action_data"]
			if typeof(nested_actions) == TYPE_ARRAY:
				for nested_action in nested_actions:
					if typeof(nested_action) == TYPE_DICTIONARY:
						_parse_action_recursively(nested_action, card_data, status_ids, card_ids)

func clear_tooltips() -> void:
	for child in get_children():
		child.queue_free()
