extends BaseMenu

@onready var profile_total_runs_label: Label = %ProfileTotalRunsLabel
@onready var profile_wins_label: Label = %ProfileWinsLabel
@onready var profile_losses_label: Label = %ProfileLossesLabel
@onready var profile_win_rate_label: Label = %ProfileWinRateLabel
@onready var profile_current_win_streak_label: Label = %ProfileCurrentWinStreakLabel
@onready var profile_highest_win_streak_label: Label = %ProfileHighestWinStreakLabel
@onready var profile_play_time_label: Label = %ProfilePlayTimeLabel
@onready var profile_current_loss_streak_label: Label = %ProfileCurrentLossStreakLabel
@onready var profile_highest_loss_streak_label: Label = %ProfileHighestLossStreakLabel
@onready var profile_fastest_run_time: Label = %ProfileFastestRunTime
@onready var profile_count_label: Label = %Count
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var stat_container: GridContainer = %StatContainer


func populate_menu() -> void:
	super()
	var profile_data: ProfileData = Global.profile_data
	if profile_data == null:
		return

	var total_runs: int = profile_data.profile_total_wins + profile_data.profile_total_losses
	var win_rate: float = float(profile_data.profile_total_wins) / float(max(total_runs, 1))

	profile_total_runs_label.text = str(total_runs)
	profile_wins_label.text = str(profile_data.profile_total_wins)
	profile_losses_label.text = str(profile_data.profile_total_losses)
	profile_win_rate_label.text = "%0.2f%%" % (win_rate * 100.0)
	profile_current_win_streak_label.text = str(profile_data.profile_current_win_streak)
	profile_highest_win_streak_label.text = str(profile_data.profile_highest_win_streak)
	profile_current_loss_streak_label.text = str(profile_data.profile_current_loss_streak)
	profile_highest_loss_streak_label.text = str(profile_data.profile_highest_loss_streak)
	profile_play_time_label.text = TextParser.format_duration(profile_data.profile_total_run_time)
	profile_fastest_run_time.text = TextParser.format_duration(
		profile_data.profile_fastest_win_run_time,
		"--:--:--",
	)

	var character_ids: Array[String] = []
	character_ids.assign(Global._id_to_character_data.keys())
	profile_count_label.text = "共 %d 个进程" % character_ids.size()
	for character_id: String in character_ids:
		var character_stat: CharacterStat = Scenes.CHARACTER_STAT.instantiate()
		stat_container.add_child(character_stat)
		character_stat.init(character_id)

	scroll_container.set_deferred("scroll_vertical", 0)


func clear_menu() -> void:
	super()
	for child: Node in stat_container.get_children():
		child.queue_free()
