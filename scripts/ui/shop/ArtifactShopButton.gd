extends BaseShopButton

@onready var button: Button = $Button

func _ready():
	button.button_up.connect(_on_button_up)

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)
	
	var artifact_id: String = _action_on_click.values.get("artifact_id", "")
	var artifact_data: ArtifactData = Global.get_artifact_data(artifact_id)
	if artifact_data != null:
		button.icon = FileLoader.load_texture(artifact_data.artifact_texture_path)
		button.mouse_entered.connect(func(): HandManager.tooltip.display_codex_artifact_tooltip(artifact_data))
		button.mouse_exited.connect(func(): HandManager.tooltip.hide_tooltip())
