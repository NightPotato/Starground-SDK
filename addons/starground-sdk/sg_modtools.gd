@tool
extends EditorPlugin

var toolPanel: Control
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
	
	add_autoload_singleton("SDKLogger", "res://addons/starground-sdk/scripts/sdk_logger.gd")
	
	# toolBar = preload("res://addons/starground-sdk/exporter_tool.tscn").instantiate()
	# add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolBar)

	toolPanel = preload("res://addons/starground-sdk/interfaces/tools_panel.tscn").instantiate()
	toolPanel.name = _get_plugin_name()
	get_editor_interface().get_editor_main_screen().add_child(toolPanel)
	_make_visible(false)
	
	#Using call deferred so SDKLogger has time to load properly
	call_deferred("_setup_autoload_sdk")


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	_remove_autoload_sdk()
	remove_autoload_singleton("SDKLogger")

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
			#Using get_node because this script gets compiled before it is run, and SDKLogger is
			#added as a Singleton in this same script
			get_node("/root/SDKLogger").info("Added {0} as Autoload.".format([aLoad[0]]))
			print("[Starground SDK] Added {0} as Autoload.".format([aLoad[0]]))
		else:
			get_node("/root/SDKLogger").info("Project already contains {0} singleton.".format([aLoad[0]]))
			print("[Starground SDK] Project already contains {0} singleton.".format([aLoad[0]]))


func _remove_autoload_sdk():
	for aLoad in sdkAutoLoads:
		remove_autoload_singleton(aLoad[0])
