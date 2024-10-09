@tool
extends Node


var defaultEditorSettings: Dictionary = {
	"ExportSettings": {
		"export_path": "",
		"export_shouldMove": false,
		"export_game_path": ""
	}
}

var editorSettings: Dictionary
var modProjects: Array

