@tool
extends EditorPlugin

var sdkTools
var modSelector

func _ready() -> void:
	print("[Starground SDK] Setting Up Mod Export Utils...")
	sdkTools = get_editor_interface().get_editor_main_screen().get_child(-1)
	sdkTools.connect("export_mod", _handle_mod_export)
	print("[Starground SDK] Finished Setting up Mod Export utils...")
	SDKEvents.connect("mod_created", _handle_new_mod)
	SDKEvents.connect("directory_changed", _on_directory_changed)


	print("[Starground SDK] Populating Mod Projects from Directory Listing...")
	SDKUtils.populate_modProjects()

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
	#zip_mod_content(contents, exportPath_Mod)
	print("[Starground SDK] - Finished Packing Mod!")
#
#func zip_mod_content(file_paths, export_path):
	## Create a new ZIPPacker instance
	#var zip_packer = ZIPPacker.new()
#
	## Open the ZIP file for writing
	#var result = zip_packer.open(export_path)
	#if result != OK:
		#push_error("Failed to open ZIP file for writing: %s" % export_path)
		#return
#
	## Iterate over the file_paths to add files to the ZIP
	#for file_path in file_paths:
		## Open the file to read its content
		#var file = FileAccess.open(file_path, FileAccess.READ)
		#if file == null:
			#push_error("Failed to open file: %s" % file_path)
			#continue
#
		#var file_data = file.get_buffer(file.get_length())  # Read the entire file as a PackedByteArray
		#file.close()
		#
		## Parse Each File for "res://mods/" references and replace with "res://"
#
		## Check if the current file is info.json
		#if file_path.ends_with("info.json"):
			## Add info.json to the root of the ZIP
			#result = zip_packer.start_file("info.json")
			#if result != OK:
				#push_error("Failed to start file: info.json in the ZIP")
			#else:
				#zip_packer.write_file(file_data)
				#zip_packer.close_file()
		#else:
			## Preserve the relative path for other files inside pd_extended_chat 
			#var relative_path = file_path.substr("res://mods/".length())  # Keep the path relative to `mods/`
#
			## Start a new file in the ZIP with the relative path
			#result = zip_packer.start_file(relative_path)
			#if result != OK:
				#push_error("Failed to start file: %s in the ZIP" % relative_path)
				#continue
#
			## Write the file data into the ZIP
			#zip_packer.write_file(file_data)
	#
			## Close the current file in the ZIP
			#zip_packer.close_file()
#
	## Close the ZIP file to finalize it
	#zip_packer.close()
#
	#print("Files successfully packaged into ZIP: %s" % export_path)
