class_name RegExUtil

# Struct-matching regex
# /struct (?:[\w]|\n)+ *{(?:\s)*(?:[\w\s,]+;\n*)*(?:\s)*}/
# Variable-matching regex
# /(?:float|vec2|vec3|vec4)\s+(?:[\w]+\s*,?\s*)+;/
# Method-matching regex
# /(?:float|vec2|vec3|vec4)\s+\w+\((?:[\w]+\s*,?\s*)*\)/


static var _memoized_regexes: Dictionary = { }


static func create(pattern: String) -> RegEx:
	if pattern in _memoized_regexes:
		return _memoized_regexes[pattern]
	var regex = RegEx.create_from_string(pattern)
	_memoized_regexes[pattern] = regex
	return regex
