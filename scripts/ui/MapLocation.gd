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
	LocationData.LOCATION_TYPES.MINIBOSS: "精英怪",
	LocationData.LOCATION_TYPES.BOSS: "Boss",
	LocationData.LOCATION_TYPES.EVENT: "异常",
	LocationData.LOCATION_TYPES.TREASURE: "加密包",
	LocationData.LOCATION_TYPES.SHOP: "暗网节点",
	LocationData.LOCATION_TYPES.REST_SITE: "维护终端",
}

var LOCATION_TYPE_TEXTURES: Dictionary = {}

var UNKNOWN_TEXTURE: Texture2D

func init(_location_data: LocationData):
	location_data = _location_data
	position = location_data.location_position
	
	if LOCATION_TYPE_TEXTURES.is_empty():
		LOCATION_TYPE_TEXTURES = {
			LocationData.LOCATION_TYPES.COMBAT: preload("res://sprites/map/map_icon_combat.png"),
			LocationData.LOCATION_TYPES.MINIBOSS: preload("res://sprites/map/map_icon_miniboss.png"),
			LocationData.LOCATION_TYPES.BOSS: preload("res://sprites/map/map_icon_boss.png"),
			LocationData.LOCATION_TYPES.EVENT: preload("res://sprites/map/map_icon_event.png"),
			LocationData.LOCATION_TYPES.TREASURE: preload("res://sprites/map/map_icon_treasure.png"),
			LocationData.LOCATION_TYPES.SHOP: preload("res://sprites/map/map_icon_shop.png"),
			LocationData.LOCATION_TYPES.REST_SITE: preload("res://sprites/map/map_icon_rest_site.png"),
		}
		UNKNOWN_TEXTURE = preload("res://sprites/map/map_icon_unknown.png")
	
	# display the type of location
	if location_data.location_obfuscated and not location_data.location_visited:
		map_label.text = "???" # unvisited obfuscated locations are marked hidden
		texture_normal = UNKNOWN_TEXTURE
	else:
		map_label.text = LOCATION_TYPE_DISPLAY_NAMES.get(location_data.location_type, "???")
		if LOCATION_TYPE_TEXTURES.has(location_data.location_type):
			texture_normal = LOCATION_TYPE_TEXTURES[location_data.location_type]

func flash_location() -> void:
	animation_player.play("flash_map_location")

func _on_button_up():
	map_location_button_up.emit(self)
