## 图鉴中每章独立的难度切换按钮，点击循环 0→1→2→...→上限→0
extends Button
class_name CodexDifficultyButton

signal difficulty_changed(difficulty: int)

var difficulty_level: int = 0
var max_difficulty: int

func _ready() -> void:
	max_difficulty = len(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS) - 1
	button_up.connect(_on_button_up)
	_update_text()

func init(_difficulty: int = 0) -> void:
	difficulty_level = _difficulty
	_update_text()

func _on_button_up() -> void:
	difficulty_level = (difficulty_level + 1) % (max_difficulty + 1)
	_update_text()
	difficulty_changed.emit(difficulty_level)

func _update_text() -> void:
	var run_modifier_id: String = Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS[difficulty_level]
	var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_id)
	if run_modifier_data != null:
		text = run_modifier_data.run_modifier_name
	else:
		text = "??"
