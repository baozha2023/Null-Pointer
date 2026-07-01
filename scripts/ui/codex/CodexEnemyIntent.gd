## Displays a single intent for a selected enemy in the codex
extends PanelContainer
class_name CodexEnemyIntent

@onready var intent_name_label: Label = %IntentNameLabel
@onready var intent_rich_text_label: RichLabelAutoSizer = %IntentRichTextLabel
@onready var next_intents_label: Label = %NextIntentsLabel

const FONT_SIZE: int = 16

var enemy_data: EnemyData = null
var base_enemy_intent_data: EnemyIntentData = null # difficulty 0 intent
var best_intents: Dictionary = {}

func init(_enemy_data: EnemyData, _base_enemy_intent_data: EnemyIntentData, _best_intents: Dictionary = {}) -> void:
	enemy_data = _enemy_data
	base_enemy_intent_data = _base_enemy_intent_data
	best_intents = _best_intents
	
	intent_name_label.text = base_enemy_intent_data.enemy_intent_name
	
	# generate the intent text
	var intent_bbcode: String = _base_enemy_intent_data.get_intent_codex_bbcode()
	intent_bbcode = TextParser.parse(intent_bbcode)
	intent_bbcode = "[font_size={0}]{1}[/font_size]".format([FONT_SIZE, intent_bbcode]) # force the font to a certain size
	intent_rich_text_label.set_bbcode(intent_bbcode)
	
	# this must be called deferred to force the rich text to not get clipped
	intent_rich_text_label.set_deferred("fit_content", true)
	
	
	# figure out the next intents in the attack pattern
	# use a string join to format
	var next_intent_names: Array[String] = []
	var next_intent_text: String = ""
	for next_intent_id: String in base_enemy_intent_data.enemy_intent_next_intent_weights:
		var next_intent_data: EnemyIntentData = null
		if best_intents.has(next_intent_id):
			next_intent_data = best_intents[next_intent_id]
		else:
			var actual_next_intent_id: String = enemy_data._get_overridden_intent_id(next_intent_id)
			next_intent_data = enemy_data.enemy_intents.get(actual_next_intent_id, null)
			
		if next_intent_data == null:
			# It is valid for next_intent_data to be null if the intent is only introduced at higher difficulties,
			# and the user is currently viewing a lower difficulty. We just skip displaying it as a next intent.
			continue
			
		var next_intent_name: String = next_intent_data.enemy_intent_name
		next_intent_names.append(next_intent_name)
	
	next_intent_text = "下一意图: " + ", ".join(next_intent_names)
	next_intents_label.text = next_intent_text
