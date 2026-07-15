extends BaseCardsetAction
class_name ActionScheduleDelayedActions

# Parameters:
# status_effect_id: String (e.g. "status_effect_delayed_execution")
# status_charges: int (countdown duration in turns)
# action_data: Array[Dictionary] (the actions to perform when countdown ends)
# operation: CardMoveOperation.TYPES - what to do with the picked cards (if any)
# variable_name_to_export: String - the key used in child actions to receive the picked cards

func is_instant_action() -> bool:
	return true

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_cardset_action([parent_combatant])

	for action_interceptor_processor in action_interceptor_processors:
		var picked_cards: Array[CardData] = _get_picked_cards(action_interceptor_processor)
		var operation: int = action_interceptor_processor.get_shadowed_action_values("operation", CardMoveOperation.TYPES.NONE)
		var status_effect_id: String = action_interceptor_processor.get_shadowed_action_values("status_effect_id", "status_effect_delayed_execution")
		var status_charges: int = action_interceptor_processor.get_shadowed_action_values("status_charges", 1)
		var variable_name_to_export: String = action_interceptor_processor.get_shadowed_action_values("variable_name_to_export", "stored_cards")

		var delayed_action_data: Array = []
		delayed_action_data.assign(action_interceptor_processor.get_shadowed_action_values("action_data", []))

		var duplicated_cards: Array[CardData] = []
		if len(picked_cards) > 0:
			CardMoveOperation.apply(picked_cards, operation)

			for c in picked_cards:
				duplicated_cards.append(c.get_prototype(true))

		var original_card_values: Dictionary = card_play_request.card_values.duplicate(true) if card_play_request else {}
		var delayed_action_entries: Array = []
		for action_dict: Dictionary in delayed_action_data:
			delayed_action_entries.append({"action_data": action_dict})
		var delayed_actions_text: String = TextParser.parse_forge_actions_to_text(delayed_action_entries, original_card_values)

		# Apply the delayed status effect to the parent combatant
		var apply_status_action: Dictionary = {
			Scripts.ACTION_APPLY_STATUS: {
				"status_effect_object_id": status_effect_id,
				"status_charge_amount": status_charges,
				"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
				"status_force_apply_new_effect": true,
				"status_custom_values": {
					"delayed_actions": delayed_action_data,
					"delayed_actions_text": delayed_actions_text,
					"stored_cards": duplicated_cards,
					"variable_name_to_export": variable_name_to_export,
					"original_card_values": original_card_values
				}
			}
		}

		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, [parent_combatant], [apply_status_action], self)
		ActionHandler.add_actions(generated_actions)
