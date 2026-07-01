extends Node2D
class_name BlockIndicator

@onready var base_sprite: Sprite2D = $BaseSprite
@onready var block_amount: Label = $BaseSprite/BlockAmount
@onready var shatter_container: Node2D = $ShatterContainer
@onready var left_half: Polygon2D = $ShatterContainer/LeftHalf
@onready var right_half: Polygon2D = $ShatterContainer/RightHalf
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_amount: int = 0

func _ready() -> void:
	if base_sprite.texture:
		var tex_size = base_sprite.texture.get_size()
		var w = tex_size.x
		var h = tex_size.y
		
		var top_y = -h / 2.0
		var bottom_y = h / 2.0
		var left_x = -w / 2.0
		var right_x = w / 2.0
		
		var left_polygon = PackedVector2Array()
		var right_polygon = PackedVector2Array()
		
		left_polygon.append(Vector2(left_x, top_y))
		left_polygon.append(Vector2(left_x, bottom_y))
		
		var segments = 8
		var mid_x = 0.0
		var offset_x = w * 0.10 # 4% jaggedness
		
		var zigzag_points = PackedVector2Array()
		for i in range(segments + 1):
			var t = float(i) / segments
			var y = lerp(top_y, bottom_y, t)
			var x = mid_x
			if i > 0 and i < segments:
				x += offset_x if (i % 2 == 0) else -offset_x
			zigzag_points.append(Vector2(x, y))
		
		for i in range(segments, -1, -1):
			left_polygon.append(zigzag_points[i])
			
		right_polygon.append(Vector2(right_x, top_y))
		right_polygon.append(Vector2(right_x, bottom_y))
		for i in range(segments, -1, -1):
			right_polygon.append(zigzag_points[i])
			
		left_half.polygon = left_polygon
		right_half.polygon = right_polygon
		
		var left_uvs = PackedVector2Array()
		for p in left_polygon:
			left_uvs.append(Vector2(p.x + w/2.0, p.y + h/2.0))
		left_half.uv = left_uvs
		
		var right_uvs = PackedVector2Array()
		for p in right_polygon:
			right_uvs.append(Vector2(p.x + w/2.0, p.y + h/2.0))
		right_half.uv = right_uvs
	
	visible = false

func update_block(amount: int) -> void:
	block_amount.text = str(amount)
	
	if amount > 0:
		visible = true
		base_sprite.visible = true
		shatter_container.visible = false
	elif current_amount > 0 and amount <= 0:
		play_shatter()
	else:
		visible = false
		
	current_amount = amount

func play_shatter() -> void:
	base_sprite.visible = false
	shatter_container.visible = true
	animation_player.play("shatter")

func _on_shatter_finished() -> void:
	if current_amount <= 0:
		visible = false
