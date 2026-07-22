## Owns the three-slot player-side formation and summoned friendly lifecycle.
extends Control
class_name FriendlyContainer

@onready var friendly_slots: Control = %FriendlySlots
@onready var friendly_layer: Control = %FriendlyLayer
@onready var player: Player = %Player

var slot_id_to_slot: Dictionary[int, CombatFriendlySlot] = {}

func _ready() -> void:
	_build_slot_cache()
	player.apply_player_formation_slot(slot_id_to_slot[CombatFormation.PLAYER_SLOT_ID])
	Signals.friendly_spawn_requested.connect(_on_friendly_spawn_requested)
	Signals.run_ended.connect(_on_run_ended)
	Signals.combat_ended.connect(clear_summoned_friendlies)
	resized.connect(_on_resized)
	call_deferred("_on_resized")

func _build_slot_cache() -> void:
	slot_id_to_slot.clear()
	for child: Node in friendly_slots.get_children():
		assert(child is CombatFriendlySlot, "FriendlySlots may only contain CombatFriendlySlot nodes")
		var slot := child as CombatFriendlySlot
		assert(CombatFormation.is_valid_friendly_slot_id(slot.slot_id), "Invalid friendly slot")
		assert(not slot_id_to_slot.has(slot.slot_id), "Duplicate friendly slot")
		slot_id_to_slot[slot.slot_id] = slot
	assert(slot_id_to_slot.size() == CombatFormation.FRIENDLY_SLOT_COUNT, "Combat must define exactly three friendly slots")

func spawn_friendly_at_slot(friendly_object_id: String, slot_id: int) -> Friendly:
	if not slot_id_to_slot.has(slot_id):
		DebugLogger.log_error("FriendlyContainer: Undefined friendly slot %d" % slot_id)
		return null
	if slot_id == CombatFormation.PLAYER_SLOT_ID:
		DebugLogger.log_error("FriendlyContainer: The player slot cannot be replaced")
		return null
	var existing: BaseCombatant = get_combatant_in_slot(slot_id)
	if existing != null:
		if not existing is Friendly:
			DebugLogger.log_error("FriendlyContainer: Slot %d is occupied" % slot_id)
			return null
		var existing_friendly := existing as Friendly
		if existing_friendly.is_alive() or existing_friendly.friendly_data.friendly_can_revive_in_combat:
			if existing_friendly.friendly_data.object_id == friendly_object_id:
				return existing_friendly
			DebugLogger.log_error("FriendlyContainer: Slot %d is occupied" % slot_id)
			return null
		# Non-revivable dead entities release their slot synchronously. queue_free()
		# alone would leave them discoverable until the end of the frame.
		_detach_and_queue_free_friendly(existing_friendly)
	var prototype: FriendlyData = Global.get_friendly_data_from_prototype(friendly_object_id)
	if prototype == null:
		DebugLogger.log_error("FriendlyContainer: Undefined friendly %s" % friendly_object_id)
		return null
	var friendly: Friendly = Scenes.FRIENDLY.instantiate()
	friendly_layer.add_child(friendly)
	friendly.init(prototype)
	friendly.apply_friendly_formation_slot(slot_id_to_slot[slot_id])
	Signals.friendly_formation_changed.emit()
	return friendly

func get_combatant_in_slot(slot_id: int) -> BaseCombatant:
	for combatant: BaseCombatant in Global.get_all_friendlies_in_formation_order():
		if combatant.combatant_slot_id == slot_id:
			return combatant
	return null

func clear_summoned_friendlies() -> void:
	for child: Node in friendly_layer.get_children():
		if child is Friendly:
			_detach_and_queue_free_friendly(child as Friendly)
	Signals.friendly_formation_changed.emit()

func _detach_and_queue_free_friendly(friendly: Friendly) -> void:
	assert(friendly.get_parent() == friendly_layer, "Friendly must belong to FriendlyLayer")
	friendly_layer.remove_child(friendly)
	friendly.queue_free()

func _on_resized() -> void:
	player.apply_player_formation_slot(slot_id_to_slot[CombatFormation.PLAYER_SLOT_ID])
	for friendly: Friendly in Global.get_summoned_friendlies_in_formation_order(true):
		var slot: CombatFriendlySlot = slot_id_to_slot.get(friendly.combatant_slot_id)
		if slot != null:
			friendly.apply_friendly_formation_slot(slot)

func _on_friendly_spawn_requested(request: FriendlySpawnRequest) -> void:
	request.spawned_friendly = spawn_friendly_at_slot(request.friendly_object_id, request.slot_id)

func _on_run_ended() -> void:
	clear_summoned_friendlies()
