## Typed request/response payload for spawning a friendly into a combat slot.
extends RefCounted
class_name FriendlySpawnRequest

var friendly_object_id: String
var slot_id: int
var spawned_friendly: Friendly = null

func _init(_friendly_object_id: String, _slot_id: int) -> void:
	friendly_object_id = _friendly_object_id
	slot_id = _slot_id
