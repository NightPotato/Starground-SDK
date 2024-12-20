@tool
class_name SDKLoggerClass extends EditorPlugin


signal info_count_changed(new_count: int)
signal warning_count_changed(new_count: int)
signal error_count_changed(new_count: int)

enum MessageType {
	INFO,
	WARNING,
	ERROR
}

var current_info_count: int = 0
var current_warning_count: int = 0
var current_error_count: int = 0
var Output: RichTextLabel
var messages: Array[Message]

var sdkLoggerPanel: Control


func _enter_tree() -> void:
	_setup_panel()


func _exit_tree() -> void:
	for message in messages:
		message.free()
	
	if sdkLoggerPanel:
		remove_control_from_bottom_panel(sdkLoggerPanel)
		sdkLoggerPanel.queue_free()


func info(message: String) -> void:
	_add_message(message, MessageType.INFO)


func warn(message: String) -> void:
	_add_message(message, MessageType.WARNING)


func error(message: String) -> void:
	_add_message(message, MessageType.ERROR)


func filter(filters: Array[MessageType], search: String) -> void:
	Output.clear()
	for message in messages:
		if message.type in filters and (search == "" or search.to_lower() in message.text.to_lower()):
			_show_message(message)


func clear() -> void:
	Output.clear()
	for message in messages:
		message.free()
	messages.clear()


func _setup_panel() -> void:
	sdkLoggerPanel = preload("res://addons/starground-sdk/interfaces/sdk_logger_panel.tscn").instantiate()
	Output = sdkLoggerPanel.Output
	add_control_to_bottom_panel(sdkLoggerPanel, "Starground SDK")


func _add_message(text: String, type: MessageType) -> void:
	match type:
		MessageType.INFO:
			current_info_count += 1
			info_count_changed.emit(current_info_count)
		MessageType.WARNING:
			current_warning_count += 1
			warning_count_changed.emit(current_warning_count)
		MessageType.ERROR:
			current_error_count += 1
			error_count_changed.emit(current_error_count)
	
	var new_message = Message.new(text, type)
	messages.append(new_message)
	_show_message(new_message)


func _show_message(message: Message) -> void:
	match message.type:
		MessageType.INFO:
			Output.append_text(message.text)
		MessageType.WARNING:
			Output.push_color(EditorInterface.get_base_control().get_theme_color("warning_color", &"Editor"))
			Output.add_image(EditorInterface.get_base_control().get_theme_icon("Warning", "EditorIcons"))
			Output.append_text(" " + message.text)
			Output.pop()
		MessageType.ERROR:
			Output.push_color(EditorInterface.get_base_control().get_theme_color("error_color", &"Editor"))
			Output.add_image(EditorInterface.get_base_control().get_theme_icon("Error", "EditorIcons"))
			Output.append_text(" " + message.text)
			Output.pop()
	Output.newline()


class Message extends Object:
	var text: String
	var type: MessageType
	
	func _init(t: String, mt: MessageType) -> void:
		text = t
		type = mt
