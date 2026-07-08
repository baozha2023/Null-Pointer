## A smooth scrolling grid container that will be populated with whatever is needed.
## The grid container will automatically adjust to fit the scroll container's size when
## the screen changes size
extends SmoothScrollContainer
class_name ResizingGridScrollContainer

@onready var grid_container: GridContainer = $MarginContainer/GridContainer

signal child_populated(child: Control)

var _is_populating_async: bool = false
var _async_populate_data: Array[Array] = []
var _async_populate_index: int = 0
var _async_packed_scene: PackedScene = null
var _async_init_method_name: String = ""
var _async_batch_size_per_frame: int = 4

#region Keep
func _ready() -> void:
	super()
	get_viewport().size_changed.connect(_on_screen_resized)

## A method to populate children given a packed scene and a list of data used to instantiate them.
func populate_children(packed_scene: PackedScene, data: Array[Array], init_method_name: String = "init") -> void:
	clear_children()
	
	for _i: int in len(data):
		var child: Control = packed_scene.instantiate()
		var args: Array = data[_i]
		
		grid_container.add_child(child)
		child.callv(init_method_name, args)
		child_populated.emit(child)
	
	call_deferred("resize_grid_columns")

## Async population to avoid freezing the main thread. Instantiates an initial batch, then continues in _process.
func populate_children_async(packed_scene: PackedScene, data: Array[Array], init_method_name: String = "init", initial_batch: int = 8, batch_per_frame: int = 4) -> void:
	clear_children()
	
	_async_populate_data = data
	_async_populate_index = 0
	_async_packed_scene = packed_scene
	_async_init_method_name = init_method_name
	_async_batch_size_per_frame = batch_per_frame
	
	var count_to_instantiate = min(initial_batch, len(_async_populate_data))
	for _i in range(count_to_instantiate):
		_instantiate_child_async(_async_populate_index)
		_async_populate_index += 1
		
	call_deferred("resize_grid_columns")
	
	if _async_populate_index < len(_async_populate_data):
		_is_populating_async = true
	else:
		_is_populating_async = false

func _process(delta: float) -> void:
	super(delta)
	
	if not _is_populating_async:
		return
		
	var count_to_instantiate = min(_async_batch_size_per_frame, len(_async_populate_data) - _async_populate_index)
	for _i in range(count_to_instantiate):
		_instantiate_child_async(_async_populate_index)
		_async_populate_index += 1
		
	if _async_populate_index >= len(_async_populate_data):
		_is_populating_async = false
		# call_deferred("resize_grid_columns") # Usually handled correctly by initial resize

func _instantiate_child_async(index: int) -> void:
	var child: Control = _async_packed_scene.instantiate()
	var args: Array = _async_populate_data[index]
	grid_container.add_child(child)
	child.callv(_async_init_method_name, args)
	
	child_populated.emit(child)

func clear_children() -> void:
	_is_populating_async = false
	for child in grid_container.get_children():
		child.queue_free()
	
func _on_screen_resized() -> void:
	resize_grid_columns()

func resize_grid_columns() -> void:
	if grid_container.get_child_count() > 0:
		var child: Control = grid_container.get_child(0)
		var child_width: int = int(child.size.x)
		var h_seperation: int = grid_container.get_theme_constant("h_separation")
		var scroll_container_width: int = int(size.x)
		
		grid_container.columns = max(int(floor((scroll_container_width - 8) / (child_width + h_seperation))), 1)
#endregion
