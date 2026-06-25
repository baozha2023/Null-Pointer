extends SceneTree
func _init():
    var tr = TextureRect.new()
    var f = FileAccess.open(\"res://check_result.txt\", FileAccess.WRITE)
    f.store_string(\"stretch_mode=\" + str(tr.stretch_mode))
    f.close()
    quit()
