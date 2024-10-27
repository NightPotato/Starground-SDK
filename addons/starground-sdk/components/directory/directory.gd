@tool
class_name DirectorySelector extends HBoxContainer

enum Type {
	GAMEPATH,
	OUTPATH,
}

@export var type: Type

@export var placeholder_text: String: 
	set(text):
		placeholder_text = text
		if DirectoryInput:
			DirectoryInput.placeholder_text = text

var current_directory: String = ""

@onready var DirectoryInput: LineEdit = $DirectoryInput
@onready var OpenDialogButton: Button = $OpenDialogButton
var DirectoryDialog: EditorFileDialog = EditorFileDialog.new()

func _ready() -> void:
	DirectoryDialog.title = "Select " + placeholder_text
	DirectoryDialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	DirectoryDialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	add_child(DirectoryDialog)
	DirectoryDialog.dir_selected.connect(_on_directoy_selected)


func _on_open_dialog_button_pressed() -> void:
	DirectoryDialog.popup_file_dialog()


func _on_directoy_selected(dir: String) -> void:
	current_directory = dir
	DirectoryInput.text = dir
	SDKData.emit_signal("directory_changed", type, dir)


func _on_directory_input_text_changed(new_text: String) -> void:
	current_directory = new_text
