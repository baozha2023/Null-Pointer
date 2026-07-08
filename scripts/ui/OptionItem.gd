extends PanelContainer
class_name OptionItem

signal option_clicked(option_data: OptionData)

@onready var icon_rect: TextureRect = %IconRect
@onready var rich_text_label: RichTextLabel = %RichTextLabel

var option_data: OptionData = null
var is_selected: bool = false
var is_disabled: bool = false

var style_normal: StyleBoxTexture
var style_hover: StyleBoxTexture
var style_pressed: StyleBoxTexture

func _ready():
	style_normal = StyleBoxTexture.new()
	style_normal.texture = preload("res://sprites/btn_common_normal.png")
	
	style_hover = StyleBoxTexture.new()
	style_hover.texture = preload("res://sprites/btn_common_hover.png")
	
	style_pressed = StyleBoxTexture.new()
	style_pressed.texture = preload("res://sprites/btn_common_pressed.png")
	
	add_theme_stylebox_override("panel", style_normal)

func init(_option_data: OptionData):
	option_data = _option_data
	if option_data.option_texture_path != "":
		icon_rect.texture = load("res://" + option_data.option_texture_path)
	else:
		icon_rect.texture = null
	
	var display_text = ""
	if option_data.option_name != "":
		display_text += "[color=cyan]" + option_data.option_name + "[/color]\n"
	display_text += option_data.option_description
	rich_text_label.text = TextParser.parse(display_text)
	
	is_disabled = option_data.option_disabled
	
	if is_disabled:
		modulate = Color(0.5, 0.5, 0.5, 1.0)
		if option_data.option_disabled_reason != "":
			rich_text_label.text += "\n[color=red](" + option_data.option_disabled_reason + ")[/color]"
	else:
		modulate = Color(1, 1, 1, 1)

func set_selected(selected: bool):
	is_selected = selected
	if is_selected:
		add_theme_stylebox_override("panel", style_pressed)
		self.self_modulate = Color(1.5, 1.5, 1.5, 1.0) # Highlight glow
	else:
		add_theme_stylebox_override("panel", style_normal)
		self.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_mouse_entered():
	if not is_disabled:
		if not is_selected:
			add_theme_stylebox_override("panel", style_hover)
		UIHover.scale_up(self)

func _on_mouse_exited():
	if not is_disabled:
		if is_selected:
			add_theme_stylebox_override("panel", style_pressed)
		else:
			add_theme_stylebox_override("panel", style_normal)
		UIHover.scale_down(self)

func _on_gui_input(event):
	if is_disabled:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		add_theme_stylebox_override("panel", style_pressed)
		option_clicked.emit(option_data)
