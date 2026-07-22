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
	
	var tooltip_text: String = status_effect_data.status_effect_tooltip
	if tooltip_text == "":
		tooltip_text = status_effect_data.status_effect_description
		
	if tooltip_text != "":
		var context: Dictionary = status_effect_script.get_tooltip_context()
		if not context.has("curiosity_current_counter"):
			context["curiosity_current_counter"] = 0
			
		var parsed_text: String = TextParser.parse(tooltip_text, context)
		bbcode += "\n" + parsed_text
		
	var decay_text = status_effect_data.get_decay_text()
	if decay_text != "":
		bbcode += " " + decay_text
		
	if HandManager.tooltip != null:
		HandManager.tooltip.display_tooltip(bbcode, true)

func _on_mouse_exited() -> void:
	UIHover.scale_down(self)
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
