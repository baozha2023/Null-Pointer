class_name ActionPickOptions
extends ActionBasePickOptions

func get_pickable_options() -> Array[OptionData]:
	# Get options from action data. They could be raw dictionaries or OptionData objects, or strings.
	# Let's assume the data generator builds OptionData objects and passes them.
	# Or, if they are strings, we fetch them from Global.
	var options_data: Array = get_action_value("options", [])
	print("ActionPickOptions: options_data size = ", len(options_data))
	var returned_options: Array[OptionData] = []
	for opt in options_data:
		print("opt type: ", typeof(opt), " is OptionData: ", opt is OptionData)
		if opt is OptionData:
			returned_options.append(opt)
		elif typeof(opt) == TYPE_STRING:
			var opt_data: OptionData = Global.get_option_data(opt)
			if opt_data != null:
				returned_options.append(opt_data)
		elif typeof(opt) == TYPE_DICTIONARY:
			var new_opt: OptionData = OptionData.new()
			new_opt.option_name = opt.get("option_name", "")
			new_opt.option_description = opt.get("option_description", "")
			new_opt.option_texture_path = opt.get("option_texture_path", "")
			new_opt.option_disabled = opt.get("option_disabled", false)
			new_opt.option_disabled_reason = opt.get("option_disabled_reason", "")
			
			var option_validators = opt.get("option_validators", [])
			if option_validators.size() > 0:
				var typed_validators: Array[Dictionary] = []
				typed_validators.assign(option_validators)
				var card_data = card_play_request.card_data if card_play_request != null else null
				if not Global.validate(typed_validators, card_data, self):
					new_opt.option_disabled = true
					
			var sub_actions = opt.get("option_sub_actions", [])
			var typed_actions: Array[Dictionary] = []
			typed_actions.assign(sub_actions)
			new_opt.option_sub_actions = typed_actions
			returned_options.append(new_opt)
	print("returned_options size = ", len(returned_options))
	return returned_options

func perform_async_action() -> void:
	var initiator: BaseCombatant = parent_combatant

	for option in picked_options:
		if len(option.option_sub_actions) > 0:
			var actions: Array[BaseAction] = ActionGenerator.create_actions(initiator, card_play_request, self.targets, option.option_sub_actions, self)
			ActionHandler.add_actions(actions)

	action_async_finished.emit()

func _to_string():
	return "Action Pick Options"
