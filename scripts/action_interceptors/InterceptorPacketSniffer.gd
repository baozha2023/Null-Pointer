extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if preview_mode:
		return ACTION_ACCEPTENCES.CONTINUE

	var parent_combatant: BaseCombatant = action_interceptor_processor.parent_action.parent_combatant
	if parent_combatant == null or not parent_combatant.is_alive():
		return ACTION_ACCEPTENCES.REJECTED
		
	# Check if user is player
	if parent_combatant != Global.get_player():
		return ACTION_ACCEPTENCES.CONTINUE
		
	# Check if target is enemy
	if not action_interceptor_processor.target is Enemy:
		return ACTION_ACCEPTENCES.CONTINUE
		
	var status_id: String = action_interceptor_processor.get_shadowed_action_values("status_effect_object_id", "")
	var status_data: StatusEffectData = Global.get_status_effect_data(status_id)
	
	if status_data and status_data.status_effect_type == StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF:
		var current_charge: int = action_interceptor_processor.get_shadowed_action_values("status_charge_amount", 1)
		if current_charge > 0:
			var rng: RandomNumberGenerator = Global.player_data.get_player_rng("rng_artifacts")
			var artifact_datas: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_packet_sniffer")
			if artifact_datas.size() > 0 and rng.randf() < 0.5:
				var artifact_data: ArtifactData = artifact_datas[0]
				var draw_action: Array[Dictionary] = [{
					Scripts.ACTION_DRAW_GENERATOR: {
						"draw_count": 1,
					},
				}]
				var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], draw_action, null)
				ActionHandler.add_actions(generated_actions)
				Signals.artifact_proc.emit(artifact_data)
				
	return ACTION_ACCEPTENCES.CONTINUE
