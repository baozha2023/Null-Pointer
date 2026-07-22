@tool
## Shared normalized battlefield anchor for either combat side.
extends Control
class_name CombatFormationSlot

const BATTLEFIELD_RENDER_BASE: int = 10
const BATTLEFIELD_RENDER_RANGE: int = 20

@export_range(0, 4, 1) var slot_id: int = 0:
	set(value):
		slot_id = value
		queue_redraw()
@export_range(0, 4, 1) var logical_order: int = 0
@export_range(0.75, 1.1, 0.01) var depth_scale: float = 1.0:
	set(value):
		depth_scale = value
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func get_ground_position() -> Vector2:
	return position + size * 0.5

## World-space ground contact point. Combatants can therefore be authored as a
## child of their slot or spawned into a shared entity layer without changing
## formation positioning code.
func get_ground_global_position() -> Vector2:
	return get_global_rect().get_center()

func get_slot_id() -> int:
	return slot_id

func get_logical_order() -> int:
	return logical_order

func get_depth_scale() -> float:
	return depth_scale

func get_render_order() -> int:
	var parent_control: Control = get_parent_control()
	var formation_height: float = maxf(parent_control.size.y if parent_control != null else 1.0, 1.0)
	var normalized_depth: float = clampf(get_ground_position().y / formation_height, 0.0, 1.0)
	return BATTLEFIELD_RENDER_BASE + roundi(normalized_depth * BATTLEFIELD_RENDER_RANGE)
