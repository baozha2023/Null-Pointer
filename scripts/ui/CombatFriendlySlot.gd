@tool
## Friendly-side formation anchor. The scene owns its visual position and scale.
extends CombatFormationSlot
class_name CombatFriendlySlot

@export var show_editor_preview: bool = true:
	set(value):
		show_editor_preview = value
		queue_redraw()

func _ready() -> void:
	super._ready()
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint() or not show_editor_preview:
		return
	var center: Vector2 = size * 0.5
	draw_circle(center, 10.0, Color(0.3, 1.0, 0.45, 0.85))
	draw_arc(center, 42.0 * depth_scale, 0.0, TAU, 32, Color(0.3, 1.0, 0.45, 0.55), 2.0, true)
