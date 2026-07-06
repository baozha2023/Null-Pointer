extends BaseArtifact

var cards_played_this_combat: int = 0

func connect_signals() -> void:
	super()
	Signals.combat_started.connect(_on_combat_started)
	Signals.card_played.connect(_on_card_played)

func _on_combat_started() -> void:
	cards_played_this_combat = 0

func _on_card_played(card_play_request: CardPlayRequest) -> void:
	if card_play_request.is_duplicate_play:
		return
	
	if cards_played_this_combat < artifact_data.artifact_counter:
		cards_played_this_combat += 1
		
		var duplicate_request: CardPlayRequest = HandManager.create_card_play_request(
			card_play_request.card_data, 
			card_play_request.selected_target, 
			false, 
			true
		)
		duplicate_request.is_duplicate_play = true
		duplicate_request.refundable_energy = 0
		duplicate_request.input_energy = card_play_request.input_energy
		duplicate_request.card_values = card_play_request.card_values.duplicate(true)
		duplicate_request.card_destination_pile = HandManager.BANISH_PILE
		duplicate_request.card_destination_strategy = HandManager.PILE_INSERTION_STRATEGIES.TOP
		
		HandManager.add_card_to_play_queue(duplicate_request, false, true)
		Signals.artifact_proc.emit(artifact_data)
