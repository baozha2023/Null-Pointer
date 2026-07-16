extends Node

const ENERGY_ICON_KEYWORD: String = "[energy_icon]"
const ENERGY_ICON_BBCODE: String = "[img width=20]res://sprites/ui/icon_energy.png[/img]"

var status_icon_regex: RegEx = RegEx.new()
var status_name_regex: RegEx = RegEx.new()
var card_name_regex: RegEx = RegEx.new()
var artifact_name_regex: RegEx = RegEx.new()
var percent_regex: RegEx = RegEx.new()

func _ready():
	status_icon_regex.compile("\\[status_icon:([^\\]]+)\\]")
	status_name_regex.compile("\\[status_name:([^\\]]+)\\]")
	card_name_regex.compile("\\[card_name:([^\\]]+)\\]")
	artifact_name_regex.compile("\\[artifact_name:([^\\]]+)\\]")
	percent_regex.compile("\\[percent:([^\\]]+)\\]")

## Global text parser to parse macros, BBCode, variables, and icon mappings
func parse(template: String, values: Dictionary = {}, base_font_size: int = 14) -> String:
	var result: String = template
	var icon_size: int = base_font_size + 6
	var energy_icon_bbcode = "[img width=%d]res://sprites/ui/icon_energy.png[/img]" % icon_size

	# 1. Base Variables [key] -> values[key]
	for key in values:
		var value = values[key]
		var val_str = format_value(key, value)
		if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
			val_str = str(abs(value))
		result = result.replace("[" + key + "]", val_str)
	# 1.5 Percentage mappings [percent:key]
	for m in percent_regex.search_all(result):
		var full_match: String = m.get_string()
		var value_key: String = m.get_string(1)
		if not values.has(value_key):
			continue
		var percent_value: Variant = values[value_key]
		if typeof(percent_value) != TYPE_FLOAT and typeof(percent_value) != TYPE_INT:
			DebugLogger.log_error("TextParser.parse(): Percentage key \"{0}\" is not numeric".format([value_key]))
			continue
		var scaled_value: float = abs(float(percent_value)) * 100.0
		var replacement: String = str(int(scaled_value)) if is_equal_approx(scaled_value, round(scaled_value)) else str(snappedf(scaled_value, 0.01))
		result = result.replace(full_match, replacement + "%")

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

	# 2.5 Card name mappings [card_name:card_id_or_value_key]
	for m in card_name_regex.search_all(result):
		var full_match: String = m.get_string()
		var token: String = m.get_string(1)
		var card_id: String = str(values.get(token, token))
		var card_data = Global.get_card_data(card_id)
		if card_data:
			var color_hex = "#ffffff"
			var color_data = Global._id_to_color_data.get(card_data.card_color_id, null)
			if color_data:
				color_hex = "#" + color_data.color.to_html(false)
			var replacement = "[color=%s][%s][/color]" % [color_hex, card_data.card_name]
			result = result.replace(full_match, replacement)
		else:
			DebugLogger.log_error("TextParser.parse(): No card with ID of \"{0}\"".format([card_id]))
			result = result.replace(full_match, card_id)

	# 2.6 Artifact name mappings [artifact_name:artifact_id_or_value_key]
	for m in artifact_name_regex.search_all(result):
		var full_match: String = m.get_string()
		var token: String = m.get_string(1)
		var artifact_id: String = str(values.get(token, token))
		var artifact_data: ArtifactData = Global.get_artifact_data(artifact_id)
		if artifact_data:
			result = result.replace(full_match, artifact_data.artifact_name)
		else:
			DebugLogger.log_error("TextParser.parse(): No artifact with ID of \"{0}\"".format([artifact_id]))
			result = result.replace(full_match, artifact_id)

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
	if "artifact_rarities" in key and val is Array:
		var rarity_names: Array[String] = []
		for rarity: int in val:
			rarity_names.append(ArtifactData.ARTIFACT_RARITY_DISPLAY.get(rarity, "未知"))
		return "、".join(rarity_names)

	if "card_rarities" in key and val is Array:
		var rarity_names: Array[String] = []
		for rarity: int in val:
			rarity_names.append(CardData.CARD_RARITY_DISPLAY.get(rarity, "未知"))
		return "、".join(rarity_names)

	if "card_types" in key and val is Array:
		var type_names: Array = []
		for t in val:
			type_names.append(CardData.CARD_TYPE_DISPLAY.get(t, "未知脚本"))
		return "、".join(type_names)

	if val is Array and len(val) > 0 and val[0] is CardData:
		var card_names: Array = []
		for c in val:
			var color_hex = "#ffffff"
			var color_data = Global._id_to_color_data.get(c.card_color_id, null)
			if color_data:
				color_hex = "#" + color_data.color.to_html(false)
			card_names.append("[color=%s][%s][/color]" % [color_hex, c.card_name])
		return "、".join(card_names)

	return str(val)

## Formats an elapsed duration without wrapping after 24 hours.
## `zero_placeholder` is useful for records such as a fastest win that does not exist yet.
func format_duration(seconds_value: float, zero_placeholder: String = "") -> String:
	if seconds_value <= 0.0 and zero_placeholder != "":
		return zero_placeholder
	var total_seconds: int = max(0, int(seconds_value))
	var hours: int = total_seconds / 3600
	var minutes: int = total_seconds % 3600 / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

## Converts forge-style action entries into readable text. `fallback_values` follows the same
## value fallback idea used by card actions, which also makes this renderer reusable for delayed
## actions whose values were captured from a CardPlayRequest.
func parse_forge_actions_to_text(forge_actions: Array, fallback_values: Dictionary = {}) -> String:
	var display_text: String = ""
	for i in forge_actions.size():
		var entry: Dictionary = forge_actions[i]
		var action_data: Dictionary = entry.get("action_data", {})
		var custom_description: String = entry.get("description", "")

		var action_name: String = ""
		var action_detail: String = ""
		for action_path: String in action_data:
			action_name = action_path.get_file().replace(".gd", "").replace("Action", "")
			var action_values: Dictionary = action_data[action_path]
			var display_values: Dictionary = fallback_values.duplicate(true)
			display_values.merge(entry.get("display_values", {}), true)
			display_values.merge(action_values, true)

			if custom_description != "":
				action_detail = parse(custom_description, display_values)
			else:
				if action_path == Scripts.ACTION_ATTACK_GENERATOR or action_path == Scripts.ACTION_ATTACK:
					var damage: int = _get_action_display_value(action_values, fallback_values, "damage", 0)
					var amount: int = _get_action_display_value(action_values, fallback_values, "number_of_attacks", 1)
					if amount > 1:
						action_detail = "造成 %d 点伤害 %d 次" % [damage, amount]
					else:
						action_detail = "造成 %d 点伤害" % damage
				elif action_path == Scripts.ACTION_ADD_HEALTH:
					var health: int = _get_action_display_value(action_values, fallback_values, "health_amount", 0)
					action_detail = "恢复 %d 点完整度" % health
				elif action_path == Scripts.ACTION_BLOCK:
					var block: int = _get_action_display_value(action_values, fallback_values, "block", 0)
					action_detail = "获得 %d 点防火墙" % block
				elif action_path == Scripts.ACTION_DRAW or action_path == Scripts.ACTION_DRAW_GENERATOR:
					var amount: int = _get_action_display_value(action_values, fallback_values, "draw_count", 1)
					action_detail = "抽取 %d 张卡牌" % amount
				elif action_path == Scripts.ACTION_DIRECT_DAMAGE:
					var damage: int = _get_action_display_value(action_values, fallback_values, "damage", 1)
					action_detail = "造成 %d 点真实伤害" % damage
				elif action_path == Scripts.ACTION_APPLY_STATUS:
					var status_id: String = _get_action_display_value(action_values, fallback_values, "status_effect_object_id", "")
					var amount: int = _get_action_display_value(action_values, fallback_values, "status_charge_amount", 1)
					var raw_text = "施加 %d 层 [status_icon:%s]" % [amount, status_id]
					action_detail = parse(raw_text)
				elif action_path == Scripts.ACTION_ADD_ENERGY:
					var amount: int = _get_action_display_value(action_values, fallback_values, "energy_amount", 1)
					var raw_text = "获得 [amount_energy_icons]"
					action_detail = parse(raw_text, {"amount": amount})
				else:
					action_detail = JSON.stringify(action_values)

		display_text += "[color=orange][%d][/color] %s\n" % [i, action_name]
		display_text += "    [color=gray]%s[/color]\n" % action_detail

	return display_text.strip_edges()

func _get_action_display_value(action_values: Dictionary, fallback_values: Dictionary, key: String, default_value: Variant) -> Variant:
	var custom_key_names: Dictionary = action_values.get("custom_key_names", {})
	var resolved_key: String = custom_key_names.get(key, key)
	if action_values.has(resolved_key):
		return action_values[resolved_key]
	return fallback_values.get(resolved_key, default_value)
