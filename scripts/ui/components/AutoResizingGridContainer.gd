extends GridContainer
class_name AutoResizingGridContainer

func _ready() -> void:
	resized.connect(resize_grid_columns)
	child_entered_tree.connect(func(_node): call_deferred("resize_grid_columns"))
	child_exiting_tree.connect(func(_node): call_deferred("resize_grid_columns"))

func resize_grid_columns() -> void:
	if get_child_count() > 0:
		var child: Control = get_child(0)
		var child_width: int = int(child.size.x)
		if child_width <= 0:
			child_width = int(child.custom_minimum_size.x)
		
		if child_width > 0:
			var h_sep: int = get_theme_constant("h_separation")
			var container_width: int = int(size.x)
			# Add a small buffer to avoid floating point precision issues
			var new_columns: int = max(int(floor((container_width + h_sep) / float(child_width + h_sep))), 1)
			if columns != new_columns:
				columns = new_columns
