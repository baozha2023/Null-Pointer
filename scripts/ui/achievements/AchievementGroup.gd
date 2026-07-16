extends VBoxContainer
class_name AchievementGroup

@onready var title_label: Label = %Title
@onready var count_label: Label = %Count
@onready var card_container: GridContainer = %CardContainer


func init(group_name: String, achievements: Array[AchievementData]) -> void:
	title_label.text = group_name
	var unlocked_count: int = 0
	achievements.sort_custom(_sort_achievements)
	for achievement_data: AchievementData in achievements:
		if AchievementManager.is_achievement_unlocked(achievement_data.object_id):
			unlocked_count += 1
		var card: AchievementCard = Scenes.ACHIEVEMENT_CARD.instantiate()
		card_container.add_child(card)
		card.init(achievement_data)
	count_label.text = "%d / %d" % [unlocked_count, achievements.size()]


func _sort_achievements(left: AchievementData, right: AchievementData) -> bool:
	if left.achievement_display_order == right.achievement_display_order:
		return left.object_id < right.object_id
	return left.achievement_display_order < right.achievement_display_order
