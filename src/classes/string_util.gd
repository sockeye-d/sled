class_name StringUtil extends Node

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
