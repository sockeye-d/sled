@tool
class_name IconTexture2D extends ImageTexture


@export var icon: String:
	get:
		return icon
	set(value):
		icon = value
		resource_name = "%s (IconTexture2D)" % icon
		_set_image()
var has_set_image: bool = false
var found_icon: bool = false
var last_imported_scale: float = -1.0


func _init() -> void:
	_set_image()
	Icons.singleton.icons_changed.connect(_set_image, CONNECT_DEFERRED)


func _set_image():
	var svg_str := Icons.find(icon)
	if svg_str:
		var svg: Image = Image.new()
		var current_scale := _get_scale()
		svg.load_svg_from_string(svg_str, current_scale)
		found_icon = true
		set_image(svg)
	else:
		found_icon = false


func _get_scale() -> float:
	var t := ThemeDB.get_project_theme()
	if not t:
		return 1.0
	return t.default_base_scale if t.has_default_base_scale() else ThemeDB.fallback_base_scale
