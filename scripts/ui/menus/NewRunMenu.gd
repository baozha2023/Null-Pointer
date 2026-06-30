## Menu for starting a new run
extends BaseMenu

@onready var character_name_label = %CharacterNameLabel
@onready var character_health_label = %CharacterHealthLabel
@onready var character_money_label = %CharacterMoneyLabel
@onready var character_description_label = %CharacterDescriptionLabel

@onready var character_artifact_texture_rect = %CharacterArtifactTextureRect
@onready var character_artifact_name_label = %CharacterArtifactNameLabel
@onready var character_artifact_description_label = %CharacterArtifactDescriptionLabel

@onready var character_poster_texture_rect: TextureRect = %CharacterPosterTextureRect
@onready var decrease_difficulty_button: Button = %DecreaseDifficultyButton
@onready var difficulty_label: LabelAutoSizer = %DifficultyLabel
@onready var increase_difficulty_button: Button = %IncreaseDifficultyButton

@onready var custom_run_modifier_button_container: VBoxContainer = %CustomRunModifierButtonContainer

@onready var character_button_container: GridContainer = %CharacterButtonContainer

@onready var seed_input: LineEdit = %SeedInput
@onready var start_run_button: Button = %StartRunButton

var selected_character_object_id: String = ""
var selected_difficulty_level: int = 0: set = set_selected_difficulty_level

var _run_modifier_object_id_to_checkbox: Dictionary = {}
var selected_custom_run_modififers: Array[String] = []

func _ready():
	super()
	start_run_button.pressed.connect(_on_start_run_button_presssed)
	
	decrease_difficulty_button.pressed.connect(_on_decrease_difficulty_button_pressed)
	increase_difficulty_button.pressed.connect(_on_increase_difficulty_button_pressed)
	
	seed_input.text_changed.connect(_on_seed_input_text_changed)
	
	Signals.run_ended.connect(_on_run_ended)
	
	set_selected_difficulty_level(0)

func populate_menu() -> void:
	super()
	populate_character_buttons()
	populate_custom_run_modifiers()

func clear_menu() -> void:
	super()
	clear_character_buttons()
	clear_custom_run_modifiers()

#region Character Selection
func populate_character_buttons() -> void:
	clear_character_buttons()
	
	var character_object_ids: Array = Global._id_to_character_data.keys()
	
	var first_button: TextureButton = null
	
	for character_object_id in character_object_ids:
		# create character button
		var character_selection_button: CharacterSelectionButton = Scenes.CHARACTER_SELECTION_BUTTON.instantiate()
		character_button_container.add_child(character_selection_button)
		character_selection_button.init(character_object_id)
		# connect signal
		character_selection_button.character_selected.connect(_on_character_selected)
		
		if first_button == null:
			first_button = character_selection_button
	
	# auto press the first button
	if first_button != null:
		first_button.button_pressed = true
		first_button.button_up.emit()
	
func clear_character_buttons() -> void:
	for child in character_button_container.get_children():
		child.queue_free()

func populate_character_info(character_object_id: String) -> void:
	var character_data: CharacterData = Global.get_character_data(character_object_id)
	if character_data != null:
		character_name_label.text = character_data.character_name
		character_health_label.text = "完整度: {0}".format([character_data.character_starting_health])
		character_money_label.text = "数据币: {0}".format([character_data.character_starting_money])
		character_description_label.text = character_data.character_description
		
		if character_data.character_background_texture_path != "":
			character_poster_texture_rect.texture = FileLoader.load_texture(character_data.character_background_texture_path)
		else:
			character_poster_texture_rect.texture = null
		
		# TODO potentially update ui to support multiple starter artifacts displayed
		if len(character_data.character_starting_artifact_ids) > 0:
			var artifact_data: ArtifactData = Global.get_artifact_data(character_data.character_starting_artifact_ids[0])
			if artifact_data != null:
				character_artifact_texture_rect.texture = FileLoader.load_texture(artifact_data.artifact_texture_path)
				character_artifact_name_label.text = artifact_data.artifact_name
				character_artifact_description_label.text = artifact_data.artifact_description
		
		# play character selection audio if it exists
		if character_data.character_selection_audio_path != "":
			ActionGenerator.generate_sound_action(character_data.character_selection_audio_path, false)

func _on_character_selected(character_object_id: String):
	selected_character_object_id = character_object_id
	# switch back to difficulty 0 since each character has independent unlock progress
	set_selected_difficulty_level(0)
	populate_character_info(selected_character_object_id)

#endregion

#region Seed
func _on_seed_input_text_changed(new_text: String):
	# validate the input of the line edit
	var caret_column: int = seed_input.caret_column	# store cursor position as changing text resets it
	var filtered_text: String = ""
	for c in new_text:
		if c >= "0" and c <= "9":
			filtered_text += c
	seed_input.text = filtered_text
	seed_input.caret_column = min(caret_column, len(seed_input.text)) # reset the cursor position

#endregion

#region Difficulty
func set_selected_difficulty_level(value: int) -> void:
	if selected_character_object_id != "":
		# Get highest won difficulty, default to -1 if never won
		var character_highest_difficulty_win: int = Global.profile_data.profile_character_id_to_highest_difficulty.get(selected_character_object_id, -1)
		if ProfileData.ENABLE_ALL_DIFFICULTIES:
			selected_difficulty_level = value
		else:
			# Player can select up to (highest win + 1)
			selected_difficulty_level = min(value, character_highest_difficulty_win + 1)
	else:
		selected_difficulty_level = value
		
	# Ensure the difficulty level does not exceed the valid run modifier IDs array
	selected_difficulty_level = clamp(selected_difficulty_level, 0, len(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS) - 1)
	
	# update text label
	var run_modifier_id: String = Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS[selected_difficulty_level]
	var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_id)
	
	if run_modifier_data != null:
		difficulty_label.text = run_modifier_data.run_modifier_name

func _on_decrease_difficulty_button_pressed():
	selected_difficulty_level = max(0, selected_difficulty_level - 1)
func _on_increase_difficulty_button_pressed():
	selected_difficulty_level = min(selected_difficulty_level + 1, len(Global.STANDARD_DIFFICULTY_RUN_MODIFIER_IDS) - 1)
#endregion

#region Custom Run Modifiers
func populate_custom_run_modifiers() -> void:
	clear_custom_run_modifiers()
	
	var run_modifier_object_ids: Array = Global._id_to_run_modifier_data.keys()
	
	for run_modifier_object_id in run_modifier_object_ids:
		var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_object_id)
		if run_modifier_data.run_modifier_is_custom:
			var custom_run_modifier_checkbox: CheckBox = Scenes.CUSTOM_RUN_MODIFIER_CHECKBOX.instantiate()
			custom_run_modifier_button_container.add_child(custom_run_modifier_checkbox)
			custom_run_modifier_checkbox.init(run_modifier_object_id)
			custom_run_modifier_checkbox.toggled.connect(_on_custom_run_modifier_toggled.bind(run_modifier_data))
			_run_modifier_object_id_to_checkbox[run_modifier_object_id] = custom_run_modifier_checkbox

func clear_custom_run_modifiers() -> void:
	_run_modifier_object_id_to_checkbox.clear()
	selected_custom_run_modififers.clear()
	for child in custom_run_modifier_button_container.get_children():
		child.queue_free()

func _on_custom_run_modifier_toggled(toggle: bool, run_modifier_data: RunModifierData):
	if toggle:
		selected_custom_run_modififers.append(run_modifier_data.object_id)
		# uncheck any exclusive boxes
		for exclusive_run_modifier_object_id in run_modifier_data.run_modifier_exclusive_to_modifier_ids:
			selected_custom_run_modififers.erase(exclusive_run_modifier_object_id)
			var custom_run_modifier_checkbox: CheckBox = _run_modifier_object_id_to_checkbox.get(exclusive_run_modifier_object_id, null)
			if custom_run_modifier_checkbox != null:
				custom_run_modifier_checkbox.set_pressed_no_signal(false)
	else:
		selected_custom_run_modififers.erase(run_modifier_data.object_id)

#endregion

#region Run Start/End
func _on_start_run_button_presssed():
	# get the seed and start the run
	var run_seed: int = seed_input.text.to_int()
	if seed_input.text.is_empty() or seed_input.text == "1234567890123456":
		randomize()
		run_seed = randi()
	Global.start_run(selected_character_object_id, run_seed, selected_difficulty_level, selected_custom_run_modififers)

func _on_run_ended():
	# go back to tile screen on failed run (save deleted), but not abandoned run (save kept)
	var has_save_file: bool = FileLoader.has_save_file()
	if not has_save_file:
		populate_menu()
	else:
		clear_menu()

#endregion
