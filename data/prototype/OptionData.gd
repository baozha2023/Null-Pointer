class_name OptionData
extends SerializableData

@export var option_name: String = ""
@export var option_description: String = ""
@export var option_texture_path: String = ""
@export var option_disabled: bool = false
@export var option_disabled_reason: String = ""
@export var option_sub_actions: Array[Dictionary] = []

func _init(_option_id: String = ""):
	object_id = _option_id
