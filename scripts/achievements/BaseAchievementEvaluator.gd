## Optional extension point for achievements whose rules cannot be expressed as data.
extends RefCounted
class_name BaseAchievementEvaluator


## Return {"accepted": bool, "candidate_value": float, "unique_value": String}.
func evaluate(
	_achievement_data: AchievementData,
	_trigger_data: AchievementTriggerData,
	_event: Dictionary[String, Variant],
) -> Dictionary[String, Variant]:
	return {"accepted": false}
