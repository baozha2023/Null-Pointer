# Completely stops damage from happening
# Tied to corresponding status effect
extends BaseActionInterceptor

const NEGATE_DAMAGE_STATUS_EFFECT_ID: String = "status_effect_negate_damage"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	var target_combatant: BaseCombatant = action_interceptor_processor.target
	if target_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not target_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED

	if action_interceptor_processor.get_incoming_health_damage() > 0:
		if not preview_mode:
			target_combatant.add_status_effect_charges(NEGATE_DAMAGE_STATUS_EFFECT_ID, -1)
		action_interceptor_processor.set_incoming_health_damage(0)
		return ACTION_ACCEPTENCES.STOPPED
	
	return ACTION_ACCEPTENCES.CONTINUE
