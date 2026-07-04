extends Node

const ENERGY_ICON_KEYWORD: String = "[energy_icon]"
const ENERGY_ICON_BBCODE: String = "[img width=20]res://sprites/ui/icon_energy.png[/img]"

var status_icon_regex: RegEx = RegEx.new()
var status_name_regex: RegEx = RegEx.new()
var card_name_regex: RegEx = RegEx.new()

func _ready():
	status_icon_regex.compile("\\[status_icon:([^\\]]+)\\]")
	status_name_regex.compile("\\[status_name:([^\\]]+)\\]")
	card_name_regex.compile("\\[card_name:([^\\]]+)\\]")

## Global text parser to parse macros, BBCode, variables, and icon mappings
func parse(template: String, values: Dictionary = {}, base_font_size: int = 14) -> String:
	var result: String = template
	var icon_size: int = base_font_size + 8
	var energy_icon_bbcode = "[img width=%d]res://sprites/ui/icon_energy.png[/img]" % icon_size
	
	# 1. Base Variables [key] -> values[key]
	for key in values:
		var value = values[key]
		var val_str = format_value(key, value)
		if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
			val_str = str(abs(value))
		result = result.replace("[" + key + "]", val_str)
	# 2. Status icon and name mappings [status_icon:status_id], [status_name:status_id]
	for m in status_icon_regex.search_all(result):
		var full_match = m.get_string()
		var status_id = m.get_string(1)
		var status_data = Global.get_status_effect_data(status_id)
		if status_data and status_data.status_effect_texture_path != "":
			var img = "[img width=%d]%s[/img]" % [icon_size, status_data.status_effect_texture_path]
			result = result.replace(full_match, img)
		else:
			result = result.replace(full_match, "")

	for m in status_name_regex.search_all(result):
		var full_match = m.get_string()
		var status_id = m.get_string(1)
		var status_data = Global.get_status_effect_data(status_id)
		if status_data:
			result = result.replace(full_match, status_data.status_effect_name)
		else:
			result = result.replace(full_match, status_id)

	# 2.5 Card name mappings [card_name:card_id]
	for m in card_name_regex.search_all(result):
		var full_match = m.get_string()
		var card_id = m.get_string(1)
		var card_data = Global.get_card_data(card_id)
		if card_data:
			var color_hex = "#ffffff"
			var color_data = Global._id_to_color_data.get(card_data.card_color_id, null)
			if color_data:
				color_hex = "#" + color_data.color.to_html(false)
			var replacement = "[color=%s][%s][/color]" % [color_hex, card_data.card_name]
			result = result.replace(full_match, replacement)
		else:
			result = result.replace(full_match, card_id)
	
	# 3. Energy icons
	result = result.replace(ENERGY_ICON_KEYWORD, energy_icon_bbcode)
	
	for e_key in values:
		var value = values[e_key]
		var val_int = 0
		if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
			val_int = int(abs(value))
		
		var icons_str: String = ""
		if val_int <= 0:
			icons_str = "0 个"
		else:
			for i in range(val_int):
				icons_str += energy_icon_bbcode
		
		result = result.replace("[" + e_key + "_energy_icons]", icons_str)

	return result

func format_value(key: String, val: Variant) -> String:
	if "card_types" in key and val is Array:
		var type_names: Array = []
		for t in val:
			type_names.append(CardData.CARD_TYPE_DISPLAY.get(t, "未知脚本"))
		return "、".join(type_names)
	return str(val)
