extends Control
class_name CharacterStat

@onready var character_icon: TextureRect = %CharacterIcon
@onready var character_name_label: Label = %CharacterNameLabel
@onready var character_play_time_label: Label = %CharacterPlayTimeLabel
@onready var character_fastest_play_time_label: Label = %CharacterFastestPlayTimeLabel
@onready var character_wins_label: Label = %CharacterWinsLabel
@onready var character_losses_label: Label = %CharacterLossesLabel
@onready var character_win_rate_label: Label = %CharacterWinRateLabel
@onready var character_current_win_streak_label: Label = %CharacterCurrentWinStreakLabel
@onready var character_highest_win_streak_label: Label = %CharacterHighestWinStreakLabel
@onready var character_current_loss_streak_label: Label = %CharacterCurrentLossStreakLabel
@onready var character_highest_loss_streak_label: Label = %CharacterHighestLossStreakLabel


func init(character_id: String) -> void:
	var profile_data: ProfileData = Global.profile_data
	var character_data: CharacterData = Global.get_character_data(character_id)
	if profile_data == null or character_data == null:
		return

	character_icon.texture = FileLoader.load_texture(character_data.character_icon_texture_path)
	character_name_label.text = character_data.character_name

	var wins: int = profile_data.profile_character_id_to_wins.get(character_id, 0)
	var losses: int = profile_data.profile_character_id_to_losses.get(character_id, 0)
	var total_runs: int = wins + losses
	var win_rate: float = float(wins) / float(max(total_runs, 1))

	character_wins_label.text = str(wins)
	character_losses_label.text = str(losses)
	character_win_rate_label.text = "%0.2f%%" % (win_rate * 100.0)
	character_current_win_streak_label.text = str(
		profile_data.profile_character_id_to_current_win_streak.get(character_id, 0),
	)
	character_highest_win_streak_label.text = str(
		profile_data.profile_character_id_to_highest_win_streak.get(character_id, 0),
	)
	character_current_loss_streak_label.text = str(
		profile_data.profile_character_id_to_current_loss_streak.get(character_id, 0),
	)
	character_highest_loss_streak_label.text = str(
		profile_data.profile_character_id_to_highest_loss_streak.get(character_id, 0),
	)

	var total_run_time: float = profile_data.profile_character_id_to_total_run_time.get(character_id, 0.0)
	var fastest_run_time: float = profile_data.profile_character_id_to_fastest_run_time.get(character_id, 0.0)
	character_play_time_label.text = TextParser.format_duration(total_run_time)
	character_fastest_play_time_label.text = TextParser.format_duration(
		fastest_run_time,
		"--:--:--",
	)
