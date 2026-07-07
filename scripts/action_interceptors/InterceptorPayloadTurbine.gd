extends BaseActionInterceptor

const MAIN_STATUS_EFFECT_ID: String = "status_effect_payload_turbine"
const LOAD_STATUS_EFFECT_ID: String = "status_effect_turn_forge_load"

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	# 检查是否是给玩家附加状态
	var player_combatant: BaseCombatant = action_interceptor_processor.target
	if player_combatant == null or not player_combatant.is_alive():
		return ACTION_ACCEPTENCES.CONTINUE
		
	if player_combatant != Global.get_player():
		return ACTION_ACCEPTENCES.CONTINUE

	# 检查附加的状态是否是载荷
	var status_id: String = action_interceptor_processor.get_shadowed_action_values("status_effect_object_id", "")
	if status_id != LOAD_STATUS_EFFECT_ID:
		return ACTION_ACCEPTENCES.CONTINUE
		
	# 检查主状态是否存在
	var main_statuses: Array = player_combatant.status_id_to_status_effects.get(MAIN_STATUS_EFFECT_ID, [])
	if len(main_statuses) == 0:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var main_status_effect_script: BaseStatusEffect = main_statuses[0].status_effect_script
	
	# 检查副层数是否 > 0 （是否有门票）
	if main_status_effect_script.status_secondary_charges <= 0:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var bonus_load: int = main_status_effect_script.status_charges
	
	# 修改当前的动作增加载荷
	var current_load: int = action_interceptor_processor.get_shadowed_action_values("status_charge_amount", 1)
	action_interceptor_processor.set_shadowed_action_values("status_charge_amount", current_load + bonus_load)
	
	# 消费门票：直接将副层数清零
	if not preview_mode:
		main_status_effect_script.status_secondary_charges = 0
		main_statuses[0].update_status_charge_display()
		
	return ACTION_ACCEPTENCES.CONTINUE
