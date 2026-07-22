## Shared logical rules for enemy and friendly battlefield formations.
## Rendering metadata lives on the common CombatFormationSlot contract; gameplay
## depends only on slot ids, logical order, and deterministic initial formations.
extends RefCounted
class_name CombatFormation

const ENEMY_SLOT_COUNT: int = 5
const FRIENDLY_SLOT_COUNT: int = 3
const PLAYER_SLOT_ID: int = 1
const AUTO_FORMATIONS: Dictionary = {
	1: [0],
	2: [1, 2],
	3: [1, 0, 2],
	4: [1, 3, 4, 2],
	5: [1, 3, 0, 4, 2],
}

static func is_valid_enemy_slot_id(slot_id: int) -> bool:
	return slot_id >= 0 and slot_id < ENEMY_SLOT_COUNT

static func is_valid_friendly_slot_id(slot_id: int) -> bool:
	return slot_id >= 0 and slot_id < FRIENDLY_SLOT_COUNT

static func get_auto_slot_ids(enemy_count: int) -> Array[int]:
	var slot_ids: Array[int] = []
	if AUTO_FORMATIONS.has(enemy_count):
		slot_ids.assign(AUTO_FORMATIONS[enemy_count])
	return slot_ids

static func get_summon_count(action_values: Dictionary) -> int:
	return maxi(int(action_values.get("number_of_spawns", 1)), 0)

static func get_summon_slot_ids(action_values: Dictionary) -> Array[int]:
	var configured_slot_ids: Array[int] = []
	configured_slot_ids.assign(action_values.get("spawn_slots", []))
	var valid_slot_ids: Array[int] = []
	for slot_id: int in configured_slot_ids:
		if not is_valid_enemy_slot_id(slot_id):
			DebugLogger.log_error("Summon action references invalid combat slot %d" % slot_id)
			return []
		if valid_slot_ids.has(slot_id):
			DebugLogger.log_error("Summon action references combat slot %d more than once" % slot_id)
			return []
		valid_slot_ids.append(slot_id)
	return valid_slot_ids
