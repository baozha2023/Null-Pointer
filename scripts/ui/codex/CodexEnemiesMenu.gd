## Displays enemys tab in the codex
extends BaseMenu

# list of acts and enemy buttons
@onready var codex_act_enemy_button_container: VBoxContainer = %CodexActEnemyButtonContainer

# visibility container for selected enemy intents
@onready var codex_enemy_intents: Control = %CodexEnemyIntents
# visibility toggle for enemy intents
@onready var codex_enemy_intents_toggle_button: Button = %CodexEnemyIntentsToggleButton
@onready var codex_enemy_initial_toggle_button: Button = %CodexEnemyInitialToggleButton
@onready var codex_enemy_deathrattle_toggle_button: Button = %CodexEnemyDeathrattleToggleButton
@onready var codex_enemy_initial: Control = %CodexEnemyInitial
@onready var codex_enemy_deathrattle: Control = %CodexEnemyDeathrattle
@onready var codex_enemy_details_container: MarginContainer = %CodexEnemyDetailsContainer
@onready var codex_enemy_initial_container: Container = %CodexEnemyInitialContainer
@onready var codex_enemy_deathrattle_container: VBoxContainer = %CodexEnemyDeathrattleContainer

# list of enemy intents
@onready var codex_enemy_intents_container: VBoxContainer = %CodexEnemyIntentsContainer

@onready var codex_enemy_name_label: Label = %CodexEnemyNameLabel
@onready var codex_enemy_texture: TextureRect = %CodexEnemyTexture
@onready var codex_enemy_health_label: Label = %CodexEnemyHealthLabel

## 每章对应的当前查看难度 (act_data.object_id → difficulty_level)
var act_difficulties: Dictionary = {}
var current_enemy_data: EnemyData = null
var current_act_id: String = ""

var current_sprite_frames: SpriteFrames = null
var current_anim_name: String = ""
var current_anim_frame: int = 0
var current_anim_timer: float = 0.0

@onready var codex_enemy_idle_button: Button = %CodexEnemyIdleButton
@onready var codex_enemy_attack_button: Button = %CodexEnemyAttackButton
@onready var codex_enemy_die_button: Button = %CodexEnemyDieButton

func _ready() -> void:
	codex_enemy_intents_toggle_button.toggled.connect(_on_info_panel_toggled.bind(codex_enemy_intents_toggle_button))
	codex_enemy_initial_toggle_button.toggled.connect(_on_info_panel_toggled.bind(codex_enemy_initial_toggle_button))
	codex_enemy_deathrattle_toggle_button.toggled.connect(_on_info_panel_toggled.bind(codex_enemy_deathrattle_toggle_button))
	set_process(false)
	
	codex_enemy_idle_button.pressed.connect(_on_play_anim.bind(AnimationData.ANIMATION_IDLE))
	codex_enemy_attack_button.pressed.connect(_on_play_anim.bind(AnimationData.ANIMATION_ATTACK))
	codex_enemy_die_button.pressed.connect(_on_play_anim.bind(AnimationData.ANIMATION_DEATH))

func populate_menu() -> void:
	super()
	_populate_codex_enemies()

func clear_menu() -> void:
	stop_animation()
	super()
	clear_codex_enemies()
	clear_codex_enemy_intents()
	clear_codex_enemy_initial()
	clear_codex_enemy_deathrattle()
	act_difficulties.clear()
	current_enemy_data = null
	current_act_id = ""

func clear_codex_enemies() -> void:
	for child: Node in codex_act_enemy_button_container.get_children():
		child.queue_free()

func clear_codex_enemy_intents() -> void:
	for child: Node in codex_enemy_intents_container.get_children():
		child.queue_free()

func clear_codex_enemy_deathrattle() -> void:
	for child: Node in codex_enemy_deathrattle_container.get_children():
		child.queue_free()

func clear_codex_enemy_initial() -> void:
	for child: Node in codex_enemy_initial_container.get_children():
		child.queue_free()


func _populate_codex_enemies() -> void:
	clear_codex_enemies()
	
	# Get all acts, sort them, then list the enemies that appear in those acts, sorted into the acts
	var act_list: Array = Global._id_to_act_data.values()
	act_list.sort_custom(_codex_act_sort)
	var enemy_id_set: Dictionary[String, Variant] = {} # used as a set for ensuring no duplicate enemies are listed
	
	for act_data: ActData in act_list:
		# create label for the act
		var codex_act_name_label = Scenes.CODEX_ACT_NAME_LABEL.instantiate()
		codex_act_enemy_button_container.add_child(codex_act_name_label)
		codex_act_name_label.init(act_data)
		
		# create difficulty toggle button for this act
		var act_id: String = act_data.object_id
		if not act_difficulties.has(act_id):
			act_difficulties[act_id] = 0
		var difficulty_button: CodexDifficultyButton = Scenes.CODEX_DIFFICULTY_BUTTON.instantiate()
		codex_act_enemy_button_container.add_child(difficulty_button)
		difficulty_button.init(act_difficulties[act_id])
		difficulty_button.difficulty_changed.connect(_on_act_difficulty_changed.bind(act_id))
		
		# get the enemies of the acts and sort by type/name
		var act_enemy_ids: Array[String] = act_data.get_act_all_enemy_ids()
		act_enemy_ids.sort_custom(_codex_enemy_sort)
		
		# generate buttons
		var first_enemy_button: bool = false
		for enemy_id: String in act_enemy_ids:
			if not enemy_id_set.has(enemy_id):
				# mark the enemy as seen
				enemy_id_set[enemy_id] = null
				# create button for the act
				var codex_enemy_button: CodexEnemyButton = Scenes.CODEX_ENEMY_BUTTON.instantiate()
				var enemy_data: EnemyData = Global.get_enemy_data(enemy_id)
				
				codex_act_enemy_button_container.add_child(codex_enemy_button)
				codex_enemy_button.init(enemy_data)
				
				codex_enemy_button.codex_enemy_button_up.connect(_on_codex_enemy_button_up)
				
				# simulate pressing the first enemy so it displays
				if not first_enemy_button:
					_on_codex_enemy_button_up(enemy_data)
					first_enemy_button = true

## 点击难度按钮：更新本章难度并刷新当前敌人信息
func _on_act_difficulty_changed(difficulty: int, act_id: String) -> void:
	act_difficulties[act_id] = difficulty
	if current_enemy_data != null and current_act_id == act_id:
		populate_codex_enemy(current_enemy_data)

## 获取某个难度下敌人的血量区间（不修改原 EnemyData）
func _get_difficulty_health(enemy_data: EnemyData, difficulty: int) -> Dictionary:
	var lower: int = enemy_data.enemy_health_max_random_lower
	var upper: int = enemy_data.enemy_health_max_random_upper
	for level: int in range(1, difficulty + 1):
		var modifiers: Dictionary = enemy_data.enemy_difficulty_to_enemy_modfiers.get(str(level), {})
		if modifiers.has("enemy_health_max_random_lower"):
			lower = modifiers["enemy_health_max_random_lower"]
		if modifiers.has("enemy_health_max_random_upper"):
			upper = modifiers["enemy_health_max_random_upper"]
	return {"lower": lower, "upper": upper}

## Populates info for a given enemy, and a list of intents
func populate_codex_enemy(enemy_data: EnemyData) -> void:
	stop_animation()
	codex_enemy_intents_toggle_button.set_pressed_no_signal(false)
	codex_enemy_initial_toggle_button.set_pressed_no_signal(false)
	codex_enemy_deathrattle_toggle_button.set_pressed_no_signal(false)
	_update_details_visibility()
	
	var difficulty: int = act_difficulties.get(current_act_id, 0)
	codex_enemy_name_label.text = enemy_data.enemy_name
	codex_enemy_texture.texture = FileLoader.load_texture(enemy_data.enemy_texture_path)
	
	var hp: Dictionary = _get_difficulty_health(enemy_data, difficulty)
	codex_enemy_health_label.text = "完整度: {0}-{1}".format([hp["lower"], hp["upper"]])
	populate_codex_enemy_intents(enemy_data, difficulty)
	populate_codex_enemy_initial(enemy_data, difficulty)
	populate_codex_enemy_deathrattle(enemy_data)

## Populates a list of intents for a given enemy at a given difficulty.
## Shows the highest-difficulty version of each intent ≤ the requested difficulty.
func populate_codex_enemy_intents(enemy_data: EnemyData, difficulty: int = 0) -> void:
	clear_codex_enemy_intents()
	
	# collect the best (highest difficulty ≤ requested) intent for each override_id
	var best_intents: Dictionary = {}  # override_id → EnemyIntentData
	for intent_data: EnemyIntentData in enemy_data.enemy_intents.values():
		if intent_data.object_id == EnemyIntentData.INTENT_INITIAL:
			continue
		if intent_data.enemy_intent_difficulty_level > difficulty:
			continue
		var overrides_id: String = intent_data.enemy_intent_overrides_id
		var existing: EnemyIntentData = best_intents.get(overrides_id)
		if existing == null or existing.enemy_intent_difficulty_level < intent_data.enemy_intent_difficulty_level:
			best_intents[overrides_id] = intent_data
	
	for intent_data: EnemyIntentData in best_intents.values():
		var codex_enemy_intent: CodexEnemyIntent = Scenes.CODEX_ENEMY_INTENT.instantiate()
		codex_enemy_intents_container.add_child(codex_enemy_intent)
		codex_enemy_intent.init(enemy_data, intent_data, best_intents)

func populate_codex_enemy_initial(enemy_data: EnemyData, difficulty: int = 0) -> void:
	clear_codex_enemy_initial()
	
	if enemy_data.enemy_block == 0 and enemy_data.enemy_initial_status_effects.is_empty():
		var empty_label = Label.new()
		empty_label.text = "无"
		codex_enemy_initial_container.add_child(empty_label)
		return
	
	if enemy_data.enemy_block > 0:
		var tooltip: String = "[color=orange]防火墙[/color]\n抵挡 " + str(enemy_data.enemy_block) + " 点伤害"
		
		var block_ui = TextureRect.new()
		block_ui.custom_minimum_size = Vector2(24, 24)
		block_ui.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		block_ui.texture = FileLoader.load_texture("sprites/ui/spr_shield_icon.png")
		
		var label = Label.new()
		label.text = str(enemy_data.enemy_block)
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var ls = LabelSettings.new()
		ls.font_size = 12
		label.label_settings = ls
		block_ui.add_child(label)
		
		block_ui.mouse_entered.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.display_tooltip(tooltip, true))
		block_ui.mouse_exited.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.hide_tooltip())
		
		codex_enemy_initial_container.add_child(block_ui)
		
	for status_id: String in enemy_data.enemy_initial_status_effects:
		var amount: int = enemy_data.enemy_initial_status_effects[status_id]
		var status_data: StatusEffectData = Global.get_status_effect_data(status_id)
		if status_data == null: continue
		var bbcode: String = "[color=orange]" + status_data.status_effect_name + "[/color]"
		if status_data.get_full_description() != "": bbcode += "\n" + status_data.get_full_description()
		
		var status_ui = Scenes.STATUS_EFFECT.instantiate()
		status_ui.set_script(null)
		status_ui.texture = FileLoader.load_texture(status_data.get_status_effect_texture_path(amount))
		status_ui.get_node("StatusChargeLabel").text = str(amount)
		status_ui.get_node("StatusSecondaryChargeLabel").text = ""
		
		status_ui.mouse_entered.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.display_tooltip(bbcode, true))
		status_ui.mouse_exited.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.hide_tooltip())
		
		codex_enemy_initial_container.add_child(status_ui)

func populate_codex_enemy_deathrattle(enemy_data: EnemyData) -> void:
	clear_codex_enemy_deathrattle()
	if enemy_data.enemy_actions_on_death.is_empty():
		var empty_label = Label.new()
		empty_label.text = "无"
		codex_enemy_deathrattle_container.add_child(empty_label)
	else:
		for action_dict in enemy_data.enemy_actions_on_death:
			var ui_node = _parse_action_to_ui(action_dict)
			codex_enemy_deathrattle_container.add_child(ui_node)

func _parse_action_to_ui(action_dict: Dictionary) -> Control:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var script_path = action_dict.keys()[0]
	var data = action_dict[script_path]
	
	var label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if script_path == Scripts.ACTION_APPLY_STATUS:
		var target = data.get("target_override", BaseAction.TARGET_OVERRIDES.SELECTED_TARGETS)
		var status_id = data.get("status_effect_object_id", "")
		var amount = data.get("status_charge_amount", 1)
		
		label.text = "对 [" + _translate_target(target) + "]: "
		container.add_child(label)
		
		var status_data: StatusEffectData = Global.get_status_effect_data(status_id)
		if status_data != null:
			var status_ui = Scenes.STATUS_EFFECT.instantiate()
			status_ui.set_script(null)
			status_ui.texture = FileLoader.load_texture(status_data.get_status_effect_texture_path(amount))
			status_ui.get_node("StatusChargeLabel").text = str(amount)
			status_ui.get_node("StatusSecondaryChargeLabel").text = ""
			
			var bbcode: String = "[color=orange]" + status_data.status_effect_name + "[/color]"
			if status_data.get_full_description() != "": bbcode += "\n" + status_data.get_full_description()
			
			status_ui.mouse_entered.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.display_tooltip(bbcode, true))
			status_ui.mouse_exited.connect(func(): if HandManager.tooltip != null: HandManager.tooltip.hide_tooltip())
			
			container.add_child(status_ui)
	else:
		label.text = "执行: " + str(action_dict)
		container.add_child(label)
		
	return container

func _translate_target(target: int) -> String:
	match target:
		BaseAction.TARGET_OVERRIDES.PLAYER: return "玩家"
		BaseAction.TARGET_OVERRIDES.ALL_COMBATANTS: return "所有角色"
		BaseAction.TARGET_OVERRIDES.ALL_ENEMIES: return "所有敌人"
		BaseAction.TARGET_OVERRIDES.LEFTMOST_ENEMY: return "最左侧敌人"
		BaseAction.TARGET_OVERRIDES.RIGHTMOST_ENEMY: return "最右侧敌人"
		BaseAction.TARGET_OVERRIDES.LEFT_ADJACENT_ENEMY: return "目标左侧相邻敌人"
		BaseAction.TARGET_OVERRIDES.RIGHT_ADJACENT_ENEMY: return "目标右侧相邻敌人"
		BaseAction.TARGET_OVERRIDES.RANDOM_ENEMY: return "随机敌人"
		BaseAction.TARGET_OVERRIDES.RANDOM_COMBATANT: return "随机角色"
		_: return "目标"

func _on_codex_enemy_button_up(enemy_data: EnemyData) -> void:
	current_enemy_data = enemy_data
	current_act_id = _get_act_id_for_enemy(enemy_data.object_id)
	populate_codex_enemy(enemy_data)

## 查找某个敌人属于哪个章节
func _get_act_id_for_enemy(enemy_id: String) -> String:
	for act_data: ActData in Global._id_to_act_data.values():
		if enemy_id in act_data.get_act_all_enemy_ids():
			return act_data.object_id
	return ""

func _on_info_panel_toggled(toggled_on: bool, pressed_button: Button) -> void:
	if toggled_on:
		if pressed_button != codex_enemy_intents_toggle_button:
			codex_enemy_intents_toggle_button.set_pressed_no_signal(false)
		if pressed_button != codex_enemy_initial_toggle_button:
			codex_enemy_initial_toggle_button.set_pressed_no_signal(false)
		if pressed_button != codex_enemy_deathrattle_toggle_button:
			codex_enemy_deathrattle_toggle_button.set_pressed_no_signal(false)
			
	_update_details_visibility()

func _update_details_visibility() -> void:
	codex_enemy_intents.visible = codex_enemy_intents_toggle_button.button_pressed
	codex_enemy_initial.visible = codex_enemy_initial_toggle_button.button_pressed
	codex_enemy_deathrattle.visible = codex_enemy_deathrattle_toggle_button.button_pressed
	
	if codex_enemy_details_container != null:
		codex_enemy_details_container.visible = codex_enemy_intents.visible or codex_enemy_initial.visible or codex_enemy_deathrattle.visible

func _codex_act_sort(act_data_1: ActData, act_data_2: ActData) -> bool:
	if act_data_1.act_codex_number == act_data_2.act_codex_number:
		return act_data_1.act_name < act_data_2.act_name
	else:
		return act_data_1.act_codex_number < act_data_2.act_codex_number

# sorts the enemies by type (standard, miniboss, boss) and then name
func _codex_enemy_sort(enemy_id_1: String, enemy_id_2: String) -> bool:
	var enemy_data_1: EnemyData = Global.get_enemy_data(enemy_id_1)
	var enemy_data_2: EnemyData = Global.get_enemy_data(enemy_id_2)
	if enemy_data_1.enemy_type == enemy_data_2.enemy_type:
		return enemy_data_1.enemy_name < enemy_data_2.enemy_name
	else:
		return enemy_data_1.enemy_type < enemy_data_2.enemy_type

#region Animations
func _on_play_anim(anim_name: String) -> void:
	if current_enemy_data == null: return
	var anim_data: AnimationData = Global.get_animation_data(current_enemy_data.enemy_animation_id)
	if anim_data != null and anim_data.animations != null and anim_data.animations.has_animation(anim_name):
		current_sprite_frames = anim_data.animations
		current_anim_name = anim_name
		current_anim_frame = 0
		current_anim_timer = 0.0
		set_process(true)
		codex_enemy_texture.texture = current_sprite_frames.get_frame_texture(current_anim_name, 0)
	else:
		stop_animation()

func stop_animation() -> void:
	current_sprite_frames = null
	set_process(false)
	if current_enemy_data != null:
		codex_enemy_texture.texture = FileLoader.load_texture(current_enemy_data.enemy_texture_path)

func _process(delta: float) -> void:
	if current_sprite_frames != null:
		current_anim_timer += delta
		var fps: float = current_sprite_frames.get_animation_speed(current_anim_name)
		if fps <= 0: fps = 5.0
		var frame_duration: float = 1.0 / fps
		
		if current_anim_timer >= frame_duration:
			current_anim_timer -= frame_duration
			current_anim_frame += 1
			
			if current_anim_frame >= current_sprite_frames.get_frame_count(current_anim_name):
				stop_animation()
			else:
				codex_enemy_texture.texture = current_sprite_frames.get_frame_texture(current_anim_name, current_anim_frame)
#endregion
