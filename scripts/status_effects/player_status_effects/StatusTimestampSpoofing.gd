## 时间戳伪造状态：将手牌费用降为0，并启动5秒倒计时强制结束回合。
extends BaseStatusEffect

func init(_status_effect_data, _parent_combatant: BaseCombatant):
	super.init(_status_effect_data, _parent_combatant)
	
	# Apply 0 cost to all current cards in hand
	for card_data in HandManager.player_hand:
		card_data.set_card_energy_cost_until_turn(0)
	
	# Start a 5-second real-time timer
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		tree.create_timer(5.0).timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	Signals.end_turn_requested.emit(0)

func _connect_signals() -> void:
	Signals.card_drawn.connect(_on_card_drawn)

func _on_card_drawn(card_data: CardData) -> void:
	card_data.set_card_energy_cost_until_turn(0)
