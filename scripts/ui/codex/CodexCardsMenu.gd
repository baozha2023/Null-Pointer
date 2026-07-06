## Displays cards tab in the codex
extends BaseMenu

@onready var codex_card_rgsc: ResizingGridScrollContainer = %CodexCardRGSC
@onready var codex_card_pack_container: VBoxContainer = %CodexCardPackContainer

@onready var codex_card_rarity_sort_button: Button = %CodexCardRaritySortButton
@onready var codex_card_cost_sort_button: Button = %CodexCardCostSortButton
@onready var codex_card_type_sort_button: Button = %CodexCardTypeSortButton
@onready var codex_card_detail_panel: Control = %CodexCardDetailPanel
@onready var codex_search_line_edit: LineEdit = %CodexSearchLineEdit

enum SortMode { RARITY, COST, TYPE }
var current_sort_mode: SortMode = SortMode.RARITY

var selected_card_pack_data: CardPackData = null
var current_search_text: String = ""

func _ready() -> void:
	codex_card_rarity_sort_button.toggle_mode = true
	codex_card_cost_sort_button.toggle_mode = true
	codex_card_type_sort_button.toggle_mode = true
	
	# 关闭自动跟随焦点，防止双击卡牌时列表自动滚动导致鼠标偏移而判定失败
	codex_card_rgsc.follow_focus = false
	
	codex_search_line_edit.text_changed.connect(_on_search_text_changed)
	
	# 优化布局：增大卡牌的左右和上下间距
	codex_card_rgsc.grid_container.add_theme_constant_override("h_separation", 45)
	codex_card_rgsc.grid_container.add_theme_constant_override("v_separation", 45)
	
	var bg = ButtonGroup.new()
	codex_card_rarity_sort_button.button_group = bg
	codex_card_cost_sort_button.button_group = bg
	codex_card_type_sort_button.button_group = bg
	
	codex_card_rarity_sort_button.button_pressed = true
	
	codex_card_rarity_sort_button.pressed.connect(func(): _set_sort_mode(SortMode.RARITY))
	codex_card_cost_sort_button.pressed.connect(func(): _set_sort_mode(SortMode.COST))
	codex_card_type_sort_button.pressed.connect(func(): _set_sort_mode(SortMode.TYPE))

func populate_menu() -> void:
	super()
	
	_populate_codex_card_packs()
	
	if len(codex_card_pack_container.get_children()) > 0:
		var card_pack_button: CodexCardPackButton = codex_card_pack_container.get_child(0)
		selected_card_pack_data = card_pack_button.card_pack_data # display first card pack

	_populate_codex_cards(selected_card_pack_data) # display all cards
	
	codex_card_rgsc.call_deferred("resize_grid_columns")

func clear_menu() -> void:
	super()
	_clear_codex_card_packs()
	codex_card_rgsc.clear_children()

# creates buttons to filter by card pack
func _populate_codex_card_packs() -> void:
	_clear_codex_card_packs()
	
	var card_pack_bg = ButtonGroup.new()
	var is_first = true
	
	var card_pack_ids: Array = Global._id_to_card_pack_data.keys()
	card_pack_ids.erase("card_pack_all") # ensure that the all card pack is displayed first
	card_pack_ids.push_front("card_pack_all")
	
	for card_pack_id: String in card_pack_ids:
		var card_pack_data: CardPackData = Global.get_card_pack_data(card_pack_id)
		if card_pack_data == null:
			breakpoint
			continue
		if card_pack_data.card_pack_displays_in_codex:
			var card_pack_button: CodexCardPackButton = Scenes.CODEX_CARD_PACK_BUTTON.instantiate()
			codex_card_pack_container.add_child(card_pack_button)
			
			card_pack_button.toggle_mode = true
			card_pack_button.button_group = card_pack_bg
			if is_first:
				card_pack_button.button_pressed = true
				is_first = false
			
			card_pack_button.init(card_pack_data)
			
			card_pack_button.codex_card_card_pack_button_pressed.connect(_on_codex_card_card_pack_button_pressed)

func _clear_codex_card_packs() ->  void:
	for child: Control in codex_card_pack_container.get_children():
		child.queue_free()

# creates display cards in codex
func _populate_codex_cards(card_pack_data: CardPackData = null) -> void:
	var card_args: Array[Array] = [] # used to instantiate cards in container
	var card_object_ids: Array = Global._id_to_card_data.keys()
	if card_pack_data == null or card_pack_data.object_id == "card_pack_all":
		# creates all cards in the game to display
		card_object_ids = Global._id_to_card_data.keys()
	else:
		# create cards from pack but include all rarities and types for the codex display
		var card_filter: CardFilter = CardFilter.new().filter_appears_in_card_packs(true)
		if card_pack_data.card_pack_color_id != "":
			card_filter = card_filter.filter_colors([card_pack_data.card_pack_color_id])
		card_filter = card_filter.filter_card_validators(card_pack_data.card_pack_validators)
		card_filter = card_filter.include_card_object_ids(card_pack_data.card_pack_card_ids)
		card_object_ids = card_filter.filtered_card_unique_object_ids.keys()
	
	# generate data to make cards
	for card_object_id: String in card_object_ids:
		var card_data: CardData = Global.get_card_data(card_object_id)
		
		if current_search_text != "" and not (current_search_text in card_data.card_name.to_lower()):
			continue
			
		card_args.append([card_data, 0, false, true, true])
	
	if len(card_args) > 1:
		card_args.sort_custom(_codex_card_custom_sort)
	
	# populate cards
	codex_card_rgsc.populate_children(Scenes.CARD, card_args)
	
	# 为每张卡牌连接双击检测信号（deferred 确保新节点已就绪）
	call_deferred("_connect_card_signals")

func _on_codex_card_card_pack_button_pressed(card_pack_data: CardPackData):
	selected_card_pack_data = card_pack_data
	_populate_codex_cards(selected_card_pack_data)

func _on_search_text_changed(new_text: String) -> void:
	current_search_text = new_text.to_lower()
	_populate_codex_cards(selected_card_pack_data)

#region Sorting
func _set_sort_mode(mode: SortMode) -> void:
	current_sort_mode = mode
	_populate_codex_cards(selected_card_pack_data)

func _codex_card_custom_sort(card_args_1: Array, card_args_2: Array) -> bool:
	var card_data_1: CardData = card_args_1[0]
	var card_data_2: CardData = card_args_2[0]
	
	if current_sort_mode == SortMode.RARITY:
		if card_data_1.card_rarity != card_data_2.card_rarity:
			return card_data_1.card_rarity < card_data_2.card_rarity
	elif current_sort_mode == SortMode.COST:
		var cost_1 = card_data_1.card_energy_cost if card_data_1.card_is_playable else -1
		var cost_2 = card_data_2.card_energy_cost if card_data_2.card_is_playable else -1
		if cost_1 != cost_2:
			return cost_1 < cost_2
		if card_data_1.card_rarity != card_data_2.card_rarity:
			return card_data_1.card_rarity < card_data_2.card_rarity
	elif current_sort_mode == SortMode.TYPE:
		if card_data_1.card_type != card_data_2.card_type:
			return card_data_1.card_type < card_data_2.card_type
		if card_data_1.card_rarity != card_data_2.card_rarity:
			return card_data_1.card_rarity < card_data_2.card_rarity
	
	return card_data_1.card_name < card_data_2.card_name

#endregion

#region Card Detail (Double Click)
var _last_click_time: int = 0
var _last_clicked_card: Card = null
const DOUBLE_CLICK_THRESHOLD_MS: int = 400

func _connect_card_signals() -> void:
	for card_node: Node in codex_card_rgsc.grid_container.get_children():
		if card_node is Card and not card_node.card_selected.is_connected(_on_codex_card_clicked):
			card_node.card_selected.connect(_on_codex_card_clicked)
			card_node.card_hovered.connect(_on_card_hovered)
			card_node.card_unhovered.connect(_on_card_unhovered)

func _on_card_hovered(card: Card) -> void:
	# 这里演示了如何传入变大比例参数，目前设为 1.15
	UIHover.scale_up(card, 1.15)

func _on_card_unhovered(card: Card) -> void:
	UIHover.scale_down(card)

func _on_codex_card_clicked(card: Card) -> void:
	var now: int = Time.get_ticks_msec()
	if card == _last_clicked_card and (now - _last_click_time) < DOUBLE_CLICK_THRESHOLD_MS:
		# 卡牌未解锁时禁用双击查看详情，并提醒用户
		if not card.card_data.is_discovered():
			UIMessage.show_message("该卡牌还未解锁")
			_last_clicked_card = null
			return
		codex_card_detail_panel.show_card_detail(card.card_data)
		_last_clicked_card = null
	else:
		_last_clicked_card = card
		_last_click_time = now
#endregion
