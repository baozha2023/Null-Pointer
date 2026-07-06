## Test mode
extends BaseRunModifier

func run_start_modification() -> void:
	Global.player_data.add_artifact("artifact_debug_card_picker")
	Global.player_data.add_artifact("artifact_debug_energy_adder")
