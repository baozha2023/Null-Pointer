extends SerializableData
class_name AchievementTriggerData

@export var achievement_event_id: String = ""
@export var achievement_conditions: Array[AchievementConditionData] = []
@export var achievement_progress_field_path: String = "value"
@export var achievement_unique_value_field_path: String = ""
@export var achievement_custom_evaluator_script_path: String = ""
