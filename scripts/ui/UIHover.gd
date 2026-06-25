## 通用悬停缩放工具。为按钮/控件提供 hover 时的浮动缩放效果。
class_name UIHover
extends RefCounted

const DEFAULT_HOVER_SCALE: float = 1.15
const DEFAULT_DURATION: float = 0.1

## 为控件一次性接入 hover 缩放效果（自动绑定 mouse_entered / mouse_exited 信号）
static func add_hover_scale(ctrl: Control, hover_scale: float = DEFAULT_HOVER_SCALE, duration: float = DEFAULT_DURATION) -> void:
	ctrl.mouse_entered.connect(_on_enter.bind(ctrl, hover_scale, duration))
	ctrl.mouse_exited.connect(_on_exit.bind(ctrl, duration))

## 手动调用：放大
static func scale_up(ctrl: Control, hover_scale: float = DEFAULT_HOVER_SCALE, duration: float = DEFAULT_DURATION) -> void:
	var t := ctrl.create_tween()
	t.tween_property(ctrl, "scale", Vector2(hover_scale, hover_scale), duration)

## 手动调用：恢复
static func scale_down(ctrl: Control, duration: float = DEFAULT_DURATION) -> void:
	var t := ctrl.create_tween()
	t.tween_property(ctrl, "scale", Vector2(1.0, 1.0), duration)


static func _on_enter(ctrl: Control, hover_scale: float, duration: float) -> void:
	scale_up(ctrl, hover_scale, duration)

static func _on_exit(ctrl: Control, duration: float) -> void:
	scale_down(ctrl, duration)
