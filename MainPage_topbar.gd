extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_new_folder_button_pressed():
	get_tree().change_scene_to_file("res://SelectDecomp.tscn")

func _on_cur_path_tree_entered():
	get_node("VBoxContainer/top_bar/HBoxContainer/cur_path").text = "Current Repo: " + GlobalVars.file_path
	if FileAccess.file_exists(GlobalVars.file_path+"/.git/HEAD"):
		var file = FileAccess.open(GlobalVars.file_path+"/.git/HEAD", FileAccess.READ)
		var buf = file.get_as_text()
		file.close()
		var branch = buf.split("/heads/")[1].strip_edges()
		get_node("VBoxContainer/top_bar/HBoxContainer/cur_path").text += " (" + branch + ")"
