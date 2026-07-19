## Summons random enemies in the requested formation slots.
## Uses the current combat's stable logical formation slots.
extends BaseAction

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action()
	
	for action_interceptor_processor in action_interceptor_processors:
		# number of spawns
		var number_of_spawns: int = maxi(
			action_interceptor_processor.get_shadowed_action_values("number_of_spawns", 1),
			0,
		)
		if number_of_spawns <= 0:
			continue
		# spawn slots that may be filled
		var summon_values: Dictionary = {
			"spawn_slots": action_interceptor_processor.get_shadowed_action_values("spawn_slots", []),
		}
		var spawn_slots: Array[int] = CombatFormation.get_summon_slot_ids(summon_values)
		# whether the summoned enemies should be flagged as minions
		var is_minion: bool = action_interceptor_processor.get_shadowed_action_values("is_minion", false)
		# a list of enemy ids that could spawn
		var random_enemy_object_ids: Array[String] = []
		random_enemy_object_ids.assign(
			action_interceptor_processor.get_shadowed_action_values("random_enemy_object_ids", [])
		)
		if random_enemy_object_ids.is_empty():
			DebugLogger.log_error("ActionSummonEnemies: No enemy type ids specified")
			continue
		var invalid_enemy_id: String = ""
		for enemy_object_id: String in random_enemy_object_ids:
			if Global.get_enemy_data(enemy_object_id) == null:
				invalid_enemy_id = enemy_object_id
				break
		if not invalid_enemy_id.is_empty():
			DebugLogger.log_error("ActionSummonEnemies: Undefined enemy id {0}".format([invalid_enemy_id]))
			continue
		var rng_name: String = action_interceptor_processor.get_shadowed_action_values("rng_name", "rng_enemy_spawning")
		var rng_enemy_spawning: RandomNumberGenerator = Global.player_data.get_player_rng(rng_name)

		# get all enemies and map them to their slot
		var enemies: Array[Enemy] = Global.get_all_enemies_in_formation_order()
		var populated_enemy_slots: Dictionary[int, Enemy] = {}
		for enemy in enemies:
			if populated_enemy_slots.has(enemy.enemy_slot_id):
				DebugLogger.log_error("ActionSummonEnemies: Multiple enemies in slot {0}".format([enemy.enemy_slot_id]))
			else:
				populated_enemy_slots[enemy.enemy_slot_id] = enemy

		# spawn enemies
		var remaining_spawns: int = number_of_spawns

		for slot_id: int in spawn_slots:
			if remaining_spawns <= 0:
				break
			if populated_enemy_slots.has(slot_id):
				var enemy: Enemy = populated_enemy_slots[slot_id]
				if enemy.is_alive():
					continue # slot already filled, skip
				else:
					populated_enemy_slots.erase(slot_id)
			
			# Randomness is consumed only for slots that will actually spawn.
			Random.shuffle_array(rng_enemy_spawning, random_enemy_object_ids)
			
			var enemy_object_id: String = random_enemy_object_ids[0]
			var spawn_request := EnemySpawnRequest.new(enemy_object_id, slot_id, is_minion)
			Signals.enemy_spawn_requested.emit(spawn_request)
			var spawned_enemy: Enemy = spawn_request.spawned_enemy
			if spawned_enemy == null:
				DebugLogger.log_warning("ActionSummonEnemies: Spawn request for slot {0} was not fulfilled".format([slot_id]))
				continue
			populated_enemy_slots[slot_id] = spawned_enemy
			remaining_spawns -= 1
		if remaining_spawns > 0:
			DebugLogger.log_warning("ActionSummonEnemies: Only spawned {0} of {1} requested enemies because no requested slots were available".format([number_of_spawns - remaining_spawns, number_of_spawns]))

func _to_string():
	return "Summon Enemy Action"
