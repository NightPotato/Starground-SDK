@tool
extends EditorPlugin

var toolPanel: Control
var sdkLoggerPanel: Control
var log_panel: RichTextLabel
var sdkAutoLoads = [
	["SDKData", "res://addons/starground-sdk/global/sdk_data.gd"],
	["SDKInternal", "res://addons/starground-sdk/scripts/sdk_internal_utils.gd"],
	["SDKDataUtils", "res://addons/starground-sdk/scripts/sdk_data_utils.gd"],
	["CreateModUtils", "res://addons/starground-sdk/scripts/create_mod_logic.gd"],
	["ExportModUtils", "res://addons/starground-sdk/scripts/export_mod_logic.gd"]
]


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	await create_sdk_logger()

	# toolBar = preload("res://addons/starground-sdk/exporter_tool.tscn").instantiate()
	# add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolBar)

	toolPanel = preload("res://addons/starground-sdk/interfaces/tools_panel.tscn").instantiate()
	toolPanel.name = _get_plugin_name()
	get_editor_interface().get_editor_main_screen().add_child(toolPanel)
	_make_visible(false)
	
	# We have to await for a frame to be able to use the SDKLogger in the setup of autoloads
	await get_tree().process_frame
	
	_setup_autoload_sdk()


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	_remove_autoload_sdk()

	if sdkLoggerPanel:
		remove_autoload_singleton("SDKLogger")
		remove_control_from_bottom_panel(sdkLoggerPanel)
		sdkLoggerPanel.queue_free()

	if toolPanel:
		toolPanel.queue_free()


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
			get_node("/root/SDKLogger").info("Added {0} as Autoload.".format([aLoad[0]]))
			print("[Starground SDK] Added {0} as Autoload.".format([aLoad[0]]))
		else:
			get_node("/root/SDKLogger").info("Project already contains {0} singleton.".format([aLoad[0]]))
			print("[Starground SDK] Project already contains {0} singleton.".format([aLoad[0]]))


func _remove_autoload_sdk():
	for aLoad in sdkAutoLoads:
		remove_autoload_singleton(aLoad[0])


func create_sdk_logger():
	add_autoload_singleton("SDKLogger", "res://addons/starground-sdk/scripts/sdk_logger.gd")
	# We need to await for the next frame so the SDKLogger exists
	await get_tree().process_frame
	sdkLoggerPanel = preload("res://addons/starground-sdk/interfaces/sdk_logger_panel.tscn").instantiate()
	# Have to use get_node instead of referencing SDKLogger directly because it doesn't exist when the 
	# script is getting parsed and will throw an error. This only happens with this script.
	get_node("/root/SDKLogger").Output = sdkLoggerPanel.Output
	add_control_to_bottom_panel(sdkLoggerPanel, "Starground SDK")
