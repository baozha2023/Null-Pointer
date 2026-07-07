# Provides an overlay to pick and view cards
extends Control

@onready var card_container: GridContainer = $ScrollContainer/MarginContainer/CardContainer
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var card_picking_label: Label = $CardPickLabel
@onready var confirm_button: Button = $ConfirmButton
@onready var back_button: Button = $BackButton
@onready var left_panel: VBoxContainer = $LeftPanel
@onready var card_pack_container: VBoxContainer = $LeftPanel/CardPackContainer
@onready var search_line_edit: LineEdit = $LeftPanel/SearchLineEdit

var all_pickable_cards: Array[CardData] = []
var selected_card_pack_data: CardPackData = null
var current_search_text: String = ""

var current_card_pick_action: ActionBasePickCards = null	# an action currently requesting cards from the player to select. If null clicking cards plays them

enum CARD_MODES {VIEW, SELECT}
var card_mode: int = CARD_MODES.VIEW	# determines to view or select the card when a card is clicked 


func _ready():
	# 关闭自动跟随焦点，防止双击卡牌时列表自动滚动导致鼠标偏移而判定失败
	scroll_container.follow_focus = false
	
	Signals.card_pick_requested.connect(_on_card_pick_requested)
	Signals.card_pick_confirmed.connect(_on_card_pick_confirmed)
	
	confirm_button.button_up.connect(_on_confirm_button_up)
	back_button.button_up.connect(_on_back_button_up)
	search_line_edit.text_changed.connect(_on_search_text_changed)
	
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)

func _on_card_pick_requested(card_pick_action: ActionBasePickCards):
	if card_pick_action != null:
		if HandManager.DECK_PICK_TYPES.has(card_pick_action.get_card_pick_type()):
			var show_filter: bool = false
			if card_pick_action.has_method("is_filter_enabled") and card_pick_action.is_filter_enabled():
				show_filter = true
				
			set_card_mode(CARD_MODES.SELECT, show_filter)
			current_card_pick_action = card_pick_action
			all_pickable_cards = card_pick_action.get_pickable_cards()
			
			if show_filter:
				current_search_text = ""
				search_line_edit.text = ""
				_populate_card_packs()
			else:
				selected_card_pack_data = null
				current_search_text = ""
				search_line_edit.text = ""
				populate_cards(all_pickable_cards)
			
			card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.visible = true
			confirm_button.disabled = not current_card_pick_action.are_enough_cards_picked()
			
			back_button.visible = current_card_pick_action.get_card_pick_can_back_out()

func _on_card_pick_confirmed():
	visible = false
	current_card_pick_action = null

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

func _populate_card_packs() -> void:
	for child in card_pack_container.get_children():
		child.queue_free()
	
	var card_pack_bg = ButtonGroup.new()
	var is_first = true
	
	var card_pack_ids: Array = Global._id_to_card_pack_data.keys()
	card_pack_ids.erase("card_pack_all")
	card_pack_ids.push_front("card_pack_all")
	
	for card_pack_id: String in card_pack_ids:
		var card_pack_data: CardPackData = Global.get_card_pack_data(card_pack_id)
		if card_pack_data == null or not card_pack_data.card_pack_displays_in_codex:
			continue
			
		var card_pack_button: CodexCardPackButton = Scenes.CODEX_CARD_PACK_BUTTON.instantiate()
		card_pack_container.add_child(card_pack_button)
		
		card_pack_button.toggle_mode = true
		card_pack_button.button_group = card_pack_bg
		if is_first:
			card_pack_button.button_pressed = true
			selected_card_pack_data = card_pack_data
			is_first = false
		
		card_pack_button.init(card_pack_data)
		card_pack_button.codex_card_card_pack_button_pressed.connect(_on_card_pack_button_pressed)
	
	_filter_and_populate_cards()

func _on_card_pack_button_pressed(card_pack_data: CardPackData) -> void:
	selected_card_pack_data = card_pack_data
	_filter_and_populate_cards()

func _on_search_text_changed(new_text: String) -> void:
	current_search_text = new_text.to_lower()
	_filter_and_populate_cards()

func _filter_and_populate_cards() -> void:
	var filtered_cards: Array[CardData] = []
	for card in all_pickable_cards:
		var color_match = false
		if selected_card_pack_data == null or selected_card_pack_data.object_id == "card_pack_all":
			color_match = true
		elif card.card_color_id == selected_card_pack_data.card_pack_color_id:
			color_match = true
			
		var search_match = false
		if current_search_text == "":
			search_match = true
		elif current_search_text in card.card_name.to_lower():
			search_match = true
			
		if color_match and search_match:
			filtered_cards.append(card)
			
	populate_cards(filtered_cards)

func _on_card_hovered(_card: Card):
	UIHover.scale_up(_card)

func _on_card_unhovered(_card: Card):
	UIHover.scale_down(_card)

func _on_card_selected(card: Card):
	if card_mode == CARD_MODES.SELECT:
		if current_card_pick_action != null:
			# unpick card
			if current_card_pick_action.picked_cards.has(card.card_data):
				current_card_pick_action.picked_cards.erase(card.card_data) # remove from picked cards
				card.set_card_glow(false)
			# pick card
			else:
				# card can be picked
				if current_card_pick_action.is_card_pickable(card.card_data):
					current_card_pick_action.picked_cards.append(card.card_data)	# add to picked cards
					card.set_card_glow(true)
					
			card_picking_label.text = current_card_pick_action.get_card_pick_text()
			confirm_button.disabled = not current_card_pick_action.are_enough_cards_picked()
			
			# quick pick automatically confirms
			if current_card_pick_action.is_quick_pick():
				_on_confirm_button_up()
			
	else:
		pass

func _on_confirm_button_up():
	visible = false
	Signals.card_pick_confirmed.emit()

func _on_back_button_up():
	visible = false
	if current_card_pick_action != null:
		current_card_pick_action.picked_cards = []
		Signals.card_pick_confirmed.emit()
	
### View mode wrappers

func set_card_mode(_card_mode: int, show_left_panel: bool = false) -> void:
	card_mode = _card_mode
	
	visible = true
	card_picking_label.visible = false
	back_button.visible = false
	confirm_button.visible = false
	left_panel.visible = show_left_panel
	
	if card_mode == CARD_MODES.VIEW:
		back_button.visible = true
	if card_mode == CARD_MODES.SELECT:
		confirm_button.visible = true
		card_picking_label.visible = true
	

func view_deck() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(Global.player_data.player_deck)

func view_draw_pile() -> void:
	set_card_mode(CARD_MODES.VIEW)
	# randomize the draw pile so player's can't see next cards
	var randomized_draw: Array[CardData] = HandManager.player_draw.duplicate(false)
	randomized_draw.shuffle() #NOTE: this doesn't need to be deterministic
	populate_cards(randomized_draw)

func view_draw_top() -> void:
	set_card_mode(CARD_MODES.VIEW)
	# show top 5 cards from draw pile in order (actual draw order)
	var player_draw: Array[CardData] = HandManager.player_draw
	var top_count: int = min(5, len(player_draw))
	var top_cards: Array[CardData] = []
	for i: int in top_count:
		top_cards.append(player_draw[-(i + 1)])
	populate_cards(top_cards)

func view_discard() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(HandManager.player_discard)

func view_exhaust() -> void:
	set_card_mode(CARD_MODES.VIEW)
	populate_cards(HandManager.player_exhaust)
	
func _on_run_started():
	visible = false
func _on_run_ended():
	visible = false
	current_card_pick_action = null
