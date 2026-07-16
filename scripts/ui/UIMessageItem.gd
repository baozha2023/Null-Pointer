extends MarginContainer
class_name UIMessageItem

@onready var panel: PanelContainer = %Panel
@onready var accent: ColorRect = %Accent
@onready var icon_rect: TextureRect = %Icon
@onready var title_label: Label = %Title
@onready var body_label: Label = %Body


func configure(
	text: String,
	icon: Texture2D = null,
	title: String = "",
	message_type: int = UIMessage.MESSAGE_TYPES.NORMAL,
) -> void:
	body_label.text = text
	title_label.text = title
	title_label.visible = title != ""
	icon_rect.texture = icon
	icon_rect.visible = icon != null
	_apply_message_type(message_type)


func _apply_message_type(message_type: int) -> void:
	var color: Color = Color(0.2, 0.82, 0.82, 1.0)
	match message_type:
		UIMessage.MESSAGE_TYPES.SUCCESS:
			color = Color(0.3, 0.95, 0.55, 1.0)
		UIMessage.MESSAGE_TYPES.WARNING:
			color = Color(1.0, 0.72, 0.24, 1.0)
		UIMessage.MESSAGE_TYPES.ERROR:
			color = Color(1.0, 0.28, 0.38, 1.0)
		UIMessage.MESSAGE_TYPES.ACHIEVEMENT:
			color = Color(0.64, 0.98, 0.34, 1.0)
	accent.color = color
	title_label.add_theme_color_override("font_color", color.lightened(0.15))
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	style.border_color = Color(color, 0.72)
	style.shadow_color = Color(color, 0.16)
	panel.add_theme_stylebox_override("panel", style)


func show_animation(duration: float) -> void:
	modulate.a = 0.0
	call_deferred("_run_animation", duration)


func _run_animation(duration: float) -> void:
	await get_tree().process_frame
	if not is_inside_tree():
		return
	var resting_y: float = position.y
	position.y = resting_y - 10.0
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(self, "position:y", resting_y, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(duration)
	tween.tween_property(self, "modulate:a", 0.0, 0.28)
	tween.parallel().tween_property(self, "position:y", resting_y - 8.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
