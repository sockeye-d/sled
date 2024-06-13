class_name StringUtil


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


static func remove_scope(string: String, scope_opening: String, scope_closing: String, start: int = 0, exclusive: bool = false) -> String:
	var sb := StringBuilder.new()
	var scope: int = 0
	var offset: int = scope_closing.length() if exclusive else 0
	for i in string.length():
		if string.substr(i).begins_with(scope_opening):
			scope += 1
		
		if not scope == 0 and string.substr(0, i + offset).ends_with(scope_closing):
			scope -= 1
		
		if scope == 0:
			sb.append(string[i])
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
	end = clampi(end, 0, string.length())
	if end == start:
		return ""
	if end < start:
		var temp := end
		end = start
		start = temp
	string = string.substr(start, end - start)
	return string


static func substr_posv(string: String, start_end: PackedInt32Array) -> String:
	if not start_end:
		return ""
	return substr_pos(string, start_end[0], -1 if start_end.size() == 1 else start_end[1])


static func substr_line_pos(string: String, start: int, end: int = 0x7FFFFFFF) -> String:
	return "\n".join(string.split("\n", true).slice(start, end + 1))


static func substr_line(string: String, start: int, len: int = -1) -> String:
	return "\n".join(string.split("\n", true).slice(start, 0x7FFFFFFF if len == -1 else start + len))

## index_map maps between indices in the string with the comments removed and
## the string with comments
static func remove_comments(string: String, index_map: Dictionary = { }, opening := "/*", closing := "*/", single_opening := "//") -> String:
	var inside_comment := false
	var sb: StringBuilder = StringBuilder.new()
	var i: int = 0
	var mapped_i: int = 0
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
			index_map[mapped_i] = i
			sb.append(string[i])
			mapped_i += 1
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
		
		if string.substr(i).begins_with(scope_closing):
			scope -= 1
		
		if scope == 0:
			return i
	return -1

static func find_scope_beginning(string: String, start: int, scope_opening: String, scope_closing: String) -> int:
	var scope: int = 1
	for i in range(start, -1, -1):
		if string.substr(i).begins_with(scope_opening):
			scope -= 1
		
		if string.substr(i).begins_with(scope_closing):
			scope += 1
		
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
static func begins_with_any(string: String, texts: PackedStringArray) -> String:
	for text in texts:
		if string.begins_with(text):
			return text
	return ""

## Returns [code]true[/code] if the string begins with any of the given strings
static func begins_with_any_index(string: String, texts: PackedStringArray) -> int:
	for text_index in texts.size():
		if string.begins_with(texts[text_index]):
			return text_index
	return -1

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
		if new_index == -1:
			index = new_index
			continue
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
		if new_index == -1:
			index = new_index
			continue
		var substr := StringUtil.substr_pos(string, index, new_index)
		if strip_edges:
			substr = substr.strip_edges()
		if allow_empty or substr:
			array.append(substr)
		index = new_index
	array.append(string.substr(index))
	return array


static func rtrim_index(string: String, what: PackedStringArray, start: int = -1) -> int:
	for i in range(posmod(start, string.length()), -1, -1):
		if not string[i] in what:
			return i
	return 0


static func get_index(string: String, line: int, column: int) -> int:
	var total_index: int = 0
	for line_str in string.split("\n").slice(0, line):
		total_index += line_str.length() + 1
	return total_index + column

## Returns (column, line)
static func get_line_col(string: String, index: int) -> Vector2i:
	var line: int = string.substr(0, index).count("\n")
	var col: int = index - string.rfind("\n", index) - 1
	return Vector2i(col, line)

## Returns the start and end of the word
static func get_word(string: String, index: int, allowed_chars_left: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_", allowed_chars_right: String = allowed_chars_left) -> PackedInt32Array:
	if string[index] not in allowed_chars_left:
		return []
	var start_index := index
	var end_index := index
	while start_index >= 0 and string[start_index] in allowed_chars_left:
		start_index -= 1
	while end_index < string.length() and string[end_index] in allowed_chars_right:
		end_index += 1
	return [start_index + 1, end_index]

## Returns the start and end of the word
static func get_word_code(string: String, index: int) -> PackedInt32Array:
	if index > string.length():
		return []
	var start_index := index
	var end_index := index
	var left_valid_chars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_."# + "".join(StringUtil.WHITESPACE)
	while end_index < string.length() - 1 and string[end_index] in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_":
		end_index += 1
	while start_index > 0 and start_index < string.length() and string[start_index] in left_valid_chars:
		start_index -= 1
		if string[start_index] == ")":
			var new_start_index = StringUtil.find_scope_beginning(string, start_index - 1, "(", ")") - 1
			if new_start_index < 0 or new_start_index > start_index:
				return []
			start_index = new_start_index
	if start_index < 0 or start_index > string.length() - 1:
		return []
	return [start_index + 1, end_index]


static func split_scoped(string: String, delim: String, scope_open: String, scope_close: String, target_scope: int = 0) -> PackedStringArray:
	var arr: PackedStringArray = []
	var scope: int = 0
	var last_index: int = 0
	for i in string.length():
		var s := string.substr(i)
		if s.begins_with(scope_open):
			scope += 1
		if s.begins_with(scope_close):
			scope -= 1
		if scope == target_scope and s.begins_with(delim):
			arr.append(StringUtil.substr_pos(string, last_index, i))
			last_index = i + delim.length()
	arr.append(string.substr(last_index))
	return arr


static func find_all_occurrences(string: String, what: String) -> Array[Vector2i]:
	var i: int = 0
	var o: Array[Vector2i] = []
	while i < string.length():
		var new_i: int = string.find(what, i)
		if new_i == -1:
			return o
		o.append(Vector2i(new_i, new_i + what.length()))
		i = new_i + what.length()
	return o


static func findn_all_occurrences(string: String, what: String) -> Array[Vector2i]:
	var i: int = 0
	var o: Array[Vector2i] = []
	while i < string.length():
		var new_i: int = string.findn(what, i)
		if new_i == -1:
			return o
		o.append(Vector2i(new_i, new_i + what.length()))
		i = new_i + what.length()
	return o
