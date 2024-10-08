@tool
extends EditorPlugin

# TODO: If any part of the Mod Creation fails we need to alert the user and remove what was already created so a retry can be made.

# TODO: Change this to get a example from the modding github.
var modStruct = [
	"res://{0}/",
	"res://{0}/scripts",
	"res://{0}/scenes",
	"res://{0}/sprites",
	"res://{0}/sounds"
]

# TODO: Change this to be dynamic from the modding github
var entryScriptContent = "extends Node

func _init() -> void:
	## The init function is where you can integrate your mod content
	pass"


# TODO: Implement Logging Solutions
# TOOD: Make Logging per file created not mod directory based.

func _ready() -> void:
	print("[Starground SDK] Setting Up Mod Creation Utils...")
	var sdkTools = get_editor_interface().get_editor_main_screen().get_child(-1)
	sdkTools.connect("create_mod", _handle_mod_creation)
	print("[Starground SDK] Finished Setting up Mod Creation utils...")


func _handle_mod_creation(mod_name: String, mod_id: String, author: String, entry_script: String, description: String):
	#  Alert user we are creating the Mod
	print("[Starground SDK] Creating new mod, please wait.")

	# Create The Folder Structure for the Mod
	var newModFiles: Array
	for file in modStruct:
		newModFiles.append(file.format([mod_id]))
	_create_mod_structure_from_array(newModFiles)
	newModFiles = [] # Free the mods contents just in case.

	# Create a info.json file with the correct information.
	# TODO: Implement this to be fetched from the Modding Github.
	var modInfoJSON = {
		"format": 1,
		"Script": "res://{0}/scripts/{1}.gd".format([mod_id, entry_script]),
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
	_create_infoJSON("res://{0}/".format([mod_id]), modInfoJSON)

	# Create the Entry Script File
	_create_populate_entry_script("res://{0}/scripts/{1}.gd".format([mod_id, entry_script]))

	# Alert user that Mod Creation is complete.
	_refresh_editor_fileSystem()
	print("[Starground SDK] Mod Creation Stage Complete... Have fun modding! Please report any bugs at https://github.com/NightPotato/Starground-SDK/issues")




# Take an Array and Creates the folders within the actual Projects FileSystem
func _create_mod_structure_from_array(structure: Array):
	for path in structure:
		_create_new_folder(path)


# Method to create info.json files
func _create_infoJSON(path: String, contents: Dictionary):
	var target_dir = DirAccess.open(path)
	print(path)
	var jsonFilePath =  path + "info.json"
	print(jsonFilePath)

	if target_dir == null:
		print("[Starground SDK] Failed to open 'res://' path during mod's info.json creation. Please report this issue.")
		return

	var file = FileAccess.open(jsonFilePath, FileAccess.WRITE)
	if file != null:
		file.store_string(pretty_print_json(contents))
		file.close()
		print("[Starground SDK] Successfully Created info.json file for the Mod.")
	else:
		print("[Starground SDK] Failed! jsonFile creation failed. Please report this issue.")

# Method to create entry_script with contents.
func _create_populate_entry_script(path: String):
	var scriptFile = FileAccess.open(path, FileAccess.WRITE)
	if scriptFile != null:
		scriptFile.store_string(entryScriptContent)
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

# Helper function to pretty-print JSON data with indentation
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