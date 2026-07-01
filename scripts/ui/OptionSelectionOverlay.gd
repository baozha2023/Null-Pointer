extends Control

@export var option_item_scene: PackedScene

@onready var prompt_label: Label = %PromptLabel
@onready var option_container: VBoxContainer = %OptionContainer
@onready var back_button: Button = %BackButton
@onready var confirm_button: Button = %ConfirmButton

var current_action: ActionBasePickOptions = null
var option_items: Array[OptionItem] = []

func _ready():
	visible = false
	Signals.option_pick_requested.connect(_on_option_pick_requested)
	
	back_button.button_up.connect(_on_back_button_up)
	confirm_button.button_up.connect(_on_confirm_button_up)
	
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)

func _on_option_pick_requested(action: ActionBasePickOptions):
	if action != null:
		current_action = action
		visible = true
		populate_options(action.get_pickable_options())
		update_ui_state()

func populate_options(options: Array[OptionData]):
	clear_options()
	
	for option_data in options:
		var item: OptionItem = option_item_scene.instantiate()
		option_container.add_child(item)
		item.init(option_data)
		item.option_clicked.connect(_on_option_clicked)
		option_items.append(item)

func clear_options():
	for child in option_container.get_children():
		child.queue_free()
	option_items.clear()

func _on_option_clicked(option_data: OptionData):
	if current_action == null:
		return
		
	# Unpick if already picked
	if current_action.picked_options.has(option_data):
		current_action.picked_options.erase(option_data)
	else:
		# Pick if pickable
		if current_action.is_option_pickable(option_data):
			current_action.picked_options.append(option_data)
			# Enforce max picks logic if needed (handled visually or in action)
			var max_picks: int = current_action.get_option_pick_max_amount()
			if max_picks > 0 and len(current_action.picked_options) > max_picks:
				# pop oldest
				current_action.picked_options.pop_front()
	
	update_ui_state()
	
	if current_action.is_quick_pick() and current_action.are_enough_options_picked():
		_on_confirm_button_up()

func update_ui_state():
	if current_action == null:
		return
		
	prompt_label.text = current_action.get_option_pick_text()
	confirm_button.visible = current_action.are_enough_options_picked()
	back_button.visible = current_action.get_option_pick_can_back_out()
	
	for item in option_items:
		item.set_selected(current_action.picked_options.has(item.option_data))

func _on_confirm_button_up():
	visible = false
	var action_temp = current_action
	current_action = null
	Signals.option_pick_confirmed.emit()

func _on_back_button_up():
	visible = false
	if current_action != null:
		current_action.picked_options.clear()
	var action_temp = current_action
	current_action = null
	Signals.option_pick_confirmed.emit()

func _on_run_started():
	visible = false

func _on_run_ended():
	visible = false
