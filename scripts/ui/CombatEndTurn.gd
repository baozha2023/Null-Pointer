# a utility object for Combat to allow asynchronous turn ending with hierarchical levels of end turn immediacy
# if a higher level of immediacy is detected in Combat a new object will be created, replacing the await
extends RefCounted
class_name CombatEndTurn

var _combat: Combat = null
enum END_TURN_QUEUE_IMMEDIACY {	# Do not rearrange
	WAIT_FOR_ALL_CARD_PLAYS,
	WAIT_FOR_ACTIONS,
	IMMEDIATE
	}
var end_turn_queue_immediacy: int = END_TURN_QUEUE_IMMEDIACY.WAIT_FOR_ALL_CARD_PLAYS

func _init(
	combat: Combat,
	_end_turn_queue_immediacy: int = END_TURN_QUEUE_IMMEDIACY.WAIT_FOR_ALL_CARD_PLAYS,
) -> void:
	_combat = combat
	end_turn_queue_immediacy = _end_turn_queue_immediacy

func wait() -> void:
	match end_turn_queue_immediacy:
		END_TURN_QUEUE_IMMEDIACY.IMMEDIATE:
			# forces the turn to instantly end, removing all remaining card plays and actions
			HandManager.refund_card_queue()
			ActionHandler.clear_all_actions()
			await _wait_for_actions_and_animations()
			end_turn()
		END_TURN_QUEUE_IMMEDIACY.WAIT_FOR_ACTIONS:
			# prevents further card plays but finishes the rest of the current action stack
			HandManager.refund_card_queue()
			HandManager.set_manual_combat_input_disabled(true)
			await _wait_for_actions_and_animations()
			end_turn()
		END_TURN_QUEUE_IMMEDIACY.WAIT_FOR_ALL_CARD_PLAYS, _:
			# default
			# continuously wait for all card plays to finish before ending the player's turn
			HandManager.set_manual_combat_input_disabled(true)
			var scene_tree: SceneTree = _combat.get_tree()
			while (
				len(HandManager.card_play_queue) > 0
				or HandManager.cards_being_played
				or ActionHandler.actions_being_performed
				or CombatPresentation.is_blocking()
			):
				await scene_tree.process_frame
			end_turn()

func _wait_for_actions_and_animations() -> void:
	if _combat == null:
		return
	while _combat != null and (
		ActionHandler.actions_being_performed
		or CombatPresentation.is_blocking()
	):
		await _combat.get_tree().process_frame

func disable() -> void:
	_combat = null

func end_turn() -> void:
	if _combat != null:
		_combat.end_turn_animation()
