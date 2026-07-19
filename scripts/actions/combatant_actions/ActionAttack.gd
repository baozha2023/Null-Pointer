## An individual attack action created by ActionAttackGenerator
## These actions are what actually damage enemies.
## Can play a sound for each attack.
extends BaseAction

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	var attacker_animation_started: bool = false

	for action_interceptor_processor in action_interceptor_processors:
		var target: BaseCombatant = action_interceptor_processor.target
		if target == null:
			continue
		if not target.is_alive():
			continue

		# Every presentation belonging to this hit starts in the same frame. The
		# ActionHandler waits for the longest tracked presentation after the Action.
		var attack_animation_name: String = action_interceptor_processor.get_shadowed_action_values("attack_animation_name", AnimationData.ANIMATION_NONE)
		if not attacker_animation_started and parent_combatant != null and attack_animation_name != AnimationData.ANIMATION_NONE:
			parent_combatant.play_animation(attack_animation_name)
			attacker_animation_started = true

		var impact_vfx_animation_id: String = action_interceptor_processor.get_shadowed_action_values("impact_vfx_animation_id", "")
		if not impact_vfx_animation_id.is_empty():
			target.create_effect_animation(impact_vfx_animation_id)

		var audio_paths: Array[String] = []
		audio_paths.assign(action_interceptor_processor.get_shadowed_action_values("audio_path", []))
		if not audio_paths.is_empty():
			ActionGenerator.play_combat_sound(audio_paths, parent_combatant)
		
		# get damage parameters
		var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
		var bypass_block: bool = action_interceptor_processor.get_shadowed_action_values("bypass_block", false)
		
		# damage the target and return results 
		var damages: Array[int] = target.damage(damage, bypass_block)
		var unblocked_damage: int = damages[0]
		var unblocked_damage_capped: int = damages[1] # damage done that does not factor overkill
		var overkill_damage: int = damages[2] # damage done beyond killing target
		
		# store unblocked/overkill damage in the CardPlayRequest if it exists.
		# this will accumulate between *all* actions sharing the same CardPlayRequest, thus
		# allowing actions such as healing on damage dealt (unblocked_damage_capped), or
		# an action that provides block based on overkill_damage. These will require providing
		# custom_key_names into the subsequent actions.
		if card_play_request != null:
			var previous_unblocked_damage: int = get_action_value("unblocked_damage", 0)
			card_play_request.card_values["unblocked_damage"] = unblocked_damage + previous_unblocked_damage
			var previous_unblocked_damage_capped: int = get_action_value("unblocked_damage_capped", 0)
			card_play_request.card_values["unblocked_damage_capped"] = unblocked_damage_capped + previous_unblocked_damage_capped
			var previous_overkill_damage: int = get_action_value("overkill_damage", 0)
			card_play_request.card_values["overkill_damage"] = overkill_damage + previous_overkill_damage
		
		# target killed by attack, perform on-lethal actions if they exist
		if not target.is_alive():
			# apply actions on lethal
			var actions_on_lethal: Array[Dictionary] = []
			actions_on_lethal.assign(get_action_value("actions_on_lethal", []))
			if len(actions_on_lethal) > 0:
				var generated_on_lethal_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, [target], actions_on_lethal, self)
				ActionHandler.add_actions(generated_on_lethal_actions)

func is_action_short_circuited():
	return get_action_value("action_short_circuits", true)

func _to_string():
	var damage: int = get_action_value("damage", 0)
	return "Attack Action: " + str(damage)
