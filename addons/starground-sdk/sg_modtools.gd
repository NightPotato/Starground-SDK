@tool
extends EditorPlugin

var toolPanel
var sdkLoggerOutput: VBoxContainer
var log_panel: RichTextLabel
var sdkAutoLoads = [
	["SDKEvents", "res://addons/starground-sdk/global/sdk_event_bus.gd"],
	["SDKData", "res://addons/starground-sdk/global/sdk_data.gd"],
	["SDKUtils", "res://addons/starground-sdk/scripts/sdk_utils.gd"],
	["CreateModUtils", "res://addons/starground-sdk/scripts/create_mod_logic.gd"],
	["ExportModUtils", "res://addons/starground-sdk/scripts/export_mod_logic.gd"]
]

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
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
			print("[Starground SDK] Added {0} as Autoload.".format([aLoad[0]]))
		else:
			print("[Starground SDK] Project already contains {0} singleton.".format([aLoad[0]]))

func _remove_autoload_sdk():
	for aLoad in sdkAutoLoads:
		remove_autoload_singleton(aLoad[0])
