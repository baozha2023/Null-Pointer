extends Control

@onready var scroll_container = $ScrollContainer
@onready var location_container = $ScrollContainer/LocationContainer
@onready var drawing_layer: Control = $ScrollContainer/LocationContainer/DrawingLayer
@onready var back_button: Button = $BackButton
@onready var title_label: Label = $TitleLabel
@onready var draw_button: Button = $DrawButton
@onready var clear_drawing_button: Button = $ClearDrawingButton
@onready var auto_boss_button: Button = $AutoBossButton

@onready var map_button = %MapButton

var can_travel: bool = false	# if clicking on a location brings you to the next location
var draw_mode_enabled: bool = false
var current_drawing_line: Line2D = null

## Adds a margin to the bottom of the map display
const MAP_Y_MARGIN: float = 150
const SCROLL_MARGIN: float = 80.0
const SCROLL_SPEED: float = 600.0

var _scroll_accumulator: float = 0.0

func _process(delta: float) -> void:
	if not visible or not draw_mode_enabled or current_drawing_line == null:
		return
		
	var mouse_pos = get_global_mouse_position()
	var scroll_amount = 0.0
	
	if mouse_pos.y < scroll_container.global_position.y + SCROLL_MARGIN:
		scroll_amount = -SCROLL_SPEED * delta
	elif mouse_pos.y > scroll_container.global_position.y + scroll_container.size.y - SCROLL_MARGIN:
		scroll_amount = SCROLL_SPEED * delta
		
	if scroll_amount != 0.0:
		_scroll_accumulator += scroll_amount
		if abs(_scroll_accumulator) >= 1.0:
			var int_scroll = int(_scroll_accumulator)
			scroll_container.scroll_vertical += int_scroll
			_scroll_accumulator -= int_scroll
			# Add a point while scrolling so the drawing follows the canvas movement
			current_drawing_line.add_point(drawing_layer.get_local_mouse_position())

func _ready():
	map_button.button_up.connect(_on_map_button_up)
	back_button.button_up.connect(_on_back_button_up)
	draw_button.button_up.connect(_on_draw_button_up)
	clear_drawing_button.button_up.connect(_on_clear_drawing_button_up)
	if auto_boss_button != null:
		auto_boss_button.button_up.connect(_on_auto_boss_button_up)
		auto_boss_button.visible = ProfileData.ENABLE_ONE_CLICK_BOSS
	
	Signals.combat_started.connect(_on_combat_started)
	Signals.combat_ended.connect(_on_combat_ended)
	
	Signals.player_killed.connect(_on_player_killed)
	Signals.dialogue_ended.connect(_on_dialogue_ended)
	
	Signals.chest_opened.connect(_on_chest_opened)
	Signals.shop_opened.connect(_on_shop_opened)
	
	Signals.map_location_selected.connect(_on_map_location_selected)
	
func populate_locations(locations: Array[LocationData] = Global.get_all_act_locations()):
	clear_locations()
	_update_title()
	
	var next_locations: Array[LocationData] = Global.get_next_locations()
	var max_y: float = 0.0 # the highest location position, used to determine container size
	
	var current_map_location: MapLocation = null
	
	var loc_dict = {}
	for loc in locations:
		loc_dict[loc.location_id] = loc
		max_y = max(max_y, loc.location_position.y)
		
	# Pass 1: Draw lines
	for loc in locations:
		if loc.location_type == LocationData.LOCATION_TYPES.STARTING:
			continue # Do not draw lines from the invisible starting location
			
		for next_id in loc.location_next_location_ids:
			if loc_dict.has(next_id):
				var next_loc = loc_dict[next_id]
				var line = Line2D.new()
				
				# Offset to point to the center of the MapLocation icon
				var offset = Vector2(32, 32)
				var start_pos = loc.location_position + offset
				var end_pos = next_loc.location_position + offset
				
				line.add_point(start_pos)
				line.add_point(end_pos)
				line.width = 4.0
				
				# Style line based on cyber theme
				if loc.location_visited and (next_loc.location_visited or (next_locations.has(next_loc) and can_travel)):
					# Historical / Available Next Path
					line.default_color = Color(0.2, 1.0, 0.5, 1.0)
					line.width = 8.0
				else:
					# Unvisited/Future Path
					line.default_color = Color(0.2, 0.4, 0.5, 0.5)
					
				location_container.add_child(line)
				
	# Pass 2: Draw MapLocations
	for location_data in locations:
		if location_data.location_type == LocationData.LOCATION_TYPES.STARTING:
			continue	# starting area not displayed
		
		var map_location: MapLocation = Scenes.MAP_LOCATION.instantiate()
		location_container.add_child(map_location)
		map_location.init(location_data)
		
		map_location.map_location_button_up.connect(_on_map_location_button_up)
		
		# flash the locations the player can travel to
		if can_travel:
			if next_locations.has(location_data):
				map_location.flash_location()
				current_map_location = map_location
	
	# set the size of the container to make scrolling posible
	location_container.custom_minimum_size.y = max_y + MAP_Y_MARGIN
	location_container.size.y = max_y + MAP_Y_MARGIN
	drawing_layer.custom_minimum_size = location_container.custom_minimum_size
	drawing_layer.size = location_container.size
	location_container.move_child(drawing_layer, location_container.get_child_count() - 1)
	
	# wait a frame to ensure container is properly resized
	await Global.get_tree().process_frame
	# set the scroll
	if current_map_location != null:
		current_map_location.grab_focus()
	else:
		# presumably the invisible starting location, set to bottom
		scroll_container.scroll_vertical = max_y
	

func clear_locations() -> void:
	for child in location_container.get_children():
		if child != drawing_layer:
			child.queue_free()

func show_map():
	populate_locations()
	visible = true

func hide_map():
	visible = false
	_stop_current_drawing_line()

func _on_map_button_up():
	show_map()

func _on_map_location_button_up(map_location: MapLocation):
	# map must be in travel mode
	if can_travel:
		# must be adjacent to player location
		if Global.get_next_locations().has(map_location.location_data):
			# visit the location
			ActionGenerator.generate_visition_location(map_location.location_data.location_id)
			
func _on_auto_boss_button_up():
	if not can_travel:
		return
	can_travel = false
	
	# Find path to boss using randomized DFS
	var current_loc_id = Global.player_data.player_location_id
	var current_loc = Global.get_location_data(current_loc_id)
	
	if current_loc == null:
		can_travel = true
		return
		
	var path: Array = []
	var stack: Array = [[current_loc, []]]
	while stack.size() > 0:
		var curr = stack.pop_back()
		var loc: LocationData = curr[0]
		var cur_path: Array = curr[1].duplicate()
		cur_path.append(loc)
		if loc.location_type == LocationData.LOCATION_TYPES.BOSS:
			path = cur_path
			break
		
		# Shuffle neighbors
		var neighbors = loc.location_next_location_ids.duplicate()
		neighbors.shuffle()
		for neighbor_id in neighbors:
			var n_loc = Global.get_location_data(neighbor_id)
			if n_loc != null:
				stack.append([n_loc, cur_path])
	
	if path.size() <= 1:
		can_travel = true
		return
		
	# Animate the path
	var offset = Vector2(32, 32)
	for i in range(1, path.size()):
		var loc_data: LocationData = path[i]
		loc_data.location_visited = true
		
		var prev_loc: LocationData = path[i-1]
		var start_pos = prev_loc.location_position + offset
		var end_pos = loc_data.location_position + offset
		
		# Find and update the line
		for child in location_container.get_children():
			if child is Line2D and child.get_point_count() == 2:
				if child.get_point_position(0).is_equal_approx(start_pos) and child.get_point_position(1).is_equal_approx(end_pos):
					child.default_color = Color(0.2, 1.0, 0.5, 1.0)
					child.width = 8.0
					break
		
		# Find the instantiated MapLocation node
		var target_map_node: MapLocation = null
		for child in location_container.get_children():
			if child is MapLocation and child.location_data == loc_data:
				target_map_node = child
				break
		
		if target_map_node != null:
			target_map_node.init(loc_data)
			target_map_node.flash_location()
			
			var tween = get_tree().create_tween()
			var target_scroll = target_map_node.position.y - scroll_container.size.y / 2.0
			target_scroll = clamp(target_scroll, 0, location_container.size.y - scroll_container.size.y)
			tween.tween_property(scroll_container, "scroll_vertical", target_scroll, 0.2)
		
		if i < path.size() - 1:
			await get_tree().create_timer(0.3).timeout
		else:
			await get_tree().create_timer(0.6).timeout # longer wait before boss
			
	# Trigger Boss Visit
	var boss_loc = path.back()
	ActionGenerator.generate_visition_location(boss_loc.location_id)
	
func _on_map_location_selected(location_data: LocationData):
	# disable travel mode
	can_travel = false
	hide_map()

func _on_combat_started(_event_id: String):
	can_travel = false

func _on_combat_ended():
	can_travel = true

func _on_player_killed(_player: Player) -> void:
	hide_map()
	clear_locations()

func _on_chest_opened():
	can_travel = true

func _on_shop_opened():
	can_travel = true

func _on_dialogue_ended():
	var player: Player = Global.get_player()
	if player.is_alive():
		can_travel = true
		show_map()
	else:
		hide_map()

func _on_back_button_up():
	hide_map()

func _input(event: InputEvent) -> void:
	if not visible or not draw_mode_enabled:
		return
	if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not _is_pointer_in_drawing_area():
		if event is InputEventMouseButton and not event.pressed:
			_stop_current_drawing_line()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drawing_line()
		else:
			_stop_current_drawing_line()
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and current_drawing_line != null:
		current_drawing_line.add_point(drawing_layer.get_local_mouse_position())
		get_viewport().set_input_as_handled()

func _update_title() -> void:
	var act_data: ActData = Global.get_act_data(Global.player_data.player_act_id)
	if act_data == null:
		title_label.text = ""
		return
	title_label.text = act_data.act_name

func _on_draw_button_up() -> void:
	draw_mode_enabled = not draw_mode_enabled
	draw_button.text = "画笔 开" if draw_mode_enabled else "画笔"
	if not draw_mode_enabled:
		_stop_current_drawing_line()

func _on_clear_drawing_button_up() -> void:
	_stop_current_drawing_line()
	for child in drawing_layer.get_children():
		child.queue_free()

func _start_drawing_line() -> void:
	_stop_current_drawing_line()
	current_drawing_line = Line2D.new()
	current_drawing_line.width = 6.0
	current_drawing_line.default_color = Color(0.1, 1.0, 0.45, 0.9)
	current_drawing_line.z_index = 200
	drawing_layer.add_child(current_drawing_line)
	current_drawing_line.add_point(drawing_layer.get_local_mouse_position())

func _stop_current_drawing_line() -> void:
	current_drawing_line = null

func _is_pointer_in_drawing_area() -> bool:
	var mouse_position: Vector2 = get_global_mouse_position()
	if not Rect2(scroll_container.global_position, scroll_container.size).has_point(mouse_position):
		return false
	for ctrl in [back_button, draw_button, clear_drawing_button]:
		if Rect2(ctrl.global_position, ctrl.size).has_point(mouse_position):
			return false
	return true
