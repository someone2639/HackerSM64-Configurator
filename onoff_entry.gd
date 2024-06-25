extends Control

@export var optname : String
@export var state : bool
@export var _filepath : String
@export var _defname : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_option_name_tree_entered():
	get_node("HBoxContainer/option_name").text = optname

func _on_option_state_tree_entered():
	var butt = get_node("HBoxContainer/option_state") as CheckButton
	butt.button_pressed = state
	butt.tooltip_text = self.tooltip_text

func _on_option_state_toggled(toggled_on):
	GlobalVars.defines_db[_filepath][_defname] = toggled_on
