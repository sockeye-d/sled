@tool
class_name Icons extends Object


@warning_ignore("unused_signal")
signal icons_changed


static var is_light_mode: bool = true
static var icons_path: String = "res://src/assets/icons_dark/"
static var loaded_icons: Dictionary[String, Image]
static var icon_textures: Dictionary[String, IconTexture2D]
static var singleton: Icons:
	get:
		if singleton == null:
			singleton = Icons.new()
		return singleton
	set(value):
		singleton = value
static var mat_regex := RegEx.create_from_string(r"mat(\d+)\b")
static var icon_color: Color
static var placeholder_image: Image


enum {
	HUE = 0,
	SAT = 1,
	LUM = 2,
}
static var color_regex: RegEx = RegEx.create_from_string(r"\w{3}\((?:[0-9]{3},?){3}\)")


static func create(icon: String, return_null_on_failure: bool = false) -> IconTexture2D:
	if icon in icon_textures:
		return icon_textures[icon]
	var tex := IconTexture2D.new()
	tex.icon = icon
	if return_null_on_failure and not tex.found_icon:
		return null
	icon_textures[icon] = tex
	return tex


static func find(icon: String, icon_scale: float) -> Image:
	if not icon:
		return placeholder_image
	icon = (icon
		.replace("3d", "3D")
		.replace("2d", "2D")
		.replace("1d", "1D")
	)
	var real_scale := _get_scale(icon_scale)
	icon = mat_regex.sub(icon, "$0x$1")
	var key := _get_icon_key(icon, real_scale)
	if key in loaded_icons:
		return loaded_icons[key]
	var tex_str: String
	if FileAccess.file_exists(icons_path + ("%s.svg" % icon)):
		tex_str = FileAccess.get_file_as_string(icons_path + ("%s.svg" % icon))
	elif FileAccess.file_exists(icons_path + ("type_%s.svg" % icon)):
		tex_str = FileAccess.get_file_as_string(icons_path + ("type_%s.svg" % icon))
	else:
		pass
		#printerr("Icon '%s' not found" % icon)
	var img: Image
	if tex_str:
		img = Image.new()
		var processed_str := replace_colors(tex_str)
		img.load_svg_from_string(processed_str, real_scale)
		loaded_icons[key] = img
	return img


static func _get_scale(icon_scale: float) -> float:
	var t := ThemeDB.get_project_theme()
	if not t:
		return icon_scale
	return (t.default_base_scale if t.has_default_base_scale() else ThemeDB.fallback_base_scale) * icon_scale


static func _get_icon_key(icon: String, icon_scale: float) -> String:
	return "".join([_get_mode_str(), icon, icon_scale])


static func _get_mode_str() -> String:
	return str(icon_color)


static func replace_colors(string: String, matches: Array[RegExMatch] = color_regex.search_all(string)) -> String:
	var sb := StringBuilder.new()
	var last_index: int = 0
	for m in matches:
		var new_index: int = m.get_start()
		sb.append(StringUtil.substr_pos(string, last_index, new_index))
		sb.append(color_string(icon_color))
		last_index = m.get_end()
	sb.append(string.substr(last_index))
	return str(sb)


static func parse_color(color: String) -> Color:
	var vals := parse_psa(
		StringUtil.substr_pos(
			color,
			color.find("(") + 1,
			color.rfind(")")
		)
		.split(",")
	)
	assert(vals.size() == 3)
	return Color8(vals[0], vals[1], vals[2])


static func parse_psa(array: PackedStringArray) -> PackedInt32Array:
	var new_array: PackedInt32Array = []
	new_array.resize(array.size())
	for i in array.size():
		assert(array[i].is_valid_int())
		new_array[i] = array[i].to_int()
	return new_array


static func color_string(color: Color) -> String:
	return "rgb(%s,%s,%s)" % [color.r8, color.g8, color.b8]


static func t_color(color: Color) -> Color:
	color = rgb_to_hsl(color)
	#color.s *= 0.7
	color.b = 1.0 - color.b
	return hsl_to_rgb(color)


static func rgb_to_hsl(color: Color) -> Color:
	var h := color.h
	var l := color.v * (1.0 - 0.5 * color.s)
	var s := (color.v - l) / minf(l, 1.0 - l)
	return Color(h, s, l, color.a)


static func hsl_to_rgb(color: Color) -> Color:
	var h: float = color[HUE]
	var v: float = color[LUM] + color[SAT] * minf(color[LUM], 1.0 - color[LUM])
	var s: float = 2.0 * (1.0 - color[LUM] / v)

	return Color.from_hsv(h, s, v, color.a)
