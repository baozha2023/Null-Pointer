## Strongly typed snapshot of aggregate statistics for one character.
extends RefCounted
class_name CharacterProfileStatsData

var character_id: String = ""
var wins: int = 0
var losses: int = 0
var current_win_streak: int = 0
var highest_win_streak: int = 0
var current_loss_streak: int = 0
var highest_loss_streak: int = 0
var highest_difficulty: int = -1
var fastest_win_run_time: float = 0.0
var total_run_time: float = 0.0


func duplicate_data() -> CharacterProfileStatsData:
	var result := CharacterProfileStatsData.new()
	result.character_id = character_id
	result.wins = wins
	result.losses = losses
	result.current_win_streak = current_win_streak
	result.highest_win_streak = highest_win_streak
	result.current_loss_streak = current_loss_streak
	result.highest_loss_streak = highest_loss_streak
	result.highest_difficulty = highest_difficulty
	result.fastest_win_run_time = fastest_win_run_time
	result.total_run_time = total_run_time
	return result
