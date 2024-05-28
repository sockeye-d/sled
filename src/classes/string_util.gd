class_name StringUtil extends Node

static func _static_init() -> void:
	var test_string = \
"I like code
/*
inside comment!!!
*/
Not inside comment
// ehghjkw
// ehkwghjkwe838962897
// regh
// geiowoi2o906
// 3toi126u9039uioj
// ehghjkw
// ehkwghjkwe838962897
// regh
// geiowoi2o906
// 3toi126u9039uioj
// ehghjkw
// ehkwghjkwe838962897
// regh
// geiowoi2o906
// 3toi126u9039uioj
// ehghjkw
// ehkwghjkwe838962897
// regh
// geiowoi2o906
// 3toi126u9039uioj
gerwhkg"

## Replaces all instances of the keys of replacements with their values
static func replace_all(string: String, replacements: Dictionary) -> String:
	for key in replacements:
		string = string.replacen(key, replacements[key])
	
	return string

## Case-insensitive version of replace_all
static func replacen_all(string: String, replacements: Dictionary) -> String:
	for key in replacements:
		string = string.replacen(key, replacements[key])
	
	return string


static func word_wrap(string: String, length: int) -> String:
	var insert_locations: PackedInt32Array = []
	var last_wrap_pos: int = 0
	var last_wrap_char_pos: int = 0
	
	for i in string.length():
		last_wrap_pos += 1
		if string[i] == " " or string[i] == "\n":
			if last_wrap_pos >= length:
				insert_locations.append(last_wrap_char_pos)
				last_wrap_pos = i - last_wrap_char_pos
			
			last_wrap_char_pos = i
	
	insert_locations.reverse()
	for location in insert_locations:
		string[location] = "\n"
	
	return string


static func substr_pos(string: String, start: int, end: int = -1) -> String:
	start = clampi(start, 0, string.length() - 1)
	if end == -1:
		end = string.length() - 1
	end = clampi(end, 0, string.length() - 1)
	if end == start:
		return ""
	string = string.substr(start, end - start)
	if end > start:
		return string.reverse()
	return string


static func substr_line_pos(string: String, start: int, end: int = 0x7FFFFFFF) -> String:
	return "\n".join(string.split("\n", true).slice(start, end + 1))


static func substr_line(string: String, start: int, len: int = -1) -> String:
	return "\n".join(string.split("\n", true).slice(start, 0x7FFFFFFF if len == -1 else start + len))


static func remove_comments(string: String, opening := "/*", closing := "*/", single_opening := "//") -> String:
	var inside_comment := false
	var sb: StringBuilder = StringBuilder.new()
	var i: int = 0
	while i < string.length():
		if string.substr(i).begins_with(opening):
			inside_comment = true
		
		if string.substr(0, i).ends_with(closing):
			inside_comment = false
			i += 1
			continue
		
		if not inside_comment and string.substr(i).begins_with(single_opening):
			while i < string.length() and string[i] != "\n":
				i += 1
			i += 1
			continue
		if not inside_comment:
			sb.append(string[i])
		i += 1
	return sb.to_string()
