# Listens to player card plays. When the player plays a card, the target gains 1 Strength (or defined status).
extends BaseActionInterceptor

const CURIOSITY_STATUS_EFFECT_ID: String = "status_effect_curiosity"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var target_combatant: BaseCombatant = action_interceptor_processor.target
	if target_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not target_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
	
	var card_play_request: CardPlayRequest = action_interceptor_processor.parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE
	var card_data: CardData = card_play_request.card_data
		
	# The status effect can be placed on ANY combatant (Player or Enemy)
	# Whoever holds the status will gain the buff when the player plays a card.

	var statuses: Array = target_combatant.status_id_to_status_effects.get(CURIOSITY_STATUS_EFFECT_ID, [])
	if len(statuses) == 0:
		return ACTION_ACCEPTENCES.CONTINUE
	var status_effect_script: BaseStatusEffect = statuses[0].status_effect_script
	var custom_values: Dictionary = status_effect_script.status_custom_values
		
	var trigger_card_types: Array = custom_values.get("curiosity_trigger_card_types", [])
	
	if card_data.card_type in trigger_card_types:
		# Check threshold
		var threshold: int = custom_values.get("curiosity_trigger_threshold", 1)
		var counter: int = custom_values.get("curiosity_current_counter", 0)
			
		counter += 1
		
		if counter >= threshold:
			counter = 0 # reset counter after triggering
			
			# Trigger the reaction
			var reaction_status_id: String = custom_values.get("curiosity_reaction_status_id", "")
			var reaction_amount: int = custom_values.get("curiosity_reaction_amount", 0)
			
			if reaction_status_id != "" and reaction_amount > 0:
				# Generate apply status action
				var action_data: Array[Dictionary] = [
					{
						Scripts.ACTION_APPLY_STATUS: {
							"status_effect_object_id": reaction_status_id,
							"status_charge_amount": reaction_amount,
							"target_override": BaseAction.TARGET_OVERRIDES.PARENT
						}
					}
				]
				var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(target_combatant, null, [target_combatant], action_data, null)
				ActionHandler.add_actions(generated_actions)
		
		# Save current counter
		custom_values["curiosity_current_counter"] = counter
			
	return ACTION_ACCEPTENCES.CONTINUE
