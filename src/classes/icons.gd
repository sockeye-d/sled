@tool
class_name Icons extends Object


@warning_ignore("unused_signal")
signal icons_changed


static var icons_path: String = "res://src/assets/icons_dark/"
static var is_light_mode: bool = true
static var loaded_icons: Dictionary = { }
static var icon_textures: Dictionary = { }
static var singleton: Icons:
	get:
		if singleton == null:
			singleton = Icons.new()
		return singleton
	set(value):
		singleton = value


static func _static_init() -> void:
	singleton.icons_changed.connect(func():
		icons_path = "res://src/assets/icons_%s/" % _get_mode_str()
	)


static func create(icon: String, return_null_on_failure: bool = false) -> IconTexture2D:
	if icon in icon_textures:
		return icon_textures[icon]
	var tex := IconTexture2D.new()
	tex.icon = icon
	if return_null_on_failure and not tex.found_icon:
		return null
	icon_textures[icon] = tex
	return tex


static func find(icon: String) -> String:
	if icons_path == "":
		icons_path = "res://src/assets/icons_dark/"
	if not icon:
		return ""
	icon = icon.replace("3d", "3D").replace("2d", "2D").replace("1d", "1D")
	var key := _get_icon_key(icon)
	if key in loaded_icons:
		return loaded_icons[key]
	var rep: PackedStringArray = [_get_mode_str(), icon]
	var tex: String
	if FileAccess.file_exists(icons_path + ("%s.svg" % icon)):
		tex = FileAccess.get_file_as_string(icons_path + ("%s.svg" % icon))
	elif FileAccess.file_exists(icons_path + ("type_%s.svg" % icon)):
		tex = FileAccess.get_file_as_string(icons_path + ("type_%s.svg" % icon))
	if tex:
		loaded_icons[key] = tex
	return tex


static func _get_icon_key(icon: String) -> String:
	return _get_mode_str() + "_" + icon


static func _get_mode_str() -> String:
	return "light" if is_light_mode else "dark"
