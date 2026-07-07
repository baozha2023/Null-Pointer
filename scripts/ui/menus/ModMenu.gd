extends BaseMenu

@onready var mod_list_vbox: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/ModListVBox
@onready var import_button: Button = $MarginContainer/VBoxContainer/TopBar/ImportButton

var mod_list_data: ModListData

const MOD_ITEM_SCENE = preload("res://scenes/ui/menus/ModItem.tscn")
var file_dialog: FileDialog

func _ready() -> void:
	super()
	
	import_button.pressed.connect(_on_import_button_pressed)
	
	file_dialog = FileDialog.new()
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.use_native_dialog = true
	file_dialog.filters = ["*.zip ; Mod Archives"]
	file_dialog.file_selected.connect(_on_file_selected)
	add_child(file_dialog)
	
	var back_btn = $MarginContainer/VBoxContainer/BottomBar/MainMenuButton
	if back_btn and get_parent().has_node("MainMenu"):
		navigation_button_to_menu[back_btn as Button] = get_parent().get_node("MainMenu") as BaseMenu
		_bind_navigation_buttons()

func populate_menu() -> void:
	super()
	
	# Clear existing items
	for child in mod_list_vbox.get_children():
		child.queue_free()
		
	mod_list_data = FileLoader._load_mod_list_data()
	var mod_folders = mod_list_data.mod_load_data.keys()
	
	for mod_folder in mod_folders:
		var mod_info = mod_list_data.mod_load_data[mod_folder]
		var is_enabled = mod_info.get("enabled", true)
		
		# Try load mod_info.json
		var mod_dict = FileLoader.load_json(mod_folder, FileLoader.MOD_INFO_FILE_NAME)
		var props = mod_dict.get("properties", {}) if mod_dict else {}
		var mod_name = props.get("mod_name", "")
		if mod_name == "":
			mod_name = "未命名模组"
			
		var mod_author = ""
		var mod_desc = ""
		var mod_version = ""
		
		if props.get("mod_author", "") != "":
			mod_author = props.get("mod_author")
		if props.get("mod_description", "") != "":
			mod_desc = props.get("mod_description")
			
		if props.has("mod_version"):
			var v = props.get("mod_version")
			if typeof(v) == TYPE_DICTIONARY and (v.get("major", 0) > 0 or v.get("minor", 0) > 0 or v.get("patch", 0) > 0):
				mod_version = "%d.%d.%d" % [v.get("major", 0), v.get("minor", 0), v.get("patch", 0)]
			
		var object_id = props.get("object_id", "")
		
		var mod_item = MOD_ITEM_SCENE.instantiate()
		mod_list_vbox.add_child(mod_item)
		mod_item.setup(mod_folder, object_id, mod_name, mod_version, mod_author, mod_desc, is_enabled)
		mod_item.mod_toggled.connect(_on_mod_toggled)
		mod_item.mod_deleted.connect(_on_mod_deleted)

func _on_mod_toggled(button_pressed: bool, mod_folder: String) -> void:
	mod_list_data.mod_load_data[mod_folder]["enabled"] = button_pressed
	FileLoader.save_json(FileLoader.EXTERNAL_DIR_PATH, FileLoader.MOD_LIST_FILE_NAME, mod_list_data.get_serializable_properties_to_json_patch())
	UIMessage.show_message("更改需要重启游戏方可生效")

func _on_mod_deleted(mod_folder: String) -> void:
	var abs_path = ProjectSettings.globalize_path(FileLoader._get_modified_filepath(mod_folder))
	OS.move_to_trash(abs_path)
	
	mod_list_data.mod_load_data.erase(mod_folder)
	FileLoader.save_json(FileLoader.EXTERNAL_DIR_PATH, FileLoader.MOD_LIST_FILE_NAME, mod_list_data.get_serializable_properties_to_json_patch())
	
	UIMessage.show_message("模组已删除！")
	populate_menu()

func _on_import_button_pressed() -> void:
	file_dialog.popup_centered()

func _on_file_selected(path: String) -> void:
	var reader = ZIPReader.new()
	var err = reader.open(path)
	if err != OK:
		UIMessage.show_message("解析 Zip 文件失败！")
		return
		
	var files = reader.get_files()
	if files.is_empty():
		UIMessage.show_message("Zip 文件为空！")
		return
		
	# Verify mod_info.json exists anywhere in zip
	var has_mod_info = false
	var root_offset = ""
	for f in files:
		if f.ends_with("mod_info.json"):
			has_mod_info = true
			if f != "mod_info.json":
				root_offset = f.get_base_dir() + "/"
			break
			
	if not has_mod_info:
		UIMessage.show_message("格式错误：压缩包内未找到 mod_info.json")
		reader.close()
		return
		
	# Extract object_id and version from ZIP's mod_info.json
	var mod_info_bytes = reader.read_file(root_offset + "mod_info.json")
	var mod_info_text = mod_info_bytes.get_string_from_utf8()
	var parser = JSON.new()
	if parser.parse(mod_info_text) != OK:
		UIMessage.show_message("解析失败：压缩包内的 mod_info.json 格式损坏！")
		reader.close()
		return
		
	var mod_dict = parser.get_data()
	var props = mod_dict.get("properties", {}) if mod_dict else {}
	
	if props.get("mod_name", "") == "":
		UIMessage.show_message("导入失败：模组配置文件中缺失 mod_name，此为必填项！")
		reader.close()
		return
		
	var object_id = props.get("object_id", "")
	
	if object_id == "":
		UIMessage.show_message("导入失败：模组配置文件中缺失 object_id！")
		reader.close()
		return
		
	var v = props.get("mod_version", {})
	var incoming_version = "%d.%d.%d" % [v.get("major", 0), v.get("minor", 0), v.get("patch", 0)]
	
	var mod_folder_name = "external/mods/" + object_id + "/"
	
	# Check for deduplication / existing versions
	if mod_list_data.mod_load_data.has(mod_folder_name):
		var installed_dict = FileLoader.load_json(mod_folder_name, FileLoader.MOD_INFO_FILE_NAME)
		var installed_props = installed_dict.get("properties", {}) if installed_dict else {}
		var iv = installed_props.get("mod_version", {})
		var installed_version = "%d.%d.%d" % [iv.get("major", 0), iv.get("minor", 0), iv.get("patch", 0)]
		
		if incoming_version == installed_version:
			UIMessage.show_message("导入中止：该模组 (v" + incoming_version + ") 已存在，无需重复导入！")
		else:
			UIMessage.show_message("导入中止：已存在该模组的另一个版本 v" + installed_version + " (本次为 v" + incoming_version + ")。请先手动卸载旧版。")
			
		reader.close()
		return
		
	var target_base_dir = FileLoader._get_modified_filepath(mod_folder_name)
	DirAccess.make_dir_recursive_absolute(target_base_dir)
	
	# Determine if we need to rewrite internal paths in mod_info.json
	var old_mod_folder = ""
	var folder_data = props.get("mod_folder_to_load_data", {})
	if folder_data.size() > 0:
		var first_key = folder_data.keys()[0]
		var parts = first_key.split("/")
		if parts.size() >= 3:
			old_mod_folder = parts[0] + "/" + parts[1] + "/" + parts[2] + "/"
			
	if old_mod_folder != "" and old_mod_folder != mod_folder_name:
		mod_info_text = mod_info_text.replace(old_mod_folder, mod_folder_name)
	
	for file_path in files:
		if root_offset != "" and not file_path.begins_with(root_offset):
			continue
			
		var relative_path = file_path.trim_prefix(root_offset)
		if relative_path == "":
			continue
			
		if file_path.ends_with("/"):
			DirAccess.make_dir_recursive_absolute(target_base_dir + relative_path)
		else:
			var parent_dir = relative_path.get_base_dir()
			if parent_dir != "":
				DirAccess.make_dir_recursive_absolute(target_base_dir + parent_dir)
				
			var content = reader.read_file(file_path)
			if relative_path == "mod_info.json":
				content = mod_info_text.to_utf8_buffer()
				
			var f = FileAccess.open(target_base_dir + relative_path, FileAccess.WRITE)
			if f:
				f.store_buffer(content)
				f.close()
				
	reader.close()
	
	# Add to mod list and default enable
	mod_list_data.mod_load_data[mod_folder_name] = {
		"enabled": true,
		"load_priority": 1.0
	}
	FileLoader.save_json(FileLoader.EXTERNAL_DIR_PATH, FileLoader.MOD_LIST_FILE_NAME, mod_list_data.get_serializable_properties_to_json_patch())
	
	UIMessage.show_message("模组导入成功并已默认开启！重启生效")
	populate_menu()
