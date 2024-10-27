@tool
extends EditorPlugin

#
# Editor Setting Data
var defaultEditorSettings: Dictionary = {
	"export_path": "",
	"export_shouldMove": false,
	"export_game_path": ""
}

var editorSettings: Dictionary
var modProjects: Array


#
# Starground SDK Event Signals
signal mod_created
signal mod_exported
signal game_start_event
signal directory_changed


#
# Default Mod Structure

# TODO: Change this to get a example from the modding github.
var modStruct = [
	"res://mods/{0}/",
	"res://mods/{0}/scripts",
	"res://mods/{0}/scenes",
	"res://mods/{0}/sprites",
	"res://mods/{0}/sounds"
]

# TODO: Change this to be dynamic from the modding github
var entryScriptContent = "extends Node

func _init() -> void:
	## The init function is where you can integrate your mod content
	pass"
