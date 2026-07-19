# This action does not do damage itself, rather it generates damaging actions which are placed immediately after on the stack
# Use this action instead of just invoking an AttackDamage action
extends BaseAction
class_name ActionAttackGenerator

func is_instant_action() -> bool:
	return true

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	
	for action_interceptor_processor in action_interceptor_processors:
		# animation
		# single will just play once for all attacks
		# per attack will play for every ActionAttack 
		# single and per attack should be defined mutually exclusively
		var attack_animation_name: String = action_interceptor_processor.get_shadowed_action_values("attack_animation_name", AnimationData.ANIMATION_ATTACK)
		var per_attack_animation_name: String = action_interceptor_processor.get_shadowed_action_values("per_attack_animation_name", AnimationData.ANIMATION_NONE)
		# applies a per hit impact animation on each enemy. Can be empty
		var impact_vfx_animation_id: String = action_interceptor_processor.get_shadowed_action_values("impact_vfx_animation_id", "")
		
		var damage: int = action_interceptor_processor.get_shadowed_action_values("damage", 0)
		var additional_damage: int = action_interceptor_processor.get_shadowed_action_values("additional_damage", 0)
		damage += additional_damage
		var delay: float = action_interceptor_processor.get_shadowed_action_values("time_delay", 0.25)
		var number_of_attacks: int = action_interceptor_processor.get_shadowed_action_values("number_of_attacks", 1)
		var merge_attacks: bool = action_interceptor_processor.get_shadowed_action_values("merge_attacks", false)	# this will take all attacks and merge them into a single attack with combined damage
		var target_override: int = action_interceptor_processor.get_shadowed_action_values("target_override", BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS)
		var audio_paths: Array[String] = []
		audio_paths.assign(action_interceptor_processor.get_shadowed_action_values("audio_path", []))
		
		var actions_on_lethal: Array[Dictionary] = []
		actions_on_lethal.assign(action_interceptor_processor.get_shadowed_action_values("actions_on_lethal", []))
		
		# generate a random number to add to damage if it exists
		var damage_random: int = action_interceptor_processor.get_shadowed_action_values("damage_random", 0)
		if damage_random > 1:
			var rng_damage_name: String = get_action_value("rng_damage_name", "rng_damage")
			var rng_damage: RandomNumberGenerator = Global.player_data.get_player_rng(rng_damage_name)
			var random_damage_amount: int = rng_damage.randi_range(0, damage_random)
			# add the random damage to the base damage
			damage += random_damage_amount
		
		if merge_attacks:
			damage = number_of_attacks * damage
			number_of_attacks = 1
		
		ActionHandler.add_actions(create_hit_actions(
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

static func create_hit_actions(
	attacker: BaseCombatant,
	request: CardPlayRequest,
	targets: Array[BaseCombatant],
	parent_action: BaseAction,
	damage: int,
	delay: float,
	number_of_attacks: int,
	target_override: int,
	actions_on_lethal: Array[Dictionary],
	audio_paths: Array[String],
	attack_animation_name: String,
	per_attack_animation_name: String,
	impact_vfx_animation_id: String,
) -> Array[BaseAction]:
	var hit_actions: Array[BaseAction] = []
	for attack_index: int in number_of_attacks:
		var hit_animation_name: String = AnimationData.ANIMATION_NONE
		if per_attack_animation_name != AnimationData.ANIMATION_NONE:
			hit_animation_name = per_attack_animation_name
		elif attack_index == 0:
			hit_animation_name = attack_animation_name
		var action_data: Array[Dictionary] = [{Scripts.ACTION_ATTACK: {
			"damage": damage,
			"time_delay": delay,
			"target_override": target_override,
			"actions_on_lethal": actions_on_lethal,
			"audio_path": audio_paths,
			"attack_animation_name": hit_animation_name,
			"impact_vfx_animation_id": impact_vfx_animation_id,
		}}]
		hit_actions.append_array(ActionGenerator.create_actions(
			attacker,
			request,
			targets,
			action_data,
			parent_action,
		))
	return hit_actions

func _to_string():
	var damage: int = get_action_value("damage", 0)
	var number_of_attacks: int = get_action_value("number_of_attacks", 0)
	return "Attack Generator Action: " + str(damage) + " x " + str(number_of_attacks)
