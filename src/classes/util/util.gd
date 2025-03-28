class_name Util


static func default(value, default_value):
	if value:
		return value
	return default_value


static func get_caret_index(code_edit: CodeEdit, caret_index: int = 0) -> int:
	return StringUtil.get_index(code_edit.text, code_edit.get_caret_line(caret_index), code_edit.get_caret_column(caret_index))


static func search(text: String, pattern: String, use_regex: bool, case_insensitive: bool, select_occurence: bool = true) -> Array[Vector2i]:
	var found_ranges: Array[Vector2i] = []
	if use_regex:
		var regex: RegEx
		if case_insensitive:
			pattern = RegExUtil.as_lowercase(pattern)
			text = text.to_lower()
		else:
			text = text
		regex = RegExUtil.create(pattern)
		if not regex:
			NotificationManager.notify("Pattern '%s' failed to compile" % pattern, NotificationManager.TYPE_ERROR)
			found_ranges = []
		else:
			found_ranges.assign(regex.search_all(text).map(_match_to_range))
	else:
		if case_insensitive:
			found_ranges = StringUtil.findn_all_occurrences(text, pattern)
		else:
			found_ranges = StringUtil.find_all_occurrences(text, pattern)
	
	return found_ranges


static func _match_to_range(m: RegExMatch) -> Vector2i:
	return Vector2i(m.get_start(), m.get_end())


static func grow_r2(rect: Rect2, amount: float) -> Rect2:
	return Rect2(rect.position - Vector2.ONE * amount * 0.5, rect.size + Vector2.ONE * amount)


static func is_none(value: Variant) -> bool:
	match typeof(value):
		TYPE_FLOAT:
			return is_equal_approx(value, -1.0)
		TYPE_VECTOR2:
			return (
				is_equal_approx(value.x, -1.0)
				or is_equal_approx(value.y, -1.0)
			)
		TYPE_VECTOR3:
			return (
				is_equal_approx(value.x, -1.0)
				or is_equal_approx(value.y, -1.0)
				or is_equal_approx(value.z, -1.0)
			)
		TYPE_INT:
			return value == -1
		TYPE_VECTOR2I:
			return value.x == -1 or value.y == -1
		TYPE_VECTOR3I:
			return value.x == -1 or value.y == -1 or value.z == -1
		TYPE_ARRAY, TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY, TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY:
			return value.size() == 0
		TYPE_DICTIONARY:
			return value.size() == 0
	return is_instance_valid(value)


static func signed_sqr(x: float) -> float:
	return x * x * signf(x)
