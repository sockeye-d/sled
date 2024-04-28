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
	TYPE_ERROR: Color(0.8, 0.3, 0.3),
}


func notify(what: String, type: int, color: Color = NOTIFICATION_COLORS[type]) -> void:
	var label: NotificationLabel = NotificationLabel.new()
	label.text = what
	label.modulate = color
	label.add_theme_constant_override(&"outline_size", 3)
	label.add_theme_color_override(&"font_outline_color", color.darkened(0.5))
	notification_tray.add_child(label)
