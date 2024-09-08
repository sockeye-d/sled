@tool
class_name IconTexture2D extends ImageTexture


@export var icon: String:
	get:
		return icon
	set(value):
		icon = value
		_reset_name()
		_set_image()
@export_range(0.5, 3.0, 0.0001, "or_greater", "or_less") var icon_scale: float = 1.0:
	get:
		return icon_scale
	set(value):
		icon_scale = value
		_reset_name()
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
		return icon_scale
	return (t.default_base_scale if t.has_default_base_scale() else ThemeDB.fallback_base_scale) * icon_scale


func _reset_name() -> void:
	resource_name = "%s@%.2fx (IconTexture2D)" % [icon, icon_scale]
