@tool
extends EditorPlugin

#
# Helper Methods for Template Related Tasks.
#

# TODO: Check if template exists.
func check_for_template_file() -> bool:
	return false

# TODO: Write logic to grab from the official Modding Repo.
func get_template_file(template: String) -> bool:

    # Check for a link to download within res://addons/starground-sdk/data/download_paths.json
    # HTTPRequest based file download
    # Move the download to res://templates/

	return true

#
# Helper Methods for Internal Tooling
#

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