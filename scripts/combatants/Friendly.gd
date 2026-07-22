extends BaseCombatant
class_name Friendly

var friendly_data: FriendlyData = null
var _active_visual_state_key: String = ""

func _ready() -> void:
	super._ready()

func init(data: FriendlyData) -> void:
	friendly_data = data
	set_combatant_display_name(friendly_data.friendly_name)
	layered_health_bar.init(friendly_data.friendly_health, friendly_data.friendly_health_max)
	set_block(friendly_data.friendly_block)
	for status_effect_object_id: String in friendly_data.friendly_initial_status_effects:
		var custom_values: Dictionary = friendly_data.friendly_initial_status_custom_values.get(status_effect_object_id, {})
		add_new_status_effect(status_effect_object_id, friendly_data.friendly_initial_status_effects[status_effect_object_id], 0, custom_values)
	_refresh_visual_state()

func get_combat_side() -> int:
	return COMBAT_SIDES.PLAYER

func get_animation_data() -> AnimationData:
	if friendly_data == null or friendly_data.friendly_animation_id.is_empty():
		return null
	return Global.get_animation_data(friendly_data.friendly_animation_id)

func apply_friendly_formation_slot(slot: CombatFormationSlot) -> void:
	apply_formation_slot(slot, friendly_data.friendly_combat_scale)

func set_block(amount: int) -> void:
	friendly_data.friendly_block = maxi(amount, 0)
	block.update_block(friendly_data.friendly_block)

func get_block() -> int:
	return friendly_data.friendly_block

func add_block(amount: int) -> void:
	set_block(friendly_data.friendly_block + amount)
	if amount > 0:
		create_block_fade()
		Signals.combatant_block_added.emit(self)

func add_health(health_amount: int, health_amount_max: int) -> void:
	set_health(friendly_data.friendly_health + health_amount, friendly_data.friendly_health_max + health_amount_max)
	if health_amount > 0:
		create_health_text(health_amount)

func heal_percentage(percent: float) -> void:
	add_health(ceili(float(friendly_data.friendly_health_max) * percent), 0)

func set_health(health_amount: int, health_amount_max: int = friendly_data.friendly_health_max) -> void:
	var was_alive: bool = is_alive()
	var old_health: int = friendly_data.friendly_health
	friendly_data.friendly_health_max = maxi(health_amount_max, 1)
	friendly_data.friendly_health = clampi(health_amount, 0, friendly_data.friendly_health_max)
	update_health_bar(friendly_data.friendly_health < old_health)
	if not was_alive and is_alive():
		add_to_group("friendlies")
		modulate = Color.WHITE
		play_animation(AnimationData.ANIMATION_IDLE)
		Signals.friendly_formation_changed.emit()

func update_health_bar(as_damage: bool = false) -> void:
	if friendly_data == null or layered_health_bar == null:
		return
	if as_damage:
		layered_health_bar.apply_damage(friendly_data.friendly_health, friendly_data.friendly_health_max, status_id_to_status_effects)
	else:
		layered_health_bar.update_health_layers(friendly_data.friendly_health, friendly_data.friendly_health_max, status_id_to_status_effects)

func get_combatant_health() -> int:
	return friendly_data.friendly_health

func get_combatant_health_max() -> int:
	return friendly_data.friendly_health_max

func is_alive() -> bool:
	return friendly_data != null and friendly_data.friendly_health > 0

func damage(raw_damage: int, bypass_block: bool = false) -> Array[int]:
	if raw_damage <= 0 or not is_alive():
		return [0, 0, 0]
	var bypassed_damage: int = raw_damage
	if friendly_data.friendly_block > 0 and not bypass_block:
		var blocked_amount: int = mini(friendly_data.friendly_block, raw_damage)
		friendly_data.friendly_block -= blocked_amount
		bypassed_damage -= blocked_amount
		Signals.combatant_blocked.emit(self, blocked_amount)
		if friendly_data.friendly_block == 0 and blocked_amount > 0:
			Signals.combatant_block_broken.emit(self)
		block.update_block(friendly_data.friendly_block)
	if bypassed_damage <= 0:
		if raw_damage > 0:
			create_block_text()
		return [0, 0, 0]
	var old_health: int = friendly_data.friendly_health
	var overkill_damage: int = maxi(bypassed_damage - old_health, 0)
	var capped_damage: int = bypassed_damage - overkill_damage
	create_damage_text(bypassed_damage)
	friendly_data.friendly_health = maxi(old_health - bypassed_damage, 0)
	Signals.combatant_damaged.emit(self, bypassed_damage, capped_damage, overkill_damage)
	update_health_bar(true)
	if old_health > 0 and friendly_data.friendly_health == 0:
		ActionGenerator.generate_combatant_death(self)
		if is_alive():
			update_health_bar(false)
			return [bypassed_damage, capped_damage, overkill_damage]
		remove_from_group("friendlies")
		modulate = Color(0.45, 0.5, 0.5, 0.75)
		update_incoming_damage_amount(false)
		Signals.friendly_formation_changed.emit()
		var death_actions: Array[BaseAction] = ActionGenerator.create_actions(self, null, [], friendly_data.friendly_actions_on_death, null)
		ActionHandler.add_actions(death_actions)
		if not friendly_data.friendly_can_revive_in_combat:
			queue_free()
	return [bypassed_damage, capped_damage, overkill_damage]

func _on_status_effects_changed() -> void:
	super._on_status_effects_changed()
	if friendly_data != null:
		_refresh_visual_state()

func _refresh_visual_state() -> void:
	# Status-driven still images intentionally override an optional base animation.
	var texture_path: String = ""
	for status_id: String in friendly_data.friendly_visual_state_status_texture_paths:
		if status_id_to_status_effects.has(status_id):
			texture_path = friendly_data.friendly_visual_state_status_texture_paths[status_id]
			break
	if not texture_path.is_empty():
		_apply_static_visual(texture_path)
		return

	var animation_data: AnimationData = get_animation_data()
	if animation_data != null:
		var animation_state_key: String = "animation:" + friendly_data.friendly_animation_id
		if animation_state_key == _active_visual_state_key:
			return
		_active_visual_state_key = animation_state_key
		animated_sprite_2d.sprite_frames = animation_data.animations
		play_animation(AnimationData.ANIMATION_IDLE)
		return

	_apply_static_visual(friendly_data.friendly_texture_path)

func _apply_static_visual(texture_path: String) -> void:
	var visual_state_key: String = "texture:" + texture_path
	if visual_state_key == _active_visual_state_key:
		return
	_active_visual_state_key = visual_state_key
	_rebuild_sprite_frames(texture_path)
	animated_sprite_2d.play(AnimationData.ANIMATION_IDLE)
	_resize_sprite_to_fixed_size()

func _rebuild_sprite_frames(texture_path: String) -> void:
	var texture: Texture2D = FileLoader.load_texture(texture_path)
	if texture == null:
		texture = FileLoader.load_texture("sprites/missing_texture.png")
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for animation_name: StringName in [
		AnimationData.ANIMATION_IDLE,
		AnimationData.ANIMATION_ATTACK,
		AnimationData.ANIMATION_DEATH,
	]:
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.add_frame(animation_name, texture)
	animated_sprite_2d.sprite_frames = frames
