extends BaseRewardButton

func init(_action_on_click: BaseAction, _reward_group: int) -> void:
	super(_action_on_click, _reward_group)
	
	var original_amount: int = _action_on_click.values.get("money_amount", 0)
	var processor: ActionInterceptorProcessor = _action_on_click._intercept_action([], true)[0]
	var money_amount: int = processor.get_shadowed_action_values("money_amount", original_amount)
	
	var arrow: String = ""
	if money_amount > original_amount:
		arrow = " ↑"
	elif money_amount < original_amount:
		arrow = " ↓"
		
	$HBoxContainer/TextLabel.text = "%s%s" % [money_amount, arrow]
	$HBoxContainer/IconRect.texture = preload("res://sprites/ui/icon_ui_money.png")

