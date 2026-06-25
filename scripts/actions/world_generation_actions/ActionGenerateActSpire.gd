## Spire-style world map generator.
## Produces a branching path structure similar to Slay the Spire.
##
## Reads generation parameters from ActData:
##   act_map_connection_density: 0.0~1.0, controls branching; 0=linear, 0.5=typical, 1.0=dense
##   act_map_floor_templates: [{min, max, pool, fixed}, ...]
##
## Floor template format: {"min": int, "max": int, "pool": String, "fixed": Array[String]}
##   pool: "easy" | "hard" | "event"
##   fixed: type strings e.g. ["SHOP"], ["TREASURE", "REST_SITE"]
##
## Connection algorithm (Slay the Spire style):
##   - Nodes sorted by x-position; each src connects to a sliding window of dsts
##   - Window centered on position-proportional target, radius = round(density * 2)
##   - Start node connects to every first-floor node; Boss always reachable (all last-floor nodes → boss)
##   - Orphan fix: any dst with 0 incoming gets edge from nearest src
##   - Fully deterministic: same seed = same map
extends BaseAction

const GRID_SPACING: int = 100
const HORIZONTAL_JITTER: int = 18

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([])
	for aip in action_interceptor_processors:
		### RNG
		var rng_name: String = aip.get_shadowed_action_values("rng_name", "rng_world_generation")
		var rng: RandomNumberGenerator = Global.player_data.get_player_rng(rng_name)

		### Act data
		var act_id: String = get_action_value("act_id", "")
		var act_data: ActData = Global.get_act_data(act_id)
		var act_number: int = get_action_value("act_number", Global.player_data.player_act)

		Global.player_data.player_act_id = act_id
		Global.player_data.player_act = act_number

		### Generation parameters from ActData
		var density: float = act_data.act_map_connection_density
		var templates: Array[Dictionary] = act_data.act_map_floor_templates
		var floor_count: int = len(templates) + 2  # +start +boss

		# allow interceptors to override
		var obfuscation_rate: float = aip.get_shadowed_action_values("location_obfuscation_rate", 0.3)
		var event_conversion_rate: float = aip.get_shadowed_action_values("location_non_combat_event_rate", 0.12)

		# positioning constants
		var template_max_nodes: int = 5
		for t in templates:
			template_max_nodes = max(template_max_nodes, int(t.get("max", 5)))
		var spread_width: int = (template_max_nodes - 1) * GRID_SPACING
		const MIDDLE: int = 400
		var x_base: float = MIDDLE - spread_width / 2.0
		var BOTTOM: int = (floor_count + 1) * GRID_SPACING

		var floors: Array[Array] = []
		var location_id_counter: int = 0
		var floor_counter: int = 0
		#region Start node
		Global.clear_locations()

		var starting_floor: Array[LocationData] = []
		var sl: LocationData = LocationData.new()
		sl.location_id = "location_0" if act_number == 1 else "location_%d_0" % act_number
		Global.player_data.location_id_to_location_data[sl.location_id] = sl
		Global.player_data.player_location_id = sl.location_id
		sl.location_act = act_number
		sl.location_index = Vector2(0, -1)
		sl.location_position = Vector2(MIDDLE, BOTTOM)
		sl.location_floor = floor_counter
		sl.location_type = LocationData.LOCATION_TYPES.STARTING
		sl.location_visited = true
		if act_number == 1:
			sl.location_event_object_id = "event_act_1_easy_combat_1"
		starting_floor.append(sl)
		floors.append(starting_floor)
		#endregion

		#region Procedural floors
		for t in templates:
			var current_floor: Array[LocationData] = []
			floor_counter += 1

			var f_min: int = t["min"]
			var f_max: int = t["max"]
			var f_pool: String = t.get("pool", "easy")
			var f_fixed: Array = t.get("fixed", [])

			var node_count: int = rng.randi_range(f_min, f_max)

			# collect node type assignments: forced types first, then pool fill
			var type_queue: Array[String] = []
			type_queue.append_array(f_fixed)
			while len(type_queue) < node_count:
				type_queue.append(f_pool)

			# shuffle so forced types are not always first visually
			Random.shuffle_array(rng, type_queue)

			for i in node_count:
				var type_str: String = type_queue[i]
				var loc: LocationData = LocationData.new()

				location_id_counter += 1
				var lid: String = "location_%d_%d" % [act_number, location_id_counter]
				loc.location_id = lid
				Global.player_data.location_id_to_location_data[lid] = loc

				loc.location_act = act_number
				loc.location_floor = floor_counter

				# assign type and pool
				var type_config: Dictionary = _get_type_config(type_str, act_data)
				loc.location_type = type_config["type"]
				loc.location_event_pool_object_id = type_config.get("pool", "")

				# position with horizontal spread
				var x_ratio: float = float(i) / max(1, node_count - 1) if node_count > 1 else 0.5
				var x_pos: float = x_base + x_ratio * spread_width + rng.randi_range(-HORIZONTAL_JITTER, HORIZONTAL_JITTER)
				var y_pos: float = BOTTOM - floor_counter * GRID_SPACING
				loc.location_index = Vector2(i, floor_counter)
				loc.location_position = Vector2(x_pos, y_pos)

				# obfuscation
				if loc.location_type in [LocationData.LOCATION_TYPES.COMBAT, LocationData.LOCATION_TYPES.TREASURE]:
					if rng.randf() < obfuscation_rate:
						loc.location_obfuscated = true

				# chance to convert combat to event
				if loc.location_type == LocationData.LOCATION_TYPES.COMBAT:
					if rng.randf() < event_conversion_rate:
						loc.location_obfuscated = true
						loc.location_type = LocationData.LOCATION_TYPES.EVENT
						loc.location_event_pool_object_id = act_data.act_non_combat_event_pool_object_id

				current_floor.append(loc)

			floors.append(current_floor)
		#endregion

		#region Boss floor
		floor_counter += 1
		var boss_floor: Array[LocationData] = []
		var bl: LocationData = LocationData.new()

		location_id_counter += 1
		var bid: String = "location_%d_%d" % [act_number, location_id_counter]
		bl.location_id = bid
		Global.player_data.location_id_to_location_data[bid] = bl

		bl.location_act = act_number
		bl.location_floor = floor_counter
		bl.location_index = Vector2(0, floor_count - 1)
		bl.location_position = Vector2(MIDDLE, BOTTOM - floor_counter * GRID_SPACING)
		bl.location_type = LocationData.LOCATION_TYPES.BOSS
		bl.location_event_pool_object_id = act_data.act_boss_event_pool_object_id

		boss_floor.append(bl)
		floors.append(boss_floor)
		#endregion

		#region Connections (spire-style sliding window)
		var window_radius: int = roundi(density * 2)  # 0, 1, or 2

		for fi in range(len(floors) - 1):
			var src_floor: Array[LocationData] = floors[fi]
			var dst_floor: Array[LocationData] = floors[fi + 1]
			var src_count: int = len(src_floor)
			var dst_count: int = len(dst_floor)
			if src_count == 0 or dst_count == 0:
				continue

			# sort by x for positional adjacency
			var src_sorted: Array = src_floor.duplicate()
			var dst_sorted: Array = dst_floor.duplicate()
			src_sorted.sort_custom(func(a, b): return a.location_position.x < b.location_position.x)
			dst_sorted.sort_custom(func(a, b): return a.location_position.x < b.location_position.x)

			# special case: start floor (1 node) → first procedural floor: connect all
			if src_count == 1:
				for j in dst_count:
					src_sorted[0].location_next_location_ids.append(dst_sorted[j].location_id)
				continue

			# special case: last floor (n nodes) → boss (1 node)
			if dst_count == 1:
				for src in src_sorted:
					src.location_next_location_ids.append(dst_sorted[0].location_id)
				continue

			# general case: sliding window
			for i in src_count:
				var src: LocationData = src_sorted[i]
				var target: int = roundi(float(i) / max(1, src_count - 1) * (dst_count - 1))
				var lo: int = max(0, target - window_radius)
				var hi: int = min(dst_count - 1, target + window_radius)
				for j in range(lo, hi + 1):
					src.location_next_location_ids.append(dst_sorted[j].location_id)

			# orphan fix: every dst must have at least 1 incoming edge
			for dst in dst_sorted:
				var has_incoming: bool = false
				for src in src_sorted:
					if dst.location_id in src.location_next_location_ids:
						has_incoming = true
						break
				if not has_incoming:
					# connect to nearest src by x-position
					var best: LocationData = src_sorted[0]
					var best_dist: float = abs(src_sorted[0].location_position.x - dst.location_position.x)
					for src in src_sorted:
						var d: float = abs(src.location_position.x - dst.location_position.x)
						if d < best_dist:
							best_dist = d
							best = src
					best.location_next_location_ids.append(dst.location_id)
		#endregion


## Maps a type string from the floor template to (type, pool) config.
func _get_type_config(type_str: String, act_data: ActData) -> Dictionary:
	match type_str:
		"easy":
			return {"type": LocationData.LOCATION_TYPES.COMBAT, "pool": act_data.act_easy_combat_event_pool_object_id}
		"hard":
			return {"type": LocationData.LOCATION_TYPES.COMBAT, "pool": act_data.act_hard_combat_event_pool_object_id}
		"event":
			return {"type": LocationData.LOCATION_TYPES.EVENT, "pool": act_data.act_non_combat_event_pool_object_id}
		"SHOP":
			return {"type": LocationData.LOCATION_TYPES.SHOP, "pool": ""}
		"REST_SITE":
			return {"type": LocationData.LOCATION_TYPES.REST_SITE, "pool": ""}
		"TREASURE":
			return {"type": LocationData.LOCATION_TYPES.TREASURE, "pool": act_data.act_easy_combat_event_pool_object_id}
		"MINIBOSS":
			return {"type": LocationData.LOCATION_TYPES.MINIBOSS, "pool": act_data.act_miniboss_event_pool_object_id}
		_:
			return {"type": LocationData.LOCATION_TYPES.COMBAT, "pool": act_data.act_easy_combat_event_pool_object_id}
