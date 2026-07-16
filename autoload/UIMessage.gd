extends CanvasLayer

enum MESSAGE_TYPES {NORMAL, SUCCESS, WARNING, ERROR, ACHIEVEMENT}

const MESSAGE_ITEM_SCENE: PackedScene = preload("res://scenes/ui/UIMessageItem.tscn")

var container: VBoxContainer


func _ready() -> void:
	layer = 100
	container = VBoxContainer.new()
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	container.offset_top = 14.0
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 10)
	add_child(container)
	Signals.achievement_unlocked.connect(show_achievement_unlocked)


## Globally show a typed toast. Icon and title are optional.
func show_message(
	text: String,
	duration: float = 2.0,
	icon: Texture2D = null,
	title: String = "",
	message_type: int = MESSAGE_TYPES.NORMAL,
) -> void:
	var item: UIMessageItem = MESSAGE_ITEM_SCENE.instantiate()
	item.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	container.add_child(item)
	item.configure(text, icon, title, message_type)
	item.show_animation(duration)


func show_achievement_unlocked(achievement_data: AchievementData) -> void:
	var icon: Texture2D = FileLoader.load_texture(achievement_data.achievement_icon_texture_path)
	show_message(
		achievement_data.achievement_description,
		3.0,
		icon,
		"成就解锁 · %s" % achievement_data.achievement_name,
		MESSAGE_TYPES.ACHIEVEMENT,
	)
