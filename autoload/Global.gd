## 管理整个应用程序核心数据的单例（Singleton），提供以下几项主要功能：
## - 为当前的“游戏进程（Run）”创建/存储 PlayerData（玩家数据），并提供查询常用玩家数据的辅助方法。
## - 存储只读数据（Read-only Data）和原型数据（Prototype Data）的查找表，并为每个表提供 Getter 获取方法。
## - 维护数据模式（Schema），用于动态加载和映射数据。
## - 存储已生成对象的缓存（Cache），提高检索效率。

## 注意（NOTE）：关于测试数据和生产数据的管理，请参阅 GlobalTestDataGenerator 和 GlobalProdDataGenerator。
extends Node

#region Schema and Data Management

## 这个查找表用于通过 Global._generate_schema() 和 FileLoader._generate_base_mod_data() 
## 自动生成其他查找表，从而在整个框架中实现数据的模式化管理（Schema Management）。
## 【严重警告 (CRITICAL)】：Global._generate_schema() 必须在 _ready() 的最顶端运行，
## 且必须在执行任何其他数据相关方法之前运行！
## 【警告 (WARNING)】：每当你在 SCHEMA 中添加了一种新的数据类型，你都应该更新这个表，
## 并且取消注释并运行一次 _ready() 中的 FileLoader._generate_base_mod_data() 以更新基础 Mod 数据。
@onready var SCHEMA: Array[Array] = [
	# 格式：["序列化数据脚本类的字符串名称", 序列化数据脚本类本身, "绑定的查找表变量名", ["可选的外部读取文件夹路径", ...]],
	# 只读数据 (Read-only data) - 游戏运行中不会改变的基础数据
	["RestActionData", RestActionData, "_id_to_rest_action_data", ["rest_actions/"]],
	["StatusEffectData", StatusEffectData, "_id_to_status_data", ["status_effects/"]],
	["ConsumableData", ConsumableData, "_id_to_consumable_data", ["consumables/"]],
	["CardDecoratorData", CardDecoratorData, "_id_to_card_decorator_data", ["card_decorators/"]],
	["ActData", ActData, "_id_to_act_data", ["acts/"]],
	["EventData", EventData, "_id_to_event_data", ["events/"]],
	["EventPoolData", EventPoolData, "_id_to_event_pool_data", ["event_pools/"]],
	["DialogueData", DialogueData, "_id_to_dialogue_data", ["dialogue/"]],
	["ActionInterceptorData", ActionInterceptorData, "_id_to_action_interceptor_data", ["action_interceptors/"]],
	["ColorData", ColorData, "_id_to_color_data", ["colors/"]],
	["KeywordData", KeywordData, "_id_to_keyword_data", ["keywords/"]],
	["CharacterData", CharacterData, "_id_to_character_data", ["characters/"]],
	["AnimationData", AnimationData, "_id_to_animation_data", ["animations/"]],
	["RunModifierData", RunModifierData, "_id_to_run_modifier_data", ["run_modifiers/"]],
	["RunStartOptionData", RunStartOptionData, "_id_to_run_start_option_data", ["run_start_options/"]],
	["CardPackData", CardPackData, "_id_to_card_pack_data", ["card_packs/"]],
	["ArtifactPackData", ArtifactPackData, "_id_to_artifact_pack_data", ["artifact_packs/"]],
	["ConsumablePackData", ConsumablePackData, "_id_to_consumable_pack_data", ["consumable_packs/"]],
	["CustomUIData", CustomUIData, "_id_to_custom_ui_data", ["custom_ui/"]],
	["CustomSignalData", CustomSignalData, "_id_to_custom_signal_data", ["custom_signals/"]],
	# 原型数据 (Prototype data) - 游戏运行时会基于这些原型克隆出可修改的实例数据
	["EnemyData", EnemyData,"_id_to_enemy_data", ["enemies/"]],
	["CardData", CardData, "_id_to_card_data", ["cards/"]],
	["ArtifactData", ArtifactData, "_id_to_artifact_data", ["artifacts/"]],
	["PlayerData", PlayerData, "_id_to_player_data", ["player/"]],
	["OptionData", OptionData, "_id_to_option_data", ["options/"]],
]

## 核心类映射表。这些查找表可以自动化地在整个应用程序中加载、保存和映射数据，
## 而不是枯燥地手写成百上千个并行的 加载/保存/注册 函数。
## 【警告 (WARNING)】：这个字典是由 _generate_schema() 自动生成的。千万不要手动往里面填东西！
var CLASS_NAME_TO_CLASS: Dictionary[String, Script] = {
	#"SerializeableData": SerializableData,
}

## 核心查找表映射。将 SerializeableData（可序列化数据）的脚本类映射到它对应的查找表（字典名）。主要用于 register_rod() 方法自动注册数据。
## 【警告 (WARNING)】：这个字典是由 _generate_schema() 自动生成的。千万不要手动往里面填东西！
var READ_ONLY_GETTER_SCHEMA: Dictionary[Script, String] = {
	#SerializableData, "id_to_data"
}

# 不可变数据（只读数据）查找表。一旦创建后，绝对不要在游戏运行时修改它们的内容！
var _id_to_rest_action_data: Dictionary[String, RestActionData] = {}
var _id_to_status_data: Dictionary[String, StatusEffectData] = {}
var _id_to_consumable_data: Dictionary[String, ConsumableData] = {}
var _id_to_card_decorator_data: Dictionary[String, CardDecoratorData] = {}
var _id_to_act_data: Dictionary[String, ActData] = {}
var _id_to_event_data: Dictionary[String, EventData] = {}
var _id_to_event_pool_data: Dictionary[String, EventPoolData] = {}
var _id_to_dialogue_data: Dictionary[String, DialogueData] = {}
var _id_to_action_interceptor_data: Dictionary[String, ActionInterceptorData] = {}
var _id_to_color_data: Dictionary[String, ColorData] = {}
var _id_to_keyword_data: Dictionary[String, KeywordData] = {}
var _id_to_character_data: Dictionary[String, CharacterData] = {}
var _id_to_animation_data: Dictionary[String, AnimationData] = {}
var _id_to_run_modifier_data: Dictionary[String, RunModifierData] = {}
var _id_to_run_start_option_data: Dictionary[String, RunStartOptionData] = {}
var _id_to_card_pack_data: Dictionary[String, CardPackData] = {}
var _id_to_artifact_pack_data: Dictionary[String, ArtifactPackData] = {}
var _id_to_consumable_pack_data: Dictionary[String, ConsumablePackData] = {}
var _id_to_custom_ui_data: Dictionary[String, CustomUIData] = {}
var _id_to_custom_signal_data: Dictionary[String, CustomSignalData] = {}

# 原型数据（Prototyped data）；这些也是只读的，它们的作用是作为模板，在需要时被克隆（Duplicate）成可变的数据实例。
var _id_to_enemy_data: Dictionary[String, EnemyData] = {}
var _id_to_card_data: Dictionary[String, CardData] = {}
var _id_to_artifact_data: Dictionary[String, ArtifactData] = {}
var _id_to_player_data: Dictionary[String, PlayerData] = {}

# 可变数据（Mutable data）；这些对象在游戏进程中是可以被随意修改的。
var player_data: PlayerData = PlayerData.new() # 当前游戏进程的玩家数据（这是从原型克隆出的实例）
var user_settings_data: UserSettingsData = UserSettingsData.new() # 玩家的本地设置（音量、全屏等）
var profile_data: ProfileData = ProfileData.new() # 玩家的总体存档进度（历史记录、总胜率等）
var is_run: bool = false # 简单的状态标记，用来检查当前是否正在进行一局游戏

## 记录标准难度修改器（Difficulty Modifiers）的对象 ID。
## 它们会被用在“新建进程”界面的难度选择器上。
## 这些 ID 必须通过 GlobalTestGeneratorData 或 GlobalProdGeneratorData 的 add_(test)_run_modifiers() 提前定义。
var STANDARD_DIFFICULTY_RUN_MODIFIER_IDS: Array[String] = [ 
	#"run_modifier_difficulty_1", "run_modifier_difficulty_2", "run_modifier_difficulty_3",
	#"run_modifier_difficulty_4", "run_modifier_difficulty_5",
]

#region cached objects
## 存储卡牌过滤器（Card Filter）的结果缓存。
## 因为在几千张卡牌中频繁进行复杂的条件搜索非常消耗性能，所以我们将搜索结果缓存起来。
## 这些缓存的键（Key）通常对应 CardPackData 的对象 ID，但也可以添加自定义的键。
## 具体逻辑参考：Global._generate_card_pack_cache()
var _id_to_card_filter_cache: Dictionary[String, CardFilter] = {}

## 存储外设插件过滤器（Artifact Filter）的结果缓存。
## 具体逻辑参考：Global._generate_artifact_pack_cache()
var _id_to_artifact_filter_cache: Dictionary[String, ArtifactFilter] = {}

## 存储物理删除品过滤器（Consumable Filter）的结果缓存。
## 具体逻辑参考：Global._generate_consumable_pack_cache()
var _id_to_consumable_filter_cache: Dictionary[String, ConsumableFilter] = {}
#endregion

## 读取最上方的 SCHEMA 数组，并生成框架中映射数据类型所需的快速查找表。
## 这个方法自动化并集中管理了大量极其枯燥的数据模式（Schema）维护工作。
## 同时，它也为测试数据生成期的 register_rod() 方法、以及基于数据表映射的文件/Mod 加载提供了底层支持。
func _generate_schema() -> void:
	for schema_row: Array in SCHEMA:
		var data_script_string: String = schema_row[0]
		var data_script: Script = schema_row[1]
		var data_lookup_table_property_name: String = schema_row[2]
		var read_only_data_folder_paths: Array[String] = []
		read_only_data_folder_paths.assign(schema_row[3])
		
		READ_ONLY_GETTER_SCHEMA[data_script] = data_lookup_table_property_name
		CLASS_NAME_TO_CLASS[data_script_string] = data_script

## 允许自动将“只读数据对象 (Read-Only-Data, ROD)”注册到它正确的查找表中。
## 这个方法对于通用数据管线极其有用，并且大幅精简了编写测试数据的代码量。
## 它依赖于前面自动生成的 READ_ONLY_GETTER_SCHEMA 表。
func register_rod(serializeable_data: SerializableData, allow_collisions: bool = true) -> void:
	var script_class: Script = serializeable_data.get_script() # 获取当前传入对象的脚本类型
	if not READ_ONLY_GETTER_SCHEMA.has(script_class):
		breakpoint
		DebugLogger.log_error("Global.register_rod(): No lookup table for {0}".format([script_class]))
		get_tree().quit()
	else:
		# 找到该 SerializeableData（可序列化数据）所匹配的查找表变量名
		var lookup_table_property_name: String = READ_ONLY_GETTER_SCHEMA[script_class]
		var lookup_table: Dictionary = get(lookup_table_property_name)
		if serializeable_data.object_id == "":
			breakpoint
			DebugLogger.log_error("Global.register_rod(): Empty object ID")
			get_tree().quit()
		if lookup_table.has(serializeable_data.object_id) and not allow_collisions:
			breakpoint
			DebugLogger.log_error("Global.register_rod(): Object ID collision in {0} for ID: {1}".format([lookup_table_property_name, serializeable_data.object_id]))
			get_tree().quit()
		# 将只读对象以其 object_id 为键，注册（写入）到对应的查找表中
		lookup_table[serializeable_data.object_id] = serializeable_data
		# 重新将更新后的查找表赋值回 Global 单例
		set(lookup_table_property_name, lookup_table)

#endregion

func _ready():
	get_tree().node_added.connect(_on_node_added_global)
	call_deferred("_apply_cursor_to_tree", get_tree().root)
	
	### 模式（Schema）初始化
	# 生成数据模式（Schema）。这必须在 Global 的其他所有操作之前完成，
	# 否则在加载数据或生成测试数据时会报错。
	_generate_schema()
	# 让 SerializableData 构建它的全局类到脚本类的映射缓存。
	# 这也必须在一切操作之前完成，否则你将无法从外部文件加载对象。
	SerializableData.build_serializable_script_cache()
	
	### 加载存档进度和用户本地设置
	FileLoader.load_profile()
	FileLoader.load_user_settings()
	
	var master_vol: float = user_settings_data.settings_audio_master_volume
	SoundManager.set_music_volume(user_settings_data.settings_audio_music_volume * master_vol)
	SoundManager.set_sound_volume(user_settings_data.settings_audio_effects_volume * master_vol)
	
	### 生成生产环境数据（真实游戏内容）
	GlobalProdDataGenerator.generate_production_data()

	### 生成测试环境数据（用于开发调试）
	#GlobalTestDataGenerator.generate_test_data()

	### 测试专用标识/作弊开关
	ProfileData.ENABLE_ALL_DIFFICULTIES = false
	ProfileData.UNLOCK_ALL_CARDS_IN_CODEX = false
	ProfileData.ENABLE_ONE_CLICK_BOSS = false
	ProfileData.REQUIRE_BZ_GAMES_LAUNCH = false
	StatsHandler.TRACK_RUN_HISTORY = true
	
	### Mod 支持和外部文件加载
	#FileLoader._generate_mod_list_data() # 生成用于加载所有外部文件的 Mod 列表
	#FileLoader._generate_base_mod_data() # 生成本体游戏的基础 Mod 数据。如果你更新了最上面的 SCHEMA，请取消注释并运行一次，然后重新注释掉
	FileLoader.load_read_only_data() # 加载所有的 Mod 和本体游戏的外部只读数据
	
	### 基于已加载数据进行二次生成
	# 根据 CustomSignalData 动态生成自定义信号
	Signals.register_all_custom_signals()
	# 根据 CardPackData 生成卡牌过滤器缓存
	Global._generate_card_pack_cache()
	# 根据 ArtifactPackData 生成外设插件过滤器缓存
	Global._generate_artifact_pack_cache()
	# 根据 ConsumablePackData 生成物理删除品过滤器缓存
	Global._generate_consumable_pack_cache()
	# 强制生成所有的特效动画
	FileLoader.generate_all_animations()
	
	### 导出数据
	# FileLoader.export_read_only_data() # 取消注释此行可将所有未导出的生成数据导出成 JSON 文件（方便开发查看）

func _on_node_added_global(node: Node) -> void:
	if node is BaseButton:
		if node.mouse_default_cursor_shape == Control.CURSOR_ARROW:
			node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
	# Dynamic Mod Support: Automatically convert all built-in resources to FileLoader
	_apply_fileloader_to_node(node)

func _apply_fileloader_to_node(node: Node) -> void:
	if not Engine.is_editor_hint(): # Ensure we don't interfere with the Godot editor
		var texture_properties = ["texture", "texture_normal", "texture_pressed", "texture_hover", "texture_disabled", "texture_focused"]
		for prop in texture_properties:
			if prop in node:
				var tex = node.get(prop)
				if tex != null and tex.resource_path.begins_with("res://sprites/"):
					var partial_path = tex.resource_path.replace("res://", "")
					node.set(prop, FileLoader.load_texture(partial_path))
					
		var audio_properties = ["stream"]
		for prop in audio_properties:
			if prop in node:
				var stream = node.get(prop)
				if stream != null and stream.resource_path.begins_with("res://sounds/"):
					var partial_path = stream.resource_path.replace("res://", "")
					node.set(prop, FileLoader.load_audio(partial_path))

func _apply_cursor_to_tree(node: Node) -> void:
	_on_node_added_global(node)
	for child in node.get_children():
		_apply_cursor_to_tree(child)

#region Run
## 使用指定的种子（Seed）和角色，开始新的一局游戏进程（Run）。
func start_run(character_object_id: String, run_seed: int, difficulty_level: int = 0, custom_run_modifier_object_ids: Array[String] = []) -> void:
	var character_data: CharacterData = get_character_data(character_object_id)
	
	# 根据所选角色，从原型数据中初始化一局新的玩家数据（Player Data）
	player_data = get_player_data_from_prototype(character_data.character_player_id)
	is_run = true # 标记为当前游戏进程已开始
	
	# 初始化这局游戏的随机数种子
	player_data.player_run_seed = run_seed
	
	#region 游戏进程数据初始化
	# 为这局游戏生成外设插件池
	# 注意：这里面包含了所有的插件，不考虑补充包（Packs）过滤
	player_data.initialize_artifact_pool()
	
	# 给玩家添加初始外设插件
	for artifact_id in character_data.character_starting_artifact_ids:
		player_data.add_artifact(artifact_id)
	
	# 给玩家添加初始卡牌（脚本）
	for card_object_id in character_data.character_starting_card_object_ids:
		player_data.player_deck.append(get_card_data_from_prototype(card_object_id))
	
	# 卡牌掉落包配置
	player_data.reward_draft_card_pack_ids.assign(character_data.character_starting_card_draft_card_pack_ids)
	# 外设插件掉落包配置
	player_data.player_artifact_pack_ids.assign(character_data.character_starting_artifact_pack_ids)
	# 物理删除品掉落包配置
	player_data.player_consumable_pack_ids.assign(character_data.character_starting_consumable_pack_ids)
	
	# 初始金钱与血量设置
	player_data.player_money = character_data.character_starting_money
	player_data.player_health_max = character_data.character_starting_health
	player_data.player_health = character_data.character_starting_health
	
	# 初始化玩家位置、章节和难度级别
	player_data.player_location_id = "location_0" # 硬编码绑定的初始节点 ID
	player_data.player_act = 1
	player_data.player_run_difficulty_level = difficulty_level
	
	# 确定这局游戏生效的全局修改器（Run Modifiers）
	player_data.player_run_modifier_object_ids = []
	# 自动生效的修改器
	for run_modifier_id: String in Global._id_to_run_modifier_data:
		var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_id)
		if run_modifier_data.run_modifier_is_automatic:
			player_data.player_run_modifier_object_ids.append(run_modifier_id)
	# 基于难度等级叠加的修改器
	if difficulty_level > 0:
		var difficulty_amount_max: int = min(difficulty_level + 1, len(STANDARD_DIFFICULTY_RUN_MODIFIER_IDS))
		player_data.player_run_modifier_object_ids.append_array(STANDARD_DIFFICULTY_RUN_MODIFIER_IDS.slice(0, difficulty_amount_max, 1, true))
	player_data.player_run_modifier_object_ids.append_array(custom_run_modifier_object_ids)
	#endregion
	
	# 进程历史记录与数据统计初始化
	player_data.player_run_stats = RunStatsData.new()
	StatsHandler.current_run_stats = player_data.player_run_stats # 更新单例的引用指向当前局
	
	
	# 取消下面这些注释可以给玩家强行塞入测试卡牌/插件/物品（官方外挂）
	# GlobalTestDataGenerator.add_test_cards_to_player_deck()
	# GlobalTestDataGenerator.add_test_artifacts_to_player()
	# GlobalTestDataGenerator.add_test_consumables_to_player()
	
	# 连接信号并生成这局游戏的缓存
	player_data.init()
	
	# 触发“对局开始时”的全局修改器效果
	perform_start_of_run_modifiers()
	
	# 生成第一章的大地图世界
	ActionGenerator.generate_act("act_1", 1)
	
	# 游戏开始时立刻进行自动存档
	FileLoader.autosave()
	
	Signals.run_started.emit()
	Signals.map_location_selected.emit(get_player_location_data())	# 模拟玩家踩上了第一个节点（出发点）
	
	# 模拟直接获得胜利（测试用）
	#await get_tree().create_timer(5).timeout
	#Signals.run_victory.emit()

## 供 end_run() 结束进程时使用的枚举状态。
enum RUN_ENDS {QUIT, LOSS, VICTORY}

## 以前面给定的状态（放弃、失败、胜利）强行结束玩家当前的游戏进程。
func end_run(run_end_state: int = RUN_ENDS.QUIT) -> void:
	match run_end_state:
		RUN_ENDS.QUIT:
			pass # 无变化，当前进度应该已经被自动存档过了，玩家可以下次继续
		RUN_ENDS.LOSS:
			FileLoader.delete_save()
			StatsHandler.lose_run() # 输了，将失败记录写进总存档
			FileLoader.save_profile()
		RUN_ENDS.VICTORY:
			FileLoader.delete_save()
			StatsHandler.win_run() # 赢了，将胜利记录写进总存档
			FileLoader.save_profile()
	
	is_run = false
	Signals.run_ended.emit()

## 在玩家的存档进度中记录一次失败，并删除当前游戏的存档，不会开始新一局游戏。
func forfeit_run_from_title() -> void:
	FileLoader.load_game(false)
	FileLoader.delete_save()
	StatsHandler.lose_run()
	FileLoader.save_profile()

## 返回当前游戏进程是否应该结束。
func is_end_of_run() -> bool:
	if not is_end_of_act():
		return false # 前方还有更多节点
	if player_data.player_act_max <= 0:
		return false # 无尽模式
	if player_data.player_act < player_data.player_act_max:
		return false # 后面还有更多章节
	return true

## 在一局游戏最开始时，遍历执行每个全局修改器（Run Modifier）的自定义逻辑。
func perform_start_of_run_modifiers() -> void:
	for run_modifier_object_id in Global.player_data.player_run_modifier_object_ids:
		var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_object_id)
		if run_modifier_data == null:
			DebugLogger.log_error("Global.perform_start_of_run_modifiers(): No RunData with id of \"{0}\"".format([run_modifier_object_id]))
			continue
		else:
			var run_modifier_modifier_script_path: String = run_modifier_data.run_modifier_modifier_script_path
			if run_modifier_modifier_script_path != "":
				var run_modidifier_script_asset = load(run_modifier_modifier_script_path)
				var run_modifier: BaseRunModifier = run_modidifier_script_asset.new()
				run_modifier.run_start_modification()

func pause_game() -> void:
	get_tree().paused = true
	Signals.game_paused.emit()
	
func unpause_game() -> void:
	get_tree().paused = false
	Signals.game_unpaused.emit()

#endregion

#region Combat and Combat Stats
## 获取代表当前玩家角色的 BaseCombatant（战斗实体）节点。
func get_player() -> Player:
	return Global.get_tree().get_first_node_in_group("players")

func get_alive_enemies() -> Array[Enemy]:
	var returned_enemies: Array[Enemy] = []
	for enemy: Enemy in Global.get_tree().get_nodes_in_group("enemies_alive_or_dead"):
		if enemy.is_alive():
			returned_enemies.append(enemy)
	return returned_enemies

func are_remaining_enemies() -> bool:
	return len(get_alive_enemies()) > 0

func get_combat_stats() -> CombatStatsData:
	# 快速获取属性的辅助方法
	# 获取玩家在这场战斗中的战斗数据统计
	return StatsHandler.current_combat_stats
	
func get_run_stats() -> RunStatsData:
	# 快速获取属性的辅助方法
	return player_data.player_run_stats
	
func is_player_in_combat() -> bool:
	return StatsHandler.current_combat_stats != null

func is_player_turn() -> bool:
	return StatsHandler.is_player_turn

#endregion

#region Artifacts
func get_artifact_data(artifact_id: String) -> ArtifactData:
	return _id_to_artifact_data.get(artifact_id, null)

func get_all_artifacts() -> Array[ArtifactData]:
	var all_artifacts: Array[ArtifactData] = []
	all_artifacts.assign(_id_to_artifact_data.values())
	return all_artifacts

func get_artifact_data_from_prototype(artifact_id: String) -> ArtifactData:
	# 根据给定的 ArtifactData 原型生成一份它的拷贝（实例）
	var artifact_data: ArtifactData = get_artifact_data(artifact_id)
	return artifact_data.get_prototype(true)
#endregion

#region Consumables
func get_consumable_data(consumable_object_id: String) -> ConsumableData:
	return _id_to_consumable_data.get(consumable_object_id, null)

func get_all_consumables() -> Array[ConsumableData]:
	var all_consumables: Array[ConsumableData] = []
	all_consumables.assign(_id_to_consumable_data.values())
	return all_consumables

func get_player_consumable_in_slot_index(consumable_slot_index: int) -> ConsumableData:
	return player_data.get_consumable_in_slot(consumable_slot_index)
#endregion

#region Card Decorators
func get_card_decorator_data(card_decorator_object_id: String) -> CardDecoratorData:
	return _id_to_card_decorator_data.get(card_decorator_object_id, null)
#endregion

#region Rest Actions
func get_rest_action_data(rest_action_object_id: String) -> RestActionData:
	return _id_to_rest_action_data.get(rest_action_object_id, null)
#endregion

#region Status Effects
func get_status_effect_data(status_effect_object_id: String) -> StatusEffectData:
	return _id_to_status_data.get(status_effect_object_id, null)
#endregion

#region Acts
func get_act_data(act_id: String) -> ActData:
	return _id_to_act_data[act_id]
#endregion
	
#region Events and Event Pools
func get_event_data(event_object_id: String) -> EventData:
	return _id_to_event_data.get(event_object_id, null)

func get_player_event_data() -> EventData:
	# 获取玩家当前所处节点（Location）的事件（Event）
	# 这通常会通过 LocationData.get_location_event_object_id() 在该位置生成一个新事件
	var player_location_data: LocationData = get_player_location_data()
	var location_event_object_id: String = player_location_data.get_location_event_object_id()
	return get_event_data(location_event_object_id)

func get_event_pool_data(event_pool_object_id: String) -> EventPoolData:
	return _id_to_event_pool_data.get(event_pool_object_id, null)
#endregion

var _id_to_option_data: Dictionary = {}
var act_scene_paths: Dictionary = {}

func get_option_data(object_id: String) -> OptionData:
	if _id_to_option_data.has(object_id):
		return _id_to_option_data.get(object_id)
	DebugLogger.log_error("Failed to fetch OptionData for id " + object_id)
	return null

#region Dialogue
func get_dialogue_data(dialogue_object_id: String) -> DialogueData:
	return _id_to_dialogue_data.get(dialogue_object_id, null)
#endregion

#region Action Interceptors
func get_action_interceptor_data(action_interceptor_object_id: String) -> ActionInterceptorData:
	return _id_to_action_interceptor_data.get(action_interceptor_object_id, null)
#endregion

#region Colors
func get_color_data(color_id: String) -> ColorData:
	return _id_to_color_data.get(color_id)
#endregion

#region Keywords
func get_keyword_data(keyword_object_id: String) -> KeywordData:
	return _id_to_keyword_data.get(keyword_object_id, null)
#endregion

#region Characters
func get_character_data(character_object_id: String) -> CharacterData:
	return _id_to_character_data.get(character_object_id, null)

func get_player_character_data() -> CharacterData:
	# 获取当前玩家正在使用的角色数据（CharacterData）
	var character_data: CharacterData = get_character_data(player_data.player_character_object_id)
	return character_data
#endregion

#region Animations
func get_animation_data(animation_object_id: String) -> AnimationData:
	return _id_to_animation_data.get(animation_object_id, null)

#endregion

#region Run Modifiers
func get_run_modifier_data(run_modifier_object_id: String) -> RunModifierData:
	return _id_to_run_modifier_data.get(run_modifier_object_id, null)
#endregion

#region Run Start Options
func get_run_start_option_data(run_start_option_object_id: String) -> RunStartOptionData:
	return _id_to_run_start_option_data.get(run_start_option_object_id, null)
#endregion

#region Custom UI
func get_custom_ui_data(custom_ui_object_id: String) -> CustomUIData:
	return _id_to_custom_ui_data.get(custom_ui_object_id, null)
#endregion

#region Custom Signals
func get_custom_signal_data(custom_signal_object_id: String) -> CustomSignalData:
	return _id_to_custom_signal_data.get(custom_signal_object_id, null)
#endregion

#region Locations
func get_location_data(location_id: String) -> LocationData:
	return player_data.location_id_to_location_data.get(location_id, null)

func get_all_locations() -> Array[LocationData]:
	var locations: Array[LocationData] = []
	for location in player_data.location_id_to_location_data.values():
		locations.append(location)
	return locations

func get_all_act_locations() -> Array[LocationData]:
	# 获取玩家当前所处章节（Act）内的所有节点（Location）
	var locations: Array[LocationData] = []
	for location in player_data.location_id_to_location_data.values():
		if location.location_act == player_data.player_act:
			locations.append(location)
	return locations

func get_player_current_floor() -> int:
	# 根据当前节点的数据，推导出当前的层数（Floor）
	var current_location_data: LocationData = Global.get_player_location_data()
	if current_location_data == null:
		breakpoint
		return -1
	return current_location_data.location_floor

func get_player_location_data() -> LocationData:
	return get_location_data(player_data.player_location_id)

func get_next_locations(location_id: String = player_data.player_location_id) -> Array[LocationData]:
	# 获取给定节点之后的相邻节点的辅助方法
	# 默认返回玩家当前节点之后的节点
	var next_locations: Array[LocationData] = []
	
	var current_location_data: LocationData = get_location_data(location_id)
	
	if current_location_data == null:
		breakpoint
		return []
		
	for next_location_id in current_location_data.location_next_location_ids:
		var next_location_data: LocationData = get_location_data(next_location_id)
		if next_location_data != null:
			next_locations.append(next_location_data)
	
	return next_locations

func is_end_of_act() -> bool:
	return len(get_next_locations()) == 0

func clear_locations() -> void:
	player_data.location_id_to_location_data.clear()
#endregion

#region Shops
## 创建一个新商店（Shop）并将其绑定到玩家当前所处的节点位置。
func generate_shop_at_player_location() -> ShopData:
	var location_data: LocationData = Global.get_player_location_data()
	var shop_data: ShopData = ShopData.new()
	shop_data.shop_location_id = location_data.location_id
	player_data.player_shop_data = shop_data
	return shop_data
	
## 如果当前节点的商店与玩家数据匹配，则获取玩家的商店数据。
## 这个方法用于防止玩家后退或读取到了上一个旧节点的旧商店数据。
func get_shop_at_player_location() -> ShopData:
	var player_shop_data: ShopData = Global.player_data.player_shop_data
	var player_location_data: LocationData = get_player_location_data()
	# 没有商店
	if player_shop_data == null:
		return null
	# 商店不在当前节点（位置不匹配）
	if player_shop_data.shop_location_id != player_location_data.location_id:
		return null
	
	return player_shop_data
#endregion

#region Enemies
func get_enemy_data(enemy_object_id: String) -> EnemyData:
	return _id_to_enemy_data.get(enemy_object_id, null)

func get_enemy_data_from_prototype(enemy_object_id: String) -> EnemyData:
	# 根据给定的 EnemyData 原型生成一份它的拷贝（实例）
	var enemy_data: EnemyData = get_enemy_data(enemy_object_id)
	return enemy_data.get_prototype(true)
#endregion

#region Player Data Prototypes

func get_player_data_from_prototype(player_id: String) -> PlayerData:
	var _player_data: PlayerData = _id_to_player_data[player_id]
	return _player_data.get_prototype(true)

#endregion

#region Cards
## 获取一个只读状态的卡牌数据（CardData）模板/原型。
## 若需在游戏中修改卡牌数据，请使用 get_card_data_from_prototype() 来生成一份可编辑的拷贝。
func get_card_data(card_object_id: String) -> CardData:
	return _id_to_card_data.get(card_object_id, null)

func get_all_cards() -> Array[CardData]:
	var all_cards: Array[CardData] = []
	for card_data in _id_to_card_data.values():
		all_cards.append(card_data)
	return all_cards

## 图鉴、万能调试仪等卡牌浏览界面共用的过滤入口。
## 浏览逻辑刻意忽略 card_appears_in_card_packs；该字段只控制局内可获取卡池，
## 不应阻止玩家查看已经注册的卡牌内容。
func get_cards_for_browser(
	input_cards: Array[CardData],
	card_pack_data: CardPackData = null,
	search_text: String = ""
) -> Array[CardData]:
	var candidate_cards: Array[CardData] = []
	candidate_cards.assign(input_cards)

	if card_pack_data != null and card_pack_data.object_id != "card_pack_all":
		var card_filter: CardFilter = CardFilter.new(candidate_cards)
		if card_pack_data.card_pack_color_id != "":
			card_filter.filter_colors([card_pack_data.card_pack_color_id])
		card_filter.filter_card_validators(card_pack_data.card_pack_validators)
		candidate_cards = card_filter.filtered_cards

		# 卡包显式列出的卡牌可绕过颜色和验证器，但不能引入输入集合之外的卡牌。
		var candidate_ids: Dictionary[String, Variant] = {}
		for card_data: CardData in candidate_cards:
			candidate_ids[card_data.object_id] = null
		for card_data: CardData in input_cards:
			if card_pack_data.card_pack_card_ids.has(card_data.object_id) and not candidate_ids.has(card_data.object_id):
				candidate_cards.append(card_data)
				candidate_ids[card_data.object_id] = null

	var normalized_search_text: String = search_text.strip_edges().to_lower()
	if normalized_search_text == "":
		return candidate_cards

	var search_results: Array[CardData] = []
	for card_data: CardData in candidate_cards:
		if (
			normalized_search_text in card_data.card_name.to_lower()
			or normalized_search_text in card_data.object_id.to_lower()
		):
			search_results.append(card_data)
	return search_results

## 根据给定的只读 CardData 原型，生成一份可变的（Mutable）卡牌数据拷贝。
func get_card_data_from_prototype(card_object_id: String) -> CardData:
	var card_data: CardData = get_card_data(card_object_id)
	return card_data.get_prototype(true)

## 给定一组只读卡牌 ID，批量获取它们的可变卡牌数据拷贝。
func get_card_data_from_prototypes(card_object_ids: Array[String]) -> Array[CardData]:
	var card_prototypes: Array[CardData] = []
	for card_object_id: String in card_object_ids:
		card_prototypes.append(get_card_data_from_prototype(card_object_id))
	return card_prototypes
#endregion

#region Caches and Packs
func get_card_pack_data(card_pack_object_id: String) -> CardPackData:
	return _id_to_card_pack_data.get(card_pack_object_id, null)

func get_artifact_pack_data(artifact_pack_object_id: String) -> ArtifactPackData:
	return _id_to_artifact_pack_data.get(artifact_pack_object_id, null)

## 使用所有已加载的卡牌包（CardPackData）生成卡牌过滤器（CardFilters），并将它们存储在缓存中以便重复使用。
## 这通常只在游戏启动时调用一次。
func _generate_card_pack_cache() -> void:
	for card_pack_data: CardPackData in Global._id_to_card_pack_data.values():
		var card_filter: CardFilter = card_pack_data.create_card_pack_card_filter()
		card_filter.cache_filter(card_pack_data.object_id)

## 注意：这个方法应该始终由 CardFilter.cache_filter() 来调用。
## 这里的 ID 通常和卡牌包 ID 是一致的，但如果从其他地方生成卡牌过滤器并缓存，也可以即兴添加特定的 ID。
func cache_card_filter(card_filter_cache_id: String, card_filter: CardFilter) -> void:
	_id_to_card_filter_cache[card_filter_cache_id] = card_filter

func get_cached_card_filter(card_filter_cache_id: String) -> CardFilter:
	return _id_to_card_filter_cache.get(card_filter_cache_id, null)

## 使用所有已加载的外设包（ArtifactPackData）生成外设过滤器（ArtifactFilters），并将它们存储在缓存中以便重复使用。
## 这通常只在游戏启动时调用一次。
func _generate_artifact_pack_cache() -> void:
	for artifact_pack_data: ArtifactPackData in Global._id_to_artifact_pack_data.values():
		var artifact_filter: ArtifactFilter = artifact_pack_data.create_artifact_pack_artifact_filter()
		artifact_filter.cache_filter(artifact_pack_data.object_id)

## 注意：这个方法应该始终由 ArtifactFilter.cache_filter() 来调用。
## 这里的 ID 通常和外设包 ID 是一致的，但如果从其他地方生成外设过滤器并缓存，也可以即兴添加特定的 ID。
func cache_artifact_filter(artifact_filter_cache_id: String, artifact_filter: ArtifactFilter) -> void:
	_id_to_artifact_filter_cache[artifact_filter_cache_id] = artifact_filter

func get_cached_artifact_filter(artifact_filter_cache_id: String) -> ArtifactFilter:
	return _id_to_artifact_filter_cache.get(artifact_filter_cache_id, null)

## 使用所有已加载的消耗品包（ConsumablePackData）生成消耗品过滤器（ConsumableFilters），并将它们存储在缓存中以便重复使用。
## 这通常只在游戏启动时调用一次。
func _generate_consumable_pack_cache() -> void:
	for consumable_pack_data: ConsumablePackData in Global._id_to_consumable_pack_data.values():
		var consumable_filter: ConsumableFilter = consumable_pack_data.create_consumable_pack_consumable_filter()
		consumable_filter.cache_filter(consumable_pack_data.object_id)

## 注意：这个方法应该始终由 ConsumableFilter.cache_filter() 来调用。
## 这里的 ID 通常和消耗品包 ID 是一致的，但如果从其他地方生成消耗品过滤器并缓存，也可以即兴添加特定的 ID。
func cache_consumable_filter(consumable_filter_cache_id: String, consumable_filter: ConsumableFilter) -> void:
	_id_to_consumable_filter_cache[consumable_filter_cache_id] = consumable_filter

func get_cached_consumable_filter(consumable_filter_cache_id: String) -> ConsumableFilter:
	return _id_to_consumable_filter_cache.get(consumable_filter_cache_id, null)
#endregion

#region General Utility
## 返回给定的所有验证器（Validators）是否全部通过。这个核心方法在整个框架中都被广泛使用。
func validate(validators: Array[Dictionary], card_data: CardData = null, action: BaseAction = null) -> bool:
	for validator_data: Dictionary in validators:
		for validator_script_path: String in validator_data:
			var validator_script_asset = load(validator_script_path)
			var validator: BaseValidator = validator_script_asset.new()
			
			var validator_values: Dictionary[String, Variant] = {}
			validator_values.assign(validator_data[validator_script_path]) # 强制转换为强类型的字典
			
			if not validator.validate(card_data, action, validator_values):
				return false
	
	return true
#endregion

var _profile_save_timer: float = 0.0

func _process(delta: float) -> void:
	if _profile_save_timer > 0.0:
		_profile_save_timer -= delta
		if _profile_save_timer <= 0.0:
			FileLoader.save_profile()

## Marks a card as discovered in the profile
func discover_card(card_id: String) -> void:
	if profile_data == null:
		return
	if not profile_data.profile_discovered_cards.has(card_id):
		profile_data.profile_discovered_cards[card_id] = true
		
		# Time-based debounce: wait 3 seconds before saving to disk
		# If another card is discovered within 3s, the timer resets
		_profile_save_timer = 3.0
