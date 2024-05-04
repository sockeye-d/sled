extends MarginContainer


func _ready() -> void:
	custom_minimum_size.x = get_window().get_visible_rect().size.x
	get_window().size_changed.connect(func(): custom_minimum_size.x = get_window().get_visible_rect().size.x)
