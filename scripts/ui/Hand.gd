## UI component that serves as a container for Card objects and provides card playing interface.
## See HandManager for globally accessible interface.
extends Control

class_name Hand

# Controls the movement speed (time) of cards, making them tween faster or slower around the hand
const CARD_TWEEN_TIME: float = 0.2
const CARD_CANCEL_TWEEN_TIME: float = 0.18
const CARD_DRAG_THRESHOLD: float = 12.0
const MOUSE_POINTER_ID: int = -1

enum CARD_INTERACTION_STATES {
	IDLE,
	PRESSING,
	DRAGGING,
	SELECTED,
	COMMITTING,
}

## During hand related card pick actions, invalid cards will appear transparent.
const INVALID_CARD_ALPHA: float = 0.3

var targeting_arrow: TargetingArrow = null

# General Nodes
@onready var player: BaseCombatant = $%Player
@onready var combat: Combat = get_parent() as Combat
@onready var battlefield: Control = %Battlefield
@onready var card_container: Control = %CardContainer
@onready var consumables: Consumables = %Consumables

# Card Picking
@onready var card_picking: Control = $%CardPicking
@onready var card_picking_label: Label = $%CardPicking/CardPickLabel
@onready var confirm_pick_button: Button = $%CardPicking/ConfirmPickButton

var current_card_pick_action: ActionBasePickCards = null # an action currently requesting cards from the player to select. If null clicking cards plays them

# Targeting
@onready var background_button: TextureButton = $%BackgroundButton
@onready var select_target_label: Label = $%SelectTargetLabel
var interaction_state: CARD_INTERACTION_STATES = CARD_INTERACTION_STATES.IDLE
var active_card: Card = null
var active_pointer_id: int = MOUSE_POINTER_ID
var active_pointer_is_touch: bool = false
var pointer_press_position: Vector2 = Vector2.ZERO
var active_pointer_position: Vector2 = Vector2.ZERO
var card_grab_offset: Vector2 = Vector2.ZERO
var current_target: Enemy = null
var hovered_card: Card = null

# Mapping
## Maps a CardData object to the actual Card represented by it in hand.
## This is usually mapped in create_cards_in_hand() and unmapped in HandManager.move_card_to_limbo()
var card_data_to_hand_card: Dictionary[CardData, Card] = { }
var card_transform_tweens: Dictionary[Card, Tween] = {}

# Card Positions and Rotations
## Curve controlling card index in hand to its rotation
@export var hand_card_rotation_curve: Curve = preload("res://misc/curves/hand_rotation_curve.tres")
const HAND_CARD_ROTATION_CURVE_MULTIPLIER: float = 6.0 # multiplies the curve sampling

## Curve controlling card index in hand to its y offset
@export var hand_card_y_offset_curve: Curve = preload("res://misc/curves/hand_y_curve.tres")
const HAND_CARD_Y_OFFSET_CURVE_MULTIPLIER: float = -20.0 # multiplies the curve sampling

const CARD_WIDTH: float = 188.0 # how big the Card asset is. NOTE: Update this if you update Card's size at all
const CARD_SEPARATION_WIDTH: float = CARD_WIDTH * .75 # how far apart each card should be from one another. Generally between .5 to 1X the card width

const MIDDLE_OFFSET: float = CARD_WIDTH / 2
var middle: float = 0.0

# y offsets for when the player hovers over a card
const CARD_UNHOVERED_HEIGHT = 0.0
const CARD_HOVERED_HEIGHT = -50

const CARD_PICK_POSITIONS: Array = [
	[0.0],
	[-0.5, 0.5],
	[-1, 0.0, 1],
	[-1.5, -0.75, 0.75, 1.5],
	[-1.5, -0.75, 0.0, 0.75, 1.5],
	[-2.25, -1.5, -0.75, 0.75, 1.5, 2.25],
	[-2.25, -1.5, -0.75, 0.0, 0.75, 1.5, 2.25],
	[-2.75, -2.25, -1.5, -0.75, 0.75, 1.5, 2.25, 2.75],
	[-2.75, -2.25, -1.5, -0.75, 0.0, 0.75, 1.5, 2.25, 2.75],
	[-3.25, -2.75, -2.25, -1.5, -0.75, 0.75, 1.5, 2.25, 2.75, 3.25],
]


func _ready():
	HandManager.hand = self
	_recalculate_hand_metrics()
	resized.connect(_recalculate_hand_metrics)

	Signals.combat_started.connect(_on_combat_started)
	Signals.combat_ended.connect(_on_combat_ended)
	Signals.run_ended.connect(_on_run_ended)
	Signals.player_killed.connect(_on_player_killed)

	Signals.card_pick_requested.connect(_on_card_pick_requested)
	Signals.card_pick_confirmed.connect(_on_card_pick_confirmed)

	Signals.enemy_clicked.connect(_on_enemy_clicked)
	Signals.enemy_hovered.connect(_on_enemy_hovered)
	CombatPresentation.blocking_started.connect(_on_blocking_presentation_started)

	confirm_pick_button.button_up.connect(_on_confirm_pick_button_up)

	background_button.button_up.connect(_on_background_button_up)

func _recalculate_hand_metrics() -> void:
	middle = (size.x / 2.0) - MIDDLE_OFFSET
	if is_node_ready():
		tween_hand()


func _process(_delta: float) -> void:
	if interaction_state == CARD_INTERACTION_STATES.IDLE:
		if _is_current_interaction_locked():
			_clear_managed_hand_hover()
		else:
			_update_managed_hand_hover(get_global_mouse_position())
		return
	if _is_current_interaction_locked():
		cancel_card_interaction()
		return
	if not is_instance_valid(active_card) or not HandManager.player_hand.has(active_card.card_data):
		cancel_card_interaction()
		return
	if is_instance_valid(current_target) and not current_target.is_alive():
		if interaction_state == CARD_INTERACTION_STATES.DRAGGING and active_card.card_data.card_requires_target:
			_set_current_target(_get_drag_target(active_pointer_position))
		else:
			_set_current_target(null)


func _input(event: InputEvent) -> void:
	if interaction_state == CARD_INTERACTION_STATES.IDLE:
		return

	if event.is_action_pressed("ui_cancel") or (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_RIGHT
		and event.pressed
	):
		cancel_card_interaction()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			if interaction_state in [CARD_INTERACTION_STATES.PRESSING, CARD_INTERACTION_STATES.DRAGGING]:
				if not active_pointer_is_touch:
					_finish_pointer_interaction(mouse_event.global_position)
			elif interaction_state == CARD_INTERACTION_STATES.SELECTED:
				_handle_selected_release(mouse_event.global_position)
		return

	if event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event
		if mouse_motion.device == InputEvent.DEVICE_ID_EMULATION:
			return
		if not active_pointer_is_touch and interaction_state in [CARD_INTERACTION_STATES.PRESSING, CARD_INTERACTION_STATES.DRAGGING]:
			_update_pointer_interaction(mouse_motion.global_position)
		return

	if event is InputEventScreenDrag:
		var screen_drag: InputEventScreenDrag = event
		if active_pointer_is_touch and screen_drag.index == active_pointer_id:
			_update_pointer_interaction(screen_drag.position)
		return

	if event is InputEventScreenTouch:
		var screen_touch: InputEventScreenTouch = event
		if screen_touch.pressed:
			return
		if interaction_state in [CARD_INTERACTION_STATES.PRESSING, CARD_INTERACTION_STATES.DRAGGING]:
			if active_pointer_is_touch and screen_touch.index == active_pointer_id:
				_finish_pointer_interaction(screen_touch.position)
		elif interaction_state == CARD_INTERACTION_STATES.SELECTED:
			_handle_selected_release(screen_touch.position)


## Recalculates the transforms of Card objects in hand and tweens them to their new positions.
func tween_hand(duration: float = CARD_TWEEN_TIME) -> void:
	var cards_in_hand: Array[Card] = get_player_hand_cards()

	### Figure out the number of cards in hand for figuring out offsets. Picking cards will adjust this number
	var hand_card_count: int = len(cards_in_hand)
	var picked_card_count: int = 0
	if current_card_pick_action != null:
		picked_card_count = len(current_card_pick_action.picked_cards)
		hand_card_count -= picked_card_count

	### Calculate dimensions of all the cards in player hand and a modified card separation value
	var all_cards_width := CARD_SEPARATION_WIDTH * hand_card_count
	var card_x_separation: float = CARD_SEPARATION_WIDTH

	# throttle separation width of cards if it begins to exceed the size of the Hand container
	var hand_width: float = size.x
	if all_cards_width > hand_width:
		card_x_separation *= (size.x / all_cards_width) # make the separation a proportion of the exceeded size and the size of the Hand container

	### Recalculate new positions/rotations for each card and tween them
	var hand_index: int = 0 # counter for number of cards in hand
	var pick_index: int = 0 # counter for number of cards picked
	var z_index_counter: int = 0

	for card_data: CardData in HandManager.player_hand:
		var card: Card = card_data_to_hand_card.get(card_data)
		if card == null:
			breakpoint
			DebugLogger.log_error("Card missing from Hand")
			continue

		# values of rotation and position after calculations
		var new_position: Vector2 = Vector2()
		var new_rot: float = 0.0

		# figure out if the card is in hand or picked
		var is_card_in_hand: bool = true
		if current_card_pick_action != null:
			if current_card_pick_action.picked_cards.has(card_data):
				is_card_in_hand = false

		# calculate new transforms
		if is_card_in_hand:
			card.z_index = z_index_counter
			z_index_counter += 1

			if hand_card_count == 1:
				# a single card in hand is made to be in middle with an offset, looks weird otherwise
				new_rot = 0
				new_position = Vector2(middle + (CARD_WIDTH / 2), 0)
			else:
				# rotation
				new_rot = 0
				var rotation_multiplier: float = hand_card_rotation_curve.sample(1.0 / (hand_card_count - 1) * hand_index)
				new_rot = HAND_CARD_ROTATION_CURVE_MULTIPLIER * rotation_multiplier
				# y position
				var card_y_offset: float = hand_card_y_offset_curve.sample(1.0 / (hand_card_count - 1) * hand_index)
				card_y_offset *= HAND_CARD_Y_OFFSET_CURVE_MULTIPLIER
				# x position
				var card_index_offset: float = float(hand_index) - (float(hand_card_count) / 2.0) + 1.0
				var card_x_offset: float = middle + (card_x_separation * card_index_offset)
				# final position
				new_position = Vector2(card_x_offset, card_y_offset)

			hand_index += 1
		else:
			# card not in hand
			var picking_center: Vector2 = card_container.to_local(card_picking.get_global_rect().get_center())
			new_position = Vector2(
				picking_center.x - MIDDLE_OFFSET + CARD_SEPARATION_WIDTH * CARD_PICK_POSITIONS[picked_card_count - 1][pick_index],
				picking_center.y - card.size.y * 0.5
			)
			new_rot = 0
			pick_index += 1

		if card == active_card and interaction_state == CARD_INTERACTION_STATES.DRAGGING:
			continue

		# interpolate card to new position and rotation
		_kill_card_transform_tween(card)
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(card.pivot, "position", new_position, duration)
		tween.tween_property(card.pivot, "rotation_degrees", new_rot, duration)
		card_transform_tweens[card] = tween


func _kill_card_transform_tween(card: Card) -> void:
	var tween: Tween = card_transform_tweens.get(card)
	if tween != null and tween.is_valid():
		tween.kill()
	card_transform_tweens.erase(card)


func update_hand_card_hover(hovered_card: Card = null) -> void:
	var z_index_counter: int = 0
	for card_data: CardData in HandManager.player_hand:
		var card_in_hand: Card = card_data_to_hand_card.get(card_data)
		if card_in_hand == null:
			continue
		if card_in_hand == active_card and interaction_state == CARD_INTERACTION_STATES.DRAGGING:
			card_in_hand.z_index = 100
			continue

		if hovered_card == card_in_hand or (
			interaction_state == CARD_INTERACTION_STATES.SELECTED and active_card == card_in_hand
		):
			# hovered card
			card_in_hand.position.y = CARD_HOVERED_HEIGHT
			card_in_hand.z_index = 50
		else:
			# unhovered cards
			card_in_hand.position.y = CARD_UNHOVERED_HEIGHT
			card_in_hand.z_index = z_index_counter
			z_index_counter += 1


func _update_managed_hand_hover(pointer_global_position: Vector2) -> void:
	var next_hovered_card: Card = _get_hovered_hand_card(pointer_global_position)
	if next_hovered_card == hovered_card:
		return
	if is_instance_valid(hovered_card):
		hovered_card.set_managed_hand_hover(false)
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
	hovered_card = next_hovered_card
	if is_instance_valid(hovered_card):
		hovered_card.set_managed_hand_hover(true)
	update_hand_card_hover(hovered_card)


func _clear_managed_hand_hover() -> void:
	if not is_instance_valid(hovered_card):
		hovered_card = null
		return
	hovered_card.set_managed_hand_hover(false)
	hovered_card = null
	if HandManager.tooltip != null:
		HandManager.tooltip.hide_tooltip()
	update_hand_card_hover()


func _get_hovered_hand_card(pointer_global_position: Vector2) -> Card:
	var closest_card: Card = null
	var closest_horizontal_distance: float = INF
	for card: Card in get_player_hand_cards():
		if not card.visible or not card.contains_global_point(pointer_global_position):
			continue
		# Card centers do not move horizontally when raised. The nearest center gives
		# overlapping fan segments one deterministic owner at their boundary.
		var horizontal_distance: float = absf(pointer_global_position.x - card.pivot.global_position.x)
		if horizontal_distance < closest_horizontal_distance:
			closest_horizontal_distance = horizontal_distance
			closest_card = card
	return closest_card


func _on_hand_pointer_pressed(card: Card, pointer_global_position: Vector2, pointer_id: int, is_touch: bool) -> void:
	if interaction_state == CARD_INTERACTION_STATES.COMMITTING:
		return
	if interaction_state == CARD_INTERACTION_STATES.SELECTED:
		if card == active_card:
			cancel_card_interaction()
			return
		cancel_card_interaction()
	elif interaction_state != CARD_INTERACTION_STATES.IDLE:
		return

	if current_card_pick_action == null:
		if HandManager.is_manual_combat_input_locked():
			return
		if _is_card_queued(card.card_data):
			return
		if not _can_begin_card_interaction(card):
			return
		if consumables != null and consumables.consumable_target_requested:
			consumables.cancel_target_request()

	interaction_state = CARD_INTERACTION_STATES.PRESSING
	active_card = card
	if is_instance_valid(hovered_card):
		hovered_card.set_managed_hand_hover(false)
	hovered_card = null
	active_card.begin_hand_interaction()
	active_pointer_id = pointer_id
	active_pointer_is_touch = is_touch
	pointer_press_position = pointer_global_position
	active_pointer_position = pointer_global_position
	card_grab_offset = card.pivot.global_position - pointer_global_position
	_set_current_target(null)


func _update_pointer_interaction(pointer_global_position: Vector2) -> void:
	if not is_instance_valid(active_card):
		cancel_card_interaction()
		return
	if current_card_pick_action != null:
		return
	active_pointer_position = pointer_global_position

	if interaction_state == CARD_INTERACTION_STATES.PRESSING:
		if pointer_press_position.distance_to(pointer_global_position) < CARD_DRAG_THRESHOLD:
			return
		interaction_state = CARD_INTERACTION_STATES.DRAGGING
		_kill_card_transform_tween(active_card)
		active_card.begin_hand_drag()
		if active_card.card_data.card_requires_target:
			_prompt_target(active_card)

	if interaction_state != CARD_INTERACTION_STATES.DRAGGING:
		return
	active_card.update_hand_drag_position(pointer_global_position, card_grab_offset)
	if active_card.card_data.card_requires_target:
		if is_instance_valid(targeting_arrow):
			if active_pointer_is_touch:
				targeting_arrow.set_pointer_position(pointer_global_position)
			else:
				targeting_arrow.clear_pointer_position()
		_set_current_target(_get_drag_target(pointer_global_position))
	else:
		active_card.set_card_play_ready_glow(_is_valid_non_target_release(pointer_global_position))


func _finish_pointer_interaction(pointer_global_position: Vector2) -> void:
	if current_card_pick_action != null:
		var picked_card: Card = active_card
		_clear_card_interaction(false)
		if is_instance_valid(picked_card):
			attempt_pick_card(picked_card)
		return

	if interaction_state == CARD_INTERACTION_STATES.PRESSING:
		_select_active_card()
		return
	if interaction_state != CARD_INTERACTION_STATES.DRAGGING:
		return

	if active_card.card_data.card_requires_target:
		var release_target: Enemy = _get_drag_target(pointer_global_position)
		if release_target != null and _try_commit_card(active_card, release_target):
			return
	elif _is_valid_non_target_release(pointer_global_position):
		if _try_commit_card(active_card, null):
			return
	cancel_card_interaction()


func _select_active_card() -> void:
	if not is_instance_valid(active_card):
		cancel_card_interaction()
		return
	interaction_state = CARD_INTERACTION_STATES.SELECTED
	active_card.reset_hand_interaction_visual()
	update_hand_card_hover(active_card)
	if active_card.card_data.card_requires_target:
		_prompt_target(active_card)
	else:
		_unprompt_target()


func _handle_selected_release(pointer_global_position: Vector2) -> void:
	if not is_instance_valid(active_card):
		cancel_card_interaction()
		return
	if active_card.card_data.card_requires_target:
		var release_target: Enemy = _get_alive_enemy_at(pointer_global_position)
		if release_target != null and _try_commit_card(active_card, release_target):
			return
	elif _is_valid_non_target_release(pointer_global_position):
		if _try_commit_card(active_card, null):
			return
	cancel_card_interaction()


func _try_commit_card(card: Card, target: Enemy) -> bool:
	if HandManager.is_manual_combat_input_locked() or not is_instance_valid(card):
		return false
	if not HandManager.player_hand.has(card.card_data):
		return false
	if card_data_to_hand_card.get(card.card_data) != card:
		return false
	if _is_card_queued(card.card_data):
		return false
	if card.card_data.card_requires_target and (target == null or not target.is_alive()):
		return false
	if not card.can_play_card(target, true):
		return false

	interaction_state = CARD_INTERACTION_STATES.COMMITTING
	var card_data: CardData = card.card_data
	var card_play_request: CardPlayRequest = HandManager.create_card_play_request(card_data, target, true, true)
	card_play_request.card_destination_pile = card_data.card_play_destination
	card_play_request.card_destination_strategy = card_data.card_play_destination_strategy
	_clear_card_interaction(false)
	HandManager.add_card_to_play_queue(card_play_request, true, false)
	return true


func _is_card_queued(card_data: CardData) -> bool:
	for card_play_request: CardPlayRequest in HandManager.card_play_queue:
		if card_play_request.card_data == card_data:
			return true
	return false


func _can_begin_card_interaction(card: Card) -> bool:
	if not card.card_data.card_requires_target:
		return card.can_play_card(null, true)
	var enemies: Array[Enemy] = Global.get_alive_enemies_in_formation_order()
	for enemy: Enemy in enemies:
		if card.can_play_card(enemy, false):
			return true
	# Reuse the normal validation/interceptor path for the player-facing failure.
	if not enemies.is_empty():
		card.can_play_card(enemies.front(), true)
	return false


func cancel_card_interaction() -> void:
	if interaction_state == CARD_INTERACTION_STATES.IDLE:
		return
	_clear_card_interaction(true)


func _is_current_interaction_locked() -> bool:
	return current_card_pick_action == null and HandManager.is_manual_combat_input_locked()


func _on_blocking_presentation_started(_source: Node) -> void:
	if current_card_pick_action == null and interaction_state != CARD_INTERACTION_STATES.IDLE:
		cancel_card_interaction()
	if current_card_pick_action == null:
		_clear_managed_hand_hover()


func _clear_card_interaction(restore_layout: bool) -> void:
	var card_to_restore: Card = active_card
	_set_current_target(null)
	_unprompt_target()
	if is_instance_valid(card_to_restore):
		card_to_restore.reset_hand_interaction_visual()
	interaction_state = CARD_INTERACTION_STATES.IDLE
	active_card = null
	active_pointer_id = MOUSE_POINTER_ID
	active_pointer_is_touch = false
	pointer_press_position = Vector2.ZERO
	active_pointer_position = Vector2.ZERO
	card_grab_offset = Vector2.ZERO
	update_hand_card_hover()
	if restore_layout:
		tween_hand(CARD_CANCEL_TWEEN_TIME)


### Targeting


func _on_background_button_up():
	if interaction_state == CARD_INTERACTION_STATES.SELECTED:
		cancel_card_interaction()


func _on_enemy_clicked(enemy: Enemy):
	if interaction_state == CARD_INTERACTION_STATES.SELECTED and is_instance_valid(active_card):
		if active_card.card_data.card_requires_target:
			if not _try_commit_card(active_card, enemy):
				cancel_card_interaction()


func _on_enemy_hovered(enemy: Enemy):
	if interaction_state in [CARD_INTERACTION_STATES.DRAGGING, CARD_INTERACTION_STATES.SELECTED]:
		if is_instance_valid(active_card) and active_card.card_data.card_requires_target:
			if not active_pointer_is_touch:
				_set_current_target(enemy)


func _set_current_target(enemy: Enemy) -> void:
	if enemy != null and not enemy.is_alive():
		enemy = null
	if current_target == enemy:
		return
	current_target = enemy
	if is_instance_valid(active_card) and active_card.card_data.card_requires_target:
		active_card.update_card_display(current_target)
	if is_instance_valid(targeting_arrow) and targeting_arrow.visible:
		targeting_arrow.target_enemy = current_target


func _get_alive_enemy_at(pointer_global_position: Vector2) -> Enemy:
	var enemies_by_render_priority: Array[Enemy] = Global.get_alive_enemies_in_formation_order()
	enemies_by_render_priority.sort_custom(func(a: Enemy, b: Enemy) -> bool:
		return a.z_index > b.z_index
	)
	for enemy: Enemy in enemies_by_render_priority:
		if enemy.contains_global_point(pointer_global_position):
			return enemy
	return null


func _get_drag_target(pointer_global_position: Vector2) -> Enemy:
	var directly_pointed_enemy: Enemy = _get_alive_enemy_at(pointer_global_position)
	if directly_pointed_enemy != null:
		return directly_pointed_enemy
	if not battlefield.get_global_rect().has_point(pointer_global_position):
		return null
	return _get_nearest_alive_enemy(active_card.pivot.global_position)


func _get_nearest_alive_enemy(origin_global_position: Vector2) -> Enemy:
	var nearest_enemy: Enemy = null
	var nearest_distance_squared: float = INF
	for enemy: Enemy in Global.get_alive_enemies_in_formation_order():
		var distance_squared: float = origin_global_position.distance_squared_to(
			enemy.get_target_anchor_global_position()
		)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_enemy = enemy
	return nearest_enemy


func _is_valid_non_target_release(pointer_global_position: Vector2) -> bool:
	return battlefield.get_global_rect().has_point(pointer_global_position)


func _prompt_target(_card: Card):
	select_target_label.visible = true
	
	if not is_instance_valid(targeting_arrow):
		targeting_arrow = preload("res://scenes/ui/TargetingArrow.tscn").instantiate()
		add_child(targeting_arrow)
	
	targeting_arrow.visible = true
	targeting_arrow.start_node = _card
	if active_pointer_is_touch:
		targeting_arrow.set_pointer_position(pointer_press_position)
	else:
		targeting_arrow.clear_pointer_position()
	targeting_arrow.target_enemy = current_target

func _unprompt_target():
	select_target_label.visible = false
	if is_instance_valid(targeting_arrow):
		targeting_arrow.visible = false
		targeting_arrow.clear_pointer_position()
		targeting_arrow.clear_target()


#region Card Picking
func update_card_pick_ui():
	# update ui
	confirm_pick_button.disabled = true
	if current_card_pick_action != null:
		var not_enough_cards_picked: bool = not current_card_pick_action.are_enough_cards_picked()
		# 如果最低数量不是必须的，即使没选够也允许确认跳过
		if not current_card_pick_action.get_min_cards_are_required_for_action():
			not_enough_cards_picked = false
		confirm_pick_button.disabled = not_enough_cards_picked
		card_picking_label.text = current_card_pick_action.get_card_pick_text()


## User selected a card while a pick request is made.
## The card will be picked or unpicked.
func attempt_pick_card(card: Card):
	if current_card_pick_action != null:
		# check if card already picked or not
		if current_card_pick_action.picked_cards.has(card.card_data):
			# card already picked; unpick card
			current_card_pick_action.picked_cards.erase(card.card_data)

		else:
			# card not already picked; try to pick card
			if current_card_pick_action.is_card_pickable(card.card_data, false):
				var picked_card_amount: int = len(current_card_pick_action.picked_cards)
				var max_card_amount: int = min(current_card_pick_action.get_card_pick_max_amount(), HandManager.PLAYER_DEFAULT_HAND_CARD_COUNT_MAX)
				if picked_card_amount < max_card_amount:
					# pick the card
					current_card_pick_action.picked_cards.append(card.card_data)
				elif max_card_amount == 1:
					# if max 1 card, it will swap them out
					current_card_pick_action.picked_cards.clear()
					current_card_pick_action.picked_cards.append(card.card_data)

		update_card_pick_ui()
		tween_hand()


func unpick_card(card: Card):
	if current_card_pick_action != null:
		current_card_pick_action.picked_cards.erase(card)


func _on_confirm_pick_button_up():
	# user has confirmed the selected cards
	Signals.card_pick_confirmed.emit()
	tween_hand()


func _on_card_pick_requested(card_selection_action: ActionBasePickCards):
	if card_selection_action.get_card_pick_type() == HandManager.HAND_PILE:
		cancel_card_interaction()
		card_picking.visible = true
		current_card_pick_action = card_selection_action
		update_card_pick_ui()
		set_hand_invalid_card_pick_visibility(true)


func _on_card_pick_confirmed():
	card_picking.visible = false
	current_card_pick_action = null
	set_hand_invalid_card_pick_visibility(true)


# used for hand card picking. All invalid cards will be temporarily hidden or transparent based on the requested action
func set_hand_invalid_card_pick_visibility(invalid_cards_visible: bool) -> void:
	var invisble_alpha: float = INVALID_CARD_ALPHA
	if not invalid_cards_visible:
		invisble_alpha = 0.0

	for card: Card in card_data_to_hand_card.values():
		card.modulate.a = 1.0
		card.visible = true
		if current_card_pick_action != null:
			if not current_card_pick_action.is_card_pickable(card.card_data):
				card.visible = invalid_cards_visible
				card.modulate.a = invisble_alpha
#endregion

#region Card Management

## Factory method for making Card ui components.
## Automatically registers the card to the hand as well.
func create_cards_in_hand(cards: Array[CardData]) -> Array[Card]:
	var created_cards: Array[Card] = []

	for card_data: CardData in cards:
		# check for duplicates
		if card_data_to_hand_card.has(card_data):
			DebugLogger.log_error("Hand cannot create an existing hand card")
			breakpoint
			continue

		var card: Card = Scenes.CARD.instantiate()
		card_container.add_child(card)
		card.init(card_data, 0, true, true)

		card.hand_pointer_pressed.connect(_on_hand_pointer_pressed)

		card_data_to_hand_card[card_data] = card

		created_cards.append(card)

	return created_cards


## Removes the Card UI elements from the hand
## NOTE: Typeically called from HandManager.
func clear_hand_cards() -> void:
	cancel_card_interaction()
	_unprompt_target()
	_clear_managed_hand_hover()
	for tween: Tween in card_transform_tweens.values():
		if tween != null and tween.is_valid():
			tween.kill()
	card_transform_tweens.clear()
	for child in card_container.get_children():
		child.queue_free()
	card_data_to_hand_card.clear()


func on_manual_combat_input_lock_changed() -> void:
	if current_card_pick_action == null and HandManager.is_manual_combat_input_locked():
		cancel_card_interaction()
		_clear_managed_hand_hover()

#endregion

### Combat/Turns

func _on_combat_started(_event_id: String):
	cancel_card_interaction()
	_unprompt_target()


func _on_combat_ended():
	clear_hand_cards()


func _on_run_ended():
	clear_hand_cards()


func _on_player_killed(_player: Player) -> void:
	cancel_card_interaction()

#region Card Trails
func create_card_trail_from_card(card: Card, card_destination_pile: String, is_combat: bool) -> void:
	var starting_position: Vector2 = card.pivot.global_position # center of card
	var destination_ui_element: Control = HandManager.card_destination_to_ui_elements.get(card_destination_pile, null)
	if destination_ui_element == null:
		# DebugLogger.log_error("No ui element mapped to \"{0}\" found for CardTrail destination".format([card_destination_pile]))
		return
	var destination_position: Vector2 = destination_ui_element.global_position + (destination_ui_element.size / 2)

	var card_trail_color_id: String = card.card_data.card_color_id
	var card_trail_color: Color = Color.WHITE
	if card_trail_color_id != "":
		var color_data: ColorData = Global.get_color_data(card_trail_color_id)
		card_trail_color = color_data.color

	# create card trail
	var card_trail: CardTrail = Scenes.CARD_TRAIL.instantiate()
	add_child(card_trail)

	card_trail.init(
		starting_position,
		destination_position,
		card_trail_color,
		destination_ui_element,
		is_combat,
	)
#endregion
#region Helpers

## Gets ui cards in player hand.
## Maintains ordering of hand.
func get_player_hand_cards() -> Array[Card]:
	var hand_cards: Array[Card] = []
	for card_data: CardData in HandManager.player_hand:
		if card_data_to_hand_card.has(card_data):
			var card: Card = card_data_to_hand_card[card_data]
			hand_cards.append(card)
	return hand_cards


func update_hand_card_display() -> void:
	# forces updates of all cards in player's hand
	for cd in card_data_to_hand_card.values():
		var card: Card = cd # typecast iterator
		card.update_card_display()
#endregion
