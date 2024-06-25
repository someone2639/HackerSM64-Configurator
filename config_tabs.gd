extends TabContainer

const onoff = preload("res://onoff_entry.tscn")
const value_entry = preload("res://value_entry.tscn")
const onoff_value_entry = preload("res://onoff_value_entry.tscn")
const Description = preload("res://Description.gd")

func process_file(tab, filepath):
	print_debug("processing ", filepath)
	var file = FileAccess.open(filepath, FileAccess.READ)
	# TODO: add descriptions
	var curDesc : String = ""
	var desc : Description = null
	var ignoringLine : bool = false
	
	while !file.eof_reached():
		var line = file.get_line()
		var state = false
		var labelname = ""
		
		if "#if" in line:
			ignoringLine = true
		if "#endif" in line:
			ignoringLine = false
		
		if ignoringLine:
			continue
		
		if "/**" in line.substr(0,3):
			curDesc = line.substr(3) + "\n"
			#print("START ", curDesc)
		elif " * " in line.substr(0,3):
			curDesc += line.substr(3) + "\n"
			#print("MIDDLE  ", curDesc)
		elif "*/" in line:
			pass
			#desc = Description.new()
			#desc.text = curDesc
			#print("END  ", curDesc)
		
		if "#define" in line:
			if "(" in line and ")" in line:
				continue
			else:
				labelname = line.split("#define")[1].strip_edges()
				if len(labelname.split(" ", false)) > 1:
					if "// #define" in line:
						var real_name = labelname.split(" ", false)[0].strip_edges()
						var val = labelname.split(" ", false)[1].strip_edges()
						var toAdd = onoff_value_entry.instantiate()
						toAdd.optname = real_name.capitalize()
						toAdd.value = val
						toAdd.state = false
						toAdd.tooltip_text = curDesc
						GlobalVars.defines_db[filepath][real_name] = [state, val]
						tab.add_child(toAdd)
					else:
						var real_name = labelname.split(" ", false)[0].strip_edges()
						var val = labelname.split(" ", false)[1].strip_edges()
						var toAdd = value_entry.instantiate()
						toAdd.optname = real_name.capitalize()
						toAdd.value = val
						toAdd.tooltip_text = curDesc
						tab.add_child(toAdd)
						GlobalVars.defines_db[filepath][real_name] = val
				else: # just on/off
					if "// #define" in line:
						state = false
					else:
						state = true
					var toAdd = onoff.instantiate()
					toAdd.optname = labelname.capitalize()
					toAdd.state = state
					print(curDesc)
					toAdd.tooltip_text = curDesc
					GlobalVars.defines_db[filepath][labelname] = state
					#print(labelname)
					tab.add_child(toAdd)

# Called when the node enters the scene tree for the first time.
func _ready():
	var dirname = GlobalVars.file_path + "/include/config/"
	var dir = DirAccess.open(dirname)
	# TODO: assume valid dir for now since we use the filepicker on prev screen
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			pass
		else:
			if ".h" in file_name:
				if "config_" in file_name and "safeguards" not in file_name:
					var margins = MarginContainer.new()
					margins.anchors_preset = PRESET_FULL_RECT
					margins.add_theme_constant_override("margin_top", 15)
					margins.add_theme_constant_override("margin_left", 15)
					margins.add_theme_constant_override("margin_bottom", 15)
					margins.add_theme_constant_override("margin_right", 15)
					
					var tab_title = file_name.split("_")[1].split(".h")[0].capitalize()
					margins.set_name(tab_title)
					add_child(margins)
					
					var tab = VBoxContainer.new()
					tab.alignment = BoxContainer.ALIGNMENT_CENTER
					tab.add_theme_constant_override("separation", 24)
					margins.add_child(tab)
					GlobalVars.defines_db[dirname + file_name] = {}
					process_file(tab, dirname + file_name)
		file_name = dir.get_next()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_apply_changes_button_pressed():
	# TODO: write all headers to decomp
	pass # Replace with function body.
