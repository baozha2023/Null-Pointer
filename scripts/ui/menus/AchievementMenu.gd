extends BaseMenu

@onready var completion_label: Label = %Completion
@onready var group_container: VBoxContainer = %GroupContainer
@onready var scroll_container: ScrollContainer = %ScrollContainer


func populate_menu() -> void:
	super()
	var grouped_achievements: Dictionary[String, Array] = {}
	var group_sort_values: Dictionary[String, Array] = {}
	var all_achievements: Array[AchievementData] = Global.get_all_achievement_data()
	var unlocked_count: int = 0
	for achievement_data: AchievementData in all_achievements:
		if AchievementManager.is_achievement_unlocked(achievement_data.object_id):
			unlocked_count += 1
		var presentation: AchievementPresentationData = achievement_data.achievement_presentation
		var group_key: String = "%s\u001f%s" % [achievement_data.achievement_source_name, presentation.achievement_category_id]
		if not grouped_achievements.has(group_key):
			grouped_achievements[group_key] = []
			group_sort_values[group_key] = [
				0 if achievement_data.achievement_is_vanilla else 1,
				achievement_data.achievement_source_name,
				presentation.achievement_category_order,
				presentation.achievement_category_name,
			]
		grouped_achievements[group_key].append(achievement_data)

	completion_label.text = "总体完成度  %d / %d" % [unlocked_count, all_achievements.size()]
	var group_keys: Array[String] = []
	group_keys.assign(grouped_achievements.keys())
	group_keys.sort_custom(func(left: String, right: String) -> bool:
		return _compare_group_sort_values(group_sort_values[left], group_sort_values[right])
	)
	for group_key: String in group_keys:
		var typed_achievements: Array[AchievementData] = []
		typed_achievements.assign(grouped_achievements[group_key])
		var sort_value: Array = group_sort_values[group_key]
		var title: String = "%s / %s" % [str(sort_value[1]), str(sort_value[3])]
		var group: AchievementGroup = Scenes.ACHIEVEMENT_GROUP.instantiate()
		group_container.add_child(group)
		group.init(title, typed_achievements)
	scroll_container.set_deferred("scroll_vertical", 0)


func clear_menu() -> void:
	super()
	for child: Node in group_container.get_children():
		child.queue_free()


func _compare_group_sort_values(left: Array, right: Array) -> bool:
	if int(left[0]) != int(right[0]):
		return int(left[0]) < int(right[0])
	if str(left[1]) != str(right[1]):
		return str(left[1]).naturalnocasecmp_to(str(right[1])) < 0
	if int(left[2]) != int(right[2]):
		return int(left[2]) < int(right[2])
	return str(left[3]).naturalnocasecmp_to(str(right[3])) < 0
