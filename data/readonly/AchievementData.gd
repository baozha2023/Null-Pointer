## Read-only, data-driven definition for an achievement.
extends SerializableData
class_name AchievementData

enum RUN_POLICIES {
	STANDARD_ONLY,
	ALLOW_CUSTOM,
	CUSTOM_ONLY,
}

@export var achievement_presentation: AchievementPresentationData = AchievementPresentationData.new()
@export var achievement_triggers: Array[AchievementTriggerData] = []
@export var achievement_progress: AchievementProgressData = null
@export var achievement_run_policy: int = RUN_POLICIES.STANDARD_ONLY
@export var achievement_record_after_unlock: bool = false

## Runtime-only provenance. External JSON cannot opt into platform synchronization.
var achievement_source_mod_object_id: String = "mod_data_base_game"
var achievement_source_name: String = "原生成就"
var achievement_is_vanilla: bool = false


func mark_as_vanilla() -> void:
	achievement_source_mod_object_id = "mod_data_base_game"
	achievement_source_name = "原生成就"
	achievement_is_vanilla = true


func set_mod_source(mod_object_id: String, mod_name: String) -> void:
	if achievement_is_vanilla:
		return
	achievement_source_mod_object_id = mod_object_id
	achievement_source_name = mod_name if mod_name != "" else mod_object_id


func get_display_name() -> String:
	return achievement_presentation.achievement_name


func get_display_description() -> String:
	return achievement_presentation.achievement_description


func get_display_icon_path() -> String:
	return achievement_presentation.achievement_icon_texture_path
