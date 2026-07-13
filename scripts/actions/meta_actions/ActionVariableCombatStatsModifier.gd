# Wraps child actions, modifying their values
# Amount based on a given combat stat
# NOTE: As this is an action and not a decorator, its wrapped value(s) are calculated on runtime
# and cannot be previewed on a card
# If you want the value to be seen in the description, use a decorator such as CardDecoratorDynamicValueModifier
extends BaseVariableActionModifier

func is_instant_action() -> bool:
	return true

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		# get combat stat multiplier
		# supports both stat_enum (int) and combat_stat_name (string) key formats
		var stat_value: int = 0
		var combat_stat_name: String = action_interceptor_processor.get_shadowed_action_values("combat_stat_name", "")
		if combat_stat_name != "":
			var stat_variable_name: String = action_interceptor_processor.get_shadowed_action_values("stat_variable_name", "")
			if combat_stat_name == "target_status_effect_charges" and stat_variable_name != "" and len(targets) > 0:
				stat_value = targets[0].get_status_charges(stat_variable_name)
			elif combat_stat_name == "player_status_effect_charges" and stat_variable_name != "" and parent_combatant != null:
				stat_value = parent_combatant.get_status_charges(stat_variable_name)
			elif combat_stat_name == "block_amount" and parent_combatant != null:
				stat_value = parent_combatant.get_block()
			elif combat_stat_name == "actions_in_forge":
				stat_value = _get_forge_action_count(action_interceptor_processor)
			else:
				stat_value = _get_combat_stat_by_name(combat_stat_name)
		else:
			var combat_stats_data: CombatStatsData = StatsHandler.current_combat_stats
			var stat_enum: int = action_interceptor_processor.get_shadowed_action_values("stat_enum", CombatStatsData.STATS.ENEMIES_KILLED)
			var turn_stat_type: int = action_interceptor_processor.get_shadowed_action_values("turn_stat_type", 0)
			stat_value = combat_stats_data.get_history_enum_stat(stat_enum, turn_stat_type)
		
		var stat_divisor: int = action_interceptor_processor.get_shadowed_action_values("stat_divisor", 1)
		if stat_divisor > 1:
			stat_value = int(stat_value / stat_divisor)
		
		var generated_actions: Array[BaseAction] = _create_modified_child_actions(action_interceptor_processor, stat_value)
		ActionHandler.add_actions(generated_actions)


## Resolves a combat_stat_name string to its current integer value.
## Supports both enum-based stats and live values like hand size.
func _get_combat_stat_by_name(stat_name: String) -> int:
	match stat_name:
		"cards_in_hand":
			return HandManager.player_hand.size()
		"attack_cards_in_hand":
			var count: int = 0
			for card_data: CardData in HandManager.player_hand:
				if card_data.card_type == CardData.CARD_TYPES.ATTACK:
					count += 1
			return count
		"skill_cards_played_this_turn":
			var count: int = 0
			for card_play_request: CardPlayRequest in StatsHandler.cards_played_this_turn:
				if card_play_request.card_data != null and card_play_request.card_data.card_type == CardData.CARD_TYPES.SKILL:
					count += 1
			return count
	return 0

func _get_forge_action_count(action_interceptor_processor: ActionInterceptorProcessor) -> int:
	var count: int = 0
	var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
	var action_types: Array = action_interceptor_processor.get_shadowed_action_values("action_types", [])
	
	for entry in forge_actions:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		if action_types.is_empty():
			count += 1
		else:
			var action_data: Dictionary = entry.get("action_data", {})
			for key in action_data:
				if key in action_types:
					count += 1
					break
	return count
