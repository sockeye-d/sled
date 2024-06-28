@tool
class_name Icons extends Object


signal icons_changed


static var is_light_mode: bool = true
static var loaded_icons: Dictionary = { }
static var singleton: Icons:
	get:
		if singleton == null:
			singleton = Icons.new()
		return singleton
	set(value):
		singleton = value


static func create(icon: String, return_null_on_failure: bool = false) -> IconTexture2D:
	var tex := IconTexture2D.new()
	tex.icon = icon
	if return_null_on_failure and not tex.found_icon:
		return null
	return tex


static func find(icon: String) -> Texture2D:
	if not icon:
		return null
	icon = icon.replace("3d", "3D").replace("2d", "2D").replace("1d", "1D")
	var key := _get_icon_key(icon)
	var mode_str := _get_mode_str()
	if key in loaded_icons:
		return loaded_icons[key]
	var tex = null
	if ResourceLoader.exists("res://src/assets/icons_%s/%s.png" % [mode_str, icon]):
		tex = load("res://src/assets/icons_%s/%s.png" % [mode_str, icon])
	elif ResourceLoader.exists("res://src/assets/icons_%s/code/%s.png" % [mode_str, icon]):
		tex = load("res://src/assets/icons_%s/code/%s.png" % [mode_str, icon])
	elif ResourceLoader.exists("res://src/assets/icons_%s/code/type_%s.png" % [mode_str, icon]):
		tex = load("res://src/assets/icons_%s/code/type_%s.png" % [mode_str, icon])
	if tex != null:
		loaded_icons[key] = tex
	return tex


static func _get_icon_key(icon: String) -> String:
	return _get_mode_str() + "_" + icon


static func _get_mode_str() -> String:
	return "light" if is_light_mode else "dark"
