## Typed request/response payload for spawning one enemy into a combat slot.
extends RefCounted
class_name EnemySpawnRequest

var enemy_object_id: String
var slot_id: int
var is_minion: bool
var spawned_enemy: Enemy = null

func _init(
	_enemy_object_id: String,
	_slot_id: int,
	_is_minion: bool,
) -> void:
	enemy_object_id = _enemy_object_id
	slot_id = _slot_id
	is_minion = _is_minion
