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
