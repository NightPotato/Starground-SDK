@tool
extends MarginContainer


@export var Output: RichTextLabel
@export var InfoButton: Button
@export var ErrorButton: Button
@export var WarningButton: Button
@export var SearchBar: LineEdit
@export var ClearButton: Button
@export var SearchButton: Button


var filter: Array[SDKLoggerClass.MessageType] = [
	SDKLogger.MessageType.INFO,
	SDKLogger.MessageType.ERROR, 
	SDKLogger.MessageType.WARNING,
]
var search: String = ""


func _ready() -> void:
	InfoButton.icon = EditorInterface.get_base_control().get_theme_icon("Popup", "EditorIcons")
	InfoButton.theme_type_variation = "EditorLogFilterButton"
	InfoButton.text = str(SDKLogger.current_info_count)
	InfoButton.toggled.connect(Callable(_on_filter_button_toggled).bind(SDKLogger.MessageType.INFO))
	SDKLogger.info_count_changed.connect(func(count): InfoButton.text = str(count))
	
	ErrorButton.icon = EditorInterface.get_base_control().get_theme_icon("StatusError", "EditorIcons")
	ErrorButton.theme_type_variation = "EditorLogFilterButton"
	ErrorButton.text = str(SDKLogger.current_error_count)
	ErrorButton.toggled.connect(Callable(_on_filter_button_toggled).bind(SDKLogger.MessageType.ERROR))
	SDKLogger.error_count_changed.connect(func(count): ErrorButton.text = str(count))
	
	WarningButton.icon = EditorInterface.get_base_control().get_theme_icon("StatusWarning", "EditorIcons")
	WarningButton.theme_type_variation = "EditorLogFilterButton"
	WarningButton.text = str(SDKLogger.current_warning_count)
	WarningButton.toggled.connect(Callable(_on_filter_button_toggled).bind(SDKLogger.MessageType.WARNING))
	SDKLogger.warning_count_changed.connect(func(count): WarningButton.text = str(count))
	
	ClearButton.icon = EditorInterface.get_base_control().get_theme_icon("Clear", "EditorIcons")
	SearchButton.icon = EditorInterface.get_base_control().get_theme_icon("Search", "EditorIcons")
	
	SearchBar.right_icon = EditorInterface.get_base_control().get_theme_icon("Search", "EditorIcons")


func _on_filter_button_toggled(toggled_on: bool, type: SDKLogger.MessageType) -> void:
	if toggled_on:
		filter.append(type)
	else:
		filter.erase(type)
	
	SDKLogger.filter(filter, search)


func _on_search_bar_text_changed(new_text: String) -> void:
	search = new_text
	SDKLogger.filter(filter, search)


func _on_search_button_toggled(toggled_on: bool) -> void:
	SearchBar.visible = toggled_on


func _on_clear_button_pressed() -> void:
	SDKLogger.clear()
