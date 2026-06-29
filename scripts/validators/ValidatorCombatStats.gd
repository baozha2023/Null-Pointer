# Validator for checking any combat stats using comparison operators
# See: CombatStatsData for stat_enum values
extends BaseValidator

func _validation(_card_data: CardData, _action: BaseAction, values: Dictionary[String, Variant]) -> bool:
	var combat_stats_data: CombatStatsData = StatsHandler.current_combat_stats
	
	var stat_enum: int = _get_validator_value("stat_enum", values, _action, CombatStatsData.STATS.ENEMIES_KILLED)
	var turn_stat_type: int = _get_validator_value("turn_stat_type", values, _action, 0) 	# -1 = total, 0 = turn, 1 = last turn, etc.
	var operator: String = _get_validator_value("operator", values, _action, ">")
	var comparison_value: int = _get_validator_value("comparison_value", values, _action, 0)
	
	var stat_value: int = combat_stats_data.get_history_enum_stat(stat_enum, turn_stat_type)
	
	return _compare(stat_value, comparison_value, operator)
