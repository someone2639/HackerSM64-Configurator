extends Entry

@export var optname : String
@export var value : String
@export var max_length : int = 0

func _on_option_name_tree_entered():
	get_node("HBoxContainer/option_name").text = optname

func _on_option_text_tree_entered():
	var toEdit = get_node("HBoxContainer/option_text") as LineEdit
	toEdit.text = value
	toEdit.max_length = max_length
	toEdit.tooltip_text = self.tooltip_text

func _on_option_text_text_changed(new_text):
	GlobalVars.defines_db[_filepath][_defname] = new_text
