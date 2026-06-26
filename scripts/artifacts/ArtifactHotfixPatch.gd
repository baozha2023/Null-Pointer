## 热修复补丁：每打出1张攻击牌充能+1，充能达到3时抽1张牌并回复1点算力。
extends BaseArtifact

func connect_signals() -> void:
	super()
	Signals.card_played.connect(_on_card_played)

func _on_card_played(card_play_request: CardPlayRequest) -> void:
	if card_play_request.card_data.card_type == CardData.CARD_TYPES.ATTACK:
		ActionGenerator.generate_artifact_counter_increment_action(artifact_data, 1)
