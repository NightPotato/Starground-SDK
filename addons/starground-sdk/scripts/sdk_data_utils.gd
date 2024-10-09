@tool
extends EditorPlugin


var toolsPanel

func _ready() -> void:
	print("Setting Reference to toolsPanel")
	toolsPanel = get_editor_interface().get_editor_main_screen().get_child(-1)


	print("[Starground SDK] Loading editor data..")

	var settings = load_editor_settings()

	if settings != null:
		SDKData.editorSettings = settings
	else:
		SDKData.editorSettings = SDKData.defaultEditorSettings
		save_editor_settings(SDKData.editorSettings)


#
# SDK Settings System
#
func save_editor_settings(content):
	var file = FileAccess.open("user://editor_settings.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(content))

func load_editor_settings():
	var file_path = "user://editor_settings.dat"  # Define the file path
	var fileContent = FileAccess.get_file_as_string(file_path)
	var settings = JSON.parse_string(fileContent)
	return settings


#
# Mod Projects
#
func add_mod_to_project(mod_id: String) -> void:
	var dropDown = toolsPanel.get_node("MarginContainer/TabContainer/Export Mod/VBoxContainer/HBoxContainer3/ModSelectDropdown")

	var available_spot = SDKData.modProjects.find("")
	if available_spot == -1:
		SDKData.modProjects.append(mod_id)
		available_spot = SDKData.modProjects.size() - 1
	else:
		SDKData.modProjects[available_spot] = SDKData.modProjects
	dropDown.add_item(mod_id, available_spot)
	print("Added Item to Mod Selection")

func remove_mod_from_project(mod_id: String) -> void:
	var dropDown = toolsPanel.get_node("MarginContainer/TabContainer/Export Mod/VBoxContainer/HBoxContainer3/ModSelectDropdown")
	var mod_id_index = SDKData.modProjects.find(mod_id)
	if mod_id_index == -1:
		return
	SDKData.modProjects[mod_id_index] = ""
	dropDown.remove_item(dropDown.get_item_index(mod_id_index))

func clear_mod_projects() -> void:
	var dropDown = toolsPanel.get_node("MarginContainer/TabContainer/Export Mod/VBoxContainer/HBoxContainer3/ModSelectDropdown")
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
	var mods = get_modProjects_from_dir()
	print(mods)
	for mod in mods:
		add_mod_to_project(mod)