## Shared world-tree status tooltip context. Gameplay configuration remains on
## the active season status, while every related status can display live values.
extends BaseStatusEffect
class_name StatusEffectWorldTreeBase

func get_tooltip_context() -> Dictionary:
	var context: Dictionary = super.get_tooltip_context()
	var config: Dictionary = _get_world_tree_config()
	if config.is_empty():
		return context

	var rings_status_id: String = config.get("world_tree_rings_status_id", "")
	var rings: int = parent_combatant.get_status_charges(rings_status_id)
	var season_configs: Dictionary = config.get("world_tree_season_configs", {})
	var spring: Dictionary = season_configs.get("status_effect_world_tree_spring", {})
	var summer: Dictionary = season_configs.get("status_effect_world_tree_summer", {})
	var autumn: Dictionary = season_configs.get("status_effect_world_tree_autumn", {})
	var winter: Dictionary = season_configs.get("status_effect_world_tree_winter", {})

	context["world_tree_growth_threshold"] = maxi(int(config.get("world_tree_growth_threshold", 6)), 1)
	context["world_tree_ring_amount"] = rings
	context["world_tree_rings_per_cycle"] = int(config.get("world_tree_rings_per_cycle", 0))
	context["world_tree_autumn_card_object_id"] = autumn.get("card_object_id", "")

	var rings_data: StatusEffectData = Global.get_status_effect_data(rings_status_id)
	context["world_tree_rings_max"] = rings_data.status_effect_charge_upper_bound if rings_data != null else 0

	context["world_tree_spring_per_ring"] = int(spring.get("per_ring", 0))
	context["world_tree_spring_value"] = int(spring.get("base", 0)) + rings * int(spring.get("per_ring", 0))
	context["world_tree_summer_per_ring"] = int(summer.get("per_ring", 0))
	context["world_tree_summer_value"] = int(summer.get("base", 0)) + rings * int(summer.get("per_ring", 0))
	var ring_interval: int = maxi(int(autumn.get("card_ring_interval", 1)), 1)
	var cards_per_interval: int = int(autumn.get("card_per_interval", 0))
	context["world_tree_autumn_ring_interval"] = ring_interval
	context["world_tree_autumn_card_per_interval"] = cards_per_interval
	context["world_tree_autumn_card_count"] = int(autumn.get("card_base", 0)) + rings / ring_interval * cards_per_interval
	context["world_tree_winter_per_ring"] = int(winter.get("per_ring", 0))
	context["world_tree_winter_value"] = int(winter.get("base", 0)) + rings * int(winter.get("per_ring", 0))

	return context

func _get_world_tree_config() -> Dictionary:
	var current_season: BaseStatusEffect = _get_current_world_tree_season()
	return current_season.status_custom_values if current_season != null else {}

func _get_current_world_tree_season() -> BaseStatusEffect:
	for status_effects_value: Variant in parent_combatant.status_id_to_status_effects.values():
		var status_effects: Array = status_effects_value
		for status_effect: StatusEffect in status_effects:
			var candidate: BaseStatusEffect = status_effect.status_effect_script
			if candidate != null and candidate.status_custom_values.has("world_tree_season_configs"):
				return candidate
	return null
