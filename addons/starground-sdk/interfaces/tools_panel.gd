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

#Mod dictionary to keep track of the OptionButton internal ids with option_id: mod_id as key value pairs
var option_button_mods = {}


func add_mod_to_list(mod_id: String):
	option_button_mods[hash(mod_id)] = mod_id
	ModSelectDropdown.add_item(mod_id, hash(mod_id))


func remove_mod_from_list(mod_id: String):
	option_button_mods.erase(hash(mod_id))
	ModSelectDropdown.remove_item(hash(mod_id))


func _on_create_button_pressed() -> void:
	var mod_name = ModNameInput.text
	var mod_id = ModIDInput.text
	var author = AuthorInput.text
	var entry_script = EntryScriptInput.text
	var description = DescriptionInput.text
	create_mod.emit(mod_name, mod_id, author, entry_script, description)


func _on_export_button_pressed() -> void:
	if ModSelectDropdown.selected == -1:
		return
	var mod_id = option_button_mods[ModSelectDropdown.get_item_id(ModSelectDropdown.selected)]
	var output_dir = OutputDirectory.current_directory
	var move_check = MoveCheckBox.button_pressed
	var game_mods_dir = GameModsDirectory.current_directory
	export_mod.emit(mod_id, output_dir, move_check, game_mods_dir)
