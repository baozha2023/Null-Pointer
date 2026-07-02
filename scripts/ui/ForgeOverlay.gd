extends Control

@onready var close_button: TextureButton = %CloseButton
@onready var title_label: Label = %TitleLabel
@onready var action_list_label: RichTextLabel = %ActionListLabel

func _ready():
	visible = false
	close_button.button_up.connect(_on_close_button_up)

	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)
	Signals.combat_started.connect(_on_combat_started)
	Signals.combat_ended.connect(_on_combat_ended)
	Signals.forge_actions_changed.connect(_on_forge_actions_changed)

func show_overlay():
	visible = true
	_refresh_display()

func hide_overlay():
	visible = false

func _on_close_button_up():
	hide_overlay()

func _on_run_started():
	visible = false

func _on_run_ended():
	visible = false

func _on_combat_started(_event_id: String):
	# Initialize forge storage for this combat
	Global.player_data.player_values["forge_actions"] = []
	_clear_artifact_counter()

func _on_combat_ended():
	# Clear forge on combat end (single combat scope)
	Global.player_data.player_values["forge_actions"] = []
	_clear_artifact_counter()
	visible = false

func _clear_artifact_counter():
	var artifacts: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge")
	if not artifacts.is_empty():
		artifacts[0].set_artifact_counter(0)

func _on_forge_actions_changed():
	if visible:
		_refresh_display()

func _refresh_display():
	var forge_actions: Array = Global.player_data.player_values.get("forge_actions", [])
	title_label.text = "锻造台（%d 条）" % forge_actions.size()

	if forge_actions.is_empty():
		action_list_label.text = "[color=gray]锻造台为空。使用「代码采集」类卡牌来存入效果。[/color]"
		return

	var display_text: String = ""
	for i in forge_actions.size():
		var entry: Dictionary = forge_actions[i]
		var action_data: Dictionary = entry.get("action_data", {})
		var load: int = entry.get("load", 0)
		var custom_description: String = entry.get("description", "")

		var action_name: String = ""
		var action_detail: String = ""
		for action_path: String in action_data:
			action_name = action_path.get_file().replace(".gd", "").replace("Action", "")
			
			if custom_description != "":
				action_detail = TextParser.parse(custom_description, action_data[action_path])
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
					action_detail = TextParser.parse(raw_text)
				elif action_path == Scripts.ACTION_ADD_ENERGY:
					var amount = action_data[action_path].get("energy_amount", 1)
					var raw_text = "获得 [amount_energy_icons]"
					action_detail = TextParser.parse(raw_text, {"amount": amount})
				else:
					action_detail = JSON.stringify(action_data[action_path])

		display_text += "[color=orange][%d][/color] %s\n" % [i, action_name]
		display_text += "    [color=gray]%s[/color]\n" % action_detail

	action_list_label.text = display_text
