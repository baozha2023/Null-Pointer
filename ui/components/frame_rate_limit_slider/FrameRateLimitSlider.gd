extends HSlider
class_name FrameRateLimitSlider

const FRAME_RATE_LIMITS: Array[int] = [60, 120, 300, 0]

@onready var value_label: Label = $ValueLabel

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	_update_value_label()

func get_frame_rate_limit() -> int:
	return FRAME_RATE_LIMITS[clampi(roundi(value), 0, FRAME_RATE_LIMITS.size() - 1)]

func set_frame_rate_limit_no_signal(frame_rate_limit: int) -> void:
	var frame_rate_limit_index: int = FRAME_RATE_LIMITS.find(frame_rate_limit)
	if frame_rate_limit_index < 0:
		DebugLogger.log_error("FrameRateLimitSlider: Unsupported frame rate limit: {0}".format([frame_rate_limit]))
		frame_rate_limit_index = FRAME_RATE_LIMITS.size() - 1
	set_value_no_signal(frame_rate_limit_index)
	_update_value_label()

func _on_value_changed(_value: float) -> void:
	_update_value_label()

func _update_value_label() -> void:
	var frame_rate_limit: int = get_frame_rate_limit()
	value_label.text = "无上限" if frame_rate_limit == 0 else str(frame_rate_limit)
