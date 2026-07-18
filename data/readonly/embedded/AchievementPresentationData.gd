extends SerializableData
class_name AchievementPresentationData

enum HIDDEN_POLICIES {
	VISIBLE,
	HIDE_DESCRIPTION,
	HIDE_ALL,
}

enum VALUE_FORMATS {
	INTEGER,
	DURATION,
	PERCENTAGE,
	CUSTOM_SUFFIX,
}

@export var achievement_name: String = "未定义成就"
@export var achievement_description: String = "未定义成就描述"
@export var achievement_icon_texture_path: String = "sprites/achievements/achievement_locked.png"
@export var achievement_category_id: String = "general"
@export var achievement_category_name: String = "通用"
@export var achievement_category_order: int = 0
@export var achievement_display_order: int = 0
@export var achievement_hidden_policy: int = HIDDEN_POLICIES.VISIBLE
@export var achievement_value_format: int = VALUE_FORMATS.INTEGER
@export var achievement_value_suffix: String = ""
@export var achievement_show_current_value: bool = true
@export var achievement_show_latest_value: bool = true
@export var achievement_show_best_value: bool = true
@export var achievement_show_recent_values: bool = false
