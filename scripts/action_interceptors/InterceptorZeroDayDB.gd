extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	var parent_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if parent_combatant == null or not parent_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
		
	# Check if this applies vulnerable
	if action_interceptor_processor.get_shadowed_action_values("status_effect_object_id", "") != "status_effect_vulnerable":
		return ACTION_ACCEPTENCES.CONTINUE
		
	# Check if user is player
	if parent_combatant != Global.get_player():
		return ACTION_ACCEPTENCES.CONTINUE
		
	# Check if target is enemy
	if not action_interceptor_processor.target is Enemy:
		return ACTION_ACCEPTENCES.CONTINUE
		
	# Get artifact from player to check its counter and variables
	var artifact_datas: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_0day_database")
	if artifact_datas.size() == 0:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var artifact_data: ArtifactData = artifact_datas[0]
		
	var has_triggered: bool = Global.player_data.player_values.get("artifact_0day_database_triggered", false)
	if has_triggered:
		return ACTION_ACCEPTENCES.CONTINUE

	var current_charge: int = action_interceptor_processor.get_shadowed_action_values("status_charge_amount", 0)
	action_interceptor_processor.set_shadowed_action_values("status_charge_amount", current_charge + artifact_data.artifact_counter)
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE

	Global.player_data.player_values["artifact_0day_database_triggered"] = true
	Signals.artifact_proc.emit(artifact_data)
		
	return ACTION_ACCEPTENCES.CONTINUE
