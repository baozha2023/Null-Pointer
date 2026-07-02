extends BaseValidator
class_name ValidatorForgeLoad

func _validation(_card_data: CardData, action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var load_required: int = _get_validator_value("load_required", values, action, 0)
	var artifacts: Array[ArtifactData] = Global.player_data.get_player_artifacts_with_artifact_id("artifact_forge")
	if not artifacts.is_empty():
		return artifacts[0].artifact_counter >= load_required
	return false

func _to_string():
	return "Validator Forge Load"
