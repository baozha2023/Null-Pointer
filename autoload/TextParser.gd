extends Node

const ENERGY_ICON_KEYWORD: String = "[energy_icon]"
const ENERGY_ICON_BBCODE: String = "[img width=24]res://sprites/ui/icon_energy.png[/img]"

var status_icon_regex: RegEx = RegEx.new()
var status_name_regex: RegEx = RegEx.new()

func _ready():
	status_icon_regex.compile("\\[status_icon:([^\\]]+)\\]")
	status_name_regex.compile("\\[status_name:([^\\]]+)\\]")

## Global text parser to parse macros, BBCode, variables, and icon mappings
func parse(template: String, values: Dictionary = {}) -> String:
	var result: String = template
	
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
			var img = "[img width=24]%s[/img]" % status_data.status_effect_texture_path
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
	
	# 3. Energy icons
	result = result.replace(ENERGY_ICON_KEYWORD, ENERGY_ICON_BBCODE)
	
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
				icons_str += ENERGY_ICON_BBCODE
		
		result = result.replace("[" + e_key + "_energy_icons]", icons_str)

	return result

func format_value(key: String, val: Variant) -> String:
	if "card_types" in key and val is Array:
		var type_names: Array = []
		for t in val:
			type_names.append(CardData.CARD_TYPE_DISPLAY.get(t, "未知脚本"))
		return "、".join(type_names)
	return str(val)
