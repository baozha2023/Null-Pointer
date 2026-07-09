## Takes all (or selected) action entries from the forge and creates a fusion card added to hand or executes them directly.
extends BaseAction

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for action_interceptor_processor in action_interceptor_processors:
		var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
		var fallback_action_data = action_interceptor_processor.get_shadowed_action_values("fallback_action_data", [])
		
		# If forge is empty, try to execute fallback action
		if forge_actions.is_empty():
			if typeof(fallback_action_data) == TYPE_DICTIONARY and not fallback_action_data.is_empty():
				fallback_action_data = [fallback_action_data]
			if typeof(fallback_action_data) == TYPE_ARRAY and not fallback_action_data.is_empty():
				var fallback_typed: Array[Dictionary] = []
				for f in fallback_action_data:
					fallback_typed.append(f)
				var initiator: BaseCombatant = parent_combatant
				var actions: Array[BaseAction] = ActionGenerator.create_actions(initiator, card_play_request, get_adjusted_action_targets(), fallback_typed, self)
				ActionHandler.add_actions(actions)
			continue

		var take_type: int = action_interceptor_processor.get_shadowed_action_values("take_type", -1)
		var clear_after_take: bool = action_interceptor_processor.get_shadowed_action_values("clear_after_take", true)
		var execute_directly: bool = action_interceptor_processor.get_shadowed_action_values("execute_directly", false)
		var override_load: int = action_interceptor_processor.get_shadowed_action_values("override_load", -1)

		# Step A: Extract actions
		var taken_actions: Array = []
		if take_type == 0:
			taken_actions.append(forge_actions[0])
		elif take_type == 1:
			taken_actions.append(forge_actions[-1])
		else:
			taken_actions = forge_actions.duplicate()

		# Calculate extracted load
		var extracted_load: int = 0
		for entry in taken_actions:
			extracted_load += entry.get("load", 0)

		# Step B: Determine total_load for cost
		var total_load: int = extracted_load
		if override_load >= 0:
			total_load = override_load

		# Step C: Precise clear
		if clear_after_take:
			if take_type == 0:
				forge_actions.remove_at(0)
			elif take_type == 1:
				forge_actions.remove_at(forge_actions.size() - 1)
			else:
				forge_actions.clear()
			
			Global.player_data.player_values["forge_actions"] = forge_actions
			
			var artifacts: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge")
			if not artifacts.is_empty():
				var new_counter = max(0, artifacts[0].artifact_counter - extracted_load)
				artifacts[0].set_artifact_counter(new_counter)
			Signals.forge_actions_changed.emit()

		# Build card_play_actions
		var card_play_actions: Array[Dictionary] = []
		var has_attack: bool = false
		var requires_target: bool = false
		for entry in taken_actions:
			var action_data: Dictionary = entry.get("action_data", {})
			card_play_actions.append(action_data)
			for action_id in action_data.keys():
				if action_id in ActionTypeGroups.ATTACK_ACTIONS:
					has_attack = true
				if action_id in ActionTypeGroups.REQUIRES_TARGET_ACTIONS:
					var override = action_data[action_id].get("target_override", -1)
					if override != BaseAction.TARGET_OVERRIDES.PLAYER and override != BaseAction.TARGET_OVERRIDES.ALL_ENEMIES and override != BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY and override != BaseAction.TARGET_OVERRIDES.RANDOM_COMBATANT and override != BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS and override != BaseAction.TARGET_OVERRIDES.PARENT:
						requires_target = true

		# Calculate final_cost based on total_load
		var final_cost: int = 0
		if total_load <= 2:
			final_cost = 0
		elif total_load <= 5:
			final_cost = 1
		elif total_load <= 8:
			final_cost = 2
		elif total_load <= 12:
			final_cost = 3
		else:
			final_cost = 4

		# Execution Logic
		if execute_directly:
			Global.player_data.player_energy = max(0, Global.player_data.player_energy - final_cost)
			Signals.energy_changed.emit()
			
			var initiator: BaseCombatant = parent_combatant
			# Reverse to ensure FIFO execution (since ActionHandler pushes to stack)
			card_play_actions.reverse()
			card_play_actions.append({Scripts.ACTION_PLAY_SOUND: {"audio_path": AudioConstants.SFX_GROUP_FORGE_FUSION}})
			var actions: Array[BaseAction] = ActionGenerator.create_actions(initiator, card_play_request, get_adjusted_action_targets(), card_play_actions, self)
			ActionHandler.add_actions(actions)
		else:
			# Check if hand is full. If full, skip card generation
			if len(HandManager.player_hand) < HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX:
				var fusion_card: CardData = CardData.new("card_forge_fusion")
				fusion_card.card_name = "融合"
				fusion_card.card_description = "释放锻造台中的指定代码，并按顺序依次执行这些指令。 [color=gray]此卡牌仅在战斗中通过特定的锻造机制动态生成。[/color]"
				fusion_card.card_texture_path = "sprites/card/white/card_forge_compile.png"
				fusion_card.card_color_id = "color_white"
				fusion_card.card_energy_cost = final_cost
				fusion_card.card_type = CardData.CARD_TYPES.ATTACK if has_attack else CardData.CARD_TYPES.SKILL
				fusion_card.card_rarity = CardData.CARD_RARITIES.GENERATED
				fusion_card.card_requires_target = requires_target
				fusion_card.card_play_destination = HandManager.BANISH_PILE
				fusion_card.card_end_of_turn_destination = HandManager.BANISH_PILE
				fusion_card.card_hint = TextParser.parse_forge_actions_to_text(taken_actions)
				
				# Reverse to ensure FIFO execution
				card_play_actions.reverse()
				card_play_actions.append({Scripts.ACTION_PLAY_SOUND: {"audio_path": AudioConstants.SFX_GROUP_FORGE_FUSION}})
				fusion_card.card_play_actions = card_play_actions

				HandManager.add_cards_to_hand([fusion_card], HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX)

func _to_string():
	return "Action Take From Forge"
