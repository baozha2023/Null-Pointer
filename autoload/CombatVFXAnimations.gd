## 战斗特效动画数据管理类
## 管理所有战斗中使用的VFX动画（攻击挥砍、冲击特效等）
class_name CombatVFXAnimations
extends RefCounted

## 注册所有战斗VFX动画到Global
static func register_all() -> void:
	_register_impact_default()
	_register_slash_orange()
	_register_slash_blue()
	_register_slash_green()
	_register_slash_red()
	_register_magic_orange()
	_register_magic_blue()
	_register_magic_green()
	_register_magic_red()

static func _register_impact_default() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_impact_default")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/impact_default/vfx_impact_default_01.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_02.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_03.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_04.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_05.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_06.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_07.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_08.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_09.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_10.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_11.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_12.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_13.png",
			"sprites/animated_effects/impact_default/vfx_impact_default_14.png",
		],
		25,
	)
	Global.register_rod(animation)

static func _register_slash_orange() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_slash_orange")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_01.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_02.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_03.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_04.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_05.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_06.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_07.png",
			"sprites/animated_effects/vfx_slash_orange/vfx_slash_orange_08.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_slash_blue() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_slash_blue")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_01.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_02.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_03.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_04.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_05.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_06.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_07.png",
			"sprites/animated_effects/vfx_slash_blue/vfx_slash_blue_08.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_slash_green() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_slash_green")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_01.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_02.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_03.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_04.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_05.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_06.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_07.png",
			"sprites/animated_effects/vfx_slash_green/vfx_slash_green_08.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_slash_red() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_slash_red")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_01.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_02.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_03.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_04.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_05.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_06.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_07.png",
			"sprites/animated_effects/vfx_slash_red/vfx_slash_red_08.png",
		],25,
	)
	Global.register_rod(animation)



static func _register_magic_orange() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_magic_orange")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_01.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_02.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_03.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_04.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_05.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_06.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_07.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_08.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_09.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_10.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_11.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_12.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_13.png",
			"sprites/animated_effects/vfx_magic_orange/vfx_magic_orange_14.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_magic_blue() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_magic_blue")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_01.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_02.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_03.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_04.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_05.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_06.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_07.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_08.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_09.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_10.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_11.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_12.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_13.png",
			"sprites/animated_effects/vfx_magic_blue/vfx_magic_blue_14.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_magic_green() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_magic_green")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_01.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_02.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_03.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_04.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_05.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_06.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_07.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_08.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_09.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_10.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_11.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_12.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_13.png",
			"sprites/animated_effects/vfx_magic_green/vfx_magic_green_14.png",
		],25,
	)
	Global.register_rod(animation)

static func _register_magic_red() -> void:
	var animation: AnimationData = AnimationData.new("animation_vfx_magic_red")
	animation.add_vfx_animations(
		[
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_01.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_02.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_03.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_04.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_05.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_06.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_07.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_08.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_09.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_10.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_11.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_12.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_13.png",
			"sprites/animated_effects/vfx_magic_red/vfx_magic_red_14.png",
		],25,
	)
	Global.register_rod(animation)
