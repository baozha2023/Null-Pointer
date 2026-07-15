## 卡牌详情面板。作为覆盖层叠加在 CodexCardsMenu 上方，展示某张卡牌的全部参数。
extends Control

signal back_pressed

var _card_preview: Card = null

# UI 引用（在 _ready 中构建）
var _background_overlay: ColorRect
var _scroll_container: ScrollContainer
var _detail_content: VBoxContainer
var _card_preview_container: CenterContainer
var _back_button: Button

const SECTION_TITLE_FONT_SIZE: int = 20
const LABEL_FONT_SIZE: int = 15



func _ready() -> void:
	visible = false
	_build_ui()

## 显示某张卡牌的全部详细参数
func show_card_detail(card_data: CardData) -> void:
	_populate_detail(card_data)
	visible = true

## 隐藏面板
func hide_card_detail() -> void:
	visible = false
	_clear_card_preview()

#region UI 构建
func _build_ui() -> void:
	# 自身铺满父容器
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	# 半透明背景遮罩
	_background_overlay = ColorRect.new()
	_background_overlay.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_background_overlay.color = Color(0.05, 0.05, 0.1, 0.92)
	add_child(_background_overlay)

	# 主布局：水平分割（左：卡牌预览 | 右：参数滚动区）
	var main_margin := MarginContainer.new()
	main_margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	main_margin.add_theme_constant_override("margin_left", 32)
	main_margin.add_theme_constant_override("margin_top", 72)
	main_margin.add_theme_constant_override("margin_right", 32)
	main_margin.add_theme_constant_override("margin_bottom", 32)
	add_child(main_margin)

	var main_hbox := HBoxContainer.new()
	main_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_theme_constant_override("separation", 32)
	main_margin.add_child(main_hbox)

	# 左侧：卡牌预览居中
	_card_preview_container = CenterContainer.new()
	_card_preview_container.custom_minimum_size = Vector2(280, 0)
	_card_preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(_card_preview_container)

	# 右侧：可滚动的参数面板
	var right_panel := PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.16, 0.85)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	right_panel.add_theme_stylebox_override("panel", panel_style)
	main_hbox.add_child(right_panel)

	_scroll_container = ScrollContainer.new()
	_scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(_scroll_container)

	_detail_content = VBoxContainer.new()
	_detail_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_content.add_theme_constant_override("separation", 6)
	_scroll_container.add_child(_detail_content)

	# 返回按钮（左上角）
	_back_button = Button.new()
	_back_button.text = "← 返回脚本列表"
	_back_button.set_anchors_and_offsets_preset(PRESET_TOP_LEFT)
	_back_button.offset_left = 16
	_back_button.offset_top = 16
	_back_button.offset_right = 200
	_back_button.offset_bottom = 56
	_back_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_back_button.pressed.connect(_on_back_button_pressed)
	
	# 应用与其他 codex 按钮相同的样式
	var normal_style := StyleBoxTexture.new()
	normal_style.texture = load("res://sprites/btn_common_normal.png")
	_back_button.add_theme_stylebox_override("normal", normal_style)
	var pressed_style := StyleBoxTexture.new()
	pressed_style.texture = load("res://sprites/btn_common_pressed.png")
	_back_button.add_theme_stylebox_override("pressed", pressed_style)
	var hover_style := StyleBoxTexture.new()
	hover_style.texture = load("res://sprites/btn_common_hover.png")
	_back_button.add_theme_stylebox_override("hover", hover_style)
	
	add_child(_back_button)
#endregion

#region 数据填充
func _populate_detail(card_data: CardData) -> void:
	# 清空旧内容
	_clear_detail_content()
	_clear_card_preview()

	# 创建卡牌预览
	_card_preview = Scenes.CARD.instantiate()
	_card_preview_container.add_child(_card_preview)
	_card_preview.init(card_data, 0, false, false)

	# 填充参数
	_add_section_title("基础信息")
	_add_param("卡牌名称", card_data.card_name)
	var color_data = Global.get_color_data(card_data.card_color_id)
	_add_param("卡池颜色", color_data.color_name if color_data != null else card_data.card_color_id)
	_add_param("基础耗能", str(card_data.card_energy_cost))
	if card_data.card_energy_cost_is_variable:
		var bound_text: String = "无上限" if card_data.card_energy_cost_variable_upper_bound < 0 else str(card_data.card_energy_cost_variable_upper_bound)
		_add_param("可变耗能上限", bound_text)
	_add_param("描述", card_data.card_description)
	if card_data.card_hint != "":
		_add_param("提示", card_data.card_hint)

	_add_separator()
	_add_section_title("机制标记")
	_add_flag("需要选择目标", card_data.card_requires_target)
	_add_flag("可打出", card_data.card_is_playable)
	_add_flag("虚无（回合结束消耗）", card_data.card_end_of_turn_destination == HandManager.EXHAUST_PILE)
	_add_flag("保留（回合结束不弃置）", card_data.does_card_retain())
	_add_flag("不可从牌组移除", card_data.card_unremovable_from_deck)
	_add_flag("不可变形", card_data.card_untransformable_from_deck)

	_add_separator()
	_add_section_title("牌面去向")
	_add_param("打出后去向", HandManager.PILE_DISPLAY_NAMES.get(card_data.card_play_destination, card_data.card_play_destination))
	_add_param("回合结束去向", HandManager.PILE_DISPLAY_NAMES.get(card_data.card_end_of_turn_destination, card_data.card_end_of_turn_destination))

	_add_separator()
	_add_section_title("数值")
	if card_data.card_values.is_empty():
		_add_text("（无）")
	else:
		for key: String in card_data.card_values:
			_add_param(key, str(card_data.card_values[key]))

	_add_separator()
	_add_section_title("升级机制")
	_add_param("升级次数上限", str(card_data.card_upgrade_amount_max) + (" （不可升级）" if card_data.card_upgrade_amount_max == 0 else ""))

	_add_section_title("  首次升级 - 属性质变")
	if card_data.card_first_upgrade_property_changes.is_empty():
		_add_text("  （无）")
	else:
		for key: String in card_data.card_first_upgrade_property_changes:
			var val: Variant = card_data.card_first_upgrade_property_changes[key]
			_add_param("  " + key, _variant_to_display(val))

	_add_section_title("  首次升级 - 数值覆盖")
	if card_data.card_first_upgrade_value_changes.is_empty():
		_add_text("  （无）")
	else:
		for key: String in card_data.card_first_upgrade_value_changes:
			_add_param("  " + key, str(card_data.card_first_upgrade_value_changes[key]))

	_add_section_title("  每次升级 - 线性成长")
	if card_data.card_upgrade_value_improvements.is_empty():
		_add_text("  （无）")
	else:
		for key: String in card_data.card_upgrade_value_improvements:
			var val: Variant = card_data.card_upgrade_value_improvements[key]
			var sign_str: String = "+" if (val is int or val is float) and val >= 0 else ""
			_add_param("  " + key, sign_str + str(val))

	_add_separator()
	_add_section_title("已配置附魔")
	if card_data.card_decorators.is_empty():
		_add_text("（无）")
	else:
		for decorator_id: String in card_data.card_decorators:
			var decorator_data: CardDecoratorData = Global.get_card_decorator_data(decorator_id)
			var name_text: String = decorator_id
			if decorator_data != null and decorator_data.card_decorator_name != "":
				name_text = decorator_data.card_decorator_name + " (" + decorator_id + ")"
			elif decorator_id == "":
				name_text = "未命名配置 (空 ID)"
			
			var params_dict: Dictionary = card_data.card_decorators[decorator_id]
			# 使用 Godot 的 JSON.stringify 转化为带有缩进的结构化 JSON
			var formatted_params: String = JSON.stringify(params_dict, "  ")
			_add_param(name_text, formatted_params)

	_add_separator()
	_add_section_title("可用附魔池")
	var available_decorators: Array[String] = _get_available_decorator_names(card_data)
	if available_decorators.is_empty():
		_add_text("（无）")
	else:
		for name: String in available_decorators:
			_add_text("• " + name)

	_add_separator()
	_add_section_title("行为钩子概览")
	_add_hook_status("打出", card_data.card_play_actions)
	_add_hook_status("弃置", card_data.card_discard_actions)
	_add_hook_status("回合结束", card_data.card_end_of_turn_actions)
	_add_hook_status("消耗", card_data.card_exhaust_actions)
	_add_hook_status("抽牌", card_data.card_draw_actions)
	_add_hook_status("保留", card_data.card_retain_actions)
	_add_hook_status("初始战斗", card_data.card_initial_combat_actions)
	_add_hook_status("加入牌组", card_data.card_add_to_deck_actions)
	_add_hook_status("移除牌组", card_data.card_remove_from_deck_actions)
	_add_hook_status("牌组变形", card_data.card_transform_in_deck_actions)

	if card_data.card_keyword_object_ids.size() > 0:
		_add_separator()
		_add_section_title("关联关键词")
		for keyword_id: String in card_data.card_keyword_object_ids:
			_add_text("• " + keyword_id)

	if card_data.card_tags.size() > 0:
		_add_separator()
		_add_section_title("卡牌标签")
		for tag: String in card_data.card_tags:
			_add_text("• " + tag)

	# 重置滚动位置到顶部
	_scroll_container.scroll_vertical = 0
#endregion

#region 辅助方法
func _get_available_decorator_names(card_data: CardData) -> Array[String]:
	var names: Array[String] = []
	for decorator_id: String in Global._id_to_card_decorator_data:
		var decorator_data: CardDecoratorData = Global.get_card_decorator_data(decorator_id)
		if not decorator_data.is_decorator_visible():
			continue
		if decorator_data.card_decorator_card_pack_id == "":
			names.append(decorator_data.card_decorator_name)
		else:
			# 检查卡牌是否属于该附魔指定的卡包
			var card_filter: CardFilter = Global.get_cached_card_filter(decorator_data.card_decorator_card_pack_id)
			if card_filter != null and card_filter.filtered_card_unique_object_ids.has(card_data.object_id):
				names.append(decorator_data.card_decorator_name)
	return names

func _variant_to_display(val: Variant) -> String:
	if val is Array or val is Dictionary:
		return JSON.stringify(val, "  ")
	else:
		return str(val)

func _clear_detail_content() -> void:
	for child: Node in _detail_content.get_children():
		child.queue_free()

func _clear_card_preview() -> void:
	if _card_preview != null:
		_card_preview.queue_free()
		_card_preview = null

func _add_section_title(title: String) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", SECTION_TITLE_FONT_SIZE)
	label.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4))
	_detail_content.add_child(label)

func _add_param(key: String, value: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)

	var key_label := Label.new()
	key_label.text = key + ":"
	key_label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	key_label.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8))
	key_label.custom_minimum_size.x = 260
	hbox.add_child(key_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(value_label)

	_detail_content.add_child(hbox)

func _add_text(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", LABEL_FONT_SIZE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_content.add_child(label)

func _add_flag(label_text: String, is_active: bool) -> void:
	var icon: String = "✓" if is_active else "✗"
	var color: Color = Color(0.4, 0.9, 0.4) if is_active else Color(0.5, 0.5, 0.5)
	_add_param(label_text, icon)
	# 给最后添加的 HBox 的 value label 上色
	var last_hbox: HBoxContainer = _detail_content.get_child(_detail_content.get_child_count() - 1) as HBoxContainer
	if last_hbox != null and last_hbox.get_child_count() >= 2:
		var val_label: Label = last_hbox.get_child(1) as Label
		if val_label != null:
			val_label.add_theme_color_override("font_color", color)

func _add_hook_status(hook_name: String, actions: Array[Dictionary]) -> void:
	var status: String = "已配置 (" + str(actions.size()) + " 项)" if actions.size() > 0 else "未配置"
	var color: Color = Color(0.4, 0.9, 0.4) if actions.size() > 0 else Color(0.5, 0.5, 0.5)
	_add_param(hook_name, status)
	var last_hbox: HBoxContainer = _detail_content.get_child(_detail_content.get_child_count() - 1) as HBoxContainer
	if last_hbox != null and last_hbox.get_child_count() >= 2:
		var val_label: Label = last_hbox.get_child(1) as Label
		if val_label != null:
			val_label.add_theme_color_override("font_color", color)

func _add_separator() -> void:
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 12)
	_detail_content.add_child(sep)
#endregion

func _on_back_button_pressed() -> void:
	hide_card_detail()
	back_pressed.emit()
