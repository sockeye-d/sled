class_name RegExUtil

# Struct-matching regex
# /struct (?:[\w]|\n)+ *{(?:\s)*(?:[\w\s,]+;\n*)*(?:\s)*}/
# Variable-matching regex
# /(?:float|vec2|vec3|vec4)\s+(?:[\w]+\s*,?\s*)+;/
# Method-matching regex
# /(?:float|vec2|vec3|vec4)\s+\w+\((?:[\w]+\s*,?\s*)*\)/


static var _memoized_regexes: Dictionary[String, RegEx] = { }


static var last_regex_create_error: Error


static func create(pattern: String) -> RegEx:
	if pattern in _memoized_regexes:
		return _memoized_regexes[pattern]
	var regex := RegEx.new()
	var err := regex.compile(pattern)
	if err:
		last_regex_create_error = err
		return null
	_memoized_regexes[pattern] = regex
	return regex


static func as_lowercase(pattern: String) -> String:
	var escape_count: int = 0
	var sb: StringBuilder = StringBuilder.new()
	for i in pattern.length():
		var append_text: String = pattern[i]
		if pattern[i] == "\\":
			escape_count += 1
		else:
			if escape_count % 2 == 0:
				append_text = append_text.to_lower()
			escape_count = 0
		sb.append(append_text)
	return str(sb)


static func searchn_all(subject: String, regex: RegEx) -> Array[RegExMatch]:
	subject = subject.to_lower()
	var pattern := RegEx.create_from_string(RegExUtil.as_lowercase(regex.get_pattern()))
	return pattern.search_all(subject)
