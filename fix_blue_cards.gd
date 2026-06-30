extends SceneTree

func _init():
	var file = FileAccess.open("res://autoload/card_generators/blue_cards.gd", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var regex = RegEx.new()
	regex.compile("(\\tcard_\\w+)\\.card_texture_path = \"external/sprites/cards/\\{0\\}/card_\\{0\\}\\.png\"\\.format\\(\\[color\\]\\)")
	
	# Replace with actual dynamic paths based on the card's object_id
	content = regex.sub(content, "$1.card_texture_path = \"sprites/card/blue/\" + $1.object_id + \".png\"", true)
	
	var out_file = FileAccess.open("res://autoload/card_generators/blue_cards.gd", FileAccess.WRITE)
	out_file.store_string(content)
	out_file.close()
	
	print("Successfully updated blue_cards.gd texture paths.")
	quit()
