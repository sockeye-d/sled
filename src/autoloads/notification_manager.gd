extends Node

@onready var notification_tray = get_tree().root.find_child("NotificationTray", true, false)

enum {
	TYPE_NORMAL,
	TYPE_WARNING,
	TYPE_ERROR,
}


const NOTIFICATION_COLORS: Dictionary = {
	TYPE_NORMAL: Color(0.5, 0.8, 0.5),
	TYPE_WARNING: Color(0.95, 0.95, 0.0),
	TYPE_ERROR: Color(1.0, 0.5, 0.5),
}


func notify(what: String, type: int, color: Color = NOTIFICATION_COLORS[type]) -> void:
	var label: NotificationLabel = NotificationLabel.new()
	label.text = what
	label.modulate = color
	label.add_theme_constant_override(&"outline_size", 3)
	label.add_theme_color_override(&"font_outline_color", color.darkened(0.5))
	notification_tray.add_child(label)
	notification_tray.move_child(label, 0)


## Use a %s placeholder for the error
func notify_err(error: Error, text: String, include_error_type := false, notification_type: int = TYPE_ERROR, notification_color: Color = NOTIFICATION_COLORS[notification_type]) -> void:
	if error:
		if include_error_type:
			text = text % error_string(error)
		notify(text, notification_type, notification_color)


func notify_if_err(error: Error, success_text: String, failed_text: String, include_error_type := false, notification_type: int = TYPE_ERROR if error else TYPE_NORMAL, notification_color: Color = NOTIFICATION_COLORS[notification_type]) -> void:
	if error:
		notify_err(error, failed_text, include_error_type, notification_type, notification_color)
	else:
		notify(success_text, notification_type, notification_color)
