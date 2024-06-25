extends FileDialog

func goto_dir(dir):
	GlobalVars.file_path = dir
	get_tree().change_scene_to_file("res://MainPage.tscn")


func _ready():
	if FileAccess.file_exists("user://decomp_dir.txt"):
		var file = FileAccess.open("user://decomp_dir.txt", FileAccess.READ)
		var dir = file.get_as_text()
		goto_dir(dir)
	else:
		#print_debug("no saved dir exists")
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_dir_selected(dir):
	# TODO: verify this is a decomp folder, error if not
	var file = FileAccess.open("user://decomp_dir.txt", FileAccess.WRITE)
	file.store_string(dir)
	goto_dir(dir)
	

func _on_canceled():
	get_tree().quit();
