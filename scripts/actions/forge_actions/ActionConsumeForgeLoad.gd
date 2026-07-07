extends BaseAction
class_name ActionConsumeForgeLoad

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var load_amount: int = action_interceptor_processor.get_shadowed_action_values("load_amount", 0)

		if load_amount <= 0:
			continue

		var player: BaseCombatant = Global.get_player()
		if player != null:
			var current_charge: int = player.get_status_charges("status_effect_turn_forge_load")
			if current_charge > 0:
				var to_remove: int = min(current_charge, load_amount)
				player.add_status_effect_charges("status_effect_turn_forge_load", -to_remove)

func _to_string():
	return "Action Consume Forge Load"
