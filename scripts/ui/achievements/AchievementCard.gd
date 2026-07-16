extends PanelContainer
class_name AchievementCard

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var description_label: Label = %Description
@onready var status_label: Label = %Status


func init(achievement_data: AchievementData) -> void:
	var is_unlocked: bool = AchievementManager.is_achievement_unlocked(achievement_data.object_id)
	if is_unlocked:
		icon_rect.texture = FileLoader.load_texture(achievement_data.achievement_icon_texture_path)
		icon_rect.modulate = Color.WHITE
		name_label.text = achievement_data.achievement_name
		description_label.text = achievement_data.achievement_description
		status_label.text = "已解锁 · %s" % _format_unlock_time(
			AchievementManager.get_unlock_timestamp(achievement_data.object_id),
		)
		status_label.add_theme_color_override("font_color", Color(0.45, 0.95, 0.58, 1.0))
	elif achievement_data.achievement_is_hidden:
		icon_rect.texture = FileLoader.load_texture("sprites/achievements/achievement_locked.png")
		icon_rect.modulate = Color(0.7, 0.75, 0.8, 1.0)
		name_label.text = "隐藏成就"
		description_label.text = "达成未知条件后解锁。"
		status_label.text = "未解锁"
	else:
		icon_rect.texture = FileLoader.load_texture(achievement_data.achievement_icon_texture_path)
		icon_rect.modulate = Color(0.32, 0.38, 0.44, 1.0)
		name_label.text = achievement_data.achievement_name
		description_label.text = achievement_data.achievement_description
		status_label.text = "未解锁"


func _format_unlock_time(timestamp: int) -> String:
	var timezone: Dictionary = Time.get_time_zone_from_system()
	var local_timestamp: int = timestamp + int(timezone.get("bias", 0)) * 60
	return Time.get_datetime_string_from_unix_time(local_timestamp, true)
