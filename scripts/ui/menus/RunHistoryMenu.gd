extends BaseMenu

@onready var runs_exist_container: Control = $RunsExistContainer
@onready var no_runs_label: Label = $NoRunsLabel
@onready var previous_run_button: Button = %PreviousRunButton
@onready var run_history_character_icon: TextureRect = %RunHistoryCharacterIcon
@onready var run_history_difficulty_label: Label = %RunHistoryDifficultyLabel
@onready var next_run_button: Button = %NextRunButton
@onready var run_history_character_name_label: Label = %RunHistoryCharacterNameLabel
@onready var run_history_seed_label: Label = %RunHistorySeedLabel
@onready var run_history_completion_date_label: Label = %RunHistoryCompletionDateLabel
@onready var run_history_message_label: RichTextLabel = %RunHistoryMessageLabel
@onready var run_history_health_label: Label = %RunHistoryHealthLabel
@onready var run_history_money_label: Label = %RunHistoryMoneyLabel
@onready var run_history_run_time_label: Label = %RunHistoryRunTimeLabel
@onready var run_history_floor_label: Label = %RunHistoryFloorLabel
@onready var run_history_consumable_container: GridContainer = %RunHistoryConsumableContainer
@onready var run_history_card_container: GridContainer = %RunHistoryCardContainer
@onready var run_history_artifact_container: GridContainer = %RunHistoryArtifactContainer

const VICTORY_MESSAGE_BBCODE: String = "[color=green]胜利[/color]"
const MISSING_EVENT_BBCODE: String = "[color=red]错误：事件缺失[/color]"

var current_run_stats: RunStatsData = null


func _ready() -> void:
	super()
	previous_run_button.button_up.connect(_on_previous_run_button_up)
	next_run_button.button_up.connect(_on_next_run_button_up)
	run_history_seed_label.mouse_filter = Control.MOUSE_FILTER_STOP
	run_history_seed_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	run_history_seed_label.gui_input.connect(_on_seed_label_gui_input)


func _on_seed_label_gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		and current_run_stats != null
	):
		DisplayServer.clipboard_set(str(current_run_stats.run_seed))
		UIMessage.show_message("种子已复制")


func populate_menu() -> void:
	super()
	_populate_run_history(ProfileStore.get_latest_run_summary())


func _populate_run_history(run_summary: RunStatsData) -> void:
	_clear_run_history()
	if run_summary == null:
		current_run_stats = null
		return
	current_run_stats = ProfileStore.load_run_details(run_summary.run_history_id)
	if current_run_stats == null:
		return

	no_runs_label.visible = false
	runs_exist_container.visible = true
	previous_run_button.visible = ProfileStore.get_older_run_summary(current_run_stats.run_history_id) != null
	next_run_button.visible = ProfileStore.get_newer_run_summary(current_run_stats.run_history_id) != null
	_populate_summary(current_run_stats)
	_populate_consumables(current_run_stats)
	_populate_cards(current_run_stats)
	_populate_artifacts(current_run_stats)


func _populate_summary(run_stats: RunStatsData) -> void:
	var character_data: CharacterData = Global.get_character_data(run_stats.run_character_id)
	if character_data == null:
		run_history_character_name_label.text = "无效进程"
		run_history_character_icon.texture = FileLoader.MISSING_TEXTURE
	else:
		run_history_character_name_label.text = character_data.character_name
		run_history_character_icon.texture = FileLoader.load_texture(character_data.character_icon_texture_path)

	var modifier_names := PackedStringArray()
	for modifier_id: String in run_stats.run_modifier_ids:
		var modifier_data: RunModifierData = Global.get_run_modifier_data(modifier_id)
		if modifier_data != null and modifier_data.run_modifier_is_custom:
			modifier_names.append(modifier_data.run_modifier_name)
	var difficulty_text: String = "难度：%d" % run_stats.run_difficulty_level
	if not modifier_names.is_empty():
		difficulty_text += "  [%s]" % ", ".join(modifier_names)
	run_history_difficulty_label.text = difficulty_text
	run_history_seed_label.text = "种子：%d" % run_stats.run_seed
	run_history_health_label.text = "完整度：%d/%d" % [run_stats.run_player_health, run_stats.run_player_health_max]
	run_history_money_label.text = "数据币：%d" % run_stats.run_player_money
	run_history_floor_label.text = "层数：%d" % run_stats.run_floor

	if run_stats.run_victory:
		run_history_message_label.parse_bbcode(VICTORY_MESSAGE_BBCODE)
	else:
		var defeat_event_data: EventData = Global.get_event_data(run_stats.run_defeat_event_id)
		if defeat_event_data == null:
			run_history_message_label.parse_bbcode(MISSING_EVENT_BBCODE)
		else:
			run_history_message_label.parse_bbcode(defeat_event_data.event_death_message_bbcode)

	var completion_date: String = Time.get_date_string_from_unix_time(run_stats.run_completion_timestamp)
	run_history_completion_date_label.text = "完成于 %s" % completion_date
	run_history_run_time_label.text = "游戏时长：%s" % TextParser.format_duration(run_stats.run_completion_time)


func _populate_consumables(run_stats: RunStatsData) -> void:
	for consumable_id: String in run_stats.run_consumable_ids:
		var consumable_data: ConsumableData = Global.get_consumable_data(consumable_id)
		if consumable_data == null:
			continue
		var codex_consumable: CodexConsumable = Scenes.CODEX_CONSUMABLE.instantiate()
		run_history_consumable_container.add_child(codex_consumable)
		codex_consumable.init(consumable_data)


func _populate_cards(run_stats: RunStatsData) -> void:
	var card_id_to_upgrade_to_count: Dictionary = {}
	for card_tuple: Array in run_stats.run_deck:
		if card_tuple.size() < 2:
			continue
		var card_id: String = str(card_tuple[0])
		var card_upgrade_level: int = int(card_tuple[1])
		var upgrade_to_count: Dictionary = card_id_to_upgrade_to_count.get(card_id, {})
		upgrade_to_count[card_upgrade_level] = int(upgrade_to_count.get(card_upgrade_level, 0)) + 1
		card_id_to_upgrade_to_count[card_id] = upgrade_to_count

	for card_id: String in card_id_to_upgrade_to_count:
		var upgrade_to_count: Dictionary = card_id_to_upgrade_to_count[card_id]
		for card_upgrade_level: int in upgrade_to_count:
			var history_card: RunHistoryCard = Scenes.RUN_HISTORY_CARD.instantiate()
			run_history_card_container.add_child(history_card)
			history_card.init(card_id, card_upgrade_level, int(upgrade_to_count[card_upgrade_level]))


func _populate_artifacts(run_stats: RunStatsData) -> void:
	for artifact_id: String in run_stats.run_artifact_ids:
		var artifact_data: ArtifactData = Global.get_artifact_data(artifact_id)
		if artifact_data == null:
			continue
		var codex_artifact: CodexArtifact = Scenes.CODEX_ARTIFACT.instantiate()
		run_history_artifact_container.add_child(codex_artifact)
		codex_artifact.init(artifact_data)


func clear_menu() -> void:
	super()
	current_run_stats = null
	_clear_run_history()
	no_runs_label.visible = true
	runs_exist_container.visible = false


func _clear_run_history() -> void:
	for child: Node in run_history_consumable_container.get_children():
		child.queue_free()
	for child: Node in run_history_card_container.get_children():
		child.queue_free()
	for child: Node in run_history_artifact_container.get_children():
		child.queue_free()


func _on_previous_run_button_up() -> void:
	if current_run_stats != null:
		_populate_run_history(ProfileStore.get_older_run_summary(current_run_stats.run_history_id))


func _on_next_run_button_up() -> void:
	if current_run_stats != null:
		_populate_run_history(ProfileStore.get_newer_run_summary(current_run_stats.run_history_id))
