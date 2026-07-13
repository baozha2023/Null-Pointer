extends Node

const PREFIX: String = "[V27 AUDIT]"
const ROOT_PRIVILEGE_SCRIPT_PATH: String = "res://scripts/actions/interceptors/InterceptorRootPrivilege.gd"
const AUDIT_INTERCEPTOR_ID: String = "interceptor_root_privilege"

var _check_count: int = 0
var _failures: Array[String] = []
var _runtime_failures: Array[String] = []

func _ready() -> void:
	await get_tree().process_frame
	_run_static_checks()
	if not Signals.combat_started.is_connected(_on_combat_started):
		Signals.combat_started.connect(_on_combat_started, CONNECT_ONE_SHOT)

func _run_static_checks() -> void:
	print("%s 开始执行 v2.7 静态审计……" % PREFIX)
	_check_required_card("card_async_execution", 1, CardData.CARD_TYPES.SKILL)
	_check_required_card("card_root_privilege", 3, CardData.CARD_TYPES.POWER)
	_check_required_card("card_ddos_attack", 1, CardData.CARD_TYPES.ATTACK)
	_check_required_card("card_low_level_format", 2, CardData.CARD_TYPES.SKILL)
	_check_required_card("card_memory_out_of_bounds", 1, CardData.CARD_TYPES.ATTACK)

	var delayed_status: StatusEffectData = Global.get_status_effect_data("status_effect_delayed_execution")
	_check(delayed_status != null, "异步执行的延迟状态已注册")
	if delayed_status != null:
		_check_file_path(delayed_status.status_effect_texture_path, "延迟状态贴图")

	var root_status: StatusEffectData = Global.get_status_effect_data("status_effect_root_privilege")
	_check(root_status != null, "Root 提权状态已注册")
	if root_status != null:
		_check(root_status.status_effect_interceptor_ids.has(AUDIT_INTERCEPTOR_ID), "Root 提权状态绑定正确的拦截器")
		_check_file_path(root_status.status_effect_texture_path, "Root 提权状态贴图")

	var root_interceptor: ActionInterceptorData = Global.get_action_interceptor_data(AUDIT_INTERCEPTOR_ID)
	_check(root_interceptor != null, "Root 提权拦截器数据已注册")
	if root_interceptor != null:
		_check_resource_path(root_interceptor.action_interceptor_script_path, "Root 提权拦截器脚本")

	var task_manager: ArtifactData = Global.get_artifact_data("artifact_taskmgr")
	_check(task_manager != null, "任务管理器外设已注册")
	if task_manager != null:
		_check_file_path(task_manager.artifact_texture_path, "任务管理器贴图")
		_check_resource_path(task_manager.artifact_script_path, "任务管理器脚本")
		_check_action_resources(task_manager.artifact_right_click_actions, "任务管理器右键动作")

	_check_root_privilege_formula()
	_check_child_request_isolation()
	_check_cardset_action_sources()

	if _failures.is_empty():
		print("%s STATIC PASS：%d 项检查全部通过。" % [PREFIX, _check_count])
	else:
		push_error("%s STATIC FAIL：%d/%d 项失败：%s" % [PREFIX, _failures.size(), _check_count, "; ".join(_failures)])
	print("%s 请开始一局并进入任意一场战斗，以完成运行时检查。" % PREFIX)

func _check_required_card(card_id: String, expected_cost: int, expected_type: int) -> void:
	var card_data: CardData = Global.get_card_data(card_id)
	_check(card_data != null, "%s 已注册" % card_id)
	if card_data == null:
		return
	_check(card_data.card_energy_cost == expected_cost, "%s 基础费用正确" % card_id)
	_check(card_data.card_type == expected_type, "%s 卡牌类型正确" % card_id)
	_check(card_data.card_name != "", "%s 名称非空" % card_id)
	_check(card_data.card_description != "", "%s 描述非空" % card_id)
	_check_file_path(card_data.card_texture_path, "%s 卡图" % card_id)
	_check_action_resources(card_data.card_play_actions, "%s 出牌动作" % card_id)

func _check_root_privilege_formula() -> void:
	var root_script: Variant = load(ROOT_PRIVILEGE_SCRIPT_PATH)
	_check(root_script != null, "Root 提权公式脚本可加载")
	if root_script == null:
		return
	_check(root_script.calculate_energy_shortfall(3, 3, 3) == 0, "费用 3、支付 3 时不透支")
	_check(root_script.calculate_energy_shortfall(3, 1, 1) == 2, "费用 3、支付 1 时透支 2")
	_check(root_script.calculate_energy_shortfall(3, 0, 0) == 3, "费用 3、支付 0 时透支 3")
	_check(root_script.calculate_energy_shortfall(3, 0, HandManager.CARD_NO_ENERGY_COST) == 0, "无费用生成牌不产生透支")
	_check(root_script.calculate_energy_shortfall(0, 0, 0) == 0, "被高优先级效果降为 0 费时不透支")
	_check(root_script.calculate_overdraft_damage(2, 1, 5) == 10, "Root 提权 1:5 比例伤害正确")
	_check(root_script.calculate_overdraft_damage(2, 2, 5) == 5, "Root 提权 2:5 比例伤害正确")

func _check_child_request_isolation() -> void:
	var request: CardPlayRequest = CardPlayRequest.new()
	request.card_values = {"nested": {"value": 1}}
	var child_request: CardPlayRequest = request.duplicate_for_child_actions()
	child_request.card_values["nested"]["value"] = 2
	_check(request.card_values["nested"]["value"] == 1, "子动作 CardPlayRequest 深拷贝隔离")

func _check_cardset_action_sources() -> void:
	var script_paths: Array[String] = []
	_collect_gd_scripts("res://scripts/actions", script_paths)
	var subclass_count: int = 0
	for script_path: String in script_paths:
		if script_path == get_script().resource_path:
			continue
		var source: String = FileAccess.get_file_as_string(script_path)
		if not source.contains("extends BaseCardsetAction"):
			continue
		subclass_count += 1
		_check(source.contains("_intercept_cardset_action("), "%s 使用统一卡牌集合拦截入口" % script_path)
		_check(not source.contains("_get_picked_cards()"), "%s 使用处理器影子值读取卡牌集合" % script_path)
	_check(subclass_count > 0, "已发现并扫描卡牌集合动作实现")

func _collect_gd_scripts(directory_path: String, output: Array[String]) -> void:
	var directory: DirAccess = DirAccess.open(directory_path)
	if directory == null:
		_check(false, "可扫描目录 %s" % directory_path)
		return
	directory.list_dir_begin()
	var entry_name: String = directory.get_next()
	while entry_name != "":
		if directory.current_is_dir():
			_collect_gd_scripts(directory_path.path_join(entry_name), output)
		elif entry_name.ends_with(".gd"):
			output.append(directory_path.path_join(entry_name))
		entry_name = directory.get_next()
	directory.list_dir_end()

func _check_action_resources(actions: Array[Dictionary], label: String) -> void:
	_check(actions.size() > 0, "%s 非空" % label)
	_check_variant_resource_paths(actions, label)

func _check_variant_resource_paths(value: Variant, label: String) -> void:
	if value is Dictionary:
		for key: Variant in value:
			if key is String and key.begins_with("res://") and key.ends_with(".gd"):
				_check_resource_path(key, "%s：%s" % [label, key])
			_check_variant_resource_paths(value[key], label)
	elif value is Array:
		for child: Variant in value:
			_check_variant_resource_paths(child, label)

func _check_resource_path(resource_path: String, label: String) -> void:
	_check(resource_path != "" and ResourceLoader.exists(resource_path), "%s 存在" % label)

func _check_file_path(file_path: String, label: String) -> void:
	var normalized_path: String = file_path if file_path.begins_with("res://") else "res://" + file_path
	_check(file_path != "" and FileAccess.file_exists(normalized_path), "%s 存在" % label)

func _on_combat_started(_event_id: String) -> void:
	await get_tree().process_frame
	var player: Player = Global.get_player()
	_check_runtime(player != null, "战斗开始后可取得玩家实例")
	if player == null:
		return
	const SOURCE_A: String = "v27_release_audit:a"
	const SOURCE_B: String = "v27_release_audit:b"
	var was_registered: bool = ActionHandler.get_registered_action_interceptor_ids(player).has(AUDIT_INTERCEPTOR_ID)
	ActionHandler.register_action_interceptor(player, AUDIT_INTERCEPTOR_ID, SOURCE_A)
	ActionHandler.register_action_interceptor(player, AUDIT_INTERCEPTOR_ID, SOURCE_B)
	_check_runtime(ActionHandler.get_registered_action_interceptor_ids(player).count(AUDIT_INTERCEPTOR_ID) == 1, "同一拦截器的两个来源只生成一个注册项")
	ActionHandler.unregister_action_interceptor(player, AUDIT_INTERCEPTOR_ID, SOURCE_A)
	_check_runtime(ActionHandler.get_registered_action_interceptor_ids(player).has(AUDIT_INTERCEPTOR_ID), "注销一个来源后拦截器仍保留")
	ActionHandler.unregister_action_interceptor(player, AUDIT_INTERCEPTOR_ID, SOURCE_B)
	_check_runtime(ActionHandler.get_registered_action_interceptor_ids(player).has(AUDIT_INTERCEPTOR_ID) == was_registered, "注销审计来源后恢复原注册状态")
	if _runtime_failures.is_empty():
		print("%s RUNTIME PASS：战斗运行时检查全部通过。" % PREFIX)
	else:
		push_error("%s RUNTIME FAIL：%s" % [PREFIX, "; ".join(_runtime_failures)])

func _check(condition: bool, label: String) -> void:
	_check_count += 1
	if condition:
		print("%s PASS：%s" % [PREFIX, label])
	else:
		_failures.append(label)
		push_error("%s FAIL：%s" % [PREFIX, label])

func _check_runtime(condition: bool, label: String) -> void:
	if condition:
		print("%s RUNTIME PASS：%s" % [PREFIX, label])
	else:
		_runtime_failures.append(label)
		push_error("%s RUNTIME FAIL：%s" % [PREFIX, label])
