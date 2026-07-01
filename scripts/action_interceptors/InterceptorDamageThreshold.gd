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
	
	var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
	if damage <= 0:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var bypass_block: bool = action_interceptor_processor.get_shadowed_action_values("bypass_block", false)
	var target_block: int = target_combatant.get_block()
	if bypass_block:
		target_block = 0
	
	# Only actual health damage counts towards the threshold
	var actual_damage: int = damage
	if damage > target_block:
		actual_damage = damage - target_block
	else:
		actual_damage = 0
		
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
			
			# Trigger the intent change
			var action_data: Array[Dictionary] = [
				{
					Scripts.ACTION_CHANGE_ENEMY_INTENT_STATE: {
						"new_intent_id": next_intent_id,
						"target_override": BaseAction.TARGET_OVERRIDES.PARENT
					}
				},
				# Also apply a stun/visual effect or clear debuffs here if needed
			]
			var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(target_combatant, null, [target_combatant], action_data, null)
			ActionHandler.add_actions(generated_actions)
			
	return ACTION_ACCEPTENCES.CONTINUE
