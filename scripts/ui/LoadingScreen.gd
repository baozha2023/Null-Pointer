extends Control

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var label: Label = $VBoxContainer/Label

var _resources_to_load: Array[Dictionary] = []
var _current_index: int = 0
const BATCH_SIZE: int = 5 # 每次 _process 加载的图片数量，以防卡死主线程

func _ready() -> void:
	# ==========================================
	# 商业化 UI 样式美化（赛博/机甲风代码动态生成）
	# ==========================================
	progress_bar.show_percentage = true # 在进度条正中央显示百分比数字
	
	# 给居中的数字加上好看的字体样式和描边，防止被发光的进度条掩盖
	progress_bar.add_theme_font_size_override("font_size", 20)
	progress_bar.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	progress_bar.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	progress_bar.add_theme_constant_override("outline_size", 4)
	
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.08, 0.1, 0.9)
	bg_style.border_width_left = 2
	bg_style.border_width_top = 2
	bg_style.border_width_right = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.2, 0.3, 0.4, 0.8)
	bg_style.corner_radius_top_left = 8
	bg_style.corner_radius_top_right = 8
	bg_style.corner_radius_bottom_right = 8
	bg_style.corner_radius_bottom_left = 8
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0.0, 0.85, 1.0, 1.0) # 赛博霓虹青蓝色
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_right = 6
	fill_style.corner_radius_bottom_left = 6
	# 添加外发光 (Glow) 效果
	fill_style.shadow_color = Color(0.0, 0.85, 1.0, 0.4)
	fill_style.shadow_size = 12
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)
	
	# 优化提示文字样式
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.85, 1.0, 0.2))
	label.add_theme_constant_override("outline_size", 4)
	
	# ==========================================

	# 收集所有需要加载的卡牌图片路径
	for card_id: String in Global._id_to_card_data:
		var card: CardData = Global._id_to_card_data[card_id]
		if card.card_texture_path != "":
			if not _has_resource(card.card_texture_path):
				_resources_to_load.append({"path": card.card_texture_path, "type": "卡牌资源"})
	
	# 收集所有需要加载的外设图片路径
	for artifact_id: String in Global._id_to_artifact_data:
		var artifact: ArtifactData = Global._id_to_artifact_data[artifact_id]
		if artifact.artifact_texture_path != "":
			if not _has_resource(artifact.artifact_texture_path):
				_resources_to_load.append({"path": artifact.artifact_texture_path, "type": "外设资源"})

	# 收集所有需要加载的消耗品图片路径
	for consumable_id: String in Global._id_to_consumable_data:
		var consumable: ConsumableData = Global._id_to_consumable_data[consumable_id]
		if consumable.consumable_texture_path != "":
			if not _has_resource(consumable.consumable_texture_path):
				_resources_to_load.append({"path": consumable.consumable_texture_path, "type": "消耗品资源"})
	
	if _resources_to_load.is_empty():
		_finish_loading()

func _has_resource(path: String) -> bool:
	for res in _resources_to_load:
		if res["path"] == path:
			return true
	return false

func _process(_delta: float) -> void:
	if _resources_to_load.is_empty():
		return
		
	var loaded_this_frame: int = 0
	var current_type: String = ""
	
	# 如果还没有加载完毕，则继续按块读取
	if _current_index < _resources_to_load.size():
		while _current_index < _resources_to_load.size() and loaded_this_frame < BATCH_SIZE:
			var res_dict: Dictionary = _resources_to_load[_current_index]
			var path: String = res_dict["path"]
			current_type = res_dict["type"]
			
			# 贴图将会被自动缓存在 FileLoader._cached_textures 内部
			var texture: Texture2D = FileLoader.load_texture(path)
			
			_current_index += 1
			loaded_this_frame += 1
			
		var target_percent: float = (float(_current_index) / float(_resources_to_load.size())) * 100.0
		
		if current_type != "":
			label.text = "正在加载%s..." % current_type
			
		# 保存目标百分比到 Meta，用作 lerp 的目标值
		set_meta("target_percent", target_percent)
	
	# 从 Meta 中获取目标值（如果没有则默认为 0.0）
	var target_val: float = get_meta("target_percent", 0.0)
	
	# 商业游戏级别的平滑动画：利用 lerpf 每一帧平滑追赶目标进度
	progress_bar.value = lerpf(progress_bar.value, target_val, 15.0 * _delta)
	
	# 只有当数据全部读取完毕，且视觉上进度条也跑到 99% 以上时，才算真正结束
	if _current_index >= _resources_to_load.size() and progress_bar.value >= 99.0:
		progress_bar.value = 100.0
		set_process(false)
		_finish_loading()

func _finish_loading() -> void:
	# 资源加载完毕，进入原主场景
	get_tree().change_scene_to_file("res://scenes/Root.tscn")
