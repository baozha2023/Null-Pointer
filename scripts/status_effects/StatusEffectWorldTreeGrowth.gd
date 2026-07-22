## Converts growth charge thresholds into data-defined seasonal transitions.
extends StatusEffectWorldTreeBase
class_name StatusEffectWorldTreeGrowth

func set_status_charges(value: int) -> void:
	var season_custom_values: Dictionary = _get_world_tree_config()
	var threshold: int = maxi(int(season_custom_values.get("world_tree_growth_threshold", 6)), 1)
	status_charges = maxi(value, 0)
	var transition_actions: Array[BaseAction] = []
	while status_charges >= threshold:
		status_charges -= threshold
		transition_actions.append_array(_perform_season_transition())
	# ActionHandler is stack-based. Reverse once so multi-season effects resolve
	# in the same chronological order as their state transitions.
	transition_actions.reverse()
	ActionHandler.add_actions(transition_actions)

func _perform_season_transition() -> Array[BaseAction]:
	var current_season: BaseStatusEffect = _get_current_world_tree_season()
	if current_season == null:
		return []
	var season_custom_values: Dictionary = current_season.status_custom_values.duplicate(true)
	var season_configs: Dictionary = season_custom_values.get("world_tree_season_configs", {})
	var current_season_id: String = current_season.status_effect_data.object_id
	var config: Dictionary = season_configs.get(current_season_id, {})
	if config.is_empty():
		return []
	var next_status_id: String = config.get("next_status_id", "")
	if next_status_id.is_empty() or not season_configs.has(next_status_id):
		push_error("World Tree season '%s' has an invalid next_status_id." % current_season_id)
		return []
	var rings_status_id: String = season_custom_values.get("world_tree_rings_status_id", "")
	var rings: int = parent_combatant.get_status_charges(rings_status_id)
	var request: CardPlayRequest = _generate_status_effect_card_play_request()
	request.card_values["season_value"] = int(config.get("base", 0)) + rings * int(config.get("per_ring", 0))
	var card_ring_interval: int = maxi(int(config.get("card_ring_interval", 1)), 1)
	request.card_values["season_card_count"] = int(config.get("card_base", 0)) + rings / card_ring_interval * int(config.get("card_per_interval", 0))
	request.card_values["season_card_object_id"] = config.get("card_object_id", "")
	var actions_data: Array[Dictionary] = []
	actions_data.assign(config.get("action_data", []))
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, request, [parent_combatant], actions_data, null)
	# Normalize all season flags before applying the next one. This keeps the
	# four data statuses mutually exclusive even if mod data applied an invalid
	# combination before growth crossed its threshold.
	for season_id: String in season_configs:
		var season_charges: int = parent_combatant.get_status_charges(season_id)
		if season_charges != 0:
			parent_combatant.add_status_effect_charges(season_id, -season_charges)
	parent_combatant.add_new_status_effect(next_status_id, 1, 0, season_custom_values)
	# Ring state changes immediately so a single large growth gain can cross a
	# complete year and use the new ring for later transitions in the same batch.
	var cycle_start_status_id: String = season_custom_values.get("world_tree_cycle_start_status_id", "")
	if next_status_id == cycle_start_status_id and not rings_status_id.is_empty():
		parent_combatant.add_status_effect_charges(
			rings_status_id,
			int(season_custom_values.get("world_tree_rings_per_cycle", 0)),
		)
	return generated_actions
