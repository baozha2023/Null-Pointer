# Displays run start options
extends Control

var _option_type_to_option_ids: Dictionary = {}
const MIXED_OPTION_COUNT: int = 3	# number of options to populate that have both an upside and downside
const COMPLETE_OPTION_COUNT: int = 1	# number of unique options to populate

## 开局叙事文本池，每次随机选一条
const INTRO_TEXTS: Array[String] = [
	"赛博空间深处，一段古老的引导程序被激活……\n它在你接入网络的第一刻，向你发来了[color=#40e0d0]祝福[/color]。",
	"防火墙发出低沉的嗡鸣，信号在暗网隧道中忽明忽暗。\n有人在注视着你的每一个数据包。这是[color=#ff6b6b]悬疑[/color]的开始。",
	"黑客的本能告诉你：代码不会说谎，但编写代码的人会。\n在一切变得太晚之前，你需要一点[color=#ffd700]技巧[/color]。",
	"你站在虚拟与现实的交界处，服务器阵列在你身后闪烁。\n这是一场豪赌——或者，一份[color=#7fff00]馈赠[/color]。",
	"黑入系统的第一秒，你就知道自己不该来这里。\n但来都来了。选择你的[color=#da70d6]机遇[/color]吧。",
	"终端屏幕上，一行像素拼凑的文字缓缓浮现：\n'你是我见过的最有趣的变量。' 随即，一个[color=#ff8c00]提议[/color]出现。",
	"深夜的服务器机房，只有你的键盘在响。\n没有人知道你是谁——趁现在，抓住你的[color=#00ced1]筹码[/color]。",
]

@onready var starting_option_container = $StartingOptionContainer
@onready var narrative_label = $NarrativeLabel
@onready var background_texture: TextureRect = $BackgroundTexture
@onready var map = $%Map
@onready var combat = $%Combat

func _ready():
	_aggregate_run_start_options()
	Signals.run_started.connect(_on_run_started)
	Signals.player_killed.connect(_on_player_killed)
	Signals.run_ended.connect(_on_run_ended)
	Signals.map_location_selected.connect(_on_map_location_selected)

func _aggregate_run_start_options() -> void:
	# sorts the various options into boxes based on type
	for option_type in RunStartOptionData.RUN_START_OPTION_TYPES.values():
		_option_type_to_option_ids[option_type] = [] as Array[String]
	for run_start_option_data in Global._id_to_run_start_option_data.values() as Array[RunStartOptionData]:
		_option_type_to_option_ids[run_start_option_data.run_start_option_type].append(run_start_option_data.object_id)

func _pick_random_background() -> void:
	## 五张背景图，图片放到 external/sprites/ui/run_start_bg/ 目录下
	const _BG_FILES: Array[String] = [
		"sprites/run_start_bg/bg_dark_web.png",
		"sprites/run_start_bg/bg_firewall_ruins.png",
		"sprites/run_start_bg/bg_server_temple.png",
		"sprites/run_start_bg/bg_quantum_corridor.png",
		"sprites/run_start_bg/bg_terminal_abyss.png",
	]
	
	var rng: RandomNumberGenerator = Global.player_data.get_player_rng("rng_run_start_background")
	var bg_path: String = _BG_FILES[rng.randi() % _BG_FILES.size()]
	var tex: Texture2D = FileLoader.load_texture(bg_path)
	background_texture.texture = tex

func _pick_random_narrative() -> String:
	var rng: RandomNumberGenerator = Global.player_data.get_player_rng("rng_run_start_options")
	return INTRO_TEXTS[rng.randi() % INTRO_TEXTS.size()]

func populate_run_start_options() -> void:
	# Presents a list of options to the player
	
	# 随机背景图和叙事文本
	_pick_random_background()
	narrative_label.text = "[center]" + _pick_random_narrative() + "[/center]"
	
	# get options based on type
	var upside_option_ids: Array[String] = _option_type_to_option_ids[RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_UPSIDE]
	var complete_option_ids: Array[String] = _option_type_to_option_ids[RunStartOptionData.RUN_START_OPTION_TYPES.COMPLETE]
	var downside_option_ids: Array[String] = _option_type_to_option_ids[RunStartOptionData.RUN_START_OPTION_TYPES.PARTIAL_DOWNSIDE]
	
	# duplicate for later removal of items
	downside_option_ids = downside_option_ids.duplicate()
	upside_option_ids = upside_option_ids.duplicate()
	complete_option_ids = complete_option_ids.duplicate()
	
	# randomize presented options
	var rng_run_start_options: RandomNumberGenerator = Global.player_data.get_player_rng("rng_run_start_options")
	Random.shuffle_array(rng_run_start_options, downside_option_ids)
	Random.shuffle_array(rng_run_start_options, upside_option_ids)
	Random.shuffle_array(rng_run_start_options, downside_option_ids)
	
	# populate mixed options
	var mixed_option_count: int = min(MIXED_OPTION_COUNT, len(upside_option_ids), len(downside_option_ids))
	for i in mixed_option_count:
		var upside_option_id: String = upside_option_ids.pop_back()
		var downside_option_id: String = downside_option_ids.pop_back()
		
		DebugLogger.log_line("Run options: " + upside_option_id + " " + downside_option_id)
		
		var upside_run_start_option_data: RunStartOptionData = Global.get_run_start_option_data(upside_option_id)
		var downside_run_start_option_data: RunStartOptionData = Global.get_run_start_option_data(downside_option_id)
		
		var upside_actions: Array[Dictionary] = upside_run_start_option_data.run_start_option_actions.duplicate()
		var downside_actions: Array[Dictionary] = downside_run_start_option_data.run_start_option_actions.duplicate()

		# concatenate partial text and actions
		var option_bbcode: String = upside_run_start_option_data.run_start_option_bb_code + ", " + downside_run_start_option_data.run_start_option_bb_code
		var option_actions: Array[Dictionary] = downside_run_start_option_data.run_start_option_actions + upside_run_start_option_data.run_start_option_actions
		
		# create a dialogue button for the option
		var run_start_option_button: DialogueOption = Scenes.DIALOGUE_OPTION.instantiate()
		starting_option_container.add_child(run_start_option_button)
		run_start_option_button.init("", option_bbcode, option_bbcode, option_actions, [])
		
		run_start_option_button.dialogue_option_clicked.connect(_on_dialogue_option_clicked)
	
	# populate complete options
	for i in min(COMPLETE_OPTION_COUNT, len(complete_option_ids)):
		# get option
		var complete_option_id: String = complete_option_ids.pop_back()
		var complete_run_start_option_data: RunStartOptionData = Global.get_run_start_option_data(complete_option_id)
		
		# get actions and bbcode
		var option_bbcode: String = complete_run_start_option_data.run_start_option_bb_code
		var option_actions: Array[Dictionary] = complete_run_start_option_data.run_start_option_actions
		
		# create a dialogue button for the option
		var run_start_option_button: DialogueOption = Scenes.DIALOGUE_OPTION.instantiate()
		starting_option_container.add_child(run_start_option_button)
		run_start_option_button.init("", option_bbcode, option_bbcode, option_actions, [])
		
		run_start_option_button.dialogue_option_clicked.connect(_on_dialogue_option_clicked)
	
func clear_run_start_options() -> void:
	for child in starting_option_container.get_children():
		child.queue_free()
	
func _on_dialogue_option_clicked(dialogue_option: DialogueOption):
	var player: Player = Global.get_player()
	# generate fake card play request
	var card_play_request: CardPlayRequest = HandManager.create_card_play_request(null, player, false, false)
	var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(player, card_play_request, [player], dialogue_option.action_data, null)
	ActionHandler.add_actions(generated_actions)
	clear_run_start_options()
	visible = false
	combat.visible = true
	
	if ActionHandler.actions_being_performed:
		await ActionHandler.actions_ended
	
	map.can_travel = true
	map.show_map()

func _show_run_start_options():
	# 先显示界面，再生成内容，避免 populate 出错时界面永远不可见
	visible = true
	combat.visible = false
	populate_run_start_options()
	
func _on_run_started():
	visible = false
	clear_run_start_options()
	
func _on_run_ended():
	visible = false
	clear_run_start_options()

func _on_player_killed(_player: Player) -> void:
	visible = false
	clear_run_start_options()

func _on_map_location_selected(location_data: LocationData):
	# determine what to do when the player visits a new location
	var location_type: int = location_data.location_type

	match location_type:
		LocationData.LOCATION_TYPES.STARTING:
			_show_run_start_options()
		_:
			visible = false
