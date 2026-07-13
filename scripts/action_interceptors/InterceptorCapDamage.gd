# Reduces incoming damage to a maximum threshold based on secondary status charges
extends BaseActionInterceptor

const CAP_DAMAGE_STATUS_EFFECT_ID: String = "status_effect_cap_damage"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var target_combatant: BaseCombatant = action_interceptor_processor.target
	if target_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not target_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED

	var health_damage: int = action_interceptor_processor.get_incoming_health_damage()
	if health_damage > 0:
		var damage_cap: int = max(0, target_combatant.get_status_secondary_charges(CAP_DAMAGE_STATUS_EFFECT_ID))
		action_interceptor_processor.set_incoming_health_damage(min(health_damage, damage_cap))
	
	return ACTION_ACCEPTENCES.CONTINUE
