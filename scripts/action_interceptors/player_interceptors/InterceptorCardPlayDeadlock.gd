## 死锁拦截器：如果玩家拥有 status_effect_deadlock，则在打出时将 card_is_playable 设为 false。
extends BaseActionInterceptor

func process_action_interception(action_interceptor_processor: ActionInterceptorProcessor, _preview_mode: bool = false) -> int:
	var player = Global.get_player()
	if player == null:
		return ACTION_ACCEPTENCES.CONTINUE
	if player.get_status_charges("status_effect_deadlock") > 0:
		action_interceptor_processor.set_shadowed_action_values("card_is_playable", false)
	return ACTION_ACCEPTENCES.CONTINUE
