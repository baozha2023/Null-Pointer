## Singleton maintaining actions taken and registered interceptors for each combatant.
## See: BaseAction, BaseActionInterceptor, ActionInterceptorProcessor, and ActionGenerator
extends Node

@onready var action_timer: Timer = Timer.new()

# actions
var action_stack: Array[Array] = []	# stack of queues of BaseActions
var current_action_queue: Array[BaseAction] = []
var current_action: BaseAction = null # the current action being invoked
var actions_being_performed: bool = false	# flag to prevent multiple actions being performed simultaneously and check for blocking

# action interceptors
# combatant -> interceptor id -> source key -> true
var _registered_action_interceptor_sources: Dictionary = {}

# signals
signal actions_ended	# all actions completed, typically signalling the end of an enemy attack or card play

func _ready():
	Signals.combat_ended.connect(_on_combat_ended)
	Signals.player_killed.connect(_on_player_killed)
	Signals.run_ended.connect(_on_run_ended)
	
	# create and configure a pausable timer
	add_child(action_timer)
	action_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	action_timer.one_shot = true
	action_timer.name = "ActionTimer"

### Actions

func add_action(action: BaseAction, enqueue: bool = false, front_of_queue: bool = false):
	add_actions([action], enqueue, front_of_queue)

## Adds actions to either the top of the stack, or the end of the current queue if enque = true.
## if front_of_queue = true it will place the actions in front of the current queue, effectively always making them
## the next action to take place.
func add_actions(actions: Array[BaseAction], enqueue: bool = false, front_of_queue: bool = false):
	if enqueue:
		# adding to queue
		if len(action_stack) == 0:
			if actions_being_performed:
				# actions already being performed
				# adds actions to the current queue
				if front_of_queue:
					current_action_queue = actions + current_action_queue
				else:
					current_action_queue += actions
			else:
				# actions not being performed
				# add the actions as a queue, the push onto stack so it can be popped off in _perform_actions()
				action_stack.append(actions)
		else:
			if front_of_queue:
				current_action_queue = actions + current_action_queue
			else:
				current_action_queue += actions
	else:
		# adding to stack
		# adds each action to top of stack as their own queue
		for action in actions:
			action_stack += [[action]]
	
	if len(actions) > 0:	# automatically perform the actions when they're added
		if not actions_being_performed:	# check to prevent multiple automatic calls of this method
			_perform_actions()

func _perform_actions() -> void:	
	# performs all actions on the action stack
	actions_being_performed = true
	while len(action_stack) > 0:
		# pop the next queue from the stack
		var action_queue = action_stack.pop_back()
		
		# assign popped queue as current queue
		current_action_queue = []
		current_action_queue.assign(action_queue) # godot typed array shennanigans; re-adding elements to typed array to preserve type integrity
		
		# perform all actions in the queue until empty
		while len(current_action_queue) > 0:
			current_action = current_action_queue.pop_front()
			# skip short circuited actions
			if current_action.is_action_short_circuited():
				if not Global.are_remaining_enemies():
					continue
			# perform action
			current_action.perform_action()
			# wait for async actions to finish
			if current_action.is_async_action():
				await current_action.action_async_finished
			# wait for action delay if one exists
			if current_action.time_delay > 0.0 and !current_action.is_instant_action():
				action_timer.start(current_action.time_delay)
				await action_timer.timeout
				# await get_tree().create_timer(current_action.time_delay).timeout
			else:
				await get_tree().process_frame
			
			current_action = null
	
	actions_being_performed = false
	actions_ended.emit()

## Removes the current async action. Will only remove short circuited actions unless force_end = true.
func _clear_current_async_action(force_end: bool = false) -> void:
	if current_action != null:
		if current_action is BaseAsyncAction:
			if current_action.async_awaiting:
				if current_action.is_action_short_circuited() or force_end:
					current_action.force_action_end() # force the action to stop awaiting something
					current_action.action_async_finished.emit() # force the action to emit a finished signal just in case
					current_action = null

func clear_all_actions() -> void:
	_clear_current_async_action(true)
	
	action_stack.clear()
	current_action_queue.clear()
	
	if actions_being_performed:
		actions_being_performed = false
		actions_ended.emit()

### Action Interception

func register_action_interceptor(base_combatant: BaseCombatant, action_interceptor_object_id: String, source_key: String) -> void:
	if base_combatant == null or action_interceptor_object_id == "" or source_key == "":
		DebugLogger.log_error("ActionHandler.register_action_interceptor(): combatant, interceptor id, and source key are required")
		return

	var combatant_sources: Dictionary = _registered_action_interceptor_sources.get(base_combatant, {})
	var interceptor_sources: Dictionary = combatant_sources.get(action_interceptor_object_id, {})
	interceptor_sources[source_key] = true
	combatant_sources[action_interceptor_object_id] = interceptor_sources
	_registered_action_interceptor_sources[base_combatant] = combatant_sources

func unregister_action_interceptor(base_combatant: BaseCombatant, action_interceptor_object_id: String, source_key: String) -> void:
	var combatant_sources: Dictionary = _registered_action_interceptor_sources.get(base_combatant, {})
	if not combatant_sources.has(action_interceptor_object_id):
		return

	var interceptor_sources: Dictionary = combatant_sources[action_interceptor_object_id]
	interceptor_sources.erase(source_key)
	if interceptor_sources.is_empty():
		combatant_sources.erase(action_interceptor_object_id)
	else:
		combatant_sources[action_interceptor_object_id] = interceptor_sources

	if combatant_sources.is_empty():
		_registered_action_interceptor_sources.erase(base_combatant)
	else:
		_registered_action_interceptor_sources[base_combatant] = combatant_sources

func get_registered_action_interceptor_ids(base_combatant: BaseCombatant) -> Array[String]:
	var interceptor_ids: Array[String] = []
	if base_combatant == null:
		return interceptor_ids
	var combatant_sources: Dictionary = _registered_action_interceptor_sources.get(base_combatant, {})
	interceptor_ids.assign(combatant_sources.keys())
	return interceptor_ids

func clear_all_action_interceptors() -> void:
	_registered_action_interceptor_sources.clear()


func _on_combat_ended():
	_clear_current_async_action()

func _on_player_killed(_player: Player):
	clear_all_actions()

func _on_run_ended():
	clear_all_action_interceptors()
	clear_all_actions()
