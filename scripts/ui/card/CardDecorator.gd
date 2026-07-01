## UI component for a card decorator attached to a Card.
## See BaseCardDecorator for logical component.
extends TextureRect
class_name CardDecorator

@onready var card_decorator_value_label: Label = $CardDecoratorValueLabel

## The behavioral script instance for this card decorator
var card_decorator_script: BaseCardDecorator = null

## Object ID for the CardDecoratorData this corresponds to
var card_decorator_id: String = ""

## The Card UI element that this is attached to
var parent_card: Card = null

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func init(_parent_card: Card, _card_decorator_id: String) -> void:
	parent_card = _parent_card
	card_decorator_id = _card_decorator_id
	
	var card_decorator_data: CardDecoratorData = Global.get_card_decorator_data(card_decorator_id)
	
	# instantiate script
	var card_decorator_script_path: String = card_decorator_data.card_decorator_script_path
	var card_decorator_script_asset = load(card_decorator_script_path)
	card_decorator_script = card_decorator_script_asset.new(parent_card, card_decorator_data)
	
	# decorator only visible if a texure is defined for it
	visible = false
	if card_decorator_data.card_decorator_texture_path != "":
		visible = true
		if has_node("Background"):
			$Background.texture = FileLoader.load_texture(card_decorator_data.card_decorator_texture_path)
	
	_update_card_decorator_value_label()

## Updates the displayed value of the decorator to match the card's value
func _update_card_decorator_value_label() -> void:
	if visible:
		var card_decorator_data: CardDecoratorData = card_decorator_script.card_decorator_data
		var card_data: CardData = card_decorator_script.card_data
		if card_decorator_data.card_decorator_label_value_name != "":
			var card_label_value: int = card_data.card_values.get(card_decorator_data.card_decorator_label_value_name, 0)
			card_decorator_value_label.text = str(card_label_value)

func _on_mouse_entered() -> void:
	if visible and card_decorator_script != null:
		var decorator_data: CardDecoratorData = card_decorator_script.card_decorator_data
		var card_data: CardData = card_decorator_script.card_data
		var formatted_desc: String = decorator_data.card_decorator_description
		
		# Replace dynamic values like [decorator_value_block] with actual values from card_values
		if card_data != null:
			for key in card_data.card_values:
				formatted_desc = formatted_desc.replace("[" + key + "]", TextParser.format_value(key, card_data.card_values[key]))
				
		HandManager.tooltip.display_decorator_tooltip(decorator_data.card_decorator_name, formatted_desc)
		
	if parent_card != null:
		parent_card.card_hovered.emit(parent_card)

func _on_mouse_exited() -> void:
	HandManager.tooltip.hide_tooltip()
	if parent_card != null:
		parent_card.card_unhovered.emit(parent_card)
