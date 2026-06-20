## The tooltip UI component used to display helpful information to the player on hovering over things.
## Displays over everything else.
## NOTE: Modify component_tooltip_data to provide more tooltips and how they display
## Uses ReferenceRects for positioning
extends Control
class_name Tooltip

@onready var pause_button: TextureButton = %PauseButton
@onready var map_button: TextureButton = %MapButton

@onready var money_label: Label = %MoneyLabel
@onready var health_label: Label = %HealthLabel

@onready var energy: TextureButton = %Energy
@onready var deck_button: TextureButton = %DeckButton
@onready var draw_pile_button: TextureButton = %DrawPile
@onready var discard_pile_button: TextureButton = %DiscardPile
@onready var exhaust_pile_button: TextureButton = %ExhaustPile
@onready var end_turn_button: Button = %EndTurnButton

@onready var panel_container: PanelContainer = $PanelContainer
@onready var tooltip_label: RichTextLabel = $PanelContainer/TooltipLabel
@onready var keyword_container: KeywordContainer = $KeywordContainer

var follow_mouse: bool = false # if the tooltip should constantly update its position over the mouse when proc'ed
var lock_x: bool = false # when following mouse, lock x coord to a given offset
var lock_y: bool = false # when following mouse, lock y coord to a given offset
var offset_x: float = 0.0 # offset when following mouse
var offset_y: float = 0.0 # offset when following mouse

const CARD_KEYWORD_PANEL_MARGIN_X: float = 6.0 # how far the tooltip should display away from Card
const CARD_KEYWORD_RIGHT_SCREEN_SIZE_MARGIN: float = 200 # how much screen space must be left on the right side of a card to display the tooltips on the right side

func _ready() -> void:
	HandManager.tooltip = self # store a reference globally for this tooltip. Godot freaks out about it otherwise
	
	# pre-set tooltips
	# [component, bbcode, if it follows mouse, lock x position, lock y position, offset component used for placement]
	var component_tooltip_data: Array[Array] = [
		[pause_button, "[color=orange]暂停[/color]\n停止游戏", true, false, true, $TooltipPositions/TopLeftTooltipPos],
		[map_button, "[color=orange]地图[/color]\n打开当前章节的地图", true, false, true, $TooltipPositions/TopLeftTooltipPos],
		[deck_button, "[color=orange]牌库[/color]\n当前拥有的所有卡牌列表。在战斗间保留", true, false, true, $TooltipPositions/TopLeftTooltipPos],
		
		[health_label, "[color=orange]生命值[/color]\n生命值归零时，游戏失败", true, false, true, $TooltipPositions/HealthTooltipPos],
		[money_label, "[color=orange]金币[/color]\n你当前拥有的金币数量", true, false, true, $TooltipPositions/MoneyTooltipPos],
		
		[energy, "[color=orange]能量[/color]\n用于打出卡牌", false, false, false, $TooltipPositions/EnergyTooltipPos],
		[draw_pile_button, "[color=orange]抽牌堆[/color]\n这些卡牌将会被抽到手中", false, false, false, $TooltipPositions/EnergyTooltipPos],
		
		[exhaust_pile_button, "[color=orange]消耗堆[/color]\n这些卡牌已从战斗中移除", false, false, false, $TooltipPositions/ExhaustTooltipPos],
		[discard_pile_button, "[color=orange]弃牌堆[/color]\n这些卡牌将会被重新洗入抽牌堆", false, false, false, $TooltipPositions/DiscardTooltipPos],
		[end_turn_button, "[color=orange]结束回合[/color]\n结束你的回合", false, false, false, $TooltipPositions/DiscardTooltipPos],
		]
	
	for component_tooltip: Array in component_tooltip_data:
		var component: Control = component_tooltip[0]
		var component_tooltip_bbcode: String = component_tooltip[1]
		var component_tooltip_follow_mouse: bool = component_tooltip[2]
		var component_tooltip_lock_x: bool = component_tooltip[3]
		var component_tooltip_lock_y: bool = component_tooltip[4]
		var component_tooltip_offset: ReferenceRect = component_tooltip[5]
	
		component.mouse_entered.connect(display_tooltip.bind(
			component_tooltip_bbcode,
			component_tooltip_follow_mouse, component_tooltip_lock_x, component_tooltip_lock_y,
			0.0, 0.0,
			component_tooltip_offset)
			)
		component.mouse_exited.connect(hide_tooltip)

## Displays a basic tooltip at a given location with given text.
## If follow_mouse = true, it will constantly repostion the tooltip offset from the mouse, with
## flags to lock the offset for each axis.
## If offset_component is used (see component_tooltip_data in _ready()) you can use a ReferenceRect
## to determine the tooltip's location, good for multiple resolution support.
func display_tooltip(tooltip_bbcode: String,
					_follow_mouse: bool = false, _lock_x: bool = false, _lock_y: bool = false,
					_offset_x: float = 0.0, _offset_y: float = 0.0, offset_component: Control = null) -> void:
	hide_tooltip()
	visible = true
	
	tooltip_label.parse_bbcode(tooltip_bbcode)
	tooltip_label.visible = true
	panel_container.visible = true
	
	follow_mouse = _follow_mouse
	lock_x = _lock_x
	lock_y = _lock_y
	
	if offset_component != null:
		offset_x = offset_component.position.x
		offset_y = offset_component.position.y
	else:
		offset_x = _offset_x
		offset_y = _offset_y
	
	global_position = Vector2(offset_x, offset_y)

## Displays a list of keywords to the left or right of a Card, based on remaining screen size
func display_card_keywords(card: Card) -> void:
	if card.card_data == null:
		return
	hide_tooltip()
	
	visible = true
	keyword_container.visible = true
	
	# use remaining screen size to determine which side of the card should display
	var screen_size: Vector2 = DisplayServer.window_get_size()
	var card_visual_global_pos: Vector2 = card.card_visual.global_position
	var card_right_side_pos: Vector2 = card_visual_global_pos + Vector2(card.size.x + CARD_KEYWORD_PANEL_MARGIN_X, 0)
	var card_left_side_pos: Vector2 = card_visual_global_pos - Vector2(keyword_container.size.x + CARD_KEYWORD_PANEL_MARGIN_X, 0)
	
	if card_right_side_pos.x + CARD_KEYWORD_RIGHT_SCREEN_SIZE_MARGIN < screen_size.x:
		# right side of card
		keyword_container.global_position = card_right_side_pos
	else:
		# left side of card
		keyword_container.global_position = card_left_side_pos
	
	keyword_container.populate_card_keywords(card.card_data)

func display_artifact_tooltip(artifact: BaseArtifact) -> void:
	var artifact_description: String = artifact.get_artifact_description()
	display_tooltip(artifact_description, true, false, false, 0.0, 0.0, null)

const ARTIFACT_RARITY_DISPLAY: Dictionary = {
	ArtifactData.ARTIFACT_RARITIES.BASIC: "基础",
	ArtifactData.ARTIFACT_RARITIES.COMMON: "普通",
	ArtifactData.ARTIFACT_RARITIES.UNCOMMON: "罕见",
	ArtifactData.ARTIFACT_RARITIES.RARE: "稀有",
	ArtifactData.ARTIFACT_RARITIES.BOSS: "头目",
	ArtifactData.ARTIFACT_RARITIES.SHOP: "商店",
	ArtifactData.ARTIFACT_RARITIES.EVENT: "事件",
}

const CONSUMABLE_RARITY_DISPLAY: Dictionary = {
	ConsumableData.CONSUMABLE_RARITIES.COMMON: "普通",
	ConsumableData.CONSUMABLE_RARITIES.UNCOMMON: "罕见",
	ConsumableData.CONSUMABLE_RARITIES.RARE: "稀有",
	ConsumableData.CONSUMABLE_RARITIES.LEGENDARY: "传说",
}

func display_codex_artifact_tooltip(artifact_data: ArtifactData) -> void:
	if artifact_data != null:
		var rarity_text: String = "\n"
		rarity_text += "[" + ARTIFACT_RARITY_DISPLAY.get(artifact_data.artifact_rarity, "???") + "]"
		
		var artifact_tooltip_bbcode: String = "[color=orange]{0}[/color]{1}\n{2}".format([
			artifact_data.artifact_name, rarity_text, artifact_data.artifact_description
		])
		display_tooltip(artifact_tooltip_bbcode, true, false, false, 0.0, 0.0, null)

func display_codex_consumable_tooltip(consumable_data: ConsumableData) -> void:
	if consumable_data != null:
		var rarity_text: String = "\n"
		rarity_text += "[" + CONSUMABLE_RARITY_DISPLAY.get(consumable_data.consumable_rarity, "???") + "]"
		
		var consumable_tooltip_bbcode: String = "[color=orange]{0}[/color]{1}\n{2}".format([
			consumable_data.consumable_name, rarity_text, consumable_data.consumable_description
		])
		display_tooltip(consumable_tooltip_bbcode, true, false, false, 0.0, 0.0, null)

func hide_tooltip() -> void:
	follow_mouse = false
	lock_x = false
	lock_y = false
	offset_x = 0.0
	offset_y = 0.0
	
	keyword_container.clear_keywords()
	visible = false
	tooltip_label.visible = false
	panel_container.visible = false
	keyword_container.visible = false
	

func _process(_delta: float) -> void:
	if follow_mouse:
		if lock_x:
			global_position.x = offset_x
		else:
			global_position.x = get_global_mouse_position().x
		if lock_y:
			global_position.y = offset_y
		else:
			global_position.y = get_global_mouse_position().y
			
