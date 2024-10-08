@tool
extends EditorPlugin



func _ready() -> void:
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

