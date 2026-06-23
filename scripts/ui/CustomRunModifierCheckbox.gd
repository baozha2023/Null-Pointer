extends CheckBox

var run_modifier_object_id: String = ""	# the character id this button represents

func init(_run_modifier_object_id: String) -> void:
	run_modifier_object_id = _run_modifier_object_id
	var run_modifier_data: RunModifierData = Global.get_run_modifier_data(run_modifier_object_id)
	if run_modifier_data != null:
		text = run_modifier_data.run_modifier_name
		tooltip_text = run_modifier_data.run_modifier_description

func _make_custom_tooltip(for_text: String) -> Object:
	var label: Label = Label.new()
	label.text = for_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(300, 0)
	return label
