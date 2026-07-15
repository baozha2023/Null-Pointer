class_name TargetingArrow
extends Node2D

@export var arrow_color: Color = Color(0.15, 0.95, 0.85, 1.0) # 赛博青色
@export var targeted_color: Color = Color(1.0, 0.2, 0.2, 1.0) # 红色

@export var dot_radius: float = 6.0
@export var speed: float = 0.2
@export var dash_count: int = 15

var start_pos: Vector2 = Vector2.ZERO
var target_enemy: Enemy = null
var start_node: Control = null
var pointer_position: Vector2 = Vector2.ZERO
var use_pointer_position: bool = false

var _anim_offset: float = 0.0
var current_bracket: Node = null

func _ready() -> void:
	top_level = true
	z_index = 4000

func _process(delta: float) -> void:
	if is_instance_valid(start_node):
		if start_node is Card:
			start_pos = start_node.pivot.global_position
		else:
			start_pos = start_node.get_global_rect().get_center()
		
	_anim_offset += speed * delta
	if _anim_offset > 1.0:
		_anim_offset -= 1.0
	queue_redraw()
	
	if is_instance_valid(target_enemy):
		var selection_btn = target_enemy.get_node("Visible/CombatantCenter/SelectionButton")
		var brackets = selection_btn.get_node_or_null("HoverBrackets")
		if not brackets:
			var brackets_scn = load("res://scenes/ui/HoverBrackets.tscn")
			if brackets_scn:
				brackets = brackets_scn.instantiate()
				brackets.name = "HoverBrackets"
				selection_btn.add_child(brackets)
		
		if current_bracket != brackets:
			if is_instance_valid(current_bracket):
				current_bracket.hide_brackets()
			current_bracket = brackets
			if current_bracket:
				current_bracket.show_brackets()
	else:
		_clear_bracket()

func set_pointer_position(pointer_global_position: Vector2) -> void:
	pointer_position = pointer_global_position
	use_pointer_position = true

func clear_pointer_position() -> void:
	use_pointer_position = false

func clear_target() -> void:
	target_enemy = null
	_clear_bracket()

func _clear_bracket() -> void:
	if is_instance_valid(current_bracket):
		current_bracket.hide_brackets()
	current_bracket = null

func _draw() -> void:
	var p2: Vector2
	var current_color: Color
	
	p2 = pointer_position if use_pointer_position else get_global_mouse_position()
	
	if is_instance_valid(target_enemy):
		current_color = targeted_color
	else:
		current_color = arrow_color
	
	var p0 = start_pos
	var dist = p0.distance_to(p2)
	# 控制点：取中点，并向上拱起
	var mid = p0.lerp(p2, 0.5)
	var p1 = mid + Vector2(0, -min(dist * 0.4, 250.0))
	
	# 近似计算曲线长度
	var curve_length = 0.0
	var prev_pt = p0
	for i in range(1, 11):
		var pt = _get_quadratic_bezier_point(p0, p1, p2, i / 10.0)
		curve_length += prev_pt.distance_to(pt)
		prev_pt = pt
		
	# 动态计算片段数量，确保间隔固定
	var spacing = 28.0
	var dynamic_dash_count = max(int(curve_length / spacing), 3)
	
	# 绘制缓慢流动的身体片段 (Chevrons)
	for i in range(dynamic_dash_count - 1): # 最后一个位置留给大箭头
		var t = fmod((i / float(dynamic_dash_count)) + _anim_offset, 1.0)
		
		# 避免在两端挤在一起
		if t < 0.08 or t > 0.95:
			continue
			
		var point = _get_quadratic_bezier_point(p0, p1, p2, t)
		
		# 计算切线方向
		var next_point = _get_quadratic_bezier_point(p0, p1, p2, min(t + 0.01, 1.0))
		var dir = (next_point - point).normalized()
		if dir.length_squared() == 0:
			dir = Vector2.RIGHT
		
		# 透明度渐变
		var alpha = smoothstep(0.08, 0.2, t) * smoothstep(0.95, 0.8, t)
		var c = current_color
		c.a *= alpha
		
		# 绘制类似杀戮尖塔的身体鳞片/箭头片段
		# 大小随 t 略微变小
		var scale_factor = lerp(1.2, 0.8, t)
		_draw_chevron(point, dir, c, 24.0 * scale_factor, 28.0 * scale_factor)
	
	# 绘制尖端大箭头
	var tangent = (p2 - _get_quadratic_bezier_point(p0, p1, p2, 0.95)).normalized()
	_draw_arrow_head(p2, tangent, current_color)

func _get_quadratic_bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)

func _draw_chevron(pos: Vector2, dir: Vector2, color: Color, length: float, width: float) -> void:
	var indentation = length * 0.4
	
	var tip = pos + dir * (length / 2.0)
	var back_left = pos - dir * (length / 2.0) + dir.orthogonal() * (width / 2.0)
	var back_right = pos - dir * (length / 2.0) - dir.orthogonal() * (width / 2.0)
	var back_center = pos - dir * (length / 2.0) + dir * indentation
	
	var pts = PackedVector2Array([tip, back_right, back_center, back_left])
	var colors = PackedColorArray([color, color, color, color])
	
	draw_polygon(pts, colors)

func _draw_arrow_head(pos: Vector2, dir: Vector2, color: Color) -> void:
	var head_length = 40.0
	var head_width = 36.0
	var indentation = 12.0
	
	var tip = pos
	var back_left = pos - dir * head_length + dir.orthogonal() * (head_width / 2.0)
	var back_right = pos - dir * head_length - dir.orthogonal() * (head_width / 2.0)
	var back_center = pos - dir * head_length + dir * indentation
	
	var pts = PackedVector2Array([tip, back_right, back_center, back_left])
	var colors = PackedColorArray([color, color, color, color])
	
	draw_polygon(pts, colors)
