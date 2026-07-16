## Strongly typed snapshot of profile-wide aggregate statistics.
extends RefCounted
class_name ProfileSummaryData

var profile_name: String = ""
var total_wins: int = 0
var total_losses: int = 0
var total_run_time: float = 0.0
var fastest_win_run_time: float = 0.0
var current_win_streak: int = 0
var current_loss_streak: int = 0
var highest_win_streak: int = 0
var highest_loss_streak: int = 0


func duplicate_data() -> ProfileSummaryData:
	var result := ProfileSummaryData.new()
	result.profile_name = profile_name
	result.total_wins = total_wins
	result.total_losses = total_losses
	result.total_run_time = total_run_time
	result.fastest_win_run_time = fastest_win_run_time
	result.current_win_streak = current_win_streak
	result.current_loss_streak = current_loss_streak
	result.highest_win_streak = highest_win_streak
	result.highest_loss_streak = highest_loss_streak
	return result
