class_name HoverBrackets
extends Control

@export var bracket_color: Color = Color(1.0, 0.8, 0.1, 1.0) # Golden yellow
@export var bracket_thickness: float = 4.0
@export var bracket_length: float = 24.0
@export var offset_distance: float = 20.0 # How far outside it starts
@export var animation_speed: float = 0.2

var anim_value: float = 0.0 : set = _set_anim_value
var _tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# Initially hide
	anim_value = 0.0

func _set_anim_value(v: float) -> void:
	anim_value = v
	queue_redraw()

func show_brackets() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "anim_value", 1.0, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func hide_brackets() -> void:
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "anim_value", 0.0, animation_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	if anim_value <= 0.01:
		return
		
	# Calculate the current offset (from far out to snug)
	var current_offset = lerp(offset_distance, 0.0, anim_value)
	
	# The base rectangle is our size (which matches parent Control due to anchors_preset)
	var rect = Rect2(Vector2.ZERO, size).grow(current_offset)
	
	var c = bracket_color
	c.a *= anim_value # Fade in based on anim_value
	
	var len = min(bracket_length, min(size.x, size.y) / 2.0)
	
	# Top Left
	var tl = rect.position
	draw_line(tl + Vector2(0, bracket_thickness/2.0), tl + Vector2(len, bracket_thickness/2.0), c, bracket_thickness)
	draw_line(tl + Vector2(bracket_thickness/2.0, 0), tl + Vector2(bracket_thickness/2.0, len), c, bracket_thickness)
	
	# Top Right
	var tr = rect.position + Vector2(rect.size.x, 0)
	draw_line(tr + Vector2(0, bracket_thickness/2.0), tr + Vector2(-len, bracket_thickness/2.0), c, bracket_thickness)
	draw_line(tr + Vector2(-bracket_thickness/2.0, 0), tr + Vector2(-bracket_thickness/2.0, len), c, bracket_thickness)
	
	# Bottom Left
	var bl = rect.position + Vector2(0, rect.size.y)
	draw_line(bl + Vector2(0, -bracket_thickness/2.0), bl + Vector2(len, -bracket_thickness/2.0), c, bracket_thickness)
	draw_line(bl + Vector2(bracket_thickness/2.0, 0), bl + Vector2(bracket_thickness/2.0, -len), c, bracket_thickness)
	
	# Bottom Right
	var br = rect.position + rect.size
	draw_line(br + Vector2(0, -bracket_thickness/2.0), br + Vector2(-len, -bracket_thickness/2.0), c, bracket_thickness)
	draw_line(br + Vector2(-bracket_thickness/2.0, 0), br + Vector2(-bracket_thickness/2.0, -len), c, bracket_thickness)
