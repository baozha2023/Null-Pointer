# Provides an overlay to pick and view cards
extends Control

@onready var card_container: GridContainer = $MarginContainer/MainVBox/ContentHBox/ScrollContainer/MarginContainer/CardContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/MainVBox/ContentHBox/ScrollContainer
@onready var card_picking_label: Label = $MarginContainer/MainVBox/HeaderVBox/CardPickLabel
@onready var confirm_button: Button = $MarginContainer/MainVBox/HeaderVBox/HBoxContainer/ConfirmButton
@onready var back_button: Button = $MarginContainer/MainVBox/HeaderVBox/HBoxContainer/BackButton

@onready var preview_vbox: VBoxContainer = $%PreviewVBox
@onready var level_label: Label = $%LevelLabel
@onready var preview_card_container: Control = $%PreviewCardContainer
@onready var downgrade_button: Button = $%DowngradeButton
@onready var upgrade_button: Button = $%UpgradeButton

var current_card_pick_action: ActionBasePickCards = null
var selected_card_data: CardData = null
var preview_target_level: int = 0
var preview_card: Card = null


func _ready():
	# 关闭自动跟随焦点，防止双击卡牌时列表自动滚动导致鼠标偏移而判定失败
	scroll_container.follow_focus = false
	
	Signals.card_pick_requested.connect(_on_card_pick_requested)
	Signals.card_pick_confirmed.connect(_on_card_pick_confirmed)
	
	confirm_button.button_up.connect(_on_confirm_button_up)
	back_button.button_up.connect(_on_back_button_up)
	downgrade_button.button_up.connect(_on_downgrade_button_up)
	upgrade_button.button_up.connect(_on_upgrade_button_up)
	
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)

func _on_card_pick_requested(card_pick_action: ActionBasePickCards):
	if card_pick_action != null:
		if card_pick_action.get_card_pick_type() == HandManager.UPGRADE_DECK:
			visible = true
			card_picking_label.visible = true
			back_button.visible = false
			confirm_button.visible = false
			current_card_pick_action = card_pick_action
			populate_cards(card_pick_action.get_pickable_cards())
			
			card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.visible = current_card_pick_action.are_enough_cards_picked()
			
			back_button.visible = current_card_pick_action.get_card_pick_can_back_out()

func _on_card_pick_confirmed():
	visible = false
	current_card_pick_action = null
	selected_card_data = null
	_update_preview()

func populate_cards(cards: Array[CardData]) -> void:
	clear_cards()

	for card_data in cards:
		var card: Card = Scenes.CARD.instantiate()
		card_container.add_child(card)
		card.init(card_data, 0, false, true)
		
		# bind signals
		card.card_hovered.connect(_on_card_hovered)
		card.card_unhovered.connect(_on_card_unhovered)
		card.card_selected.connect(_on_card_selected)

func clear_cards():
	for child in card_container.get_children():
		child.queue_free()

func _on_card_hovered(_card: Card):
	pass

func _on_card_unhovered(_card: Card):
	pass

func _on_card_selected(card: Card):
	if current_card_pick_action != null:
		var max_cards = current_card_pick_action.get_card_pick_max_amount()
		
		# unpick card
		if current_card_pick_action.picked_cards.has(card.card_data):
			current_card_pick_action.picked_cards.erase(card.card_data) # remove from picked cards
			card.set_card_glow(false)
			if selected_card_data == card.card_data:
				selected_card_data = null
				_update_preview()
		# pick card
		else:
			# card can be picked (pass false to bypass max size check so we can auto-switch)
			if current_card_pick_action.is_card_pickable(card.card_data, false):
				# Auto-switch for single selection
				if max_cards == 1 and len(current_card_pick_action.picked_cards) > 0:
					var old_card_data = current_card_pick_action.picked_cards[0]
					current_card_pick_action.picked_cards.clear()
					for child in card_container.get_children():
						if child.card_data == old_card_data:
							child.set_card_glow(false)
				
				# Ensure we still have room if it's multiple selection
				if len(current_card_pick_action.picked_cards) < max_cards:
					current_card_pick_action.picked_cards.append(card.card_data)	# add to picked cards
					card.set_card_glow(true)
					selected_card_data = card.card_data
					preview_target_level = min(selected_card_data.card_upgrade_amount + 1, selected_card_data.card_upgrade_amount_max)
					_update_preview()
				
		card_picking_label.text = current_card_pick_action.get_card_pick_text()
		confirm_button.visible = current_card_pick_action.are_enough_cards_picked()
		
		# quick pick automatically confirms
		if current_card_pick_action.is_quick_pick():
			_on_confirm_button_up()

func _on_confirm_button_up():
	visible = false
	Signals.card_pick_confirmed.emit()

func _on_back_button_up():
	visible = false
	if current_card_pick_action != null:
		current_card_pick_action.picked_cards = []
		Signals.card_pick_confirmed.emit()
	

	
func _update_preview() -> void:
	if preview_card != null:
		preview_card.queue_free()
		preview_card = null
		
	if selected_card_data == null:
		preview_vbox.visible = false
		return
		
	preview_vbox.visible = true
	
	# clamp preview target level (cannot preview below current level)
	preview_target_level = clamp(preview_target_level, selected_card_data.card_upgrade_amount, selected_card_data.card_upgrade_amount_max)
	
	# Duplicate the actual selected card to preserve dynamic modifications
	var preview_data: CardData = selected_card_data.duplicate(true)
	
	# Apply only the difference in upgrades
	var upgrades_needed = preview_target_level - selected_card_data.card_upgrade_amount
	if upgrades_needed > 0:
		preview_data.upgrade_card(upgrades_needed, true)
	
	preview_card = Scenes.CARD.instantiate()
	preview_card_container.add_child(preview_card)
	preview_card.set_anchors_preset(Control.PRESET_CENTER)
	preview_card.init(preview_data, 0, false, true)
	
	# Update labels and buttons
	level_label.text = "当前等级: %d / %d  |  预览等级: %d" % [selected_card_data.card_upgrade_amount, selected_card_data.card_upgrade_amount_max, preview_target_level]
	
	downgrade_button.disabled = (preview_target_level <= selected_card_data.card_upgrade_amount)
	upgrade_button.disabled = (preview_target_level >= selected_card_data.card_upgrade_amount_max)

func _on_upgrade_button_up() -> void:
	preview_target_level += 1
	_update_preview()

func _on_downgrade_button_up() -> void:
	preview_target_level -= 1
	_update_preview()

func _on_run_started():
	visible = false
func _on_run_ended():
	visible = false
	current_card_pick_action = null
	selected_card_data = null
	_update_preview()
