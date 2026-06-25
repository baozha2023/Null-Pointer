# UI element for a status effect
extends TextureRect
class_name StatusEffect

var status_effect_script: BaseStatusEffect

@onready var status_charge_label: Label = $StatusChargeLabel
@onready var status_secondary_charge_label = $StatusSecondaryChargeLabel

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func update_status_charge_display() -> void:
	visible = status_effect_script.status_effect_data.status_effect_is_visible
	
	var status_effect_data: StatusEffectData = status_effect_script.status_effect_data
	var status_effect_charge_upper_bound: int = status_effect_data.status_effect_charge_upper_bound
	
	if status_effect_script.status_charges == 1 and status_effect_charge_upper_bound > 1:
		status_charge_label.text = ""
	else:
		status_charge_label.text = str(status_effect_script.status_charges)
	
	if status_effect_script.status_secondary_charges == 0:
		status_secondary_charge_label.text = ""
	else:
		status_secondary_charge_label.text = str(status_effect_script.status_secondary_charges)
		
	# texture
	var status_effect_texture_path: String = status_effect_data.get_status_effect_texture_path(status_effect_script.status_charges)
	texture = FileLoader.load_texture(status_effect_texture_path)

func _on_mouse_entered() -> void:
	UIHover.scale_up(self)
	var status_effect_data: StatusEffectData = status_effect_script.status_effect_data
	var bbcode: String = "[color=orange]" + status_effect_data.status_effect_name + "[/color]"
	
	if status_effect_data.status_effect_description != "":
		bbcode += "\n" + status_effect_data.status_effect_description
		
	if status_effect_data.status_effect_decay_rate != 0:
		bbcode += "\n每时钟周期衰减 " + str(abs(status_effect_data.status_effect_decay_rate)) + " 层。"
		
	if HandManager.tooltip != null:
		HandManager.tooltip.display_tooltip(bbcode, true)

func _on_mouse_exited() -> void:
	UIHover.scale_down(self)
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
