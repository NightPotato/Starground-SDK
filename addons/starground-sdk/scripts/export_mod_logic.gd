@tool
extends EditorPlugin


func _ready() -> void:
	print("[Starground SDK] Setting Up Mod Export Utils...")
	var sdkTools = get_editor_interface().get_editor_main_screen().get_child(-1)
	sdkTools.connect("export_mod", _handle_mod_export)
	print("[Starground SDK] Finished Setting up Mod Export utils...")


func _handle_mod_export(mod_id, output_dir, move_check, game_mods_dir) -> void:
	pass