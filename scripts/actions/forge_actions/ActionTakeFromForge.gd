## Takes all (or selected) action entries from the forge and creates a fusion card added to hand.
## Values:
##   clear_all: bool (default true) - if true, clears the entire forge after taking
##   clear_indices: Array[int] (default []) - if clear_all is false, only remove entries at these indices
extends BaseAction

func perform_action() -> void:
	var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
	if forge_actions.is_empty():
		return

	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var clear_all: bool = action_interceptor_processor.get_shadowed_action_values("clear_all", true)
		var clear_indices: Array = action_interceptor_processor.get_shadowed_action_values("clear_indices", [])

		# Determine which entries to consume
		var consumed_entries: Array = []
		if clear_all:
			consumed_entries = forge_actions.duplicate(true)
		else:
			for idx in clear_indices:
				if idx >= 0 and idx < forge_actions.size():
					consumed_entries.append(forge_actions[idx])

		if consumed_entries.is_empty():
			return

		# Build card_play_actions and compute total cost
		var card_play_actions: Array[Dictionary] = []
		var total_cost: int = 0
		var has_attack: bool = false

		for entry in consumed_entries:
			var action_data: Dictionary = entry.get("action_data", {})
			var cost: int = entry.get("cost", 0)
			card_play_actions.append(action_data)
			total_cost += cost

			# Check if any action is an attack (needs target)
			if action_data.has(Scripts.ACTION_ATTACK) or action_data.has(Scripts.ACTION_ATTACK_GENERATOR):
				has_attack = true

		# Check if hand is full. If full, skip card generation but still clear the forge.
		if len(HandManager.player_hand) < HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX:
			# Create the fusion card
			var fusion_card: CardData = CardData.new("card_forge_fusion")
			fusion_card.card_name = "融合编译"
			fusion_card.card_description = "很神秘，暂不显示"
			fusion_card.card_texture_path = "sprites/cards/card_forge_compile.png"
			fusion_card.card_color_id = "color_white"
			fusion_card.card_energy_cost = max(0, total_cost)
			fusion_card.card_type = CardData.CARD_TYPES.ATTACK if has_attack else CardData.CARD_TYPES.SKILL
			fusion_card.card_rarity = CardData.CARD_RARITIES.GENERATED
			fusion_card.card_requires_target = has_attack
			fusion_card.card_play_destination = HandManager.BANISH_PILE
			# Reverse to ensure FIFO execution (since ActionHandler pushes to stack)
			card_play_actions.reverse()
			fusion_card.card_play_actions = card_play_actions

			# Add to hand
			HandManager.add_cards_to_hand([fusion_card], HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX)

		# Clear forge entries
		if clear_all:
			Global.player_data.player_values["forge_actions"] = []
		else:
			# Remove indices from highest to lowest to avoid shifting
			var sorted_indices: Array = clear_indices.duplicate()
			sorted_indices.sort()
			sorted_indices.reverse()
			for idx in sorted_indices:
				if idx >= 0 and idx < forge_actions.size():
					forge_actions.remove_at(idx)
			Global.player_data.player_values["forge_actions"] = forge_actions

		Signals.forge_actions_changed.emit()

func _to_string():
	return "Action Take From Forge"
