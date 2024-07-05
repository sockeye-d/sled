@tool
extends EditorScript

var path := "res://src/scripts/keyword_smooth.svg"
var color_regex: RegEx = RegEx.create_from_string(r"\w{3}\((?:[0-9]{3},?){3}\)")

func _run() -> void:
	var svg := File.get_text(path)
	print(replace_colors(svg, color_regex.search_all(svg)))


func replace_colors(string: String, matches: Array[RegExMatch]) -> String:
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
	return Color.from_hsv(color.h, color.s, 1.2 - color.v, color.a)
	#return color.inverted()
