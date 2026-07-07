class_name CardEnchantOverlay
extends Control

@onready var card_container: GridContainer = $MarginContainer/MainVBox/ContentHBox/ScrollContainer/MarginContainer/CardContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/MainVBox/ContentHBox/ScrollContainer
@onready var card_picking_label: Label = $MarginContainer/MainVBox/HeaderVBox/CardPickLabel
@onready var confirm_button: Button = $MarginContainer/MainVBox/HeaderVBox/HBoxContainer/ConfirmButton
@onready var back_button: Button = $MarginContainer/MainVBox/HeaderVBox/HBoxContainer/BackButton

@onready var enchant_vbox: VBoxContainer = $MarginContainer/MainVBox/ContentHBox/EnchantVBox
@onready var enchant_list_container: VBoxContainer = $%EnchantListContainer
@onready var confirm_enchant_button: Button = $%ConfirmEnchantButton

@onready var preview_vbox: VBoxContainer = $%PreviewVBox
@onready var preview_card_container: Control = $%PreviewCardContainer

var current_card_pick_action: ActionBasePickCards = null
var selected_card_data: CardData = null
var selected_enchant_id: String = ""
var preview_card: Card = null

func _ready():
	# 关闭自动跟随焦点，防止双击卡牌时列表自动滚动导致鼠标偏移而判定失败
	scroll_container.follow_focus = false
	
	Signals.card_pick_requested.connect(_on_card_pick_requested)
	Signals.card_pick_confirmed.connect(_on_card_pick_confirmed)
	
	confirm_button.button_up.connect(_on_confirm_button_up)
	back_button.button_up.connect(_on_back_button_up)
	confirm_enchant_button.button_up.connect(_on_confirm_enchant_button_up)
	
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)

func _on_card_pick_requested(card_pick_action: ActionBasePickCards):
	if card_pick_action != null:
		if card_pick_action.get_card_pick_type() == HandManager.ENCHANT_DECK:
			visible = true
			card_picking_label.visible = true
			confirm_button.visible = true
			confirm_button.disabled = true
			current_card_pick_action = card_pick_action
			populate_cards(card_pick_action.get_pickable_cards())
			
			var max_cards = current_card_pick_action.get_card_pick_max_amount()
			if max_cards > 1:
				card_picking_label.text = "%s (剩余: %d)" % [current_card_pick_action.get_card_pick_text(), max_cards]
			else:
				card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.disabled = true # Not using the generic confirm button
			
			back_button.visible = current_card_pick_action.get_card_pick_can_back_out()

func _on_card_pick_confirmed():
	visible = false
	current_card_pick_action = null
	selected_card_data = null
	_update_enchant_list()
	_update_preview()

func populate_cards(cards: Array[CardData]) -> void:
	clear_cards()

	for card_data in cards:
		var card: Card = Scenes.CARD.instantiate()
		card_container.add_child(card)
		card.init(card_data, 0, false, true)
		
		if current_card_pick_action != null and not current_card_pick_action.is_card_pickable(card_data, false):
			card.modulate = Color(0.3, 0.3, 0.3, 1.0)
		
		# bind signals
		card.card_hovered.connect(_on_card_hovered)
		card.card_unhovered.connect(_on_card_unhovered)
		card.card_selected.connect(_on_card_selected)

func clear_cards():
	for child in card_container.get_children():
		child.queue_free()

func _on_card_hovered(_card: Card):
	UIHover.scale_up(_card)

func _on_card_unhovered(_card: Card):
	UIHover.scale_down(_card)

func _on_card_selected(card: Card):
	if current_card_pick_action != null:
		if not current_card_pick_action.is_card_pickable(card.card_data, false):
			return
			
		# unpick card
		if selected_card_data == card.card_data:
			selected_card_data = null
			card.set_card_glow(false)
			_update_enchant_list()
			_update_preview()
		# pick card
		else:
			if selected_card_data != null:
				for child in card_container.get_children():
					if child.card_data == selected_card_data:
						child.set_card_glow(false)
			
			selected_card_data = card.card_data
			card.set_card_glow(true)
			_update_enchant_list()
			_update_preview()

func _on_confirm_button_up():
	visible = false
	Signals.card_pick_confirmed.emit()

func _on_back_button_up():
	visible = false
	if current_card_pick_action != null:
		current_card_pick_action.picked_cards = []
		Signals.card_pick_confirmed.emit()

func _update_enchant_list() -> void:
	for child in enchant_list_container.get_children():
		child.queue_free()
		
	selected_enchant_id = ""
	confirm_enchant_button.disabled = true
	confirm_enchant_button.text = "确认附魔"
	
	if selected_card_data == null:
		enchant_vbox.visible = false
		return
		
	enchant_vbox.visible = true
	
	var valid_enchants: Array[String] = []
	for decorator_id in GlobalProdDecoratorsGenerator.REST_SITE_ENCHANT_POOL:
		if selected_card_data.is_card_decorator_applicable(decorator_id):
			valid_enchants.append(decorator_id)
			
	if len(valid_enchants) == 0:
		var no_enchant_label = Label.new()
		no_enchant_label.text = "无可用的附魔"
		no_enchant_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		enchant_list_container.add_child(no_enchant_label)
		return
		
	# 随机附魔按钮
	var random_btn = Button.new()
	random_btn.text = "随机附魔 (25 金币)"
	random_btn.custom_minimum_size = Vector2(0, 40)
	random_btn.button_up.connect(_on_enchant_option_selected.bind("random"))
	random_btn.mouse_entered.connect(func(): HandManager.tooltip.display_decorator_tooltip("随机附魔", "从所有可用的附魔中随机抽取一个应用至该卡牌。"))
	random_btn.mouse_exited.connect(func(): HandManager.tooltip.hide_tooltip())
	enchant_list_container.add_child(random_btn)
	
	# 指定附魔按钮
	for decorator_id in valid_enchants:
		var decorator_data = Global.get_card_decorator_data(decorator_id)
		var btn = Button.new()
		btn.text = "%s (100 金币)" % decorator_data.card_decorator_name
		btn.custom_minimum_size = Vector2(0, 40)
		btn.button_up.connect(_on_enchant_option_selected.bind(decorator_id))
		
		var context = {}
		context.merge(decorator_data.card_decorator_value_changes)
		context.merge(decorator_data.card_decorator_value_improvements)
		var desc = TextParser.parse(decorator_data.card_decorator_description, context)
		btn.mouse_entered.connect(func(): HandManager.tooltip.display_decorator_tooltip(decorator_data.card_decorator_name, desc))
		btn.mouse_exited.connect(func(): HandManager.tooltip.hide_tooltip())
		
		enchant_list_container.add_child(btn)

func _on_enchant_option_selected(id: String) -> void:
	selected_enchant_id = id
	confirm_enchant_button.disabled = false
	
	var cost = 25 if selected_enchant_id == "random" else 100
	if Global.player_data.player_money < cost:
		confirm_enchant_button.text = "金币不足"
		confirm_enchant_button.disabled = true
	else:
		confirm_enchant_button.text = "确认附魔"
	
	# Highlight selected
	var idx = 0
	var valid_enchants: Array[String] = []
	for decorator_id in GlobalProdDecoratorsGenerator.REST_SITE_ENCHANT_POOL:
		if selected_card_data.is_card_decorator_applicable(decorator_id):
			valid_enchants.append(decorator_id)
			
	for child in enchant_list_container.get_children():
		if child is Button:
			var is_selected = false
			if selected_enchant_id == "random" and idx == 0:
				is_selected = true
			elif idx > 0 and selected_enchant_id == valid_enchants[idx - 1]:
				is_selected = true
			
			if is_selected:
				child.add_theme_color_override("font_color", Color.YELLOW)
			else:
				child.remove_theme_color_override("font_color")
			idx += 1
			
	_update_preview()

func _on_confirm_enchant_button_up() -> void:
	if selected_enchant_id == "" or selected_card_data == null:
		return
		
	var cost = 25 if selected_enchant_id == "random" else 100
	if Global.player_data.player_money < cost:
		return
		
	Global.player_data.add_money(-cost)
	
	var chosen_id = selected_enchant_id
	if chosen_id == "random":
		var valid_enchants: Array[String] = []
		for decorator_id in GlobalProdDecoratorsGenerator.REST_SITE_ENCHANT_POOL:
			if selected_card_data.is_card_decorator_applicable(decorator_id):
				valid_enchants.append(decorator_id)
		
		# select randomly
		var rng = Global.player_data.get_player_rng("rng_card_picking")
		chosen_id = valid_enchants[rng.randi_range(0, len(valid_enchants) - 1)]
		
	selected_card_data.add_card_decorator(chosen_id, {})
	
	current_card_pick_action.picked_cards.append(selected_card_data)
	
	var max_cards = current_card_pick_action.get_card_pick_max_amount()
	if len(current_card_pick_action.picked_cards) >= max_cards:
		# Complete the pick action
		_on_confirm_button_up()
	else:
		selected_card_data = null
		selected_enchant_id = ""
		populate_cards(current_card_pick_action.get_pickable_cards())
		_update_enchant_list()
		_update_preview()
		
		var remaining = max_cards - len(current_card_pick_action.picked_cards)
		card_picking_label.text = "%s (剩余: %d)" % [current_card_pick_action.get_card_pick_text(), remaining]

func _update_preview() -> void:
	if preview_card != null:
		preview_card.queue_free()
		preview_card = null
		
	if selected_card_data == null:
		preview_vbox.visible = false
		return
		
	preview_vbox.visible = true
	
	var preview_data: CardData = selected_card_data.get_prototype(true)
	
	if selected_enchant_id != "" and selected_enchant_id != "random":
		preview_data.add_card_decorator(selected_enchant_id, {})
		
	preview_card = Scenes.CARD.instantiate()
	preview_card_container.add_child(preview_card)
	preview_card.set_anchors_preset(Control.PRESET_CENTER)
	preview_card.init(preview_data, 0, false, true)

func _on_run_started():
	visible = false
func _on_run_ended():
	visible = false
	current_card_pick_action = null
	selected_card_data = null
	_update_preview()
