# Listens to player card plays. When the player plays a card,
# the player gains a reaction buff based on custom_values configuration.
# This interceptor is for PLAYER-held curiosity2 (modifies_parent=true).
# Supports multiple instances (status_effect_allows_multiples) with independent counters.
extends BaseActionInterceptor

const CURIOSITY_STATUS_EFFECT_ID: String = "status_effect_curiosity2"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	# Only process once per card play: _intercept_action passes [null, enemy1, enemy2, ...]
	# as targets. Parent-side interceptors fire for every target, so we skip non-null targets.
	if action_interceptor_processor.target != null:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var holder: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if holder == null or not holder.is_alive():
		return ACTION_ACCEPTENCES.CONTINUE
	
	var card_play_request: CardPlayRequest = action_interceptor_processor.parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE
	var card_data: CardData = card_play_request.card_data
	
	# Iterate over ALL curiosity2 status instances on the holder (supports allows_multiples)
	var statuses: Array = holder.status_id_to_status_effects.get(CURIOSITY_STATUS_EFFECT_ID, [])
	for status_effect in statuses:
		var status_effect_script: BaseStatusEffect = status_effect.status_effect_script
		var custom_values: Dictionary = status_effect_script.status_custom_values
		
		var trigger_card_types: Array = custom_values.get("curiosity_trigger_card_types", [])
		
		if card_data.card_type in trigger_card_types:
			var threshold: int = custom_values.get("curiosity_trigger_threshold", 1)
			var counter: int = custom_values.get("curiosity_current_counter", 0)
			
			counter += 1
			
			if counter >= threshold:
				counter = 0 # reset counter after triggering
				
				var reaction_status_id: String = custom_values.get("curiosity_reaction_status_id", "")
				var reaction_amount: int = custom_values.get("curiosity_reaction_amount", 0)
				
				if reaction_status_id != "" and reaction_amount > 0:
					var action_data: Array[Dictionary] = [
						{
							Scripts.ACTION_APPLY_STATUS: {
								"status_effect_object_id": reaction_status_id,
								"status_charge_amount": reaction_amount,
								"target_override": BaseAction.TARGET_OVERRIDES.PARENT
							}
						}
					]
					var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(holder, null, [holder], action_data, null)
					ActionHandler.add_actions(generated_actions)
			
			# Save current counter
			custom_values["curiosity_current_counter"] = counter
	
	return ACTION_ACCEPTENCES.CONTINUE
