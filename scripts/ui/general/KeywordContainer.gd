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
			
	# parse actions for status effects
	for action in card_data.card_play_actions:
		if action.has(Scripts.ACTION_APPLY_STATUS):
			var status_id = action[Scripts.ACTION_APPLY_STATUS].get("status_effect_object_id", "")
			if status_id != "" and not card_status_effect_object_ids.has(status_id):
				card_status_effect_object_ids.append(status_id)
	
	clear_tooltips()
	
	if Global.user_settings_data.settings_enable_card_keywords:
		var all_child_keywords: Array[String] = _get_all_recursive_child_keywords(card_keyword_object_ids)
		for keyword_object_id in all_child_keywords:
			var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
			add_child(keyword_tooltip)
			keyword_tooltip.init(keyword_object_id)
	
	if Global.user_settings_data.settings_enable_card_status_effects:
		for status_id in card_status_effect_object_ids:
			var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
			add_child(keyword_tooltip)
			keyword_tooltip.init_status_effect(status_id)
	
	if Global.user_settings_data.settings_enable_card_hints and card_data.card_hint != "":
		var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
		add_child(keyword_tooltip)
		keyword_tooltip.init_custom("小tips", card_data.card_hint)

func populate_keywords(keyword_object_ids: Array[String]) -> void:
	clear_tooltips()
	var all_child_keywords: Array[String] = _get_all_recursive_child_keywords(keyword_object_ids)
	for keyword_object_id in all_child_keywords:
		var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
		add_child(keyword_tooltip)
		keyword_tooltip.init(keyword_object_id)

func _get_all_recursive_child_keywords(keyword_object_ids: Array[String]) -> Array[String]:
	# searches (BFS) all child keywords and returns the full list
	# this is typically a shallow search but ensures all keywords are properly listed 
	var all_child_keywords: Array[String] = keyword_object_ids.duplicate()
	var i: int = 0
	while i < len(all_child_keywords):
		var keyword_object_id: String = all_child_keywords[i]
		var keyword_data: KeywordData = Global.get_keyword_data(keyword_object_id)
		if keyword_data == null:
			DebugLogger.log_error("EnemyContainer._get_all_recursive_child_keywords(): No keyword of id {0} found".format([keyword_object_id]))
		else:
			for child_keyword_object_id in keyword_data.keyword_child_keyword_object_ids:
				if not all_child_keywords.has(child_keyword_object_id):
					all_child_keywords.append(child_keyword_object_id)
		i += 1
	return all_child_keywords

func clear_tooltips() -> void:
	for child in get_children():
		child.queue_free()
