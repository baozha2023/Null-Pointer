extends BaseCombatant
class_name Enemy

@onready var enemy_intent: HBoxContainer = $Visible/Intent

# icons used for displaying specific intent types
@onready var attacking_intent: TextureRect = $Visible/Intent/AttackingIntent
@onready var blocking_intent: TextureRect = $Visible/Intent/BlockingIntent
@onready var debuffing_intent: TextureRect = $Visible/Intent/DebuffingIntent
@onready var buffing_intent: TextureRect = $Visible/Intent/BuffingIntent
@onready var summoning_intent: TextureRect = $Visible/Intent/SummoningIntent

# maps the EnemyIntentData.enemy_intent_display_type to the texture to display
@onready var INTENT_DISPLAY_TYPE_TO_INTENT: Dictionary[int, TextureRect] = {
	EnemyIntentData.INTENT_DISPLAY_TYPES.ATTACKING: attacking_intent,
	EnemyIntentData.INTENT_DISPLAY_TYPES.BLOCKING: blocking_intent,
	EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING: debuffing_intent,
	EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING: buffing_intent,
	EnemyIntentData.INTENT_DISPLAY_TYPES.SUMMONING: summoning_intent,
}

@onready var enemy_intent_amount_label: Label = $Visible/Intent/IntentAmount

@onready var name_label = %NameLabel
@onready var death_animation_player: AnimationPlayer = $DeathAnimationPlayer

var enemy_data: EnemyData = null
var enemy_slot: int = 0 # the spawn slot the enemy is in

var enemy_intent_attack_damage: int = 0
var enemy_intent_number_of_attacks: int = 0

func init(_enemy_data: EnemyData):
	enemy_data = _enemy_data
	
	selection_button.mouse_entered.connect(_on_mouse_entered)
	selection_button.mouse_exited.connect(_on_mouse_exited)
	
	enemy_intent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enemy_intent_amount_label.mouse_filter = Control.MOUSE_FILTER_PASS
	enemy_intent_amount_label.mouse_default_cursor_shape = Control.CURSOR_ARROW
	
	# keep attack damage number adjacent to attacking icon
	enemy_intent.move_child(enemy_intent_amount_label, 1)
	enemy_intent_amount_label.mouse_entered.connect(_on_single_intent_mouse_entered.bind(EnemyIntentData.INTENT_DISPLAY_TYPES.ATTACKING, enemy_intent_amount_label))
	enemy_intent_amount_label.mouse_exited.connect(_on_intent_mouse_exited.bind(enemy_intent_amount_label))
	
	var special_intent: TextureRect = summoning_intent.duplicate()
	enemy_intent.add_child(special_intent)
	INTENT_DISPLAY_TYPE_TO_INTENT[EnemyIntentData.INTENT_DISPLAY_TYPES.SPECIAL] = special_intent
	
	for display_type: int in INTENT_DISPLAY_TYPE_TO_INTENT:
		var intent_icon: TextureRect = INTENT_DISPLAY_TYPE_TO_INTENT[display_type]
		intent_icon.tooltip_text = ""
		intent_icon.mouse_filter = Control.MOUSE_FILTER_PASS
		intent_icon.mouse_entered.connect(_on_single_intent_mouse_entered.bind(display_type, intent_icon))
		intent_icon.mouse_exited.connect(_on_intent_mouse_exited.bind(intent_icon))
	
	animated_sprite_2d.sprite_frames = get_animation_sprite_frames()
	play_animation(AnimationData.ANIMATION_IDLE)
	
	# apply initial effects
	for status_effect_object_id in enemy_data.enemy_initial_status_effects.keys():
		var charge_amount: int = enemy_data.enemy_initial_status_effects[status_effect_object_id]
		var custom_values: Dictionary = enemy_data.enemy_initial_status_custom_values.get(status_effect_object_id, {})
		add_new_status_effect(status_effect_object_id, charge_amount, 0, custom_values)
	
	name_label.text = enemy_data.enemy_name
	
	# update_health_bar()
	layered_health_bar.init(enemy_data.enemy_health, enemy_data.enemy_health_max)
	
	# Dynamic Mod Support
	attacking_intent.texture = preload("res://sprites/intents/enemy_intent_attacking.png")
	blocking_intent.texture = preload("res://sprites/intents/enemy_intent_blocking.png")
	debuffing_intent.texture = preload("res://sprites/intents/enemy_intent_debuffing.png")
	buffing_intent.texture = preload("res://sprites/intents/enemy_intent_buffing.png")
	summoning_intent.texture = preload("res://sprites/intents/enemy_intent_summoning.png")
	if INTENT_DISPLAY_TYPE_TO_INTENT.has(EnemyIntentData.INTENT_DISPLAY_TYPES.SPECIAL):
		INTENT_DISPLAY_TYPE_TO_INTENT[EnemyIntentData.INTENT_DISPLAY_TYPES.SPECIAL].texture = preload("res://sprites/missing_texture.png")
	
func get_animation_data() -> AnimationData:
	var animation_data: AnimationData = Global.get_animation_data(enemy_data.enemy_animation_id)
	return animation_data

## Does damage to combatant and returns [unblocked damage dealt, damage to 0 (if enemy dies), overkill damage (if enemy dies)]
## eg 15 damage on 10 remaining health and 3 block will return [12, 10, 2].
## bypass_block = true will do damage directly to health.
func damage(_damage: int, bypass_block: bool = false) -> Array[int]:
	var bypassed_damage: int = _damage # raw unblocked damage
	var bypassed_damage_capped: int = 0 # damage done that does not factor in overkill damage
	var overkill_damage: int = 0 # damage done past 0
	
	if enemy_data.enemy_block > 0 and not bypass_block:
		if enemy_data.enemy_block > _damage:
			# damage less than block
			enemy_data.enemy_block -= _damage
			bypassed_damage = 0
			create_block_text()
			Signals.combatant_blocked.emit(self, _damage)
		else:
			# damage exceeds block
			bypassed_damage = _damage - enemy_data.enemy_block
			enemy_data.enemy_block = 0
			Signals.combatant_block_broken.emit(self)
	
	block.update_block(enemy_data.enemy_block)
	
	if bypassed_damage <= 0:
		return [0,0,0]
	
	create_damage_text(bypassed_damage)
	
	overkill_damage = max(0, bypassed_damage - enemy_data.enemy_health)
	bypassed_damage_capped = bypassed_damage - overkill_damage
	
	# check health to prevent multiple deaths
	if enemy_data.enemy_health > 0:
		# damage the enemy
		enemy_data.enemy_health = max(0, enemy_data.enemy_health - bypassed_damage)
		Signals.combatant_damaged.emit(self, bypassed_damage, bypassed_damage_capped, overkill_damage)
		
		# generate an interceptable action and intercept it to possibly change health
		if enemy_data.enemy_health <= 0:
			ActionGenerator.generate_combatant_death(self)
		
		# update healthbar and potentially kill enemy
		update_health_bar(true)
		if enemy_data.enemy_health <= 0:
			if not death_animation_player.is_playing():
				play_animation(AnimationData.ANIMATION_DEATH)
				death_animation_player.play("Enemy/death")
				remove_from_group("enemies")
				Signals.enemy_killed.emit(self)
	
	return [bypassed_damage, bypassed_damage_capped, overkill_damage]

func set_block(amount: int) -> void:
	enemy_data.enemy_block = max(0, amount)
	block.update_block(enemy_data.enemy_block)

func get_block() -> int:
	return enemy_data.enemy_block

func add_block(amount: int) -> void:
	set_block(enemy_data.enemy_block + amount)
	if amount > 0:
		create_block_fade()
		Signals.combatant_block_added.emit(self)

#region Health
func heal_percentage(percent: float):
	var percentage_health: int = int(ceil(float(enemy_data.enemy_health_max) * percent))
	add_health(percentage_health, 0)

func add_health(health_amount: int, health_amount_max: int = 0) -> void:
	set_health(enemy_data.enemy_health + health_amount, enemy_data.enemy_health_max + health_amount_max)

func set_health(health_amount: int, health_amount_max: int = enemy_data.enemy_health_max) -> void:
	var is_damaged: bool = health_amount < enemy_data.enemy_health
	
	enemy_data.enemy_health_max = max(1, enemy_data.enemy_health_max)
	enemy_data.enemy_health = clamp(0, health_amount, enemy_data.enemy_health_max)
	
	update_health_bar(is_damaged)

func update_health_bar(as_damage: bool = false) -> void:
	if as_damage:
		layered_health_bar.apply_damage(enemy_data.enemy_health, enemy_data.enemy_health_max, status_id_to_status_effects)
	else:
		layered_health_bar.update_health_layers(enemy_data.enemy_health, enemy_data.enemy_health_max, status_id_to_status_effects)

func get_combatant_health() -> int:
	return enemy_data.enemy_health

func get_combatant_health_max() -> int:
	return enemy_data.enemy_health_max

#endregion

## Forcefully sets the enemy's intent to a specific intent state ID.
func force_set_enemy_intent(new_intent_id: String) -> void:
	enemy_data.force_set_intent_state(new_intent_id)
	update_enemy_intent()
	Signals.enemy_intent_changed.emit()

## Changes the enemy's intent to the next intent in the random walk.
func cycle_enemy_intent():
	enemy_data.cycle_next_intent_state()
	update_enemy_intent()
	Signals.enemy_intent_changed.emit()

## Displays the enemy's intentions above them based on their current intent.
func update_enemy_intent():
	# get current intent's attack
	var current_enemy_intent: EnemyIntentData = enemy_data.get_current_intent()
	var attack_damage: int = 0
	var number_of_attacks: int = 0
	if current_enemy_intent == null:
		breakpoint
	else:
		attack_damage = current_enemy_intent.enemy_intent_attack_damage
		number_of_attacks = current_enemy_intent.enemy_intent_number_of_attacks
	
	# reset intent icon visibility
	for intent_icon: TextureRect in INTENT_DISPLAY_TYPE_TO_INTENT.values():
		intent_icon.hide()
	
	# show intent icons based on intent
	for display_intent_type: int in current_enemy_intent.enemy_intent_display_types:
		var intent_icon: TextureRect = INTENT_DISPLAY_TYPE_TO_INTENT.get(display_intent_type, null)
		if intent_icon == null:
			breakpoint
			DebugLogger.log_error("Enemey: No intent icon mapped to EnemyIntentData.INTENT_DISPLAY_TYPES of value {0}".format([display_intent_type]))
			continue
		else:
			intent_icon.show()
	
	var player: Player = Global.get_player()
	
	### damage
	# intercept an attack action in preview mode
	var action_data: Array[Dictionary] = [{
			Scripts.ACTION_ATTACK: 
				{
				"damage": attack_damage,
				"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
				}}]
	var generated_action: BaseAction = ActionGenerator.create_actions(self, null, [player], action_data, null)[0]
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = generated_action._intercept_action([player], true)
	
	if len(action_interceptor_processors) == 1:
		var action_interceptor_processor: ActionInterceptorProcessor = action_interceptor_processors[0]
		# get intercepted attack values
		enemy_intent_attack_damage = max(0, action_interceptor_processor.get_shadowed_action_values("damage", 0))

	
	### number of attacks
	# intercept an attack action generator in preview mode
	action_data = [{
		Scripts.ACTION_ATTACK_GENERATOR: 
			{
			"damage": attack_damage,
			"number_of_attacks": number_of_attacks,
			"target_override": BaseAction.TARGET_OVERRIDES.PLAYER
			}}]
	generated_action = ActionGenerator.create_actions(self, null, [player], action_data, null)[0]
	action_interceptor_processors = generated_action._intercept_action([player], true)
	
	if len(action_interceptor_processors) == 1:
		var action_interceptor_processor: ActionInterceptorProcessor = action_interceptor_processors[0]
		# get intercepted attack values
		enemy_intent_number_of_attacks = max(0, action_interceptor_processor.get_shadowed_action_values("number_of_attacks", 0))
	
	### Display intent
	enemy_intent_amount_label.visible = false
	if enemy_intent_attack_damage * enemy_intent_number_of_attacks > 0:
		enemy_intent_amount_label.visible = true
		enemy_intent_amount_label.text = str(enemy_intent_attack_damage)
		if enemy_intent_number_of_attacks > 1:
			enemy_intent_amount_label.text += " x " + str(enemy_intent_number_of_attacks)

func is_alive() -> bool:
	return enemy_data.enemy_health > 0

func is_attacking() -> bool:
	return enemy_intent_number_of_attacks > 0

func _on_combat_started(_event_id: String):
	pass

func _on_combat_ended():
	queue_free()

func _on_player_turn_started():
	cycle_enemy_intent()

func _on_selection_button_up():
	if is_alive():
		Signals.enemy_clicked.emit(self)

func _on_mouse_entered():
	Signals.enemy_hovered.emit(self)
	name_label.visible = true

func _on_mouse_exited():
	Signals.enemy_hovered.emit(null)
	name_label.visible = false

func _on_death_animtation_finished():
	# called from animation player
	Signals.enemy_death_animation_finished.emit(self)

func _on_single_intent_mouse_entered(display_type: int, intent_icon: Control) -> void:
	UIHover.scale_up(intent_icon)
	if HandManager.tooltip == null: return
	
	var current_enemy_intent: EnemyIntentData = enemy_data.get_current_intent()
	if current_enemy_intent == null: return
	
	if not display_type in current_enemy_intent.enemy_intent_display_types:
		return
		
	var bbcode: String = ""
	var codex_text: String = current_enemy_intent.get_intent_codex_bbcode(display_type)
	codex_text = TextParser.parse(codex_text)
	
	match display_type:
		EnemyIntentData.INTENT_DISPLAY_TYPES.ATTACKING:
			bbcode += "[color=red]意图攻击[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		EnemyIntentData.INTENT_DISPLAY_TYPES.BLOCKING:
			bbcode += "[color=cyan]意图防御[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		EnemyIntentData.INTENT_DISPLAY_TYPES.DEBUFFING:
			bbcode += "[color=purple]意图减益[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		EnemyIntentData.INTENT_DISPLAY_TYPES.BUFFING:
			bbcode += "[color=green]意图增益[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		EnemyIntentData.INTENT_DISPLAY_TYPES.SUMMONING:
			bbcode += "[color=white]意图召唤[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		EnemyIntentData.INTENT_DISPLAY_TYPES.SPECIAL:
			bbcode += "[color=cyan]特殊机制[/color]"
			if codex_text != "":
				bbcode += "\n" + codex_text
		
	if bbcode != "":
		HandManager.tooltip.display_tooltip(bbcode, true)

func _on_intent_mouse_exited(intent_icon: Control) -> void:
	UIHover.scale_down(intent_icon)
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
