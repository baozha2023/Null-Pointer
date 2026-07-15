## Invisible technical status used by the Mycelial Network power.
## Each charge is the amount of Overshield gained whenever a card is exhausted.
extends BaseStatusEffect
class_name StatusEffectMycelialNetwork

const WASTE_CARD_OBJECT_ID: String = "card_waste"
const OVERSHIELD_STATUS_EFFECT_ID: String = "status_effect_overshield"

func _connect_signals() -> void:
	Signals.card_exhausted.connect(_on_card_exhausted)

func _on_card_exhausted(card_data: CardData) -> void:
	if not is_instance_valid(parent_combatant) or not parent_combatant.is_alive():
		return
	if not parent_combatant.is_in_group("players"):
		return

	var action_data: Array[Dictionary] = []
	if card_data.object_id == WASTE_CARD_OBJECT_ID:
		action_data.append({Scripts.ACTION_DRAW_GENERATOR: {"draw_count": 1}})
	action_data.append({
		Scripts.ACTION_APPLY_STATUS: {
			"status_effect_object_id": OVERSHIELD_STATUS_EFFECT_ID,
			"status_charge_amount": status_charges,
			"target_override": BaseAction.TARGET_OVERRIDES.PARENT,
		}
	})

	var card_play_request: CardPlayRequest = _generate_status_effect_card_play_request()
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(parent_combatant, card_play_request, [parent_combatant], action_data, null)
	ActionHandler.add_actions(generated_actions)
