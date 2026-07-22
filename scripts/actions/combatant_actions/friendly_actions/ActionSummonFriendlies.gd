## Summons one or more player-side combatants into configured friendly slots.
extends BaseAction
class_name ActionSummonFriendlies

func perform_action() -> void:
	if not Global.is_player_in_combat():
		return
	for processor: ActionInterceptorProcessor in _intercept_action([]):
		var friendly_ids: Array[String] = []
		friendly_ids.assign(processor.get_shadowed_action_values("friendly_object_ids", []))
		var spawn_slots: Array[int] = []
		spawn_slots.assign(processor.get_shadowed_action_values("spawn_slots", []))
		if friendly_ids.is_empty() or spawn_slots.is_empty():
			DebugLogger.log_error("ActionSummonFriendlies: Friendly IDs and formation slots are required")
			continue
		var seen_slots: Dictionary[int, bool] = {}
		var slots_are_valid: bool = true
		for slot_id: int in spawn_slots:
			if not CombatFormation.is_valid_friendly_slot_id(slot_id) or slot_id == CombatFormation.PLAYER_SLOT_ID:
				DebugLogger.log_error("ActionSummonFriendlies: Invalid friendly slot %d" % slot_id)
				slots_are_valid = false
				break
			if seen_slots.has(slot_id):
				DebugLogger.log_error("ActionSummonFriendlies: Friendly slot %d is listed more than once" % slot_id)
				slots_are_valid = false
				break
			seen_slots[slot_id] = true
		if not slots_are_valid:
			continue
		var ids_are_valid: bool = true
		for friendly_id: String in friendly_ids:
			if Global.get_friendly_data(friendly_id) != null:
				continue
			DebugLogger.log_error("ActionSummonFriendlies: Undefined friendly %s" % friendly_id)
			ids_are_valid = false
			break
		if not ids_are_valid:
			continue

		var spawn_count: int = maxi(processor.get_shadowed_action_values("number_of_spawns", spawn_slots.size()), 0)
		if spawn_count > spawn_slots.size():
			DebugLogger.log_error(
				"ActionSummonFriendlies: Requested %d summons but only %d slots were provided"
				% [spawn_count, spawn_slots.size()]
			)
			continue
		if friendly_ids.size() > 1 and friendly_ids.size() != spawn_count:
			DebugLogger.log_error(
				"ActionSummonFriendlies: Multiple friendly IDs must match the requested summon count"
			)
			continue
		var fulfilled_count: int = 0
		for index: int in spawn_count:
			# A single prototype may populate several slots; multiple prototypes pair
			# one-to-one with the declared summon count.
			var friendly_id: String = friendly_ids[0] if friendly_ids.size() == 1 else friendly_ids[index]
			var slot_id: int = spawn_slots[index]
			var request := FriendlySpawnRequest.new(friendly_id, slot_id)
			Signals.friendly_spawn_requested.emit(request)
			if request.spawned_friendly != null:
				fulfilled_count += 1
		if fulfilled_count < spawn_count:
			DebugLogger.log_warning(
				"ActionSummonFriendlies: Fulfilled %d of %d requested summons" % [fulfilled_count, spawn_count]
			)

func _to_string() -> String:
	return "Summon Friendlies Action"
