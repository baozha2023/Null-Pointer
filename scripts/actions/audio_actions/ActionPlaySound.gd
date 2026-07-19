## Plays a sound fx track
extends BaseAction

func perform_action() -> void:
	var action_interceptor_processors: Array[ActionInterceptorProcessor] = _intercept_action([null])
	for action_interceptor_processor: ActionInterceptorProcessor in action_interceptor_processors:
		var audio_paths: Array[String] = []
		audio_paths.assign(action_interceptor_processor.get_shadowed_action_values("audio_path", []))
		if audio_paths.is_empty():
			continue
		var audio_path: String = audio_paths.pick_random()
		var audio_path_is_absolute: bool = action_interceptor_processor.get_shadowed_action_values("audio_path_is_absolute", false)
		var blocks_combat_presentation: bool = action_interceptor_processor.get_shadowed_action_values("blocks_combat_presentation", false)
		var audio: AudioStream = FileLoader.load_audio(audio_path, audio_path_is_absolute, false)
		if audio == null:
			DebugLogger.log_error("ActionPlaySound: Failed to load audio {0}".format([audio_path]))
			continue
		var audio_stream_player: AudioStreamPlayer = SoundManager.play_ui_sound(audio)
		if blocks_combat_presentation:
			CombatPresentation.track_audio(audio_stream_player)

func is_instant_action() -> bool:
	return true

func _to_string():
	return "Play Sound Action"
