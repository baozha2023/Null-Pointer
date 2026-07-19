## Owns the five-slot 2.5D enemy formation, spawning, and summon previews.
extends Control
class_name EnemyContainer

@onready var enemy_slots: Control = %EnemySlots
@onready var enemy_layer: Control = %EnemyLayer

var slot_id_to_slot: Dictionary[int, CombatEnemySlot] = {}

func _ready() -> void:
	_build_slot_cache()
	resized.connect(_on_resized)
	Signals.run_ended.connect(_on_run_ended)
	Signals.enemy_spawn_requested.connect(_on_enemy_spawn_requested)
	Signals.enemy_intent_changed.connect(_on_enemy_intent_changed)
	Signals.enemy_killed.connect(_on_enemy_killed)
	Signals.enemy_death_animation_finished.connect(_on_enemy_death_animation_finished)
	call_deferred("_on_resized")

func _build_slot_cache() -> void:
	slot_id_to_slot.clear()
	for child: Node in enemy_slots.get_children():
		assert(child is CombatEnemySlot, "EnemySlots may only contain CombatEnemySlot nodes")
		var slot: CombatEnemySlot = child as CombatEnemySlot
		var slot_id: int = slot.get_slot_id()
		assert(CombatFormation.is_valid_slot_id(slot_id), "Invalid combat slot id %d" % slot_id)
		assert(not slot_id_to_slot.has(slot_id), "Duplicate combat slot id %d" % slot_id)
		slot_id_to_slot[slot_id] = slot
	assert(slot_id_to_slot.size() == CombatFormation.SLOT_COUNT, "Combat must define exactly five enemy slots")

func populate_enemies_from_event(event_data: EventData = Global.get_player_event_data()) -> void:
	clear_enemies()
	var enemy_count: int = event_data.event_weighted_enemy_object_ids.size()
	var slot_ids: Array[int] = []
	if event_data.event_enemy_slot_ids.is_empty():
		slot_ids = CombatFormation.get_auto_slot_ids(enemy_count)
		if slot_ids.is_empty():
			DebugLogger.log_error("EnemyContainer: No automatic formation supports {0} enemies in event {1}".format([enemy_count, event_data.object_id]))
			return
	else:
		slot_ids.assign(event_data.event_enemy_slot_ids)
		if not _validate_explicit_slots(slot_ids, enemy_count, event_data.object_id):
			return

	for enemy_index: int in enemy_count:
		var enemy_weights: Dictionary = event_data.event_weighted_enemy_object_ids[enemy_index]
		var weights: Dictionary[Variant, int] = {}
		weights.assign(enemy_weights)
		var rng_enemy_spawning: RandomNumberGenerator = Global.player_data.get_player_rng("rng_enemy_spawning")
		var enemy_object_id: String = Random.get_weighted_selection(rng_enemy_spawning, weights)
		spawn_enemy_at_slot(enemy_object_id, slot_ids[enemy_index])

	call_deferred("refresh_summon_previews")

func _validate_explicit_slots(slot_ids: Array[int], enemy_count: int, event_id: String) -> bool:
	if slot_ids.size() != enemy_count:
		DebugLogger.log_error("EnemyContainer: Event {0} defines {1} enemies but {2} initial slots".format([event_id, enemy_count, slot_ids.size()]))
		return false
	var seen_slots: Dictionary[int, bool] = {}
	for slot_id: int in slot_ids:
		if not slot_id_to_slot.has(slot_id):
			DebugLogger.log_error("EnemyContainer: Event {0} references invalid slot {1}".format([event_id, slot_id]))
			return false
		if seen_slots.has(slot_id):
			DebugLogger.log_error("EnemyContainer: Event {0} references slot {1} more than once".format([event_id, slot_id]))
			return false
		seen_slots[slot_id] = true
	return true

func _spawn_enemy(enemy_object_id: String, slot_id: int, is_minion: bool = false) -> Enemy:
	var slot: CombatEnemySlot = slot_id_to_slot.get(slot_id)
	if slot == null:
		DebugLogger.log_error("EnemyContainer: Cannot spawn enemy in undefined slot {0}".format([slot_id]))
		return null
	if Global.get_enemy_data(enemy_object_id) == null:
		DebugLogger.log_error("EnemyContainer: Cannot spawn undefined enemy {0}".format([enemy_object_id]))
		return null
	var enemy: Enemy = Scenes.ENEMY.instantiate()
	var enemy_data: EnemyData = Global.get_enemy_data_from_prototype(enemy_object_id)
	if is_minion:
		enemy_data.enemy_is_minion = true
	enemy_data.apply_enemy_difficulty_modifiers()
	enemy_data.randomize_health(true)
	enemy_layer.add_child(enemy)
	enemy.init(enemy_data)
	enemy.apply_formation_slot(slot)
	return enemy

func spawn_enemy_at_slot(enemy_object_id: String, slot_id: int, is_minion: bool = false) -> Enemy:
	var existing_enemy: Enemy = get_enemy_in_slot(slot_id)
	if existing_enemy != null:
		if existing_enemy.is_alive():
			DebugLogger.log_error("EnemyContainer: Attempted to spawn into occupied slot {0}".format([slot_id]))
			return null
		_detach_and_queue_free_enemy(existing_enemy)
	var enemy: Enemy = _spawn_enemy(enemy_object_id, slot_id, is_minion)
	call_deferred("refresh_summon_previews")
	return enemy

func get_enemy_in_slot(slot_id: int) -> Enemy:
	for enemy: Enemy in Global.get_all_enemies_in_formation_order():
		if enemy.enemy_slot_id != slot_id:
			continue
		return enemy
	return null

func refresh_summon_previews() -> void:
	for slot: CombatEnemySlot in slot_id_to_slot.values():
		slot.set_summon_preview(false)
	var preview_reserved_slots: Dictionary[int, bool] = {}
	for enemy: Enemy in Global.get_alive_enemies_in_formation_order():
		var intent: EnemyIntentData = enemy.enemy_data.get_current_intent()
		if intent == null:
			continue
		for custom_action: Dictionary in intent.enemy_intent_custom_actions:
			if not custom_action.has(Scripts.ACTION_SUMMON_ENEMIES):
				continue
			var action_values: Dictionary = custom_action[Scripts.ACTION_SUMMON_ENEMIES]
			var spawn_count: int = CombatFormation.get_summon_count(action_values)
			var spawn_slots: Array[int] = CombatFormation.get_summon_slot_ids(action_values)
			var previews_added: int = 0
			for slot_id: int in spawn_slots:
				if previews_added >= spawn_count:
					break
				if preview_reserved_slots.has(slot_id):
					continue
				var occupying_enemy: Enemy = get_enemy_in_slot(slot_id)
				if occupying_enemy != null and occupying_enemy.is_alive():
					continue
				slot_id_to_slot[slot_id].set_summon_preview(true)
				preview_reserved_slots[slot_id] = true
				previews_added += 1

func clear_enemies() -> void:
	for enemy: Enemy in enemy_layer.get_children():
		_detach_and_queue_free_enemy(enemy)
	for slot: CombatEnemySlot in slot_id_to_slot.values():
		slot.set_summon_preview(false)

func _detach_and_queue_free_enemy(enemy: Enemy) -> void:
	assert(enemy.get_parent() == enemy_layer, "Enemy must belong to this formation's EnemyLayer")
	enemy_layer.remove_child(enemy)
	enemy.queue_free()

func _on_resized() -> void:
	for enemy: Enemy in enemy_layer.get_children():
		var slot: CombatEnemySlot = slot_id_to_slot.get(enemy.enemy_slot_id)
		if slot != null:
			enemy.apply_formation_slot(slot)

func _on_enemy_spawn_requested(request: EnemySpawnRequest) -> void:
	request.spawned_enemy = spawn_enemy_at_slot(
		request.enemy_object_id,
		request.slot_id,
		request.is_minion,
	)

func _on_enemy_intent_changed() -> void:
	call_deferred("refresh_summon_previews")

func _on_enemy_killed(_enemy: Enemy) -> void:
	call_deferred("refresh_summon_previews")

func _on_enemy_death_animation_finished(_enemy: Enemy) -> void:
	call_deferred("refresh_summon_previews")

func _on_run_ended() -> void:
	clear_enemies()
