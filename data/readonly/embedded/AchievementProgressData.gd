extends SerializableData
class_name AchievementProgressData

enum COMPARISONS {
	GREATER_OR_EQUAL,
	LESS_OR_EQUAL,
	EQUAL,
}

enum AGGREGATIONS {
	COUNT,
	SUM,
	LATEST,
	MAXIMUM,
	MINIMUM,
	UNIQUE_COUNT,
}

enum SCOPES {
	LIFETIME,
	RUN,
	COMBAT,
	TURN,
}

@export var achievement_target_value: float = 1.0
@export var achievement_unlock_comparison: int = COMPARISONS.GREATER_OR_EQUAL
@export var achievement_aggregation: int = AGGREGATIONS.COUNT
@export var achievement_scope: int = SCOPES.LIFETIME
@export var achievement_recent_history_limit: int = 5
