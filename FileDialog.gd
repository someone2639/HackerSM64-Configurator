extends FileDialog


func _ready():
	if len(GlobalVars.file_path) > 0:
		pass
	elif FileAccess.file_exists("user://decomp_dir.txt"):
		var file = FileAccess.open("user://decomp_dir.txt", FileAccess.READ)
		var dir = file.get_as_text()
		file.close()
		GlobalVars.file_path = dir
		get_tree().call_deferred("change_scene_to_file", "res://MainPage.tscn")


func _on_dir_selected(dir):
	# TODO: verify this is a decomp folder, error if not
	var file = FileAccess.open("user://decomp_dir.txt", FileAccess.WRITE)
	file.store_string(dir)
	GlobalVars.file_path = dir
	get_tree().change_scene_to_file("res://MainPage.tscn")
	

func _on_canceled():
	get_tree().quit();

