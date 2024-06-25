extends Control

@export var optname : String
@export var state : bool
@export var value : String
@export var _filepath : String
@export var _defname : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_option_name_tree_entered():
	get_node("HBoxContainer/option_name").text = optname

func _on_option_text_tree_entered():
	var toEdit = get_node("HBoxContainer/buttons/option_text") as LineEdit
	toEdit.text = value
	toEdit.editable = state

func _on_option_on_tree_entered():
	get_node("HBoxContainer/buttons/option_on").button_pressed = state


func _on_option_on_toggled(toggled_on):
	var toEdit = get_node("HBoxContainer/buttons/option_text") as LineEdit
	toEdit.editable = toggled_on
	GlobalVars.defines_db[_filepath][_defname] = [toggled_on, toEdit.text]

func _on_option_text_text_changed(new_text):
	GlobalVars.defines_db[_filepath][_defname] = [true, new_text]
