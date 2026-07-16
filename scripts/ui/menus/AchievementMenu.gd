extends BaseMenu

@onready var completion_label: Label = %Completion
@onready var group_container: VBoxContainer = %GroupContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer


func populate_menu() -> void:
	super()
	var grouped_achievements: Dictionary[String, Array] = {}
	var all_achievements: Array[AchievementData] = Global.get_all_achievement_data()
	var unlocked_count: int = 0
	for achievement_data: AchievementData in all_achievements:
		if AchievementManager.is_achievement_unlocked(achievement_data.object_id):
			unlocked_count += 1
		var group_name: String = achievement_data.achievement_source_name
		if not grouped_achievements.has(group_name):
			grouped_achievements[group_name] = []
		grouped_achievements[group_name].append(achievement_data)

	completion_label.text = "总体完成度  %d / %d" % [unlocked_count, all_achievements.size()]
	var group_names: Array[String] = []
	group_names.assign(grouped_achievements.keys())
	group_names.sort_custom(_sort_group_names)
	for group_name: String in group_names:
		var typed_achievements: Array[AchievementData] = []
		typed_achievements.assign(grouped_achievements[group_name])
		var group: AchievementGroup = Scenes.ACHIEVEMENT_GROUP.instantiate()
		group_container.add_child(group)
		group.init(group_name, typed_achievements)
	scroll_container.set_deferred("scroll_vertical", 0)


func clear_menu() -> void:
	super()
	for child: Node in group_container.get_children():
		child.queue_free()


func _sort_group_names(left: String, right: String) -> bool:
	if left == "原生成就":
		return true
	if right == "原生成就":
		return false
	return left.naturalnocasecmp_to(right) < 0
