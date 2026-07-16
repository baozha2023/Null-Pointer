extends BaseAchievementTrigger


func _connect_triggers() -> void:
	Signals.card_played.connect(_on_card_played)


func _on_card_played(card_play_request: CardPlayRequest) -> void:
	if card_play_request.card_data != null and card_play_request.card_data.object_id == "card_modded_card":
		request_unlock()
