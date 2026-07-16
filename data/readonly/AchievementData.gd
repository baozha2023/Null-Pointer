## Read-only definition for an achievement. Runtime unlock state is stored by ProfileStore.
extends SerializableData
class_name AchievementData

@export var achievement_name: String = "未定义成就"
@export var achievement_description: String = "未定义成就描述"
@export var achievement_icon_texture_path: String = "sprites/achievements/achievement_locked.png"
@export var achievement_is_hidden: bool = false
@export var achievement_display_order: int = 0
@export var achievement_trigger_script_path: String = ""
@export var achievement_trigger_values: Dictionary[String, Variant] = {}
@export var achievement_disallows_custom_runs: bool = false

## Runtime-only provenance. External achievement JSON cannot opt into platform synchronization.
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
