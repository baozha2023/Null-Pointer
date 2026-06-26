# Wraps child actions, modifying their values
# Amount based on a given combat stat
# NOTE: As this is an action and not a decorator, its wrapped value(s) are calculated on runtime
# and cannot be previewed on a card
# If you want the value to be seen in the description, use a decorator such as CardDecoratorDynamicValueModifier
extends BaseAction

func is_instant_action() -> bool:
	return true

func perform_action():
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		var modified_action_data: Array[Dictionary] = []
		var action_data = action_interceptor_processor.get_shadowed_action_values("action_data", [])
		
		# wrapper values
		var multiplied_values: Array = action_interceptor_processor.get_shadowed_action_values("multiplied_values", [])	# the key names of the values of child actions multiplied by this action
		var multiplied_values_bases: Dictionary = action_interceptor_processor.get_shadowed_action_values("multiplied_values_bases", {})	# allows for a base value on top of modified values. eg Base + (X x Value)
		
		# get combat stat multiplier
		# supports both stat_enum (int) and combat_stat_name (string) key formats
		var stat_value: int = 0
		var combat_stat_name: String = action_interceptor_processor.get_shadowed_action_values("combat_stat_name", "")
		if combat_stat_name != "":
			stat_value = _get_combat_stat_by_name(combat_stat_name)
		else:
			var combat_stats_data: CombatStatsData = StatsHandler.current_combat_stats
			var stat_enum: int = action_interceptor_processor.get_shadowed_action_values("stat_enum", CombatStatsData.STATS.ENEMIES_KILLED)
			var is_total_stat: bool = action_interceptor_processor.get_shadowed_action_values("is_total_stat", false)
			if is_total_stat:
				stat_value = combat_stats_data.get_total_enum_stat(stat_enum)
			else:
				stat_value = combat_stats_data.get_turn_enum_stat(stat_enum)
		
		# creates a duplicate of the child action data, then modifies any keys with a multiple of the card play's input energy
		for action in action_data.duplicate(true):
			for action_script_path in action:
				for action_path in action:
					var action_values: Dictionary = action[action_script_path]
					for value_key in action_values.keys():
						if value_key in multiplied_values:
							var base_value: int = multiplied_values_bases.get(value_key, 0)
							var value: int = action_values[value_key]
							action_values[value_key] = base_value + (value * stat_value)
			
			modified_action_data.append(action)
		
		# also modifies any card play values
		for value_key in card_play_request.card_values.keys():
			if value_key in multiplied_values:
				var base_value: int = multiplied_values_bases.get(value_key, 0)
				var value: int = card_play_request.card_values[value_key]
				card_play_request.card_values[value_key] = base_value + (value * stat_value)
		
		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, targets, modified_action_data, self)
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
	return 0
