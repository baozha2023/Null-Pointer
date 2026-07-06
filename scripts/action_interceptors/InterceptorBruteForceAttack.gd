extends BaseActionInterceptor

const ACTION_ATTACK_GENERATOR: String = "res://scripts/actions/combatant_actions/ActionAttackGenerator.gd"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var parent_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if parent_combatant == null or not parent_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
		
	var card_data: CardData = action_interceptor_processor.parent_action.get_action_card_data()
	if card_data == null or card_data.card_type != CardData.CARD_TYPES.ATTACK:
		return ACTION_ACCEPTENCES.REJECTED
		
	var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
	action_interceptor_processor.set_shadowed_action_values("damage", damage + 2)
	
	return ACTION_ACCEPTENCES.CONTINUE
