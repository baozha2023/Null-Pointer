# Listens to damage taken. Accumulates health damage in its secondary charges.
# If secondary charges >= primary charges, it triggers a phase shift (ActionChangeEnemyIntentState).
extends BaseActionInterceptor

const DAMAGE_THRESHOLD_STATUS_EFFECT_ID: String = "status_effect_damage_threshold"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE
	
	var target_combatant: BaseCombatant = action_interceptor_processor.target
	if target_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not target_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
	
	var actual_damage: int = action_interceptor_processor.get_incoming_health_damage()
	if actual_damage > 0:
		target_combatant.add_status_effect_charges(DAMAGE_THRESHOLD_STATUS_EFFECT_ID, 0, actual_damage)
		
		var current_accumulated_damage: int = target_combatant.get_status_secondary_charges(DAMAGE_THRESHOLD_STATUS_EFFECT_ID)
		var threshold_limit: int = target_combatant.get_status_charges(DAMAGE_THRESHOLD_STATUS_EFFECT_ID)
		
		if current_accumulated_damage >= threshold_limit:
			# Reset the threshold tracker
			target_combatant.add_status_effect_charges(DAMAGE_THRESHOLD_STATUS_EFFECT_ID, 0, -current_accumulated_damage)
			
			# Increase the threshold for the next time (e.g., +20)
			# We can do this by adding primary charges!
			var statuses: Array = target_combatant.status_id_to_status_effects.get(DAMAGE_THRESHOLD_STATUS_EFFECT_ID, [])
			var threshold_increase: int = 20
			var next_intent_id: String = "intent_overheat"
			
			if len(statuses) > 0:
				var custom_values: Dictionary = statuses[0].status_effect_script.status_custom_values
				threshold_increase = custom_values.get("damage_threshold_increase_amount", 20)
				next_intent_id = custom_values.get("damage_threshold_target_intent", "intent_overheat")
				
			target_combatant.add_status_effect_charges(DAMAGE_THRESHOLD_STATUS_EFFECT_ID, threshold_increase, 0)
			
			var action_data: Array[Dictionary] = []
			if next_intent_id != "":
				action_data.append({
					Scripts.ACTION_CHANGE_ENEMY_INTENT_STATE: {
						"new_intent_id": next_intent_id,
						"target_override": BaseAction.TARGET_OVERRIDES.PARENT
					}
				})
			
			if len(statuses) > 0:
				var custom_values: Dictionary = statuses[0].status_effect_script.status_custom_values
				if custom_values.has("damage_threshold_actions"):
					action_data.append_array(custom_values.get("damage_threshold_actions", []))

			var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(target_combatant, null, [target_combatant], action_data, null)
			ActionHandler.add_actions(generated_actions)
			
	return ACTION_ACCEPTENCES.CONTINUE
