@tool
extends MarginContainer


signal create_mod(mod_name: String, mod_id: String, author: String, entry_script: String, description: String)
signal export_mod(mod_id: String, output_dir: String, move_check: bool, game_mods_dir: String)

@export var ModNameInput: LineEdit
@export var ModIDInput: LineEdit
@export var AuthorInput: LineEdit
@export var EntryScriptInput: LineEdit
@export var DescriptionInput: TextEdit

@export var ModSelectDropdown: OptionButton
@export var OutputDirectory: DirectorySelector
@export var MoveCheckBox: CheckBox
@export var GameModsDirectory: DirectorySelector

@export var ErrorDialog: AcceptDialog

var mod_ids = []


func _ready() -> void:
	clear_mod_list()


func add_mod_to_list(mod_id: String):
	var available_spot = mod_ids.find("")
	if available_spot == -1:
		mod_ids.append(mod_id)
		available_spot = mod_ids.size() - 1
	else:
		mod_ids[available_spot] = mod_ids
	ModSelectDropdown.add_item(mod_id, available_spot)


func remove_mod_from_list(mod_id: String):
	var mod_id_index = mod_ids.find(mod_id)
	if mod_id_index == -1:
		return
	mod_ids[mod_id_index] = ""
	ModSelectDropdown.remove_item(ModSelectDropdown.get_item_index(mod_id_index))


func clear_mod_list():
	mod_ids = []
	ModSelectDropdown.clear()


func display_error(error_text: String) -> void:
	ErrorDialog.dialog_text = error_text
	ErrorDialog.popup_centered()


func _on_create_button_pressed() -> void:
	var mod_name = ModNameInput.text
	if mod_name.replace(" ", "").replace("	", "").is_empty():
		display_error("Mod Name must not be empty!")
		return
	
	var mod_id = ModIDInput.text
	if not mod_id.is_valid_identifier():
		display_error("Mod ID must be a valid identifier! 
		A valid identifier may contain only letters, digits and underscores (_), and the first character must not be a digit.")
		return
	
	var author = AuthorInput.text
	if author.replace(" ", "").replace("	", "").is_empty():
		display_error("Author must not be empty!")
		return
	
	var entry_script = EntryScriptInput.text
	if not entry_script.is_valid_filename() or " " in entry_script:
		display_error("Entry Script must me a valid file name!")
		return
	
	var description = DescriptionInput.text
	
	create_mod.emit(mod_name, mod_id, author, entry_script, description)


func _on_export_button_pressed() -> void:
	if ModSelectDropdown.selected == -1:
		display_error("No Mod Selected!")
		return
	
	var dropdown_id = ModSelectDropdown.get_item_id(ModSelectDropdown.selected)
	if dropdown_id >= mod_ids.size() or mod_ids[dropdown_id] == "":
		display_error("Mod Not Found In Internal Dropdown List! Critical Error!")
		return
	var mod_id = mod_ids[dropdown_id]
	
	var output_dir = OutputDirectory.current_directory
	if output_dir.is_empty():
		display_error("Select Output Directory to export!")
		return
	if not DirAccess.dir_exists_absolute(output_dir):
		display_error("The selected Output Directory does not exist! Select a valid Output Directory!")
		return
	
	var move_check = MoveCheckBox.button_pressed
	var game_mods_dir = GameModsDirectory.current_directory
	if move_check:
		if game_mods_dir.is_empty():
			display_error("Select Game Mods Directory, or turn off Move Export, to export!")
			return
		if not DirAccess.dir_exists_absolute(game_mods_dir):
			display_error("The selected Game Mods Directory does not exist! Select a valid Game Mods Directory!")
			return
	
	export_mod.emit(mod_id, output_dir, move_check, game_mods_dir)
