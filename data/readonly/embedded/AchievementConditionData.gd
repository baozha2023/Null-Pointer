extends SerializableData
class_name AchievementConditionData

enum OPERATORS {
	EQUAL,
	NOT_EQUAL,
	GREATER,
	GREATER_OR_EQUAL,
	LESS,
	LESS_OR_EQUAL,
	CONTAINS,
	IN,
	IS_TRUE,
	IS_FALSE,
}

@export var achievement_condition_field_path: String = "value"
@export var achievement_condition_operator: int = OPERATORS.EQUAL
@export var achievement_condition_value: Variant = null
