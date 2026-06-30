extends CanvasLayer

var container: VBoxContainer

func _ready() -> void:
	layer = 100 # Ensure it is always on top
	
	container = VBoxContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	container.offset_top = 10
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Small gap between messages
	container.add_theme_constant_override("separation", 10)
	
	add_child(container)

## Globally show a toast message, similar to Vue's Message component
func show_message(text: String, duration: float = 2.0) -> void:
	var item_scene = preload("res://scenes/ui/UIMessageItem.tscn")
	var item_node = item_scene.instantiate()
	
	# Pass the text to the item. Either it has a set_message method, or we try to find a Label child.
	if item_node.has_method("set_message"):
		item_node.set_message(text)
	else:
		var label = item_node.find_child("Label", true, false)
		if label != null and "text" in label:
			label.text = text
			
	if item_node is Control:
		item_node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		
	container.add_child(item_node)
	
	# If the item handles its own animation (has a show_animation method), let it handle it.
	# Otherwise, we provide a default fade animation.
	if item_node.has_method("show_animation"):
		item_node.show_animation(duration)
	else:
		item_node.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(item_node, "modulate:a", 1.0, 0.2)
		tween.tween_interval(duration)
		tween.tween_property(item_node, "modulate:a", 0.0, 0.3)
		tween.tween_callback(item_node.queue_free)
