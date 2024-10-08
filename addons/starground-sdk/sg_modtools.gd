@tool
extends EditorPlugin

var toolPanel
var sdkLoggerOutput: VBoxContainer
var log_panel: RichTextLabel
var sdkAutoLoads = [
	["SDKData", "res://addons/starground-sdk/global/sdk_data.gd"],
	["SDKInternal", "res://addons/starground-sdk/scripts/sdk_internal_utils.gd"],
	["LoggerUtils", "res://addons/starground-sdk/scripts/logger_utils.gd"],
	["SDKDataUtils", "res://addons/starground-sdk/scripts/sdk_data_utils.gd"],
	["CreateModUtils", "res://addons/starground-sdk/scripts/create_mod_logic.gd"],
	["ExportModUtils", "res://addons/starground-sdk/scripts/export_mod_logic.gd"]
]

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	create_sdk_logger()

	# toolBar = preload("res://addons/starground-sdk/exporter_tool.tscn").instantiate()
	# add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolBar)

	toolPanel = preload("res://addons/starground-sdk/interfaces/tools_panel.tscn").instantiate()
	toolPanel.name = _get_plugin_name()
	get_editor_interface().get_editor_main_screen().add_child(toolPanel)
	_make_visible(false)


	_setup_autoload_sdk()



func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	_remove_autoload_sdk()

	if sdkLoggerOutput:
		remove_control_from_bottom_panel(sdkLoggerOutput)
		sdkLoggerOutput.free()

	if toolPanel:
		toolPanel.free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible):
	if toolPanel:
		toolPanel.visible = visible

func _get_plugin_name():
	return "Starground SDK"


func _get_plugin_icon():
	return EditorInterface.get_base_control().get_theme_icon(&"Tools", &"EditorIcons")


func _setup_autoload_sdk() -> void:
	for aLoad in sdkAutoLoads:
		if not ProjectSettings.has_setting("autoload/" + aLoad[0]):
			add_autoload_singleton(aLoad[0], aLoad[1])
			log_message("Added {0} as Autoload.".format([aLoad[0]]))
			print("[Starground SDK] Added {0} as Autoload.".format([aLoad[0]]))
		else:
			print("[Starground SDK] Project already contains {0} singleton.".format([aLoad[0]]))

func _remove_autoload_sdk():
	for aLoad in sdkAutoLoads:
		remove_autoload_singleton(aLoad[0])


# TODO: Move this to a better implementation that I can globally reference within mutltiple locations.
func create_sdk_logger():
	sdkLoggerOutput = VBoxContainer.new()
	log_panel = RichTextLabel.new()
	log_panel.bbcode_enabled = true
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sdkLoggerOutput.add_child(log_panel)

	add_control_to_bottom_panel(sdkLoggerOutput, "Starground SDK")

# Function to log standard messages with BBCode support
func log_message(message: String):
	log_panel.append_text("[color=#f26f0c][Starground SDK][/color] - " + message + "\n")
	# log_panel.append_bbcode("[color=#f26f0c][Starground SDK][/color] - " + message + "\n")

# Function to log warning messages in yellow
func log_warning(message: String):
	log_panel.append_bbcode("[color=yellow]" + message + "[/color]\n")

# Function to log error messages in red
func log_error(message: String):
	log_panel.append_bbcode("[color=red]" + message + "[/color]\n")