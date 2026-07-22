## Pure presentation component for a combatant's projected incoming damage.
## Combat logic supplies the value; this node owns only display and hover UI.
extends HBoxContainer
class_name IncomingDamageIndicator

@onready var amount_label: Label = $IncomingDamageAmount
@onready var intent_texture: TextureRect = $TextureRect

var amount: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intent_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	set_amount(0)

func set_amount(value: int, combatant_is_alive: bool = true) -> void:
	amount = maxi(value, 0)
	amount_label.text = str(amount)
	visible = amount > 0 and combatant_is_alive

func _on_mouse_entered() -> void:
	UIHover.scale_up(self)
	if HandManager.tooltip != null:
		HandManager.tooltip.display_tooltip(
			"[color=red]预计承伤[/color]\n本轮即将受到 %d 点总伤害。" % amount,
			true,
		)

func _on_mouse_exited() -> void:
	UIHover.scale_down(self)
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
