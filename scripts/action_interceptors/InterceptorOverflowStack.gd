extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	# Check if target is player
	if action_interceptor_processor.target != Global.get_player():
		return ACTION_ACCEPTENCES.CONTINUE
		
	var status_id: String = action_interceptor_processor.get_shadowed_action_values("status_effect_object_id", "")
	var status_data: StatusEffectData = Global.get_status_effect_data(status_id)
	
	if status_data and status_data.status_effect_type == StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF:
		var current_charge: int = action_interceptor_processor.get_shadowed_action_values("status_charge_amount", 1)
		if current_charge > 0:
			action_interceptor_processor.set_shadowed_action_values("status_charge_amount", current_charge + 1)
			if not preview_mode:
				var artifact_datas: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_overflow_stack")
				if artifact_datas.size() > 0:
					var artifact_data: ArtifactData = artifact_datas[0]
					Signals.artifact_proc.emit(artifact_data)
				
	return ACTION_ACCEPTENCES.CONTINUE
