extends Control

const VICTORY_ACCENT: Color = Color("55E6D3")
const DEFEAT_ACCENT: Color = Color("F06478")
const VICTORY_MESSAGE: String = "主进程已完成，本次运行数据已归档。"
const DEFAULT_DEFEAT_MESSAGE: String = "主进程已终止，本次运行数据已归档。"

const STAT_COMBAT_STANDARD: String = "COMBAT_STANDARD_COUNT"
const STAT_COMBAT_MINIBOSS: String = "COMBAT_MINIBOSS_COUNT"
const STAT_COMBAT_BOSS: String = "COMBAT_BOSS_COUNT"
const STAT_REST: String = "REST_REST_COUNT"
const STAT_UPGRADE: String = "REST_UPGRADE_CARDS_COUNT"
const STAT_MONEY_GAINED: String = "MONEY_GAINED_AMOUNT"
const STAT_CARDS_PLAYED: String = "CARDS_PLAYED"
const STAT_DAMAGE_TAKEN: String = "PLAYER_DAMAGED_AMOUNT"
const STAT_DAMAGE_DEALT: String = "ENEMY_DAMAGED_CAPPED_AMOUNT"

@onready var backdrop_glow: ColorRect = %BackdropGlow
@onready var top_glow: ColorRect = %TopGlow
@onready var main_panel: PanelContainer = %MainPanel
@onready var status_badge: PanelContainer = %StatusBadge
@onready var result_kicker: Label = %ResultKicker
@onready var result_title: Label = %ResultTitle
@onready var end_run_message_label: RichTextLabel = %EndRunMessageLabel
@onready var duration_value: Label = %DurationValue
@onready var header_separator: ColorRect = %HeaderSeparator

@onready var portrait_frame: PanelContainer = %PortraitFrame
@onready var character_icon: TextureRect = %CharacterIcon
@onready var character_name: Label = %CharacterName
@onready var character_status: Label = %CharacterStatus
@onready var health_value: Label = %HealthValue
@onready var health_bar: ProgressBar = %HealthBar
@onready var difficulty_label: Label = %DifficultyLabel
@onready var floor_label: Label = %FloorLabel
@onready var seed_label: Label = %SeedLabel

@onready var combat_value: Label = %CombatValue
@onready var damage_value: Label = %DamageValue
@onready var cards_value: Label = %CardsValue
@onready var money_value: Label = %MoneyValue
@onready var standard_label: Label = %StandardLabel
@onready var elite_label: Label = %EliteLabel
@onready var boss_label: Label = %BossLabel
@onready var rest_label: Label = %RestLabel
@onready var upgrade_label: Label = %UpgradeLabel
@onready var damage_taken_label: Label = %DamageTakenLabel

@onready var archive_status_label: Label = %ArchiveStatusLabel
@onready var end_run_button: Button = %EndRunButton

var player_run_end_state: int = Global.RUN_ENDS.QUIT
var reveal_tween: Tween


func _ready() -> void:
	end_run_button.button_up.connect(_on_end_run_button_up)
	Signals.combat_ended.connect(_on_combat_ended)
	Signals.run_started.connect(_on_run_started)
	Signals.run_ended.connect(_on_run_ended)
	Signals.run_victory.connect(_on_run_victory)
	Signals.player_death_animation_finished.connect(_on_player_death_animation_finished)


func _populate_run_profile() -> void:
	var player_data: PlayerData = Global.player_data
	if player_data == null:
		character_name.text = "未知进程"
		character_icon.texture = FileLoader.MISSING_TEXTURE
		health_value.text = "0 / 0"
		health_bar.max_value = 1.0
		health_bar.value = 0.0
		difficulty_label.text = "协议等级  --"
		floor_label.text = "终止层数  --"
		seed_label.text = "SEED  --"
		duration_value.text = "00:00:00"
		return

	var character_data: CharacterData = Global.get_player_character_data()
	if character_data != null:
		character_name.text = character_data.character_name
		if character_data.character_icon_texture_path.is_empty():
			character_icon.texture = FileLoader.MISSING_TEXTURE
		else:
			character_icon.texture = FileLoader.load_texture(character_data.character_icon_texture_path)
	else:
		character_name.text = "未知进程"
		character_icon.texture = FileLoader.MISSING_TEXTURE

	var maximum_health: int = max(1, player_data.player_health_max)
	health_value.text = "%d / %d" % [player_data.player_health, player_data.player_health_max]
	health_bar.max_value = float(maximum_health)
	health_bar.value = float(clamp(player_data.player_health, 0, maximum_health))
	difficulty_label.text = "协议等级  %d" % player_data.player_run_difficulty_level

	var location_data: LocationData = Global.get_player_location_data()
	var final_floor: int = location_data.location_floor if location_data != null else 0
	floor_label.text = "终止层数  %d" % final_floor
	seed_label.text = "SEED  %d" % player_data.player_run_seed
	duration_value.text = TextParser.format_duration(player_data.player_run_time)


func _populate_run_stats() -> void:
	var run_stats: RunStatsData = StatsHandler.current_run_stats
	if run_stats == null:
		DebugLogger.log_error("RunSummaryOverlay: Current run stats not detected")

	var standard_count: int = _get_stat(run_stats, STAT_COMBAT_STANDARD)
	var elite_count: int = _get_stat(run_stats, STAT_COMBAT_MINIBOSS)
	var boss_count: int = _get_stat(run_stats, STAT_COMBAT_BOSS)
	var total_combats: int = standard_count + elite_count + boss_count

	combat_value.text = str(total_combats)
	damage_value.text = str(_get_stat(run_stats, STAT_DAMAGE_DEALT))
	cards_value.text = str(_get_stat(run_stats, STAT_CARDS_PLAYED))
	money_value.text = str(_get_stat(run_stats, STAT_MONEY_GAINED))

	standard_label.text = "标准战斗\n%d" % standard_count
	elite_label.text = "精英战斗\n%d" % elite_count
	boss_label.text = "Boss 战斗\n%d" % boss_count
	rest_label.text = "休息次数\n%d" % _get_stat(run_stats, STAT_REST)
	upgrade_label.text = "升级次数\n%d" % _get_stat(run_stats, STAT_UPGRADE)
	damage_taken_label.text = "承受伤害\n%d" % _get_stat(run_stats, STAT_DAMAGE_TAKEN)


func _get_stat(run_stats: RunStatsData, stat_name: String) -> int:
	if run_stats == null:
		return 0
	return run_stats.get_run_total_stat(stat_name)


func _show_summary(is_victory: bool, message_bbcode: String) -> void:
	player_run_end_state = Global.RUN_ENDS.VICTORY if is_victory else Global.RUN_ENDS.LOSS
	_apply_result_style(is_victory)
	_populate_run_profile()
	_populate_run_stats()
	end_run_message_label.parse_bbcode(message_bbcode)
	end_run_button.disabled = false
	visible = true
	_animate_reveal()


func _apply_result_style(is_victory: bool) -> void:
	var accent: Color = VICTORY_ACCENT if is_victory else DEFEAT_ACCENT
	var accent_soft: Color = Color(accent.r, accent.g, accent.b, 0.14)
	var accent_medium: Color = Color(accent.r, accent.g, accent.b, 0.55)

	result_kicker.text = "运行完成" if is_victory else "运行终止"
	result_title.text = "胜利" if is_victory else "战败"
	character_status.text = "进程已归档" if is_victory else "进程已终止"
	archive_status_label.text = "✓ 胜利记录将在返回后写入档案" if is_victory else "✓ 失败记录将在返回后写入档案"

	result_kicker.add_theme_color_override("font_color", accent.lightened(0.28))
	result_title.add_theme_color_override("font_color", accent)
	result_title.add_theme_color_override("font_shadow_color", accent_soft)
	character_status.add_theme_color_override("font_color", accent.lightened(0.08))
	backdrop_glow.color = accent_soft
	top_glow.color = Color(accent.r, accent.g, accent.b, 0.88)
	header_separator.color = accent_medium

	_set_panel_accent(main_panel, accent, 0.72)
	_set_panel_accent(status_badge, accent, 0.85, 0.22)
	_set_panel_accent(portrait_frame, accent, 0.68)
	_set_button_accent(accent)


func _set_panel_accent(
	panel: PanelContainer,
	accent: Color,
	border_alpha: float,
	background_alpha: float = -1.0,
) -> void:
	var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if style == null:
		return
	style.border_color = Color(accent.r, accent.g, accent.b, border_alpha)
	if background_alpha >= 0.0:
		style.bg_color = Color(accent.r, accent.g, accent.b, background_alpha)
	panel.add_theme_stylebox_override("panel", style)


func _set_button_accent(accent: Color) -> void:
	var normal_style: StyleBoxFlat = end_run_button.get_theme_stylebox("normal").duplicate() as StyleBoxFlat
	var hover_style: StyleBoxFlat = end_run_button.get_theme_stylebox("hover").duplicate() as StyleBoxFlat
	var pressed_style: StyleBoxFlat = end_run_button.get_theme_stylebox("pressed").duplicate() as StyleBoxFlat
	var focus_style: StyleBoxFlat = end_run_button.get_theme_stylebox("focus").duplicate() as StyleBoxFlat

	if normal_style != null:
		normal_style.bg_color = accent.darkened(0.68)
		normal_style.border_color = Color(accent.r, accent.g, accent.b, 0.88)
		end_run_button.add_theme_stylebox_override("normal", normal_style)
	if hover_style != null:
		hover_style.bg_color = accent.darkened(0.48)
		hover_style.border_color = accent.lightened(0.3)
		hover_style.shadow_color = Color(accent.r, accent.g, accent.b, 0.32)
		end_run_button.add_theme_stylebox_override("hover", hover_style)
	if pressed_style != null:
		pressed_style.bg_color = accent.darkened(0.74)
		pressed_style.border_color = accent.darkened(0.18)
		end_run_button.add_theme_stylebox_override("pressed", pressed_style)
	if focus_style != null:
		focus_style.border_color = accent.lightened(0.38)
		end_run_button.add_theme_stylebox_override("focus", focus_style)


func _animate_reveal() -> void:
	if reveal_tween != null and reveal_tween.is_valid():
		reveal_tween.kill()

	modulate = Color(1.0, 1.0, 1.0, 0.0)
	main_panel.scale = Vector2(0.965, 0.965)
	reveal_tween = create_tween().set_parallel(true)
	reveal_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	reveal_tween.tween_property(self, "modulate:a", 1.0, 0.22)
	reveal_tween.tween_property(main_panel, "scale", Vector2.ONE, 0.28)
	reveal_tween.chain().tween_callback(end_run_button.grab_focus)


func _on_combat_ended() -> void:
	if Global.is_end_of_run():
		Signals.run_victory.emit()


func _on_run_started() -> void:
	visible = false
	end_run_button.disabled = false


func _on_run_ended() -> void:
	visible = false


func _on_run_victory() -> void:
	_show_summary(true, VICTORY_MESSAGE)


func _on_player_death_animation_finished(_player: Player) -> void:
	var death_message: String = DEFAULT_DEFEAT_MESSAGE
	var event_data: EventData = Global.get_player_event_data()
	if event_data != null and not event_data.event_death_message_bbcode.is_empty():
		death_message = event_data.event_death_message_bbcode
	_show_summary(false, death_message)


func _on_end_run_button_up() -> void:
	end_run_button.disabled = true
	visible = false
	Global.end_run(player_run_end_state)
