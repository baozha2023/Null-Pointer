extends PanelContainer

@onready var name_label = $MarginContainer/HBoxContainer/TextVBox/HeaderHBox/NameLabel
@onready var version_label = $MarginContainer/HBoxContainer/TextVBox/HeaderHBox/VersionLabel
@onready var author_label = $MarginContainer/HBoxContainer/TextVBox/HeaderHBox/AuthorLabel
@onready var desc_label = $MarginContainer/HBoxContainer/TextVBox/DescLabel
@onready var toggle_check = $MarginContainer/HBoxContainer/ActionVBox/ToggleCheck
@onready var delete_button = $MarginContainer/HBoxContainer/ActionVBox/DeleteButton

var mod_folder: String

signal mod_toggled(button_pressed: bool, mod_folder: String)
signal mod_deleted(mod_folder: String)

func setup(p_mod_folder: String, p_object_id: String, p_name: String, p_version: String, p_author: String, p_desc: String, is_enabled: bool) -> void:
	mod_folder = p_mod_folder
	name_label.text = p_name
	
	if p_version != "":
		version_label.text = "v" + p_version
		version_label.show()
	else:
		version_label.hide()
		
	if p_author != "":
		author_label.text = "作者: " + p_author
		author_label.show()
	else:
		author_label.hide()
		
	if p_desc != "":
		desc_label.text = p_desc
		desc_label.show()
	else:
		desc_label.hide()
		
	toggle_check.button_pressed = is_enabled
	toggle_check.text = "开启" if is_enabled else "关闭"
	
	if p_object_id == "mod_data_base_game":
		delete_button.hide()
	else:
		delete_button.show()

func _ready() -> void:
	toggle_check.toggled.connect(_on_check_toggled)
	delete_button.pressed.connect(_on_delete_pressed)

func _on_check_toggled(button_pressed: bool) -> void:
	toggle_check.text = "开启" if button_pressed else "关闭"
	mod_toggled.emit(button_pressed, mod_folder)

func _on_delete_pressed() -> void:
	mod_deleted.emit(mod_folder)
