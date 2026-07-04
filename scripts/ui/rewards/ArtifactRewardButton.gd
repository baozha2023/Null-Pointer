extends BaseRewardButton

var artifact_data: ArtifactData = null

func init(_action_on_click: BaseAction, _reward_group: int) -> void:
	super(_action_on_click, _reward_group)
	
	var artifact_id: String = _action_on_click.values.get("artifact_id", "")
	artifact_data = Global.get_artifact_data(artifact_id)
	if artifact_data != null:
		$HBoxContainer/TextLabel.text = artifact_data.artifact_name
		$HBoxContainer/IconRect.texture = FileLoader.load_texture(artifact_data.artifact_texture_path)
		
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		tree_exiting.connect(_on_mouse_exited)

func _on_mouse_entered():
	if HandManager.tooltip != null and artifact_data != null:
		HandManager.tooltip.display_codex_artifact_tooltip(artifact_data)

func _on_mouse_exited():
	if HandManager.tooltip != null and HandManager.tooltip.visible:
		HandManager.tooltip.hide_tooltip()
