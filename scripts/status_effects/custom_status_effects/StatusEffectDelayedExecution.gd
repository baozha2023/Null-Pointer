extends BaseStatusEffect
class_name StatusEffectDelayedExecution

func perform_status_effect_process_actions() -> void:
	super.perform_status_effect_process_actions()

	status_charges -= 1

	if status_charges <= 0:
		var stored_cards: Array = status_custom_values.get("stored_cards", [])
		var delayed_actions: Array = status_custom_values.get("delayed_actions", [])
		var variable_name_to_export: String = status_custom_values.get("variable_name_to_export", "")

		if len(delayed_actions) > 0:
			var exported_data: Array[Dictionary] = []

			# Deep copy and inject variables if applicable
			for action_dict in delayed_actions:
				var dup_action = action_dict.duplicate(true)
				if variable_name_to_export != "":
					for script_path in dup_action:
						# If multiple cards were stored, export the array; if only one, export the single card
						if len(stored_cards) == 1:
							dup_action[script_path][variable_name_to_export] = stored_cards[0]
						elif len(stored_cards) > 1:
							dup_action[script_path][variable_name_to_export] = stored_cards
						else:
							dup_action[script_path][variable_name_to_export] = null
				exported_data.append(dup_action)

			var card_play_request: CardPlayRequest = _generate_status_effect_card_play_request()
			var original_card_values: Dictionary = status_custom_values.get("original_card_values", {})
			card_play_request.card_values.merge(original_card_values, true)

			var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, [parent_combatant], exported_data, null)
			ActionHandler.add_actions(generated_actions)

		# Manually remove this specific status effect instance
		if parent_combatant.status_id_to_status_effects.has(status_effect_data.object_id):
			var instances: Array = parent_combatant.status_id_to_status_effects[status_effect_data.object_id]
			for ui_element in instances:
				if ui_element.status_effect_script == self:
					parent_combatant.call("_remove_status_effect", ui_element)
					break
	else:
		# update the UI charge display
		if parent_combatant.status_id_to_status_effects.has(status_effect_data.object_id):
			var instances: Array = parent_combatant.status_id_to_status_effects[status_effect_data.object_id]
			for ui_element in instances:
				if ui_element.status_effect_script == self:
					ui_element.update_status_charge_display()
					break
