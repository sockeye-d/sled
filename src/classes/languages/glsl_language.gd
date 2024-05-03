class_name GLSLLanguage extends Language


const _ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."


static func _static_init() -> void:
	base_types = [
		"void",
		# Basic types
		"bool",
		"int",
		"uint",
		"float",
		"double",
		# Vector types
		"bvec2",
		"bvec3",
		"bvec4",
		"ivec2",
		"ivec3",
		"ivec4",
		"uvec2",
		"uvec3",
		"uvec4",
		"dvec2",
		"dvec3",
		"dvec4",
		"vec2",
		"vec3",
		"vec4",
		# Square matrices
		"mat2",
		"mat3",
		"mat4",
		# Non-square matrices
		"mat2x2",
		"mat2x3",
		"mat2x4",
		"mat3x2",
		"mat3x3",
		"mat3x4",
		"mat4x2",
		"mat4x3",
		"mat4x4",
		"mat4x2",
		"mat2x3",
		"mat2x4",
		# Double-precision matrices
		"dmat2",
		"dmat3",
		"dmat4",
		"dmat2x2",
		"dmat2x3",
		"dmat2x4",
		"dmat3x2",
		"dmat3x3",
		"dmat3x4",
		"dmat4x2",
		"dmat4x3",
		"dmat4x4",
		"dmat4x2",
		"dmat2x3",
		"dmat2x4",
		# Samplers
		"sampler1D",
		"sampler2D",
		"sampler3D",
		"samplerCube",
		"sampler2DRect",
		"sampler1DArray",
		"sampler2DArray",
		"samplerCubeArray",
		"samplerBuffer",
		"sampler2DMS",
		"sampler2DMSArray",
		"isampler1D",
		"isampler2D",
		"isampler3D",
		"isamplerCube",
		"isampler2DRect",
		"isampler1DArray",
		"isampler2DArray",
		"isamplerCubeArray",
		"isamplerBuffer",
		"isampler2DMS",
		"isampler2DMSArray",
		"usampler1D",
		"usampler2D",
		"usampler3D",
		"usamplerCube",
		"usampler2DRect",
		"usampler1DArray",
		"usampler2DArray",
		"usamplerCubeArray",
		"usamplerBuffer",
		"usampler2DMS",
		"usampler2DMSArray",
		"sampler1DShadow",
		"sampler2DShadow",
		"samplerCubeShadow",
		"sampler2DRectShadow",
		"sampler1DArrayShadow",
		"sampler2DArrayShadow",
		"samplerCubeArrayShadow",
	]
	keywords = [
		# Swizzle masks
		"x",
		"y",
		"z",
		"w",
		"r",
		"g",
		"b",
		"a",
		"s",
		"t",
		"p",
		"q",
		# Other
		"attribute",
		"const",
		"uniform",
		"varying",
		"layout",
		"centroid",
		"flat",
		"smooth",
		"noperspective",
		"patch",
		"sample",
		"break",
		"continue",
		"do",
		"for",
		"while",
		"switch",
		"case",
		"default",
		"if",
		"else",
		"subroutine",
		"in",
		"out",
		"inout",
		"lowp",
		"mediump",
		"highp",
		"precision",
		"struct",
		# Preprocessor stuff
		"define",
		"defined",
		"undef",
		
		"#if",
		"#ifdef",
		"#ifndef",
		"#else",
		"#elif",
		"#endif",
		
		"#version",
		"#compatibility",
		"#line",
		"#pragma",
		"#extension",
		"#include",
	]
	comment_regions = ["//", "/* */"]
	# GLSL has no strings
	string_regions = []


static func get_code_completion_suggestions(path: String, file: String, line: int = -1, base_path: String = path) -> Array[CodeCompletionSuggestion]:
	# Takes a little effort to convert an untyped array to a typed one
	var untyped_array: Array = _get_code_completion_suggestions(path, file, line, 0, base_path).values()
	var typed_array: Array[CodeCompletionSuggestion] = []
	typed_array.assign(untyped_array)
	return typed_array


static func _get_code_completion_suggestions(path: String, file: String, editing_line: int = -1, depth: int = 0, base_path: String = "", visited_files: PackedStringArray = []) -> Dictionary:
	visited_files.append(path)
	# Dictionary[value, CodeCompletionSuggestion]
	var suggestions: Dictionary = { }
	var included_files: PackedStringArray = []
	var definitions: Dictionary = { }
	var file_split = file.replace(";", "\n").split("\n", false)
	if not editing_line == -1:
		file_split.resize(editing_line)

	var is_comment: bool = false
	for line_whitespaceful in file_split:
		var line = line_whitespaceful.strip_edges().lstrip(" ")
		var line_comments_removed = ""
		# Find the comments so they can be removed
		for char_ind in line.length():
			if char_ind + 1 < line.length() and line[char_ind] == "/" and line[char_ind + 1] == "/":
				# Line comment, can break here instead of setting is_comment
				# because nothing interesting is
				# going to happen for the rest of the line
				line_comments_removed = line.substr(0, char_ind)
				break
			if char_ind + 1 < line.length() and line[char_ind] == "/" and line[char_ind + 1] == "*":
				# Beginning of a block comment,
				is_comment = true
				continue
			if char_ind + 1 < line.length() and line[char_ind] == "*" and line[char_ind + 1] == "/":
				# End of the block comment
				is_comment = false
				continue
			if not is_comment:
				line_comments_removed += line[char_ind]

		var symbols: PackedStringArray = _split_string_into_symbols(line_comments_removed)
		for i in range(1, symbols.size()):
			# Is the symbol a variable?
			if (
			(
				symbols[i - 1].ends_with(",")
				or symbols[i - 1] in base_types
			)
			and _is_valid_var_name(symbols[i])
			):
				suggestions[symbols[i]] = (CodeCompletionSuggestion.new(
						CodeEdit.KIND_VARIABLE,
						symbols[i],
						CodeEdit.LOCATION_PARENT_MASK | depth,
						))
			# Is it a preproccesor directive?
			if symbols[i - 2] == "#":
				var directive = symbols[i - 1]
				var value = "".join(symbols.slice(i))
				match directive:
					"define":
						var suggestion = CodeCompletionSuggestion.new(
								CodeEdit.KIND_CONSTANT,
								symbols[i],
								CodeEdit.LOCATION_PARENT_MASK | depth)
						definitions[value] = suggestion
						suggestions[value] = suggestion
					"undef":
						suggestions.erase(value)
					"include":
						# Not really a suggestion, will be handled later
						included_files.append(value.lstrip("'\"").rstrip("'\""))
			# Is it a function?
			if symbols[i] == "(" and _is_valid_var_name(symbols[i - 1]) and symbols[i - 2] in base_types:
				suggestions[symbols[i - 1]] = CodeCompletionSuggestion.new(
						CodeEdit.KIND_MEMBER,
						symbols[i - 1],
						CodeEdit.LOCATION_PARENT_MASK | depth,
						)

	for included_file in included_files:
		var new_path = path.get_base_dir().path_join(included_file).simplify_path()
		if included_file.begins_with("/") or included_file.begins_with("\\"):
			if not base_path:
				continue
			new_path = base_path.path_join(included_file).simplify_path()
		if not included_file in visited_files and FileAccess.file_exists(new_path):
			suggestions.merge(_get_code_completion_suggestions(
					new_path,
					FileAccess.open(new_path, FileAccess.READ).get_as_text(true),
					-1,
					depth + 1,
					base_path,
					))

	return suggestions


static func _split_string_into_symbols(string: String, allow_empty: bool = false) -> PackedStringArray:
	string = string.lstrip(" ")
	var arr: PackedStringArray = []
	var begin: int = 0
	for end in range(1, string.length()):

		if (string[end - 1] in _ALPHABET) != (string[end] in _ALPHABET):
			var sub: String = string.substr(begin, end - begin).lstrip(" ").rstrip(" ")
			if allow_empty or sub:
				arr.append(sub)
			begin = end

	arr.append(string.substr(begin))
	return arr


static func _is_valid_var_name(name: String) -> bool:
	if " " in name:
		return false

	if name[0] in "0123456789":
		return false

	if name in base_types:
		return false

	if name in keywords:
		return false

	for ch in name:
		if not ch.to_lower() in "abcdefghijklmnopqrstuvwxyz0123456789":
			return false

	return true
