## The tooltip UI component used to display helpful information to the player on hovering over things.
## Displays over everything else.
## NOTE: Modify component_tooltip_data to provide more tooltips and how they display
## Uses ReferenceRects for positioning
extends Control
class_name Tooltip

@onready var combat: Control = get_tree().current_scene.get_node("RunScreen/Combat")
@onready var pause_button: TextureButton = combat.get_node("%PauseButton")
@onready var map_button: TextureButton = combat.get_node("%MapButton")

@onready var money_container: Control = combat.get_node("%MoneyContainer")
@onready var health_container: Control = combat.get_node("%HealthContainer")

@onready var energy: TextureButton = combat.get_node("%Energy")
@onready var deck_button: TextureButton = combat.get_node("%DeckButton")
@onready var draw_top_pile_button: TextureButton = combat.get_node("%DrawTopPile")
@onready var draw_pile_button: TextureButton = combat.get_node("%DrawPile")
@onready var discard_pile_button: TextureButton = combat.get_node("%DiscardPile")
@onready var exhaust_pile_button: TextureButton = combat.get_node("%ExhaustPile")
@onready var end_turn_button: Button = combat.get_node("%EndTurnButton")

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
		[pause_button, "[color=orange]挂起[/color]\n停止进程", true, false, false, null],
		[map_button, "[color=orange]网络拓扑[/color]\n打开当前章节的网络拓扑", true, false, false, null],
		[deck_button, "[color=orange]脚本库[/color]\n当前拥有的所有脚本列表。在节点跳转间保存", true, false, false, null],
		
		[health_container, "[color=orange]完整度[/color]\n完整度归零时，系统崩溃。", true, false, false, null],
		[money_container, "[color=orange]数据币[/color]\n你当前拥有的数据币数量。", true, false, false, null],
		
		[draw_top_pile_button, "[color=orange]预读取缓存[/color]\n按实际顺序预览内存队列顶部的脚本", true, false, false, null],
		[energy, "[color=orange]算力[/color]\n用于调用脚本", true, false, false, null],
		[draw_pile_button, "[color=orange]内存队列[/color]\n这些脚本将被加载到线程中", true, false, false, null],
		
		[exhaust_pile_button, "[color=orange]坏道区[/color]\n这些脚本已从当前时钟周期中物理删除", false, false, false, $TooltipPositions/ExhaustTooltipPos],
		[discard_pile_button, "[color=orange]回收站[/color]\n这些脚本将会被重新分配入内存队列", false, false, false, $TooltipPositions/DiscardTooltipPos],
		[end_turn_button, "[color=orange]结束周期[/color]\n结束当前时钟周期", false, false, false, $TooltipPositions/DiscardTooltipPos],
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
	
	tooltip_bbcode = TextParser.parse(tooltip_bbcode)
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
	
	follow_mouse = true
	lock_x = false
	lock_y = false
	keyword_container.position = Vector2(10, 10) # offset from mouse
	
	keyword_container.populate_card_keywords(card.card_data)

## Displays a standalone tooltip for a specific card decorator
func display_decorator_tooltip(decorator_name: String, decorator_description: String) -> void:
	if decorator_name == "" or decorator_description == "":
		return
	hide_tooltip()
	
	visible = true
	keyword_container.visible = true
	
	follow_mouse = true
	lock_x = false
	lock_y = false
	keyword_container.position = Vector2(10, 10) # offset from mouse
	
	keyword_container.clear_tooltips()
	
	var keyword_tooltip = Scenes.KEYWORD_TOOLTIP.instantiate()
	keyword_container.add_child(keyword_tooltip)
	keyword_tooltip.init_custom(decorator_name, decorator_description)

func display_artifact_tooltip(artifact: BaseArtifact) -> void:
	display_codex_artifact_tooltip(artifact.artifact_data)

const CONSUMABLE_RARITY_DISPLAY: Dictionary = {
	ConsumableData.CONSUMABLE_RARITIES.COMMON: "内置",
	ConsumableData.CONSUMABLE_RARITIES.UNCOMMON: "开源",
	ConsumableData.CONSUMABLE_RARITIES.RARE: "闭源",
	ConsumableData.CONSUMABLE_RARITIES.LEGENDARY: "零日",
}

func display_codex_artifact_tooltip(artifact_data: ArtifactData) -> void:
	if artifact_data != null:
		var rarity_text: String = "\n"
		rarity_text += "[" + ArtifactData.ARTIFACT_RARITY_DISPLAY.get(artifact_data.artifact_rarity, "???") + "]"
		
		var context: Dictionary = {
			"artifact_counter": artifact_data.artifact_counter,
		}
		var parsed_desc: String = TextParser.parse(artifact_data.artifact_description, context)
		
		var artifact_tooltip_bbcode: String = "[color=orange]{0}[/color]{1}\n{2}".format([
			artifact_data.artifact_name, rarity_text, parsed_desc
		])
		display_tooltip(artifact_tooltip_bbcode, true, false, false, 0.0, 0.0, null)

## Displays one combined tooltip for all concrete cards/artifacts referenced by a run-start option.
func display_run_start_option_tooltip(references: Array[Dictionary]) -> void:
	var sections: Array[String] = []
	var seen_references: Dictionary = {}
	for reference: Dictionary in references:
		var reference_type: String = reference.get("type", "")
		var object_id: String = reference.get("object_id", "")
		var dedupe_key: String = reference_type + ":" + object_id
		if seen_references.has(dedupe_key):
			continue
		seen_references[dedupe_key] = true
		if reference_type == "card":
			var card_data: CardData = Global.get_card_data(object_id)
			if card_data == null:
				DebugLogger.log_error("Tooltip.display_run_start_option_tooltip(): No card of id \"{0}\" found".format([object_id]))
				continue
			var color_hex: String = "#ffffff"
			var color_data: ColorData = Global.get_color_data(card_data.card_color_id)
			if color_data != null:
				color_hex = "#" + color_data.color.to_html(false)
			var display_name: String = card_data.card_name
			if card_data.card_is_playable:
				var cost_text: String = "X" if card_data.card_energy_cost_is_variable else str(card_data.card_energy_cost)
				if card_data.card_energy_cost_is_variable and card_data.card_energy_cost_variable_upper_bound >= 1:
					cost_text += "-" + str(card_data.card_energy_cost_variable_upper_bound)
				display_name += "(" + cost_text + ")"
			var card_description: String = TextParser.parse(card_data.card_description, card_data.card_values)
			sections.append("[color={0}]{1}[/color]\n{2}".format([color_hex, display_name, card_description]))
		elif reference_type == "artifact":
			var artifact_data: ArtifactData = Global.get_artifact_data_from_prototype(object_id)
			if artifact_data == null:
				DebugLogger.log_error("Tooltip.display_run_start_option_tooltip(): No artifact of id \"{0}\" found".format([object_id]))
				continue
			var custom_values: Dictionary = reference.get("custom_values", {})
			for key: Variant in custom_values:
				artifact_data.set(key, custom_values[key])
			var artifact_context: Dictionary = custom_values.duplicate(true)
			artifact_context["artifact_counter"] = artifact_data.artifact_counter
			artifact_context["artifact_counter_max"] = artifact_data.artifact_counter_max
			var artifact_description: String = TextParser.parse(artifact_data.artifact_description, artifact_context)
			var rarity_name: String = ArtifactData.ARTIFACT_RARITY_DISPLAY.get(artifact_data.artifact_rarity, "???")
			sections.append("[color=orange]{0}[/color]\n[{1}]\n{2}".format([artifact_data.artifact_name, rarity_name, artifact_description]))
	if not sections.is_empty():
		display_tooltip("\n\n".join(sections), true, false, false, 10.0, 10.0, null)

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
	
	keyword_container.clear_tooltips()
	visible = false
	tooltip_label.visible = false
	panel_container.visible = false
	panel_container.reset_size()
	keyword_container.visible = false
	keyword_container.reset_size()
	

func _process(_delta: float) -> void:
	if follow_mouse:
		var screen_size: Vector2 = get_viewport_rect().size
		var tooltip_size: Vector2 = Vector2.ZERO
		if panel_container.visible:
			tooltip_size = panel_container.size
		elif keyword_container.visible:
			tooltip_size = keyword_container.size
			
		var target_x: float = offset_x if lock_x else get_global_mouse_position().x
		var target_y: float = offset_y if lock_y else get_global_mouse_position().y
		
		if not lock_x:
			var cursor_offset_x = 15.0
			if target_x + cursor_offset_x + tooltip_size.x > screen_size.x:
				target_x = target_x - tooltip_size.x - cursor_offset_x
			else:
				target_x += cursor_offset_x
				
		if not lock_y:
			var cursor_offset_y = 15.0
			if target_y + cursor_offset_y + tooltip_size.y > screen_size.y:
				target_y = target_y - tooltip_size.y - cursor_offset_y
			else:
				target_y += cursor_offset_y
				
		global_position.x = clamp(target_x, 0, max(0, screen_size.x - tooltip_size.x))
		global_position.y = clamp(target_y, 0, max(0, screen_size.y - tooltip_size.y))

## Globally formats a metadata variable (like card types array or status ID) into a localized string representation.
