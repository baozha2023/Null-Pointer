class_name ActionBasePickOptions
extends BaseAsyncAction

var picked_options: Array[OptionData] = []

func perform_action():
	Signals.option_pick_requested.emit(self)
	async_awaiting = true
	await Signals.option_pick_confirmed
	async_awaiting = false
	perform_async_action()

func perform_async_action() -> void:
	# Override this to do something with picked_options, then emit action_async_finished
	action_async_finished.emit()

func force_action_end() -> void:
	if async_awaiting:
		Signals.option_pick_confirmed.emit()

func get_pickable_options() -> Array[OptionData]:
	return []

func is_option_pickable(_option: OptionData) -> bool:
	return true

func get_option_pick_max_amount() -> int:
	return get_action_value("max_picks", 1)

func are_enough_options_picked() -> bool:
	var min_amount: int = get_action_value("min_picks", 1)
	return len(picked_options) >= min_amount

func get_option_pick_text() -> String:
	return get_action_value("pick_text", "Choose an Option")

func is_quick_pick() -> bool:
	return get_action_value("is_quick_pick", false)

func get_option_pick_can_back_out() -> bool:
	return get_action_value("can_back_out", false)
