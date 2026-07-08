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

func parse_forge_actions_to_text(forge_actions: Array) -> String:
	var display_text: String = ""
	for i in forge_actions.size():
		var entry: Dictionary = forge_actions[i]
		var action_data: Dictionary = entry.get("action_data", {})
		var custom_description: String = entry.get("description", "")

		var action_name: String = ""
		var action_detail: String = ""
		for action_path: String in action_data:
			action_name = action_path.get_file().replace(".gd", "").replace("Action", "")
			
			if custom_description != "":
				action_detail = parse(custom_description, action_data[action_path])
			else:
				if action_path == Scripts.ACTION_ATTACK_GENERATOR or action_path == Scripts.ACTION_ATTACK:
					var damage = action_data[action_path].get("damage", 0)
					var amount = action_data[action_path].get("number_of_attacks", 1)
					if amount > 1:
						action_detail = "造成 %d 点伤害 %d 次" % [damage, amount]
					else:
						action_detail = "造成 %d 点伤害" % damage
				elif action_path == Scripts.ACTION_ADD_HEALTH:
					var health = action_data[action_path].get("health_amount", 0)
					action_detail = "恢复 %d 点完整度" % health
				elif action_path == Scripts.ACTION_BLOCK:
					var block = action_data[action_path].get("block", 0)
					action_detail = "获得 %d 点防火墙" % block
				elif action_path == Scripts.ACTION_DRAW or action_path == Scripts.ACTION_DRAW_GENERATOR:
					var amount = action_data[action_path].get("draw_count", 1)
					action_detail = "抽取 %d 张卡牌" % amount
				elif action_path == Scripts.ACTION_DIRECT_DAMAGE:
					var damage = action_data[action_path].get("damage", 1)
					action_detail = "造成 %d 点真实伤害" % damage
				elif action_path == Scripts.ACTION_APPLY_STATUS:
					var status_id = action_data[action_path].get("status_effect_object_id", "")
					var amount = action_data[action_path].get("status_charge_amount", 1)
					var raw_text = "施加 %d 层 [status_icon:%s]" % [amount, status_id]
					action_detail = parse(raw_text)
				elif action_path == Scripts.ACTION_ADD_ENERGY:
					var amount = action_data[action_path].get("energy_amount", 1)
					var raw_text = "获得 [amount_energy_icons]"
					action_detail = parse(raw_text, {"amount": amount})
				else:
					action_detail = JSON.stringify(action_data[action_path])

		display_text += "[color=orange][%d][/color] %s\n" % [i, action_name]
		display_text += "    [color=gray]%s[/color]\n" % action_detail

	return display_text.strip_edges()
