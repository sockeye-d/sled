@tool
class_name Throbber extends Control


@onready var color_rect: ColorRect = %ColorRect


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if not is_node_ready():
			await ready
		color_rect.material.set_shader_parameter(&"color", get_theme_color(&"color", &"Throbber"))
		custom_minimum_size = Vector2(0, get_theme_constant(&"thickness", &"Throbber"))
