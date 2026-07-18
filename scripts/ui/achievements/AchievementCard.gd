extends PanelContainer
class_name AchievementCard

@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %Name
@onready var description_label: Label = %Description
@onready var status_label: Label = %Status
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var progress_label: Label = %Progress
@onready var details_label: Label = %Details


func init(achievement_data: AchievementData) -> void:
	var presentation: AchievementPresentationData = achievement_data.achievement_presentation
	var state: AchievementStateData = AchievementManager.get_achievement_state(achievement_data.object_id)
	var is_unlocked: bool = state.unlocked_at > 0
	var hide_all: bool = not is_unlocked and presentation.achievement_hidden_policy == AchievementPresentationData.HIDDEN_POLICIES.HIDE_ALL
	var hide_description: bool = not is_unlocked and presentation.achievement_hidden_policy == AchievementPresentationData.HIDDEN_POLICIES.HIDE_DESCRIPTION

	if hide_all:
		icon_rect.texture = FileLoader.load_texture("sprites/achievements/achievement_locked.png")
		icon_rect.modulate = Color(0.7, 0.75, 0.8, 1.0)
		name_label.text = "隐藏成就"
		description_label.text = "达成未知条件后解锁。"
		status_label.text = "未解锁"
		_hide_progress()
		return

	icon_rect.texture = FileLoader.load_texture(presentation.achievement_icon_texture_path)
	icon_rect.modulate = Color.WHITE if is_unlocked else Color(0.38, 0.45, 0.5, 1.0)
	name_label.text = presentation.achievement_name
	description_label.text = "达成隐藏条件后解锁。" if hide_description else presentation.achievement_description
	if is_unlocked:
		status_label.text = "已解锁 · %s" % _format_unlock_time(state.unlocked_at)
		status_label.add_theme_color_override("font_color", Color(0.45, 0.95, 0.58, 1.0))
	else:
		status_label.text = "未解锁"
	if hide_description:
		_hide_progress()
		return
	_populate_progress(achievement_data, state)


func _populate_progress(achievement_data: AchievementData, state: AchievementStateData) -> void:
	var progress: AchievementProgressData = achievement_data.achievement_progress
	if progress == null:
		_hide_progress()
		return
	var presentation: AchievementPresentationData = achievement_data.achievement_presentation
	progress_bar.visible = presentation.achievement_show_current_value
	progress_label.visible = presentation.achievement_show_current_value
	details_label.visible = true
	var has_value: bool = state.update_count > 0
	var current_text: String = AchievementManager.format_value(achievement_data, state.current_value) if has_value else "暂无记录"
	var target_text: String = AchievementManager.format_value(achievement_data, progress.achievement_target_value)
	progress_label.text = "当前 %s / 目标 %s" % [current_text, target_text]
	if has_value:
		progress_bar.value = _get_progress_percentage(progress, state.best_value)
	else:
		progress_bar.value = 0.0
	var detail_parts: Array[String] = []
	if has_value and presentation.achievement_show_latest_value:
		detail_parts.append("最近 %s" % AchievementManager.format_value(achievement_data, state.latest_value))
	if has_value and presentation.achievement_show_best_value:
		detail_parts.append("最佳 %s" % AchievementManager.format_value(achievement_data, state.best_value))
	if presentation.achievement_show_recent_values:
		var recent_values: Array[AchievementRecentValueData] = AchievementManager.get_achievement_recent_values(achievement_data.object_id)
		var recent_texts: Array[String] = []
		for index: int in min(3, recent_values.size()):
			recent_texts.append(AchievementManager.format_value(achievement_data, recent_values[index].value))
		if not recent_texts.is_empty():
			detail_parts.append("记录 %s" % " / ".join(recent_texts))
	details_label.text = " · ".join(detail_parts)
	details_label.visible = not details_label.text.is_empty()


func _get_progress_percentage(progress: AchievementProgressData, best_value: float) -> float:
	var target: float = progress.achievement_target_value
	match progress.achievement_unlock_comparison:
		AchievementProgressData.COMPARISONS.LESS_OR_EQUAL:
			if best_value <= target:
				return 100.0
			if target <= 0.0:
				return 0.0
			return clamp(abs(target) / max(abs(best_value), abs(target)) * 100.0, 0.0, 100.0)
		AchievementProgressData.COMPARISONS.EQUAL:
			if is_equal_approx(best_value, target):
				return 100.0
			return clamp((1.0 - abs(best_value - target) / max(abs(target), 1.0)) * 100.0, 0.0, 100.0)
		_:
			if best_value >= target:
				return 100.0
			if target <= 0.0:
				return 0.0
			return clamp(best_value / target * 100.0, 0.0, 100.0)


func _hide_progress() -> void:
	progress_bar.visible = false
	progress_label.visible = false
	details_label.visible = false


func _format_unlock_time(timestamp: int) -> String:
	var timezone: Dictionary = Time.get_time_zone_from_system()
	var local_timestamp: int = timestamp + int(timezone.get("bias", 0)) * 60
	return Time.get_datetime_string_from_unix_time(local_timestamp, true)
