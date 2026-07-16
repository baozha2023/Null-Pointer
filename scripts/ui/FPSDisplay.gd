## Displays the current frame rate at a fixed refresh interval.
extends Label

const REFRESH_INTERVAL_SECONDS: float = 2.0

var _elapsed_since_refresh: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = Global.user_settings_data.settings_display_fps
	if visible:
		_refresh_fps()

func _process(delta: float) -> void:
	var display_fps: bool = Global.user_settings_data.settings_display_fps
	if display_fps != visible:
		visible = display_fps
		_elapsed_since_refresh = 0.0
		if visible:
			_refresh_fps()

	if not visible:
		return

	_elapsed_since_refresh += delta
	if _elapsed_since_refresh < REFRESH_INTERVAL_SECONDS:
		return

	_elapsed_since_refresh = fmod(_elapsed_since_refresh, REFRESH_INTERVAL_SECONDS)
	_refresh_fps()

func _refresh_fps() -> void:
	text = "FPS: %d" % roundi(Engine.get_frames_per_second())
