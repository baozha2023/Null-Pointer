## 死锁验证器：如果玩家拥有 status_effect_deadlock，则拦截所有出牌。
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	# Check if player has the deadlock status effect
	var player = Global.get_player()
	if player == null:
		return true
	if player.get_status_charges("status_effect_deadlock") > 0:
		return false
	return true
