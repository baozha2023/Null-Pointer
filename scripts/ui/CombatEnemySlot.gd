@tool
## A normalized battlefield anchor with stable targeting and render-order metadata.
extends Control
class_name CombatEnemySlot

const EDITOR_PREVIEW_TEXTURE: Texture2D = preload("res://sprites/enemies/act1/enemy_patrol_sweeper.png")
const RING_POINT_COUNT: int = 48
const EDITOR_PREVIEW_BASE_SIZE: Vector2 = Vector2(128.0, 128.0)
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
@export var show_editor_preview: bool = true:
	set(value):
		show_editor_preview = value
		queue_redraw()

var _summon_preview_active: bool = false
var _summon_preview_phase: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	queue_redraw()

func get_ground_position() -> Vector2:
	return position + size * 0.5

func get_slot_id() -> int:
	return slot_id

func get_logical_order() -> int:
	return logical_order

func get_depth_scale() -> float:
	return depth_scale

func get_render_order() -> int:
	# CanvasItem z order follows the ground-contact line. This keeps overlap correct
	# when a designer moves a slot in Combat.tscn without maintaining a second value.
	var formation_height: float = maxf(get_parent_control().size.y, 1.0)
	var normalized_depth: float = clampf(get_ground_position().y / formation_height, 0.0, 1.0)
	return BATTLEFIELD_RENDER_BASE + roundi(normalized_depth * BATTLEFIELD_RENDER_RANGE)

func set_summon_preview(active: bool) -> void:
	if _summon_preview_active == active:
		return
	_summon_preview_active = active
	set_process(active)
	queue_redraw()

func _process(delta: float) -> void:
	_summon_preview_phase = fmod(_summon_preview_phase + delta * 1.6, TAU)
	queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint() and show_editor_preview:
		_draw_editor_enemy_preview()
	if not _summon_preview_active:
		return
	var center: Vector2 = size * 0.5
	var pulse: float = 0.82 + sin(_summon_preview_phase) * 0.12
	var radius: Vector2 = Vector2(52.0, 17.0) * pulse
	var points: PackedVector2Array = PackedVector2Array()
	for point_index: int in RING_POINT_COUNT + 1:
		var angle: float = TAU * float(point_index) / float(RING_POINT_COUNT)
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points.slice(0, RING_POINT_COUNT), Color(0.08, 0.95, 0.92, 0.12))
	draw_polyline(points, Color(0.15, 1.0, 0.95, 0.78), 3.0, true)
	_draw_summon_silhouette(center, pulse)

func _draw_editor_enemy_preview() -> void:
	var ground_position: Vector2 = size * 0.5
	var preview_size: Vector2 = EDITOR_PREVIEW_BASE_SIZE * depth_scale
	var preview_rect: Rect2 = Rect2(
		ground_position - Vector2(preview_size.x * 0.5, preview_size.y),
		preview_size,
	)
	var shadow_points: PackedVector2Array = PackedVector2Array()
	for point_index: int in RING_POINT_COUNT:
		var angle: float = TAU * float(point_index) / float(RING_POINT_COUNT)
		shadow_points.append(
			ground_position + Vector2(
				cos(angle) * 42.0 * depth_scale,
				sin(angle) * 9.0 * depth_scale,
			)
		)
	draw_colored_polygon(shadow_points, Color(0.005, 0.012, 0.02, 0.42))
	draw_texture_rect(EDITOR_PREVIEW_TEXTURE, preview_rect, false, Color(1.0, 1.0, 1.0, 0.78))
	draw_arc(
		ground_position,
		10.0,
		0.0,
		TAU,
		24,
		Color(0.15, 1.0, 0.95, 0.9),
		2.0,
		true,
	)

func _draw_summon_silhouette(center: Vector2, pulse: float) -> void:
	var hologram_color: Color = Color(0.18, 1.0, 0.96, 0.24)
	var outline_color: Color = Color(0.45, 1.0, 0.98, 0.42)
	var body_center: Vector2 = center + Vector2(0.0, -20.0)
	draw_circle(body_center + Vector2(0.0, -27.0), 8.0 * pulse, hologram_color)
	var silhouette: PackedVector2Array = PackedVector2Array([
		body_center + Vector2(-9.0, -17.0),
		body_center + Vector2(-18.0, 2.0),
		body_center + Vector2(-11.0, 17.0),
		body_center + Vector2(-6.0, 4.0),
		body_center + Vector2(-5.0, 27.0),
		body_center + Vector2(0.0, 17.0),
		body_center + Vector2(5.0, 27.0),
		body_center + Vector2(6.0, 4.0),
		body_center + Vector2(11.0, 17.0),
		body_center + Vector2(18.0, 2.0),
		body_center + Vector2(9.0, -17.0),
	])
	draw_colored_polygon(silhouette, hologram_color)
	silhouette.append(silhouette[0])
	draw_polyline(silhouette, outline_color, 2.0, true)
