## Prototype data for a player-side combatant summoned into the battlefield.
extends PrototypeData
class_name FriendlyData

@export var friendly_name: String = ""
@export var friendly_texture_path: String = "sprites/missing_texture.png"
@export var friendly_animation_id: String = ""
@export_range(0.5, 2.0, 0.05) var friendly_combat_scale: float = 1.0

@export var friendly_health: int = 20
@export var friendly_health_max: int = 20
@export var friendly_block: int = 0
@export var friendly_can_revive_in_combat: bool = false
@export var friendly_actions_on_death: Array[Dictionary] = []

@export var friendly_initial_status_effects: Dictionary[String, int] = {}
@export var friendly_initial_status_custom_values: Dictionary = {}

## A status can change the world sprite without coupling status logic to UI code.
@export var friendly_visual_state_status_texture_paths: Dictionary[String, String] = {}
