@tool
extends Node
class_name SGModUtils


static func get_file_as_text(path: String) -> String:
    var file_access := FileAccess.open(path, FileAccess.READ)
    var content := file_access.get_as_text()
    file_access.close()
    return content