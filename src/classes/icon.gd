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
		var new_img: Image = img.duplicate().get_image()
		new_img.resize(
			int(img.get_width() * _get_scale()),
			int(img.get_height() * _get_scale()),
			Image.Interpolation.INTERPOLATE_CUBIC,
		)
		found_icon = true
		if has_set_image:
			update(new_img)
		else:
			set_image(new_img)
	else:
		found_icon = false


func _get_scale() -> float:
	var t := ThemeDB.get_project_theme()
	if not t:
		return 1.0
	return t.default_base_scale if t.has_default_base_scale() else ThemeDB.fallback_base_scale
