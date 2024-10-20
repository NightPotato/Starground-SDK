@tool
extends EditorPlugin

var toolsPanel

# Load Settings for Editor on Startup.
func _ready() -> void:
	toolsPanel = get_editor_interface().get_editor_main_screen().get_child(-1)
	print("[Starground SDK] Loading editor data..")
	var settings = load_editor_settings()

	if settings != null:
		SDKData.editorSettings = settings
	else:
		SDKData.editorSettings = SDKData.defaultEditorSettings
		save_editor_settings()
		
#
# SDK Settings Utils
func save_editor_settings():
	var file = FileAccess.open("user://editor_settings.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(SDKData.editorSettings))

func load_editor_settings():
	var file_path = "user://editor_settings.dat"  # Define the file path
	var fileContent = FileAccess.get_file_as_string(file_path)
	var settings = JSON.parse_string(fileContent)
	return settings

#
# Mod Project Management Utils
func add_mod_to_project(mod_id: String) -> void:
	var dropDown = toolsPanel.ModSelectDropdown
	var available_spot = SDKData.modProjects.find("")
	if available_spot == -1:
		SDKData.modProjects.append(mod_id)
		available_spot = SDKData.modProjects.size() - 1
	else:
		SDKData.modProjects[available_spot] = SDKData.modProjects
	dropDown.add_item(mod_id, available_spot)

func remove_mod_from_project(mod_id: String) -> void:
	var dropDown = toolsPanel.ModSelectDropdown
	var mod_id_index = SDKData.modProjects.find(mod_id)
	if mod_id_index == -1:
		return
	SDKData.modProjects[mod_id_index] = ""
	dropDown.remove_item(dropDown.get_item_index(mod_id_index))

func clear_mod_projects() -> void:
	var dropDown = toolsPanel.ModSelectDropdown
	SDKData.modProjects = []
	dropDown.clear()

# Auto-generate a list of Mod Projects from Res://mods/
func get_modProjects_from_dir() -> Array:
	var folder_list = []
	var dir = DirAccess.open("res://mods/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				folder_list.append(file_name)
			file_name = dir.get_next()
	else:
		print("[Starground SDK] An error occurred when trying to access the path.")
	return folder_list

func populate_modProjects() -> void:
	clear_mod_projects()
	var mods = get_modProjects_from_dir()
	for mod in mods:
		add_mod_to_project(mod)

#
# Path Utils
func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []

	var possible_paths = [path]
	var index: int = 0
	while index < len(possible_paths):
		var current_folder: String = possible_paths[index]

		var folders = Array(DirAccess.get_directories_at(current_folder)).map(
				func(folder): return current_folder + "/" + folder
				)
		possible_paths.append_array(folders)

		var files = Array(DirAccess.get_files_at(current_folder)).map(
				func(file): return current_folder + "/" + file
				)
		file_paths.append_array(files)

		index += 1
	return file_paths

func pretty_print_json(data: Dictionary, indent: int = 4) -> String:
	return _pretty_print(data, indent, 0)

# Recursive function to handle indentation for nested structures
func _pretty_print(data, indent: int, level: int) -> String:
	var output = ""
	if typeof(data) == TYPE_DICTIONARY:
		output += "{\n"
		for key in data.keys():
			output += " ".repeat(level + indent) + "\"" + str(key) + "\": "
			output += _pretty_print(data[key], indent, level + indent) + ",\n"
		output = output.trim_suffix(",\n") + "\n"
		output += " ".repeat(level) + "}"
	elif typeof(data) == TYPE_ARRAY:
		output += "[\n"
		for item in data:
			output += " ".repeat(level + indent) + _pretty_print(item, indent, level + indent) + ",\n"
		output = output.trim_suffix(",\n") + "\n"
		output += " ".repeat(level) + "]"
	elif typeof(data) == TYPE_STRING:
		output += "\"" + data + "\""
	else:
		output += str(data)
	return output
