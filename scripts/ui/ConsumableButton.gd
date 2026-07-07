# represents a consumable slot
# can be empty
extends TextureButton
class_name ConsumableButton

var consumable_slot_index: int = 0	# which consumable slot this button corresponds to

const EMPTY_TEXTURE = preload("res://sprites/ui/icon_ui_consumable_empty.png")

signal consumable_slot_button_up(slot_index: int)

func _ready():
	UIHover.add_hover_scale(self)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func init(_consumable_slot_index: int):
	consumable_slot_index = _consumable_slot_index
	
	var consumable_data: ConsumableData = Global.get_player_consumable_in_slot_index(consumable_slot_index)
	if consumable_data != null:
		# texture
		texture_normal = FileLoader.load_texture(consumable_data.consumable_texture_path)
		self_modulate.a = 1.0
	else:
		# empty consumable slot
		self_modulate.a = 0.3
		texture_normal = EMPTY_TEXTURE
	

func _on_button_up():
	consumable_slot_button_up.emit(consumable_slot_index)

func _on_mouse_entered():
	var consumable_data: ConsumableData = Global.get_player_consumable_in_slot_index(consumable_slot_index)
	if consumable_data != null and HandManager.tooltip != null:
		HandManager.tooltip.display_codex_consumable_tooltip(consumable_data)

func _on_mouse_exited():
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
