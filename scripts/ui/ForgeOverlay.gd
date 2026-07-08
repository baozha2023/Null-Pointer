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
	var actual_load: int = 0
	for entry in forge_actions:
		actual_load += entry.get("load", 0)
	title_label.text = "锻造台（实际负载：%d）" % actual_load

	if forge_actions.is_empty():
		action_list_label.text = "[color=gray]锻造台为空。使用「代码采集」类卡牌来存入效果。[/color]"
		return

	action_list_label.text = TextParser.parse_forge_actions_to_text(forge_actions)
