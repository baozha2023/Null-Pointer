## Read only data providing the topology of an act. See: ActionGenerateActSpire.
extends SerializableData
class_name ActData

## How the act should appear in text.
@export var act_name: String = "第一扇区"

## The act number this act is expected to be in. This is just used for the codex for
## sorting purposes. If there are multiple acts in parallel they can both be the same number.
@export var act_codex_number: int = 1
## How the act appears in the codex listing in enemy section.
@export var act_codex_color: Color = Color.WHITE


## The path to the script used to generate this act. You can change this to enable
## custom act generation
@export var act_action_script_path: String = Scripts.ACTION_GENERATE_ACT

#region Map Generation (used by ActionGenerateActSpire)
## Connection density: 0.0 = each node connects to 1 target (clean parallel lanes, spire-like).
## Higher values add extra cross-connections: 0.3 = moderate branching, 0.5 = more forks.
@export var act_map_connection_density: float = 0.0
## Floor layout templates. Each dict: {"min": int, "max": int, "pool": String, "fixed": Array[String]}
## Fixed types are guaranteed (e.g. ["SHOP"]), remainder filled by pool.
## Total floors = len(templates) + 2 (start + boss).
## NOT @export — set programmatically in act gd files.
var act_map_floor_templates: Array[Dictionary] = []
#endregion

## The event pool for this act's easy combats. Used for generation of locations in this act.
@export var act_easy_combat_event_pool_object_id: String = ""

## The event pool for this act's hard combats. Used for generation of locations in this act.
@export var act_hard_combat_event_pool_object_id: String = ""

## The event pool for non combat events. Used for generation of locations in this act.
@export var act_non_combat_event_pool_object_id: String = ""

## The pool for the miniboss events of the act
@export var act_miniboss_event_pool_object_id: String = ""

## The pool for the boss event at the end of the act
@export var act_boss_event_pool_object_id: String = ""

## The potential acts that can come after this one. Not having another act after this will result in no
## more acts being generated and the run ending. If multiple are provided one will randomly be chosen.
@export var act_next_act_ids: Array[String] = []

## A path to an external texture file to use for this act.
@export var act_background_texture_path: String = ""

@export var act_music_ambient_file_path: String = ""
@export var act_music_combat_file_path: String = ""
@export var act_music_miniboss_file_path: String = ""
@export var act_music_boss_file_path: String = ""

## Gets all combat EventData object ids for this act
func get_act_all_combat_event_ids() -> Array[String]:
	var combat_event_id_list: Array[String] = []
	if act_easy_combat_event_pool_object_id != "":
		var event_pool_data: EventPoolData = Global.get_event_pool_data(act_easy_combat_event_pool_object_id)
		combat_event_id_list.append_array(event_pool_data.event_pool_event_object_ids)
	if act_hard_combat_event_pool_object_id != "":
		var event_pool_data: EventPoolData = Global.get_event_pool_data(act_hard_combat_event_pool_object_id)
		combat_event_id_list.append_array(event_pool_data.event_pool_event_object_ids)
	if act_miniboss_event_pool_object_id != "":
		var event_pool_data: EventPoolData = Global.get_event_pool_data(act_miniboss_event_pool_object_id)
		combat_event_id_list.append_array(event_pool_data.event_pool_event_object_ids)
	if act_boss_event_pool_object_id != "":
		var event_pool_data: EventPoolData = Global.get_event_pool_data(act_boss_event_pool_object_id)
		combat_event_id_list.append_array(event_pool_data.event_pool_event_object_ids)
	
	return combat_event_id_list

## Gets all enemies that appear in this act.
func get_act_all_enemy_ids() -> Array[String]:
	var act_enemy_ids: Array[String] = []
	var act_combat_event_ids: Array[String] = get_act_all_combat_event_ids()
	
	# dict used as Set
	var enemy_id_set: Dictionary[String, Variant] = {}
	
	# run through each event and grab all enemies that can spawn from it
	for event_id: String in act_combat_event_ids:
		var event_data: EventData = Global.get_event_data(event_id)
		for spawn_slot: Dictionary in event_data.event_weighted_enemy_object_ids:
			for enemy_id: String in spawn_slot:
				if not enemy_id_set.has(enemy_id):
					enemy_id_set[enemy_id] = null
					act_enemy_ids.append(enemy_id)
	
				# also collect enemies that can be summoned by this enemy's intents
				var enemy_data: EnemyData = Global.get_enemy_data(enemy_id)
				if enemy_data != null:
					for intent_data: EnemyIntentData in enemy_data.enemy_intents.values():
						for custom_action: Dictionary in intent_data.enemy_intent_custom_actions:
							for action_data: Variant in custom_action.values():
								if action_data is Dictionary and action_data.has("random_enemy_object_ids"):
									for summoned_id: String in action_data["random_enemy_object_ids"]:
										if not enemy_id_set.has(summoned_id):
											enemy_id_set[summoned_id] = null
											act_enemy_ids.append(summoned_id)
	
	return act_enemy_ids

func _get_native_properties() -> Dictionary:
	return {
		"act_codex_color": Color(),
	}

## Default floor templates used by ActionGenerateActSpire.
## Each chapter's add_act() can call this or supply its own custom array.
static func default_floor_templates() -> Array[Dictionary]:
	return [
		{"min": 4, "max": 6, "pool": "easy", "fixed": []},                        # 1
		{"min": 4, "max": 6, "pool": "easy", "fixed": []},                        # 2
		{"min": 3, "max": 4, "pool": "easy", "fixed": ["SHOP"]},                  # 3  shop
		{"min": 4, "max": 6, "pool": "easy", "fixed": ["SHOP"]},                  # 4  shop
		{"min": 4, "max": 6, "pool": "easy", "fixed": []},                        # 5
		{"min": 3, "max": 4, "pool": "easy", "fixed": ["MINIBOSS"]},              # 6  miniboss
		{"min": 2, "max": 3, "pool": "easy", "fixed": ["REST_SITE"]},             # 7  rest
		{"min": 4, "max": 6, "pool": "hard", "fixed": ["MINIBOSS"]},              # 8  miniboss
		{"min": 4, "max": 6, "pool": "hard", "fixed": []},                        # 9
		{"min": 3, "max": 4, "pool": "easy", "fixed": ["TREASURE", "SHOP"]},      # 10 treasure+shop
		{"min": 3, "max": 5, "pool": "hard", "fixed": ["REST_SITE"]},             # 11 rest
		{"min": 3, "max": 5, "pool": "hard", "fixed": []},                        # 12
	]
