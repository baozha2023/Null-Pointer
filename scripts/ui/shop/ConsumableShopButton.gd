extends BaseShopButton

@onready var button: Button = $Button

func _ready():
	button.button_up.connect(_on_button_up)

func init(_action_on_click: BaseAction) -> void:
	super(_action_on_click)
	
	var consumable_object_id: String = _action_on_click.values.get("consumable_object_id", "")
	var consumable_data: ConsumableData = Global.get_consumable_data(consumable_object_id)
	if consumable_data != null:
		button.icon = FileLoader.load_texture(consumable_data.consumable_texture_path)
		button.mouse_entered.connect(func(): HandManager.tooltip.display_codex_consumable_tooltip(consumable_data))
		button.mouse_exited.connect(func(): HandManager.tooltip.hide_tooltip())
