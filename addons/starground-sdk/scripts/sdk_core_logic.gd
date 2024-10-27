@tool
extends EditorPlugin

var sdkTools
var modSelector

func _ready() -> void:
	print("[Starground SDK] Setting Up Mod Creation Utils...")
	var sdkTools = get_editor_interface().get_editor_main_screen().get_child(-1)
	sdkTools.connect("create_mod", _handle_mod_creation)
	print("[Starground SDK] Finished Setting up Mod Creation utils...")
	
	print("[Starground SDK] Setting Up Mod Export Utils...")
	sdkTools = get_editor_interface().get_editor_main_screen().get_child(-1)
	sdkTools.connect("export_mod", _handle_mod_export)
	print("[Starground SDK] Finished Setting up Mod Export utils...")
	SDKData.connect("mod_created", _handle_new_mod)
	SDKData.connect("directory_changed", _on_directory_changed)

	print("[Starground SDK] Populating Mod Projects from Directory Listing...")
	SDKUtils.populate_modProjects()


func _handle_mod_creation(mod_name: String, mod_id: String, author: String, entry_script: String, description: String):
	#  Alert user we are creating the Mod
	print("[Starground SDK] Creating new mod, please wait.")

	# Create The Folder Structure for the Mod
	var newModFiles: Array
	for file in SDKData.modStruct:
		newModFiles.append(file.format([mod_id]))
	_create_mod_structure_from_array(newModFiles)
	newModFiles = [] # Free the mods contents just in case.

	# Create a info.json file with the correct information.
	# TODO: Implement this to be fetched from the Modding Github.
	var modInfoJSON = {
		"format": 1,
		"Script": "res://{0}/{1}.gd".format([mod_id, entry_script]),
		"Data": {
			"ID": mod_id,
			"DisplayName": mod_name,
			"ModVersion": "1.0.0",
			"Description": description,
			"GameVersions": ["0.9.0.0"],
			"Author": author,
			"Dependencies": [],
		}
	}
	_create_infoJSON("res://mods/{0}/".format([mod_id]), modInfoJSON)

	# Create the Entry Script File
	_create_populate_entry_script("res://mods/{0}/{1}.gd".format([mod_id, entry_script]))

	# Alert user that Mod Creation is complete.
	_refresh_editor_fileSystem()
	print("[Starground SDK] Mod Creation Stage Complete... Have fun modding! Please report any bugs at https://github.com/NightPotato/Starground-SDK/issues")
	SDKData.emit_signal("mod_created")
	
# Take an Array and Creates the folders within the actual Projects FileSystem
func _create_mod_structure_from_array(structure: Array):
	for path in structure:
		_create_new_folder(path)
		
# Method to create info.json files
func _create_infoJSON(path: String, contents: Dictionary):
	var target_dir = DirAccess.open(path)
	var jsonFilePath =  path + "info.json"

	if target_dir == null:
		print("[Starground SDK] Failed to open 'res://' path during mod's info.json creation. Please report this issue.")
		return

	var file = FileAccess.open(jsonFilePath, FileAccess.WRITE)
	if file != null:
		file.store_string(SDKUtils.pretty_print_json(contents))
		file.close()
		print("[Starground SDK] Successfully Created info.json file for the Mod.")
	else:
		print("[Starground SDK] Failed! jsonFile creation failed. Please report this issue.")

# Method to create entry_script with contents.
func _create_populate_entry_script(path: String):
	var scriptFile = FileAccess.open(path, FileAccess.WRITE)
	if scriptFile != null:
		scriptFile.store_string(SDKData.entryScriptContent)
		scriptFile.close()
		print("[Starground SDK] Successfully Created Mod Entry Script..")
	else:
		print("[Starground SDK] Mod Creation Failed. Could not create entry script. Please report this issue.")
		
# Method to Handle Folder Creation
func _create_new_folder(desiredPath):
	var dir = DirAccess.open("res://")

	if dir == null:
		print("[Starground SDK] Failed to open 'res://' path during mod creation. Please report this issue.")
		return

	if dir.dir_exists_absolute(desiredPath):
		print("[Starground SDK] Mod folder already exists? Did you make an error is the naming of your mod?")
	else:
		var result = dir.make_dir_absolute(desiredPath)
		if result == OK:
			print("[Starground SDK] Successfully create directory!")
		else:
			print("[Starground SDK] Failed to create directory.")

# Method to Refresh the project structure after making edits.
func _refresh_editor_fileSystem():
	get_editor_interface().get_resource_filesystem().scan()
	
func _on_directory_changed(type, dir) -> void:
	if type == 0:
		SDKData.editorSettings["export_game_path"] = dir
	if type == 1:
		SDKData.editorSettings["export_path"] = dir
	
	SDKUtils.save_editor_settings()

func _handle_new_mod():
	SDKUtils.populate_modProjects()

func _handle_mod_export(mod_id, output_dir, move_check, game_mods_dir) -> void:
	_pack_mod_to_export_path(mod_id, output_dir)

func _pack_mod_to_export_path(mod_id, export_path):
	var contents = SDKUtils.get_all_file_paths("res://mods/{0}".format([mod_id]))
	var exportPath_Mod = export_path + "/{0}.zip".format([mod_id])
	
	GMLCore.export_mod_project(contents, exportPath_Mod)
	print("[Starground SDK] - Finished Packing Mod!")
