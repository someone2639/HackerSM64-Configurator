extends Entry

@export var optname : String
@export var items : Array
@export var max_length : int = 0

func _on_option_name_tree_entered():
	get_node("option_name").text = optname

func _on_option_drops_tree_entered():
	var toEdit = get_node("option_drops") as OptionButton
	for i in len(items):
		toEdit.add_item(items[i], i)
	toEdit.item_count = len(items)
	toEdit.select(items.find(_defVal))
	toEdit.tooltip_text = self.tooltip_text

func _on_option_drops_item_selected(index):
	GlobalVars.defines_db[_filepath][_defname] = items[index]
