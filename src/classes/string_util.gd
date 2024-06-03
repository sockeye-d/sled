class_name StringUtil extends Node


const WHITESPACE := ["\n", " ", "\r"]


static func remove_inaccesible_scope(string: String, scope_opening: String, scope_closing: String, start: int = -1) -> String:
	var sb := StringBuilder.new()
	var scope: int = 0
	var last_scope = scope
	var inside_bad_scope: bool = false
	for i in range(posmod(start, string.length()), -1, -1):
		if string.substr(i + 1).begins_with(scope_opening):
			scope -= 1
			if inside_bad_scope and scope == last_scope:
				inside_bad_scope = false
		
		if string.substr(0, i + 0).ends_with(scope_closing):
			if not inside_bad_scope:
				last_scope = scope
			inside_bad_scope = true
			scope += 1
		
		if scope < 1 and not inside_bad_scope:
			sb.append(string[i])
	sb.reverse()
	return str(sb)


## The array returned contains the scope detected. If the scope is -1, it means
## it was inaccesible, otherwise it is the scope level (0 is the closest scope,
## 1 is the next closest, etc.)
static func detect_inaccesible_scope(string: String, scope_opening: String, scope_closing: String, start: int = -1) -> PackedInt32Array:
	var array: PackedInt32Array = []
	array.resize(string.length())
	var scope: int = 0
	var last_scope = scope
	var inside_bad_scope: bool = false
	for i in range(posmod(start, string.length()), -1, -1):
		if string.substr(i + 1).begins_with(scope_opening):
			scope -= 1
			if inside_bad_scope and scope == last_scope:
				inside_bad_scope = false
		
		if string.substr(0, i + 0).ends_with(scope_closing):
			if not inside_bad_scope:
				last_scope = scope
			inside_bad_scope = true
			scope += 1
		
		if scope < 1 and not inside_bad_scope:
			array[i] = -scope
		else:
			array[i] = -1
	return array

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
	if end < start:
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


static func find_scoped(string: String, what: String, start: int, scope_opening: String, scope_closing: String) -> int:
	var scope: int = 0
	for i in range(start, string.length()):
		if string.substr(i).begins_with(scope_opening):
			scope += 1
			continue
		if string.substr(0, i).ends_with(scope_closing):
			scope -= 1
			continue
		if scope == 0 and string.substr(i).begins_with(what):
			return i
	return -1


static func find_scope_end(string: String, start: int, scope_opening: String, scope_closing: String) -> int:
	var scope: int = 1
	for i in range(start, string.length()):
		if string.substr(i).begins_with(scope_opening):
			scope += 1
		
		if string.substr(0, i).ends_with(scope_closing):
			scope -= 1
		
		if scope == 0:
			return i
	return -1

## Finds the first instance of any of the elements of [code]what[/code]
static func find_any(string: String, what: PackedStringArray, start: int = 0) -> int:
	var current_index: int = -1
	for w in what:
		var index := string.find(w, start)
		if not index == -1 and index < current_index or current_index == -1:
			current_index = index
	return current_index

## Finds the first instance of any of the elements of [code]what[/code]
static func findn_any(string: String, what: PackedStringArray, start: int = 0) -> int:
	var current_index: int = -1
	for w in what:
		var index := string.findn(w, start)
		if not index == -1 and index < current_index or current_index == -1:
			current_index = index
	return current_index

## Finds the last instance of any of the elements of [code]what[/code]
static func rfind_any(string: String, what: PackedStringArray, start: int = 0) -> int:
	var current_index: int = -1
	for w in what:
		var index := string.rfind(w, start)
		if not index == -1 and index > current_index:
			current_index = index
	return current_index

## Finds the last instance of any of the elements of [code]what[/code]
static func rfindn_any(string: String, what: PackedStringArray, start: int = 0) -> int:
	var current_index: int = -1
	for w in what:
		var index := string.rfindn(w, start)
		if not index == -1 and index > current_index or current_index == -1:
			current_index = index
	return current_index

## Returns [code]true[/code] if the string begins with any of the given strings
static func begins_with_any(string: String, texts: PackedStringArray) -> bool:
	for text in texts:
		if string.begins_with(text):
			return true
	return false

## Returns [code]true[/code] if the string ends with any of the given strings
static func ends_with_any(string: String, texts: PackedStringArray) -> bool:
	for text in texts:
		if string.ends_with(text):
			return true
	return false


static func split_at(string: String, index: int) -> PackedStringArray:
	return [string.substr(0, index), string.substr(index)]


static func split_at_first(string: String, what: String, strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var index := string.find(what)
	if not allow_empty and index == -1:
		return [string]
	return [string.substr(0, index), string.substr(index)]


static func split_at_first_any(string: String, what: PackedStringArray, strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var index := StringUtil.find_any(string, what)
	if not allow_empty and index == -1:
		return [string]
	return [string.substr(0, index), string.substr(index)]


static func split_at_firstn(string: String, what: String, strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var index := string.findn(what)
	if not allow_empty and index == -1:
		return [string]
	if strip_edges:
		return [string.substr(0, index).strip_edges(), string.substr(index).strip_edges()]
	return [string.substr(0, index), string.substr(index)]


static func split_at_firstn_any(string: String, what: PackedStringArray, strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var index := StringUtil.findn_any(string, what)
	if not allow_empty and index == -1:
		return [string]
	if strip_edges:
		return [string.substr(0, index).strip_edges(), string.substr(index).strip_edges()]
	return [string.substr(0, index), string.substr(index)]


static func split_at_sequence(string: String, what: Array[PackedStringArray], strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var array: PackedStringArray = []
	var index: int = 0
	for w in what:
		var new_index := StringUtil.find_any(string, w, index)
		var substr := StringUtil.substr_pos(string, index, new_index)
		if strip_edges:
			substr = substr.strip_edges()
		if allow_empty or substr:
			array.append(substr)
		index = new_index
	array.append(string.substr(index))
	return array


static func splitn_at_sequence(string: String, what: Array[PackedStringArray], strip_edges: bool = false, allow_empty: bool = true) -> PackedStringArray:
	var array: PackedStringArray = []
	var index: int = 0
	for w in what:
		var new_index := StringUtil.findn_any(string, w, index)
		var substr := StringUtil.substr_pos(string, index, new_index)
		if strip_edges:
			substr = substr.strip_edges()
		if allow_empty or substr:
			array.append(substr)
		index = new_index
	array.append(string.substr(index))
	return array
