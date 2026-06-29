extends BaseRunModifier

func run_start_modification() -> void:
	print("Difficulty 4 enabled")
	Global.player_data.player_health_max = max(1, Global.player_data.player_health_max - 10)
	Global.player_data.player_health = min(Global.player_data.player_health_max, max(1, Global.player_data.player_health - 10))
	Global.player_data.player_money = max(0, Global.player_data.player_money - 300)
	Global.player_data.add_artifact("artifact_data_scarcity")
