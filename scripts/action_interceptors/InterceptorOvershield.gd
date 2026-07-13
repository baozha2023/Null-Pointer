# Reduces damage by overshield amount
extends BaseActionInterceptor

const OVERSHIELD_STATUS_EFFECT_ID: String = "status_effect_overshield"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	# Enemy intents and card descriptions show attack output before defensive reserves are consumed.
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE

	var target_combatant: BaseCombatant = action_interceptor_processor.target
	if target_combatant == null:
		return ACTION_ACCEPTENCES.REJECTED
	if not target_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED

	var health_damage: int = action_interceptor_processor.get_incoming_health_damage()
	if health_damage <= 0:
		return ACTION_ACCEPTENCES.CONTINUE

	var overshield_charges: int = max(0, target_combatant.get_status_charges(OVERSHIELD_STATUS_EFFECT_ID))
	var absorbed_damage: int = min(health_damage, overshield_charges)
	action_interceptor_processor.set_incoming_health_damage(health_damage - absorbed_damage)
	if not preview_mode and absorbed_damage > 0:
		target_combatant.add_status_effect_charges(OVERSHIELD_STATUS_EFFECT_ID, -absorbed_damage)
	
	return ACTION_ACCEPTENCES.CONTINUE
