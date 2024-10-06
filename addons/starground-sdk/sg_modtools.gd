@tool
extends EditorPlugin

var toolPanel

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	# toolBar = preload("res://addons/starground-sdk/exporter_tool.tscn").instantiate()
	# add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolBar)
	
	toolPanel = preload("res://addons/starground-sdk/interfaces/tools_panel.tscn").instantiate()
	toolPanel.name = _get_plugin_name()
	get_editor_interface().get_editor_main_screen().add_child(toolPanel)
	_make_visible(false)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	if toolPanel:
		toolPanel.free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible):
	if toolPanel:
		toolPanel.visible = visible

# func connect_to_script_editor() -> void:
# 	EditorInterface.get_script_editor().editor_script_changed.connect(ModToolUtils.reload_script.bind(mod_tool_store))

func _get_plugin_name():
	return "Starground SDK"


func _get_plugin_icon():
	return EditorInterface.get_base_control().get_theme_icon(&"Tools", &"EditorIcons")
