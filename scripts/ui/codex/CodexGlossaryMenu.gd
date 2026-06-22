## Displays glossary tab in the codex, listing all keywords and status effects
extends BaseMenu

@onready var codex_glossary_container: VBoxContainer = %CodexGlossaryContainer

func _ready() -> void:
	pass

func populate_menu() -> void:
	super()
	_populate_glossary()

func clear_menu() -> void:
	super()
	_clear_glossary()

func _populate_glossary() -> void:
	_clear_glossary()
	
	# Section: Keywords
	_add_section_header("关键词")
	for keyword_id: String in Global._id_to_keyword_data:
		var keyword_data: KeywordData = Global._id_to_keyword_data[keyword_id]
		if keyword_data.keyword_name != "":
			_add_glossary_entry(keyword_data.keyword_name, keyword_data.keyword_text_bb_code)
	
	# Separator
	_add_separator()
	
	# Section: Status Effects
	_add_section_header("状态效果")
	for status_id: String in Global._id_to_status_data:
		var status_data: StatusEffectData = Global._id_to_status_data[status_id]
		if status_data.status_effect_name != "" and status_data.status_effect_is_visible:
			var type_text: String = ""
			match status_data.status_effect_type:
				StatusEffectData.STATUS_EFFECT_TYPES.BUFF:
					type_text = "[color=green]【增益】[/color]"
				StatusEffectData.STATUS_EFFECT_TYPES.DEBUFF:
					type_text = "[color=red]【减益】[/color]"
				StatusEffectData.STATUS_EFFECT_TYPES.NEUTRAL:
					type_text = "[color=gray]【中性】[/color]"
			
			var description: String = type_text
			
			if status_data.status_effect_description != "":
				description += " " + status_data.status_effect_description
			
			# Add decay info
			if status_data.status_effect_decay_rate != 0:
				description += " 每时钟周期衰减 " + str(abs(status_data.status_effect_decay_rate)) + " 层。"
			
			_add_glossary_entry(status_data.status_effect_name, description, status_data.status_effect_texture_path)

func _add_section_header(text: String) -> void:
	var label: RichTextLabel = RichTextLabel.new()
	label.bbcode_enabled = true
	label.fit_content = true
	label.scroll_active = false
	label.custom_minimum_size = Vector2(0, 36)
	label.text = "[color=orange][font_size=20]" + text + "[/font_size][/color]"
	codex_glossary_container.add_child(label)

func _add_glossary_entry(entry_name: String, description_bb_code: String, texture_path: String = "") -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 32)
	hbox.add_theme_constant_override("separation", 12)
	
	# Optional icon
	if texture_path != "":
		var icon: TextureRect = TextureRect.new()
		icon.texture = FileLoader.load_texture(texture_path)
		icon.custom_minimum_size = Vector2(24, 24)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		hbox.add_child(icon)
	
	# Name label
	var name_label: RichTextLabel = RichTextLabel.new()
	name_label.bbcode_enabled = true
	name_label.fit_content = true
	name_label.scroll_active = false
	name_label.custom_minimum_size = Vector2(160, 0)
	name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	name_label.text = "[color=yellow]" + entry_name + "[/color]"
	hbox.add_child(name_label)
	
	# Description label
	var desc_label: RichTextLabel = RichTextLabel.new()
	desc_label.bbcode_enabled = true
	desc_label.fit_content = true
	desc_label.scroll_active = false
	desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_label.text = description_bb_code
	hbox.add_child(desc_label)
	
	codex_glossary_container.add_child(hbox)

func _add_separator() -> void:
	var separator: HSeparator = HSeparator.new()
	separator.custom_minimum_size = Vector2(0, 16)
	codex_glossary_container.add_child(separator)

func _clear_glossary() -> void:
	if codex_glossary_container == null:
		return
	for child: Control in codex_glossary_container.get_children():
		child.queue_free()
