extends BaseAction
class_name ActionTimeAttackGenerator

enum TIME_EXTRACTION_MODES {
	ONES_DIGIT,
	TOTAL_SECONDS,
	TOTAL_MINUTES,
}

func is_instant_action() -> bool:
	return true

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		# animation
		var attack_animation_name: String = action_interceptor_processor.get_shadowed_action_values("attack_animation_name", AnimationData.ANIMATION_ATTACK)
		var per_attack_animation_name: String = action_interceptor_processor.get_shadowed_action_values("per_attack_animation_name", AnimationData.ANIMATION_NONE)
		var impact_vfx_animation_id: String = action_interceptor_processor.get_shadowed_action_values("impact_vfx_animation_id", "")
		
		# --- TIME BASED DAMAGE LOGIC START ---
		var locked_run_time: float = 0.0
		if card_play_request != null:
			locked_run_time = card_play_request.card_values.get("locked_run_time", 0.0)
			
		var time_extraction_mode: int = action_interceptor_processor.get_shadowed_action_values("time_extraction_mode", TIME_EXTRACTION_MODES.ONES_DIGIT)
		var time_multiplier: int = action_interceptor_processor.get_shadowed_action_values("time_multiplier", 1)
		
		var extracted_time_value: int = 0
		match time_extraction_mode:
			TIME_EXTRACTION_MODES.ONES_DIGIT:
				extracted_time_value = int(locked_run_time) % 10
			TIME_EXTRACTION_MODES.TOTAL_SECONDS:
				extracted_time_value = int(locked_run_time)
			TIME_EXTRACTION_MODES.TOTAL_MINUTES:
				extracted_time_value = int(locked_run_time) / 60
			_:
				DebugLogger.log_error("ActionTimeAttackGenerator: Unsupported time_extraction_mode {0}".format([time_extraction_mode]))
				continue
			
		var damage: int = extracted_time_value * time_multiplier
		# --- TIME BASED DAMAGE LOGIC END ---
		
		var additional_damage: int = action_interceptor_processor.get_shadowed_action_values("additional_damage", 0)
		damage += additional_damage
		var delay: float = action_interceptor_processor.get_shadowed_action_values("time_delay", 0.25)
		var number_of_attacks: int = action_interceptor_processor.get_shadowed_action_values("number_of_attacks", 1)
		var merge_attacks: bool = action_interceptor_processor.get_shadowed_action_values("merge_attacks", false)
		var target_override: int = action_interceptor_processor.get_shadowed_action_values("target_override", BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS)
		var audio_paths: Array[String] = []
		audio_paths.assign(action_interceptor_processor.get_shadowed_action_values("audio_path", []))
		
		var actions_on_lethal: Array[Dictionary] = []
		actions_on_lethal.assign(action_interceptor_processor.get_shadowed_action_values("actions_on_lethal", []))
		
		var damage_random: int = action_interceptor_processor.get_shadowed_action_values("damage_random", 0)
		if damage_random > 1:
			var rng_damage_name: String = get_action_value("rng_damage_name", "rng_damage")
			var rng_damage: RandomNumberGenerator = Global.player_data.get_player_rng(rng_damage_name)
			var random_damage_amount: int = rng_damage.randi_range(0, damage_random)
			damage += random_damage_amount
		
		if merge_attacks:
			damage = number_of_attacks * damage
			number_of_attacks = 1
		
		ActionHandler.add_actions(ActionAttackGenerator.create_hit_actions(
			parent_combatant,
			card_play_request,
			targets,
			self,
			damage,
			delay,
			number_of_attacks,
			target_override,
			actions_on_lethal,
			audio_paths,
			attack_animation_name,
			per_attack_animation_name,
			impact_vfx_animation_id,
		))

func _to_string():
	var multiplier: int = get_action_value("time_multiplier", 1)
	return "Time Attack Generator Action: time_value x " + str(multiplier)
