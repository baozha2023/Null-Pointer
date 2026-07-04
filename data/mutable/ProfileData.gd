## Maintains data for the player's aggregate. Includes run history.
## NOTE: Managed by StatsHandler at the end of runs
extends SerializableData
class_name ProfileData

@export var profile_name: String = ""

# aggregate stats across all characters
@export var profile_total_wins: int = 0
@export var profile_total_losses: int = 0

@export var profile_character_id_to_wins: Dictionary[String, int] = {}
@export var profile_character_id_to_losses: Dictionary[String, int] = {}

@export var profile_total_run_time: float = 0.0
@export var profile_fastest_win_run_time: float = 0.0

# streaks across all characters
@export var profile_current_win_streak: int = 0
@export var profile_current_loss_streak: int = 0
@export var profile_highest_win_streak: int = 0
@export var profile_highest_loss_streak: int = 0

# NOTE: Winning/losing with another character does not reset win/loss streaks of other characters
@export var profile_character_id_to_current_win_streak: Dictionary[String, int] = {}
@export var profile_character_id_to_highest_win_streak: Dictionary[String, int] = {}
@export var profile_character_id_to_current_loss_streak: Dictionary[String, int] = {}
@export var profile_character_id_to_highest_loss_streak: Dictionary[String, int] = {}

## Setting this to true will allow you to select any difficulty level
## for any character, regardless of highest beaten difficulty.
static var ENABLE_ALL_DIFFICULTIES: bool = false

## Setting this to true will reveal all cards in the codex regardless of whether they have been discovered.
static var UNLOCK_ALL_CARDS_IN_CODEX: bool = false

## 测试专用常量：是否开启一键打 Boss（控制地图中一键 boss 按钮的可见性）
static var ENABLE_ONE_CLICK_BOSS: bool = false

## Tracks which cards the player has discovered (encountered) in the game.
@export var profile_discovered_cards: Dictionary = {}

## The highest difficulty each character beat a run at. Defaults to 0.
## NOTE: This will prevent the player from selecting certain difficulties, if ENABLE_ALL_DIFFICULTIES = false
@export var profile_character_id_to_highest_difficulty: Dictionary[String, int] = {}
@export var profile_character_id_to_fastest_run_time: Dictionary[String, float] = {}
@export var profile_character_id_to_total_run_time: Dictionary[String, float] = {}

## Tracks the run data of all runs in this profile.
@export var profile_run_history: Array[RunStatsData] = []
