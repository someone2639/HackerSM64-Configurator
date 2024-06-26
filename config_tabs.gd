extends TabContainer

const onoff = preload("res://EntryTemplates/onoff/onoff_entry.tscn")
const value_entry = preload("res://EntryTemplates/value/value_entry.tscn")
const onoff_value_entry = preload("res://EntryTemplates/onoff_value/onoff_value_entry.tscn")
const dropdown_entry = preload("res://EntryTemplates/dropdown/dropdown_entry.tscn")
const Description = preload("res://Description.gd")

var enumDict = {}

# funny chatgpt function
func filter_c_comments(line: String) -> String:
	# Remove single-line comments
	var single_line_comment_index = line.find("//")
	if single_line_comment_index != -1:
		line = line.substr(0, single_line_comment_index)

	# Remove multi-line comments
	while line.find("/*") != -1 and line.find("*/") != -1:
		var start_comment = line.find("/*")
		var end_comment = line.find("*/") + 2
		line = line.substr(0, start_comment) + line.substr(end_comment, line.length() - end_comment)

	return line.strip_edges()

func populate_enum_dicts():
	var dirname = GlobalVars.file_path + "/src/game/"
	var dir = DirAccess.get_files_at(dirname)
	for file in dir:
		var inEnum = false
		var enumName = ""

		var fullpath = dirname + file

		if ".h" in file:
			var fo = FileAccess.open(fullpath, FileAccess.READ)
			var fb = fo.get_as_text()
			fo.close()
			
			var fl = fb.split("\n")
			for l in fl:
				var line = filter_c_comments(l)
				if "enum" in line:
					inEnum = true
					enumName = line.split(" ", false)[1].strip_edges()
					enumDict[enumName] = []
					continue
				if "};" in line:
					inEnum = false
					continue
				if inEnum:
					if "," in line:
						var ename = line.split(" ", false)[0].split(",")[0]
						enumDict[enumName] += [ename]
	# Special case for level defines
	enumDict["Levels"] = []
	var fo = FileAccess.open(GlobalVars.file_path+"/levels/level_defines.h", FileAccess.READ)
	var fb = fo.get_as_text()
	fo.close()
	var fl = fb.split("\n")
	for line in fl:
		if "DEFINE_LEVEL" in line:
			enumDict["Levels"] += [line.split(",",false)[1].strip_edges()]

func process_file(tab, filepath):
	#print_debug("processing ", filepath)
	var file = FileAccess.open(filepath, FileAccess.READ)
	# TODO: descriptions work but are very hacky and depend on the repo being written a certain
	#       way. also they currently use comment/uncomment terms instead of enable/disable
	var curDesc : String = ""
	var _desc : Description = null
	var ignoringLine : bool = false
	
	# TODO: Special cases
	# internal rom name: pad to 20 chars, have a limit too
	# 
	
	while !file.eof_reached():
		var line = file.get_line()
		var state = false
		var labelname = ""
		
		if "#endif" in line:
			ignoringLine = false
		elif "#elif" in line:
			ignoringLine = true
		elif "#if" in line:
			ignoringLine = true
		
		if ignoringLine:
			continue
		
		if "/**" in line.substr(0,3):
			curDesc = line.substr(3) + "\n"
		elif " * " in line.substr(0,3):
			curDesc += line.substr(3) + "\n"
		elif "*/" in line:
			pass
			#desc = Description.new()
			#desc.text = curDesc

		if "#define" in line:
			if "(" in line and ")" in line:
				continue
			else:
				var toAdd = null
				labelname = line.split("#define")[1].strip_edges()
				if len(labelname.split(" ", false)) > 1:
					if "// #define" in line: # On/Off with Value
						var val = labelname.split(" ", false)[1].strip_edges()
						labelname = labelname.split(" ", false)[0].strip_edges()
						toAdd = onoff_value_entry.instantiate()
						toAdd.value = val
						toAdd.state = false
						GlobalVars.defines_db[filepath][labelname] = [state, val]
					else: # Value
						var val = labelname.split(" ", false)[1].strip_edges()
						labelname = labelname.split(" ", false)[0].strip_edges()

						for e in enumDict:
							if val in enumDict[e]: # Dropdown
								toAdd = dropdown_entry.instantiate()
								toAdd.items = enumDict[e]
								toAdd._defVal = val
								break

						if toAdd == null:
							toAdd = value_entry.instantiate()
							toAdd.value = val
							if labelname.split(" ", false)[0].strip_edges() == "INTERNAL_ROM_NAME":
								toAdd.max_length = 20
								val = line.split('"', false)[1].strip_edges()
								toAdd.value = val

						GlobalVars.defines_db[filepath][labelname] = val
				else: # just on/off
					if "// #define" in line:
						state = false
					else:
						state = true
					toAdd = onoff.instantiate()
					toAdd.state = state
					GlobalVars.defines_db[filepath][labelname] = state
				toAdd.optname = labelname.capitalize()
				toAdd._defname = labelname
				toAdd._filepath = filepath
				toAdd.tooltip_text = curDesc
				tab.add_child(toAdd)

# Called when the node enters the scene tree for the first time.
func _ready():
	var dirname = GlobalVars.file_path + "/include/config/"
	var dir = DirAccess.open(dirname)
	
	populate_enum_dicts()
	
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

					#var scroller = ScrollContainer.new()
					#scroller.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					#scroller.size_flags_vertical = Control.SIZE_EXPAND_FILL
					#margins.add_child(scroller)

					var tab = VBoxContainer.new()
					tab.alignment = BoxContainer.ALIGNMENT_CENTER
					tab.add_theme_constant_override("separation", 24)
					margins.add_child(tab)
					GlobalVars.defines_db[dirname + file_name] = {}
					process_file(tab, dirname + file_name)
		file_name = dir.get_next()

func _on_apply_changes_button_pressed():
	for filename in GlobalVars.defines_db:
		var db = GlobalVars.defines_db[filename]
		var file = FileAccess.open(filename, FileAccess.READ)
		var filebuf = file.get_as_text()
		file.close()
		var fl = filebuf.split("\n")
		var outbuf = ""
		for i in len(fl):
			var line = fl[i]

			if "#define" in line.substr(0,10):
				var defname = line.split("#define")[1].strip_edges()
				if len(defname.split(" ", false)) > 1:
					defname = defname.split(" ", false)[0].strip_edges()
				if defname in db:
					if defname == "INTERNAL_ROM_NAME":
						outbuf += "#define " + defname + ' "' + db[defname].rpad(20, " ") + '"\n'
					elif db[defname] is int:
						outbuf += "#define " + defname + " " + str(db[defname]) + "\n"
					elif db[defname] is String:
						outbuf += "#define " + defname + " " + db[defname] + "\n"
					elif db[defname] is bool:
						if db[defname]:
							outbuf += "#define " + defname + "\n"
						else:
							outbuf += "// #define " + defname + "\n"
					elif db[defname] is Array:
						if db[defname][0]:
							outbuf += "#define " + defname + " " + str(db[defname][1]) + "\n"
						else:
							outbuf += "// #define " + defname + " " + str(db[defname][1]) + "\n"
				else:
					outbuf += line + "\n"
			else:
				if i < len(fl) - 1:
					outbuf += line + "\n"
				
		file = FileAccess.open(filename, FileAccess.WRITE)
		file.store_string(outbuf)
		file.close()
