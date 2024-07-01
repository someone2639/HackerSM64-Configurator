extends Entry

@export var optname : String
@export var state : bool

func _on_option_name_tree_entered():
	get_node("option_name").text = optname

func _on_option_state_tree_entered():
	var butt = get_node("option_state") as CheckButton
	butt.button_pressed = state
	butt.tooltip_text = self.tooltip_text

func _on_option_state_toggled(toggled_on):
	GlobalVars.defines_db[_filepath][_defname] = toggled_on
