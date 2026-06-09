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
		_set_image(false)
var has_set_image: bool = false
var found_icon: bool = false
var last_imported_scale: float = -1.0
var timer: SceneTreeTimer


func _init() -> void:
	_set_image()
	Icons.singleton.icons_changed.connect(_set_image, CONNECT_DEFERRED)


func _set_image(force: bool = true):
	if not force and Engine.is_editor_hint():
		if timer:
			timer.timeout.disconnect(timer.timeout.get_connections().front().callable)
		timer = Engine.get_main_loop().create_timer(0.5)
		timer.timeout.connect(_set_image.bind(true))
		return
	var img := Icons.find(icon, icon_scale)
	if img:
		set_image(img)
	found_icon = img != null


func _reset_name() -> void:
	resource_name = "%s@%.2fx (IconTexture2D)" % [icon, icon_scale]
