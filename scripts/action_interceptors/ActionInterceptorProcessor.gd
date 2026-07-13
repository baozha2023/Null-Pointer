## Utility object for processing a chain of interceptors, see: BaseAction.intercept_action().
## Iterates over all interceptors of a given action-parent-target pairing, in order of interceptor priority
## defined by ActionInterceptorData.action_interceptor_priority.
## After the chain is finished, shadowed_action_values will be populated with modified values
## and the processor ultimately accepted/rejected.
## A rejected processsor will be discarded in the final returned result.
extends Node
class_name ActionInterceptorProcessor

var parent_action: BaseAction = null	# the action tied to this processor
var target: BaseCombatant = null	# the sub target to use for interception processing. Can be null

## This will contain any modified values for the parent action after processing has taken place.
## NOTE: Use get_shadowed_action_values() and set_shadowed_action_values() in interceptors
## instead of modifying this directly.
var shadowed_action_values: Dictionary = {}

func _init(_parent_action: BaseAction, _target: BaseCombatant):
	parent_action = _parent_action
	target = _target

## Called via BaseAction.intercept_action().
## iterates over all interceptors, returning if the chain was accepted or rejected for further processing the action
## preview_mode flag is used for things like displaying cards in hand after modifiers or hovering cards over enemies. This tells interceptors to not create actual side effects
func process_interceptor_chain(preview_mode: bool = false, interceptor_scopes: Array[int] = []) -> bool:
	var action_interceptors: Array[BaseActionInterceptor] = _get_action_interceptors_modifying_pair(
		parent_action,
		parent_action.parent_combatant,
		target,
		interceptor_scopes,
	)
	for action_interceptor in action_interceptors:
		var result: int = action_interceptor.process_action_interception(self, preview_mode)
		if result == BaseActionInterceptor.ACTION_ACCEPTENCES.STOPPED:
			break
		if result == BaseActionInterceptor.ACTION_ACCEPTENCES.REJECTED:
			# Preview chains are pure projections and must always return a processor to the UI.
			if preview_mode:
				continue
			return false
	
	return true

## Used by both interceptors during processing, then by the action after processing has taken place.
## this will shadow the parent action's values, allowing for interceptors to "modify" an action's
## values without actually changing them by standing above them in the action value hierarchy.
## First getting the original value, then shadowing with a value that will be continually modified.
func get_shadowed_action_values(key: String, default_value: Variant) -> Variant:
	var custom_action_value_keys: Dictionary = parent_action.values.get("custom_key_names", {})	# allows for having cards/actions use custom key names that convert to regular action key names. Useful for having cards with 2 of the same action but different values
	var key_name: String = custom_action_value_keys.get(key, key)
	if shadowed_action_values.has(key_name):
		return shadowed_action_values[key_name]
	else:
		return parent_action.get_action_value(key, default_value)

## Sets a value for a shadowed action value. Importantly, it will also perform custom_key_names
## conversions.
func set_shadowed_action_values(key: String, value: Variant) -> void:
	var custom_action_value_keys: Dictionary = parent_action.values.get("custom_key_names", {})	# allows for having cards/actions use custom key names that convert to regular action key names. Useful for having cards with 2 of the same action but different values
	var key_name: String = custom_action_value_keys.get(key, key)
	shadowed_action_values[key_name] = value

## Returns block which the intercepted damage action will actually use.
func get_effective_target_block() -> int:
	if target == null:
		return 0
	var bypass_block: bool = get_shadowed_action_values("bypass_block", false)
	if bypass_block:
		return 0
	return max(0, target.get_block())

## Returns the health damage expected after the target's normal block calculation.
func get_incoming_health_damage() -> int:
	var damage: int = get_shadowed_action_values("damage", 0)
	return max(0, damage - get_effective_target_block())

## Writes desired health damage back as pre-block raw damage. This keeps block consumption in the
## combatant's final damage() call and prevents mitigation interceptors from subtracting it twice.
func set_incoming_health_damage(health_damage: int) -> void:
	var raw_damage: int = max(0, health_damage) + get_effective_target_block()
	set_shadowed_action_values("damage", raw_damage)

## Returns a priority-sorted array of all interceptors involving an action, its parent, and its target.
## Both parent and target can be the same, and one or both can be null.
## Additional flags ignore_all_interceptors, ignored_interceptor_ids, and forced_interceptor_ids can
## be provided through the action's values to alter which interceptors are allowed to be populated.
func _get_action_interceptors_modifying_pair(
	action: BaseAction,
	parent_combatant: BaseCombatant,
	target_combatant: BaseCombatant,
	interceptor_scopes: Array[int],
) -> Array[BaseActionInterceptor]:
	var returned_action_interceptors: Array[BaseActionInterceptor] = []
	var interceptor_data_list: Array[ActionInterceptorData] = []
	var selected_interceptor_ids: Dictionary[String, bool] = {}
	var action_script_path: String = action.get_script().resource_path
	
	### Get interceptor flags from action data
	# Use ignore_all_interceptors = true for actions which should always be performed unmodified
	var ignore_all_interceptors: bool = get_shadowed_action_values("ignore_all_interceptors", false)
	if ignore_all_interceptors:
		return []
	
	# InterceptorData IDs for specific interceptors to not use for this action.
	var ignored_interceptor_ids: Array[String] = []
	ignored_interceptor_ids.assign(get_shadowed_action_values("ignored_interceptor_ids", []))
	
	# InterceptorData IDs which bypass registration, but still obey ignore, action path, and scope.
	var forced_interceptor_ids: Array[String] = []
	forced_interceptor_ids.assign(get_shadowed_action_values("forced_interceptor_ids", []))

	### Parent Interceptors
	var parent_action_interceptor_object_ids: Array[String] = ActionHandler.get_registered_action_interceptor_ids(parent_combatant)
	for action_interceptor_object_id in parent_action_interceptor_object_ids:
		if ignored_interceptor_ids.has(action_interceptor_object_id):
			continue
		var action_interceptor_data: ActionInterceptorData = Global.get_action_interceptor_data(action_interceptor_object_id)
		if not _is_interceptor_compatible(action_interceptor_data, action_script_path, interceptor_scopes):
			continue
		if action_interceptor_data.action_interceptor_scope == ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET:
			continue
		interceptor_data_list.append(action_interceptor_data)
		selected_interceptor_ids[action_interceptor_object_id] = true

	### Target Interceptors
	var target_action_interceptor_object_ids: Array[String] = ActionHandler.get_registered_action_interceptor_ids(target_combatant)
	for action_interceptor_object_id in target_action_interceptor_object_ids:
		if ignored_interceptor_ids.has(action_interceptor_object_id):
			continue
		var action_interceptor_data: ActionInterceptorData = Global.get_action_interceptor_data(action_interceptor_object_id)
		if not _is_interceptor_compatible(action_interceptor_data, action_script_path, interceptor_scopes):
			continue
		if action_interceptor_data.action_interceptor_scope != ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET:
			continue
		if not selected_interceptor_ids.has(action_interceptor_object_id):
			interceptor_data_list.append(action_interceptor_data)
			selected_interceptor_ids[action_interceptor_object_id] = true

	### Forced Interceptors
	for forced_interceptor_id: String in forced_interceptor_ids:
		if ignored_interceptor_ids.has(forced_interceptor_id):
			continue
		if selected_interceptor_ids.has(forced_interceptor_id):
			continue
		var action_interceptor_data: ActionInterceptorData = Global.get_action_interceptor_data(forced_interceptor_id)
		if not _is_interceptor_compatible(action_interceptor_data, action_script_path, interceptor_scopes):
			continue
		if action_interceptor_data.action_interceptor_scope == ActionInterceptorData.INTERCEPTOR_SCOPES.TARGET and target_combatant == null:
			continue
		interceptor_data_list.append(action_interceptor_data)
		selected_interceptor_ids[forced_interceptor_id] = true

	### Return
	interceptor_data_list.sort_custom(_sort_action_interceptor_priorities)

	for action_interceptor_data in interceptor_data_list:
		var action_interceptor_asset = load(action_interceptor_data.action_interceptor_script_path)
		var action_interceptor: BaseActionInterceptor = action_interceptor_asset.new()
		returned_action_interceptors.append(action_interceptor)

	return returned_action_interceptors

func _is_interceptor_compatible(
	action_interceptor_data: ActionInterceptorData,
	action_script_path: String,
	interceptor_scopes: Array[int],
) -> bool:
	if action_interceptor_data == null:
		return false
	if not action_interceptor_data.action_intercepted_action_paths.has(action_script_path):
		return false
	if not interceptor_scopes.is_empty() and not interceptor_scopes.has(action_interceptor_data.action_interceptor_scope):
		return false
	return true

func _sort_action_interceptor_priorities(action_interceptor_data_1: ActionInterceptorData, action_interceptor_data_2: ActionInterceptorData) -> bool:
	# custom sort method for sorting the priorities of a given list of interceptors
	if action_interceptor_data_1.action_interceptor_priority == action_interceptor_data_2.action_interceptor_priority:
		return action_interceptor_data_1.object_id > action_interceptor_data_2.object_id
	else:
		return action_interceptor_data_1.action_interceptor_priority > action_interceptor_data_2.action_interceptor_priority
