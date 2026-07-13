extends BaseActionInterceptor
class_name InterceptorRootPrivilege

static func calculate_energy_shortfall(effective_cost: int, input_energy: int, refundable_energy: int) -> int:
	if refundable_energy == HandManager.CARD_NO_ENERGY_COST:
		return 0
	return max(0, effective_cost - max(0, input_energy))

static func calculate_overdraft_damage(shortfall: int, status_charges: int, secondary_charges: int) -> int:
	if shortfall <= 0:
		return 0
	return ceil(shortfall * float(secondary_charges) / float(max(1, status_charges)))

func process_action_interception(processor: ActionInterceptorProcessor, preview_mode: bool = false) -> int:
	if processor.parent_action == null or processor.parent_action.get_script().resource_path != Scripts.ACTION_CARD_PLAY:
		return ACTION_ACCEPTENCES.CONTINUE

	var card_play_request: CardPlayRequest = processor.parent_action.card_play_request
	if card_play_request == null or card_play_request.card_data == null:
		return ACTION_ACCEPTENCES.CONTINUE

	var card_data: CardData = card_play_request.card_data
	# Read the current shadow so higher-priority cost modifiers (for example, a free-card effect)
	# are respected before Root Privilege caps the payable amount.
	var effective_cost: int = processor.get_shadowed_action_values(
		"card_energy_cost",
		card_data.get_card_energy_cost(true, true)
	)

	if preview_mode:
		var current_energy: int = Global.player_data.player_energy
		# For UI/Preview: override the cost so the card appears playable
		if effective_cost > current_energy:
			processor.set_shadowed_action_values("card_energy_cost", current_energy)
			processor.set_shadowed_action_values("card_is_playable", true)
		return ACTION_ACCEPTENCES.CONTINUE

	# ONLY run the damage logic once per actual card play!
	# The global broadcast passes 'null' as the first target. We only react to that one to prevent duplicate damage.
	if processor.target != null:
		return ACTION_ACCEPTENCES.CONTINUE

	# Energy is reserved before the actual card-play interception. input_energy records the amount
	# paid at queue time, whereas Global.player_data.player_energy is already the post-payment value.
	var shortfall: int = calculate_energy_shortfall(
		effective_cost,
		card_play_request.input_energy,
		card_play_request.refundable_energy
	)
	if shortfall > 0:
		var parent_combatant: BaseCombatant = processor.parent_action.parent_combatant

		var status_charge_amount: int = 1
		var status_secondary_charges: int = 5
		if parent_combatant.status_id_to_status_effects.has("status_effect_root_privilege"):
			var statuses: Array = parent_combatant.status_id_to_status_effects["status_effect_root_privilege"]
			if statuses.size() > 0:
				var status_effect = statuses[0]
				status_charge_amount = max(1, status_effect.status_effect_script.status_charges)
				status_secondary_charges = status_effect.status_effect_script.status_secondary_charges

		var damage_amount: int = calculate_overdraft_damage(
			shortfall,
			status_charge_amount,
			status_secondary_charges
		)

		var damage_action: Dictionary = {
			Scripts.ACTION_DIRECT_DAMAGE: {
				"damage": damage_amount
			}
		}

		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, [parent_combatant], [damage_action], processor.parent_action)
		ActionHandler.add_actions(generated_actions, true) # insert immediately before card play finishes

	return ACTION_ACCEPTENCES.CONTINUE
