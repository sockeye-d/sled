@tool
extends EditorScript
## Inverts all the icons

enum {
	HUE = 0,
	SAT = 1,
	LUM = 2,
}

var src_icons_path := "res://src/assets/icons_dark"
var dst_icons_path := "res://src/assets/icons_light"
var color_regex: RegEx = RegEx.create_from_string(r"\w{3}\((?:[0-9]{3},?){3}\)")
var svg_filter := "*.svg"

var default_import: String = """
[remap]

importer="keep"
"""

func _run() -> void:
	if DirAccess.dir_exists_absolute(dst_icons_path):
		DirAccess.remove_absolute(dst_icons_path)
	convert_icons(src_icons_path, dst_icons_path)
	EditorInterface.get_resource_filesystem().scan.call_deferred()

func convert_icons(from_path: String, to_path: String, base_path: String = from_path) -> void:
	for filename in DirAccess.get_files_at(from_path):
		if not filename.match(svg_filter):
			continue
		
		var src_path := from_path.path_join(filename)
		var dst_path := to_path.path_join(src_path.trim_prefix(base_path))
		var dst_dir := dst_path.get_base_dir()
		
		var new_svg := replace_colors(FileAccess.get_file_as_string(src_path))
		
		if not DirAccess.dir_exists_absolute(dst_dir):
			DirAccess.make_dir_recursive_absolute(dst_dir)
		
		var file := FileAccess.open(dst_path, FileAccess.WRITE)
		file.store_string(new_svg)
		file.flush()
		
		#file = FileAccess.open(dst_path + ".import", FileAccess.WRITE)
		#file.store_string(default_import)
		#file.flush()
		
		print("Converted ", src_path.trim_prefix(base_path))
	
	for dirname in DirAccess.get_directories_at(from_path):
		convert_icons(from_path.path_join(dirname), to_path, base_path)


func replace_colors(string: String, matches: Array[RegExMatch] = color_regex.search_all(string)) -> String:
	var sb := StringBuilder.new()
	var last_index: int = 0
	for m in matches:
		var new_index: int = m.get_start()
		sb.append(StringUtil.substr_pos(string, last_index, new_index))
		sb.append(color_string(t_color(parse_color(m.get_string()))))
		last_index = m.get_end()
	sb.append(string.substr(last_index))
	return str(sb)


func parse_color(color: String) -> Color:
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


func parse_psa(array: PackedStringArray) -> PackedInt32Array:
	var new_array: PackedInt32Array = []
	new_array.resize(array.size())
	for i in array.size():
		assert(array[i].is_valid_int())
		new_array[i] = array[i].to_int()
	return new_array


func color_string(color: Color) -> String:
	return "rgb(%s,%s,%s)" % [color.r8, color.g8, color.b8]


func t_color(color: Color) -> Color:
	color = rgb_to_hsl(color)
	color.b = 1.0 - color.b
	return hsl_to_rgb(color)


func rgb_to_hsl(color: Color) -> Color:
	var h := color.h
	var l := color.v * (1.0 - 0.5 * color.s)
	var s := (color.v - l) / minf(l, 1.0 - l)
	return Color(h, s, l, color.a)


func hsl_to_rgb(color: Color) -> Color:
	var h: float = color[HUE]
	var v: float = color[LUM] + color[SAT] * minf(color[LUM], 1.0 - color[LUM])
	var s: float = 2.0 * (1.0 - color[LUM] / v)
	
	return Color.from_hsv(h, s, v, color.a)
