extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_new_folder_button_pressed():
	get_tree().change_scene_to_file("res://SelectDecomp.tscn")

func _on_cur_path_tree_entered():
	get_node("VBoxContainer/top_bar/HBoxContainer/cur_path").text = "Current Path: " + GlobalVars.file_path
