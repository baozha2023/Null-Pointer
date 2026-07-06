extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_played.connect(_on_card_played)

func _on_card_played(card_play_request: CardPlayRequest) -> void:
	if card_play_request.card_data.card_type != CardData.CARD_TYPES.SKILL:
		return
	
	if card_play_request.is_duplicate_play:
		return
		
	var cost: int = card_play_request.input_energy
	if cost <= 0:
		return
		
	var rng: RandomNumberGenerator = Global.player_data.get_player_rng("rng_artifacts")
	if rng.randf() < (artifact_data.artifact_counter / 100.0):
		var refund_action: Array[Dictionary] = [{
			Scripts.ACTION_ADD_ENERGY: {
				"energy_amount": cost,
			},
		}]
		var generated_actions: Array[BaseAction] = ActionGenerator.create_actions(null, null, [], refund_action, null)
		ActionHandler.add_actions(generated_actions)
		Signals.artifact_proc.emit(artifact_data)
