@tool
class_name IconTexture2D extends ImageTexture


@export var icon: String:
	get:
		return icon
	set(value):
		icon = value
		resource_name = "%s (Icon)" % icon
		_set_image()
var has_set_image: bool = false
var found_icon: bool = false


func _init() -> void:
	_set_image()
	Icons.singleton.icons_changed.connect(_set_image)


func _set_image():
	var img := Icons.find(icon)
	if img:
		found_icon = true
		if has_set_image:
			update(img.get_image())
		else:
			set_image(img.get_image())
	else:
		found_icon = false
