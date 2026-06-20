extends TextureButton
class_name MapLocation

var location_data: LocationData = null
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var map_label: Label = $MapLabel

signal map_location_button_up(map_location: MapLocation)

func _ready():
	button_up.connect(_on_button_up)

const LOCATION_TYPE_DISPLAY_NAMES: Dictionary = {
	LocationData.LOCATION_TYPES.STARTING: "起点",
	LocationData.LOCATION_TYPES.COMBAT: "战斗",
	LocationData.LOCATION_TYPES.MINIBOSS: "小头目",
	LocationData.LOCATION_TYPES.BOSS: "头目",
	LocationData.LOCATION_TYPES.EVENT: "事件",
	LocationData.LOCATION_TYPES.TREASURE: "宝箱",
	LocationData.LOCATION_TYPES.SHOP: "商店",
	LocationData.LOCATION_TYPES.REST_SITE: "休息站",
}

func init(_location_data: LocationData):
	location_data = _location_data
	position = location_data.location_position
	
	# display the type of location
	if location_data.location_obfuscated and not location_data.location_visited:
		map_label.text = "???" # unvisited obfuscated locations are marked hidden
	else:
		map_label.text = LOCATION_TYPE_DISPLAY_NAMES.get(location_data.location_type, "???")

func flash_location() -> void:
	animation_player.play("flash_map_location")

func _on_button_up():
	location_data.location_visited = true
	map_location_button_up.emit(self)
