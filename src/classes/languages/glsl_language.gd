class_name GLSLLanguage extends Language


const _ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._"


static func _static_init() -> void:
#region consts
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
	
	keywords = _create_icons([
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
		"return",
		# Preprocessor stuff
		"#define",
		"#defined",
		"#undef",
		
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
	])
#endregion
	comment_regions = ["//", "/* */"]
	# GLSL has no strings
	string_regions = []

## Dictionary[String, FileContents]
## Used to cache the results of get_file_contents() calls, keys are file paths
static var contents_cache: Dictionary = { }


static func _create_icons(arr: PackedStringArray) -> Dictionary:
	var dict: Dictionary = { }
	for item in arr:
		var icon: Texture2D
		if item.begins_with("#"):
			icon = Icons.create("keyword_definition")
		else:
			icon = Util.default(Icons.create("keyword_" + item, true), Icons.create("keyword"))
		dict[item] = icon
	return dict


static func get_code_completion_suggestions(path: String, file: String, line: int = -1, col: int = -1, base_path: String = path, contents: FileContents = null) -> Array[CodeCompletionSuggestion]:
	if not contents:
		contents = FileContents.new()
	contents = get_file_contents(path, file, 0, base_path, true)
	contents.merge(FileContents.built_in_contents)
	var caret_index := StringUtil.get_index(file, line, col)
	return contents.as_suggestions(caret_index, file)


static func get_file_contents(path: String, file: String, depth: int = 0, base_path: String = "", currently_edited_file: bool = false, visited_files: PackedStringArray = []) -> FileContents:
	visited_files.append(path)
	if not currently_edited_file and contents_cache.has(path):
		# NOTE: determine whether shallow duplication is necessary
		# because get_code_completion_suggestions merges it with the built-in
		# types
		return contents_cache[path]
	var contents = FileContents.new()
	if not file:
		return contents
	var structs_keys: PackedStringArray = Type.built_in_structs.keys()
	var index_map: Dictionary = { }
	file = StringUtil.remove_comments(file, index_map)
	var tl_scope := Scope.new(0)
	var scope_stack: Array[Scope] = [tl_scope]
	contents.variables.append(tl_scope)
	var i := 0
	var last_func: Function = null
	while i < file.length():
		var substr := file.substr(i)
		var current_scope = scope_stack.size() - 1
		
		if substr.begins_with("{"):
			var new_scope := Scope.new(index_map[i])
			scope_stack.push_back(new_scope)
			contents.variables.append(new_scope)
			if last_func:
				for arg in last_func.arguments:
					arg.depth = current_scope + 1
					new_scope.variables[arg.name] = arg
			i += 1
			continue
		
		if substr.begins_with("}"):
			var last_scope: Scope = scope_stack.pop_back()
			last_scope.end_index = index_map[i]
			i += 1
			continue
		
		if substr.begins_with("#"):
			var end := substr.find("\n")
			var def := StringUtil.substr_pos(substr, 0, end)
			last_func = null
			var kind := def.trim_prefix("#").strip_edges(true, false)
			if kind.begins_with("include"):
				var included_path = StringUtil.substr_pos(def, def.find("\"") + 1, def.rfind("\""))
				var new_path = path.get_base_dir().path_join(included_path).simplify_path()
				if included_path.begins_with("/") or included_path.begins_with("\\"):
					if base_path:
						new_path = base_path.path_join(included_path).simplify_path()
				if not included_path in visited_files and FileAccess.file_exists(new_path):
					var text := File.get_text(new_path)
					var include_contents := get_file_contents(
						new_path,
						text,
						depth + 1,
						base_path,
						true,
						visited_files,
					)
					contents.merge(include_contents)
			if kind.begins_with("define"):
				var obj := Definition.from_def(StringUtil.split_at_first_any(def, StringUtil.WHITESPACE, true)[-1])
				if obj:
					contents.add(obj)
			if end == -1:
				break
			i += end
		if substr.begins_with("struct"):
			# It is a struct
			var open_brace: int = substr.find("{")
			if open_brace == -1:
				i += 1
				continue
			var close_brace: int = StringUtil.find_scope_end(substr, open_brace + 1, "{", "}")
			var def := substr.substr(0, close_brace)
			var obj := Struct.from_def(def)
			if obj:
				last_func = null
				obj.depth = current_scope
				contents.add(obj)
				structs_keys.append(obj.name)
			else:
				i += 1
				continue
			if close_brace == -1:
				break
			i += close_brace + 1
			continue
		var type_str: String = StringUtil.begins_with_any(substr, structs_keys + PackedStringArray(["void"]))
		var is_qualifier: bool = i > 0 and StringUtil.begins_with_any(substr, Variable.qualifiers.keys()) and file[i - 1] in StringUtil.WHITESPACE
		if type_str or is_qualifier:
			var end := StringUtil.find_any(substr, ["{", ";"])
			var def := substr.substr(0, end)
			
			var equals_index := def.find("=")
			var parens_index := def.find("(")
			
			if not is_qualifier and (type_str == "void" or not parens_index == -1 and (equals_index == -1 or parens_index < equals_index)):
				var obj := Function.from_def(def)
				if obj:
					last_func = obj
					obj.depth = current_scope
					contents.add(obj)
			else:
				var objs := Variable.from_def(def, current_scope)
				if objs and scope_stack:
					last_func = null
					for obj in objs:
						scope_stack[-1].variables[obj.name] = obj
			if end == -1:
				break
			#if substr[end] == ";":
				#end = substr.find(";")
			i += end
			continue
		i += 1
	contents_cache[path] = contents
	return contents


class FileContents:
	static var built_in_contents: FileContents = null:
		set(value):
			built_in_contents = value
		get:
			if not built_in_contents:
				built_in_contents = FileContents.new()
				built_in_contents.structs.merge(Type.built_in_structs)
				built_in_contents.funcs.merge(Type.built_in_functions)
				#for s: Struct in Type.built_in_structs.values():
					#built_in_contents.add(s.as_fn())
				built_in_contents.add_depth(CodeEdit.LOCATION_OTHER)
			return built_in_contents
	
	## Dictionary[String, Struct]
	var structs: Dictionary = { }
	var variables: Array[Scope]
	## Dictionary[String, Array[Function]]
	var funcs: Dictionary = { }
	## Dictionary[String, Definition]
	var defs: Dictionary
	
	func add(obj: Type) -> void:
		if not obj:
			return
		if obj is Definition:
			defs[obj.name] = obj
		if obj is Struct:
			structs[obj.name] = obj
			add(obj.as_fn())
		if obj is Function:
			if not obj.name in funcs:
				funcs[obj.name] = [obj]
			else:
				funcs[obj.name].append(obj)
	
	func _to_string() -> String:
		return "\n\n".join([
			ArrayUtil.join_line(ArrayUtil.to_string_array(structs.values())),
			ArrayUtil.join_line(ArrayUtil.to_string_array(variables)),
			ArrayUtil.join_line(ArrayUtil.to_string_array(funcs.values())),
			ArrayUtil.join_line(ArrayUtil.to_string_array(defs.values())),
		])
	
	## Reports whether more suggestions should be added in the first item of
	## [code]exclusive[/code]
	func as_suggestions(index: int, text: String = "", exclusive_contextual_suggestions: bool = false, exclusive := []) -> Array[CodeCompletionSuggestion]:
		var suggestions: Array[CodeCompletionSuggestion] = []
		var contextual_suggestions := _get_contextual_suggestions(index, text)
		if not exclusive_contextual_suggestions or not contextual_suggestions:
			for struct in structs.values():
				var s: CodeCompletionSuggestion = struct.as_completion_suggestion()
				suggestions.append(s)
			for scope in variables:
				if scope.includes(index):
					suggestions.append_array(scope.as_completion_suggestions())
			for f in funcs.values():
				suggestions.append(f[0].as_completion_suggestion())
			for d: Definition in defs.values():
				suggestions.append(d.as_completion_suggestion())
			exclusive.append(false)
		else:
			exclusive.append(true)
		suggestions.append_array(_get_contextual_suggestions(index, text))
		return suggestions
	
	
	func _get_contextual_suggestions(index: int, text: String) -> Array[CodeCompletionSuggestion]:
		if not text:
			return []
		var dot_index: int = index
		while dot_index > 0 and dot_index < text.length():
			if text[dot_index] == ".":
				break
			if text[dot_index].to_lower() not in "abcdefghijklmnopqrstuvwxyz_" + "".join(StringUtil.WHITESPACE):
				dot_index = -1
				break
			dot_index -= 1
		if dot_index == -1:
			return []
		var v := get_variable(StringUtil.substr_posv(text, StringUtil.get_word_code(text, dot_index)), dot_index)
		if not v:
			return []
		var suggestions: Array[CodeCompletionSuggestion] = []
		var type: Struct = structs.merged(FileContents.built_in_contents.structs)[v.type]
		for prop in type.properties.values():
			suggestions.append(prop.as_completion_suggestion())
		return suggestions
	
	func add_depth(depth: int) -> void:
		for key in structs:
			structs[key].depth += depth
		for scope in variables:
			scope.add_depth(depth)
		for key in funcs:
			for f in funcs[key]:
				f.depth += depth
		for d: Definition in defs:
			d.depth += depth
	
	
	func merge(file_contents: FileContents) -> void:
		structs.merge(file_contents.structs)
		defs.merge(file_contents.defs)
		## Merge the top-level vars with the other top-level vars
		var tl := Scope.get_top_level(file_contents.variables)
		if tl:
			Scope.get_top_level(variables).merge(
					tl.variables
				)
		for key in file_contents.funcs:
			if key in funcs:
				# Function does exist so merge the arrays
				funcs[key].append_array(file_contents.funcs[key])
			else:
				# Function does not exist so insert a new key
				funcs[key] = file_contents.funcs[key]
	
	func find(what: String) -> Type:
		if funcs.has(what):
			return funcs[what]
		var found_var := Scope.find(variables, what)
		if found_var:
			return found_var
		return null
	
	## NOTE: performs a [b]shallow[/b] copy (only copies arrays and dictionaries
	## , not their sub-objects)
	func duplicate() -> FileContents:
		var new := FileContents.new()
		new.structs = structs.duplicate()
		new.variables = variables.duplicate()
		new.funcs = funcs.duplicate()
		new.defs = defs.duplicate()
		return new
	
	## Finds the variable with member access, e.g.
	## [code]custom_struct_var.member[/code] would return the correct variable
	## for [code]member[/code]
	func get_variable(string: String, index: int) -> Variable:
		var chain: PackedStringArray = StringUtil.split_scoped(string, ".", "(", ")")
		ArrayUtil.map_in_place_s(chain, func(chain_str: String) -> String: return chain_str.strip_edges())
		#return null
		if not chain or Array(chain).any(func(chain_str: String) -> bool: return chain_str.is_empty()):
			return null
		if chain.size() == 1:
			return Scope.find(variables, chain[0], index)
		var structs_merged: Dictionary = structs.merged(Type.built_in_structs)
		var v
		if "(" in chain[0]:
			v = funcs[chain[0].get_slice("(", 0)][0]
		else:
			v = Scope.find(variables, chain[0], index) as Variable
		var s: Struct
		for i in range(1, chain.size()):
			if not v:
				return null
			s = structs_merged[v.type]
			if not s:
				return null
			v = s.properties.get(chain[i])
		return v
	
	
	func get_tooltip(text: String, index: int) -> String:
		if index > text.length() - 1:
			return ""
		var simple_word_bounds := StringUtil.get_word(text, index)
		if not simple_word_bounds:
			return ""
		var simple_word: String = StringUtil.substr_posv(text, simple_word_bounds).strip_edges()
		var i: int = simple_word_bounds[1] - 1
		while true:
			i += 1
			if text[i] in StringUtil.WHITESPACE:
				continue
			if text[i] == "(":
				break
			i = -1
			break
		if not i == -1:
			if simple_word in defs and defs[simple_word] is Macro:
				var args: PackedStringArray = StringUtil.split_scoped(StringUtil.substr_pos(text, simple_word_bounds[1] + 1, StringUtil.find_scope_end(text, i + 1, "(", ")")), ",", "(", ")")
				ArrayUtil.map_in_place_s(args, func(arg: String) -> String: return arg.strip_edges())
				return str(defs[simple_word]) + "\n\n" + (defs[simple_word] as Macro).get_expanded(args)
			var m_funcs := funcs.merged(FileContents.built_in_contents.funcs)
			if simple_word in m_funcs:
				return str("\n".join(m_funcs[simple_word]))
		if simple_word in structs:
			return str(structs[simple_word])
		if simple_word in defs:
			return str(defs[simple_word])
		var complex_word: String = StringUtil.substr_posv(text, StringUtil.get_word_code(text, index))
		var v = get_variable(complex_word, index)
		if v:
			return str(v)
		return ""


class Scope:
	var start_index: int = -1
	var end_index: int = -1
	## Dictionary[String, Variable]
	var variables: Dictionary = { }
	
	func _init(_start_index: int) -> void:
		start_index = _start_index
	
	func _to_string() -> String:
		return "%s -> %s{\n\t%s\n}" % [
			start_index,
			end_index,
			"\n\t".join(variables.values().map(func(v: Variable): return str(v))),
		]
	
	func includes(index: int) -> bool:
		return end_index == -1 or start_index < index and index <= end_index
	
	func merge(with_variables: Dictionary) -> void:
		variables.merge(with_variables)
	
	func add_depth(depth: int) -> void:
		for key in variables:
			variables[key].depth += depth
		
	func as_completion_suggestions() -> Array[CodeCompletionSuggestion]:
		var arr: Array[CodeCompletionSuggestion] = []
		arr.assign(variables.values().map(func(element: Variable) -> CodeCompletionSuggestion: return element.as_completion_suggestion()))
		return arr
	
	
	static func get_top_level(scopes: Array[Scope]) -> Scope:
		if scopes:
			for i in range(scopes.size() - 1, -1, -1):
				if scopes[i].end_index == -1:
					return scopes[i]
		return null
	
	
	static func find(scopes: Array[Scope], what: String, index: int = -1) -> Variable:
		for scope in scopes:
			if scope.variables.has(what) and (index == -1 or scope.includes(index)):
				return scope.variables[what]
		return null


class Type:
	
#region consts
	static var _prefix_map := {
		"b": "bool",
		"i": "int",
		"u": "uint",
		"d": "double",
	}
	
	static var built_in_structs := {
		"float": _create_vector("float", "float", 1),
		"bool": _create_vector("bool", "bool", 1),
		"int": _create_vector("int", "int", 1),
		"uint": _create_vector("uint", "uint", 1),
		"double": _create_vector("double", "double", 1),
		# Vector types
		"bvec2": _create_vector("bvec2"),
		"bvec3": _create_vector("bvec3"),
		"bvec4": _create_vector("bvec4"),
		"ivec2": _create_vector("ivec2"),
		"ivec3": _create_vector("ivec3"),
		"ivec4": _create_vector("ivec4"),
		"uvec2": _create_vector("uvec2"),
		"uvec3": _create_vector("uvec3"),
		"uvec4": _create_vector("uvec4"),
		"dvec2": _create_vector("dvec2"),
		"dvec3": _create_vector("dvec3"),
		"dvec4": _create_vector("dvec4"),
		"vec2": _create_vector("vec2"),
		"vec3": _create_vector("vec3"),
		"vec4": _create_vector("vec4"),
		## Square matrices
		"mat2": _create_matrix("mat2"),
		"mat3": _create_matrix("mat3"),
		"mat4": _create_matrix("mat4"),
		## Non-square matrices
		"mat2x2": _create_matrix("mat2x2"),
		"mat2x3": _create_matrix("mat2x3"),
		"mat2x4": _create_matrix("mat2x4"),
		"mat3x2": _create_matrix("mat3x2"),
		"mat3x3": _create_matrix("mat3x3"),
		"mat3x4": _create_matrix("mat3x4"),
		"mat4x2": _create_matrix("mat4x2"),
		"mat4x3": _create_matrix("mat4x3"),
		"mat4x4": _create_matrix("mat4x4"),
		## Double-precision matrices
		"dmat2": _create_matrix("dmat2"),
		"dmat3": _create_matrix("dmat3"),
		"dmat4": _create_matrix("dmat4"),
		"dmat2x2": _create_matrix("dmat2x2"),
		"dmat2x3": _create_matrix("dmat2x3"),
		"dmat2x4": _create_matrix("dmat2x4"),
		"dmat3x2": _create_matrix("dmat3x2"),
		"dmat3x3": _create_matrix("dmat3x3"),
		"dmat3x4": _create_matrix("dmat3x4"),
		"dmat4x2": _create_matrix("dmat4x2"),
		"dmat4x3": _create_matrix("dmat4x3"),
		"dmat4x4": _create_matrix("dmat4x4"),
		## Samplers
		"sampler1D": Type.new("sampler1D", 16, Icons.create("type_sampler1d")),
		"sampler2D": Type.new("sampler2D", 16, Icons.create("type_sampler2d")),
		"sampler3D": Type.new("sampler3D", 16, Icons.create("type_sampler3d")),
		"samplerCube": Type.new("samplerCube", 16, Icons.create("type_samplerCube")),
		"sampler2DRect": Type.new("sampler2DRect", 16, Icons.create("type_sampler2d")),
		"sampler1DArray": Type.new("sampler1DArray", 16, Icons.create("type_sampler1d")),
		"sampler2DArray": Type.new("sampler2DArray", 16, Icons.create("type_sampler2d")),
		"samplerCubeArray": Type.new("samplerCubeArray", 16, Icons.create("type_samplerCube")),
		"samplerBuffer": Type.new("samplerBuffer", 16, Icons.create("type_sampler1d")),
		"sampler2DMS": Type.new("sampler2DMS", 16, Icons.create("type_sampler2d")),
		"sampler2DMSArray": Type.new("sampler2DMSArray", 16, Icons.create("type_sampler2d")),
		"isampler1D": Type.new("isampler1D", 16, Icons.create("type_sampler1d")),
		"isampler2D": Type.new("isampler2D", 16, Icons.create("type_sampler2d")),
		"isampler3D": Type.new("isampler3D", 16, Icons.create("type_sampler3d")),
		"isamplerCube": Type.new("isamplerCube", 16, Icons.create("type_samplerCube")),
		"isampler2DRect": Type.new("isampler2DRect", 16, Icons.create("type_sampler2d")),
		"isampler1DArray": Type.new("isampler1DArray", 16, Icons.create("type_sampler1d")),
		"isampler2DArray": Type.new("isampler2DArray", 16, Icons.create("type_sampler2d")),
		"isamplerCubeArray": Type.new("isamplerCubeArray", 16, Icons.create("type_samplerCube")),
		"isamplerBuffer": Type.new("isamplerBuffer", 16, Icons.create("type_sampler1d")),
		"isampler2DMS": Type.new("isampler2DMS", 16, Icons.create("type_sampler2d")),
		"isampler2DMSArray": Type.new("isampler2DMSArray", 16, Icons.create("type_sampler2d")),
		"usampler1D": Type.new("usampler1D", 16, Icons.create("type_sampler1d")),
		"usampler2D": Type.new("usampler2D", 16, Icons.create("type_sampler2d")),
		"usampler3D": Type.new("usampler3D", 16, Icons.create("type_sampler3d")),
		"usamplerCube": Type.new("usamplerCube", 16, Icons.create("type_samplerCube")),
		"usampler2DRect": Type.new("usampler2DRect", 16, Icons.create("type_sampler2d")),
		"usampler1DArray": Type.new("usampler1DArray", 16, Icons.create("type_sampler1d")),
		"usampler2DArray": Type.new("usampler2DArray", 16, Icons.create("type_sampler2d")),
		"usamplerCubeArray": Type.new("usamplerCubeArray", 16, Icons.create("type_samplerCube")),
		"usamplerBuffer": Type.new("usamplerBuffer", 16, Icons.create("type_sampler1d")),
		"usampler2DMS": Type.new("usampler2DMS", 16, Icons.create("type_sampler2d")),
		"usampler2DMSArray": Type.new("usampler2DMSArray", 16, Icons.create("type_sampler2d")),
		"sampler1DShadow": Type.new("sampler1DShadow", 16, Icons.create("type_sampler1d")),
		"sampler2DShadow": Type.new("sampler2DShadow", 16, Icons.create("type_sampler1d")),
		"samplerCubeShadow": Type.new("samplerCubeShadow", 16, Icons.create("type_samplerCube")),
		"sampler2DRectShadow": Type.new("sampler2DRectShadow", 16, Icons.create("type_sampler2d")),
		"sampler1DArrayShadow": Type.new("sampler1DArrayShadow", 16, Icons.create("type_sampler1d")),
		"sampler2DArrayShadow": Type.new("sampler2DArrayShadow", 16, Icons.create("type_sampler2d")),
		"samplerCubeArrayShadow": Type.new("samplerCubeArrayShadow", 16, Icons.create("type_samplerCube")),
	}
	
	static var _prefix_types := {
		"f": [
			"float",
			"vec2",
			"vec3",
			"vec4",
			"double",
			"dvec2",
			"dvec3",
			"dvec4",
		],
		
		"f_no_d": [
			"float",
			"vec2",
			"vec3",
			"vec4",
		],
		
		"i": [
			"int",
			"ivec2",
			"ivec3",
			"ivec4"
		],
		
		"u": [
			"uint",
			"uvec2",
			"uvec3",
			"uvec4"
		],
		
		"b": [
			"bool",
			"bvec2",
			"bvec3",
			"bvec4"
		],
		
		"": [
			"float",
			"vec2",
			"vec3",
			"vec4",
			"double",
			"dvec2",
			"dvec3",
			"dvec4",
			"int",
			"ivec2",
			"ivec3",
			"ivec4",
			"uint",
			"uvec2",
			"uvec3",
			"uvec4",
			"bool",
			"bvec2",
			"bvec3",
			"bvec4",
		],
		
		"v": [
			"vec2",
			"vec3",
			"vec4",
			"dvec2",
			"dvec3",
			"dvec4",
			"ivec2",
			"ivec3",
			"ivec4",
			"uvec2",
			"uvec3",
			"uvec4",
			"bvec2",
			"bvec3",
			"bvec4",
		],
		
		"v_comp": [
			"vec2",
			"vec3",
			"vec4",
			"dvec2",
			"dvec3",
			"dvec4",
			"ivec2",
			"ivec3",
			"ivec4",
			"uvec2",
			"uvec3",
			"uvec4",
		],
		
		"bv_comp": [
			"bvec2",
			"bvec3",
			"bvec4",
		],
		
		"mat": [
			"mat2",
			"mat3",
			"mat4",
			"mat2x2",
			"mat2x3",
			"mat2x4",
			"mat3x2",
			"mat3x3",
			"mat3x4",
			"mat4x2",
			"mat4x3",
			"mat4x4",
		],
		
		"sampler": [
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
		],
		
		"sampler_vec": [
			"float",
			"vec2",
			"vec3",
			"vec3",
			"vec2",
			"vec2",
			"vec3",
			"vec4",
			"float",
			"vec2",
			"vec3",
			"float",
			"vec2",
			"vec3",
			"vec3",
			"vec2",
			"vec2",
			"vec3",
			"vec4",
			"float",
			"vec2",
			"vec3",
			"float",
			"vec2",
			"vec3",
			"vec3",
			"vec2",
			"vec2",
			"vec3",
			"vec4",
			"float",
			"vec2",
			"vec3",
			"float",
			"vec2",
			"vec3",
			"vec2",
			"float",
			"vec2",
			"vec3",
		],
		
		"sampler_ivec": [
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"ivec2",
			"ivec3",
			"ivec4",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"ivec2",
			"ivec3",
			"ivec4",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"ivec2",
			"ivec3",
			"ivec4",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec3",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
		],
		
		"sampler_ivec_offset": [
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"ivec3",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"int",
			"ivec2",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
			"ivec2",
			"int",
			"ivec2",
			"ivec3",
		],
	}
	
	static var built_in_functions := {
#region Trig funcs
		"radians": _create_multi_func("radians", ["degrees"], ["f"]),
		"degrees": _create_multi_func("degrees", ["radians"], ["f"]),
		"sin": _create_multi_func("sin", ["angle"], ["f"]),
		"cos": _create_multi_func("cos", ["angle"], ["f"]),
		"tan": _create_multi_func("tan", ["angle"], ["f"]),
		"asin": _create_multi_func("asin", ["angle"], ["f"]),
		"acos": _create_multi_func("acos", ["angle"], ["f"]),
		"atan": _create_multi_func("atan", ["y", "x"], ["f"]) + _create_multi_func("atan", ["y_over_x"], ["f"]),
		"sinh": _create_multi_func("sinh", ["x"], ["f"]),
		"cosh": _create_multi_func("cosh", ["x"], ["f"]),
		"tanh": _create_multi_func("tanh", ["x"], ["f"]),
		"asinh": _create_multi_func("asinh", ["x"], ["f"]),
		"acosh": _create_multi_func("acosh", ["x"], ["f"]),
		"atanh": _create_multi_func("atanh", ["x"], ["f"]),
#endregion
		
#region Power/logarithms
		"pow": _create_multi_func("pow", ["x", "y"], ["f"]),
		"exp": _create_multi_func("exp", ["x"], ["f"]),
		"log": _create_multi_func("log", ["x"], ["f"]),
		"exp2": _create_multi_func("exp2", ["x"], ["f"]),
		"log2": _create_multi_func("log2", ["x"], ["f"]),
		"inversesqrt": _create_multi_func("inversesqrt", ["x"], ["f"]),
#endregion
		
#region Rounding and clamping
		"abs": _create_multi_func("abs", ["x"], [""]),
		"sign": _create_multi_func("sign", ["x"], [""]),
		"floor": _create_multi_func("floor", ["x"], ["f"]),
		"ceil": _create_multi_func("ceil", ["x"], ["f"]),
		"trunc": _create_multi_func("trunc", ["x"], ["f"]),
		"fract": _create_multi_func("fract", ["x"], ["f"]),
		"mod": _create_multi_func("mod", ["x", "y"], ["f"]),
		"min": _create_multi_func("min", ["x", "y"], [""]),
		"max": _create_multi_func("max", ["x", "y"], [""]),
		"clamp": _create_multi_func("clamp", ["x", "min", "max"], [""]),
		"mix": _create_multi_func("mix", ["a", "b", "x"], ["f"]),
		"step": _create_multi_func("step", ["edge", "x"], [""]),
		"smoothstep": _create_multi_func("smoothstep", ["edge_0", "edge_1", "x"], [""]),
#endregion
		
#region Vector operations
		"length": _create_multi_func("length", ["vector"], ["v"], "float"),
		"dot": _create_multi_func("dot", ["a", "b"], ["v"], "float"),
		"cross": _create_multi_func("cross", ["a", "b"], ["vec3"], "vec3"),
		"normalize": _create_multi_func("normalize", ["vector"], ["v"], "v"),
		"faceforward": _create_multi_func("faceforward", ["normal", "incident", "normal_reference"], ["v"], "v"),
		"reflect": _create_multi_func("reflect", ["incident", "normal"], ["v"], "v"),
		"refract": _create_multi_func("refract", ["incident", "normal", "eta"], ["v", "v", "float"]),
#endregion
		
#region Matrix operations
		"determinant": _create_multi_func("determinant", ["matrix"], ["m"], "float"),
		"outerProduct": [
			Function.new("outerProduct", "mat2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "mat3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "mat4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec4"),
				]),
			Function.new("outerProduct", "mat2x3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "mat3x2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "mat2x4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "mat4x2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec4"),
				]),
			Function.new("outerProduct", "mat3x4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "mat4x3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec4"),
				]),
			
			Function.new("outerProduct", "dmat2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "dmat3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "dmat4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec4"),
				]),
			Function.new("outerProduct", "dmat2x3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "dmat3x2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "dmat2x4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec2"),
				]),
			Function.new("outerProduct", "dmat4x2", [
					Variable.new("c", "vec2"),
					Variable.new("r", "vec4"),
				]),
			Function.new("outerProduct", "dmat3x4", [
					Variable.new("c", "vec4"),
					Variable.new("r", "vec3"),
				]),
			Function.new("outerProduct", "dmat4x3", [
					Variable.new("c", "vec3"),
					Variable.new("r", "vec4"),
				]),
			],
		"matrixCompMult": _create_multi_func("matrixCompMult", ["a", "b"], ["mat"]),
		"inverse": _create_multi_func("inverse", ["inverse"], ["mat"]),
		"transpose": _create_multi_func("transpose", ["inverse"], ["mat"]),
#endregion
		
#region Texture sampling
		"texture": _create_multi_func("texture", ["sampler", "coord", "bias"], ["sampler", "sampler_vec", "float"], "vec4"),
		"textureLod": _create_multi_func("textureLod", ["sampler", "coord", "lod"], ["sampler", "sampler_vec", "float"], "vec4"),
		"textureLodOffset": _create_multi_func("textureLodOffset", ["sampler", "coord", "lod", "offset"], ["sampler", "sampler_vec", "float", "sampler_ivec_offset"], "vec4"),
		"textureGrad": _create_multi_func("textureGrad", ["sampler", "coord", "dPdx", "dPdy"], ["sampler", "sampler_vec", "vec2", "vec2"], "vec4"),
		"textureGradOffset": _create_multi_func("textureGradOffset", ["sampler", "coord", "dPdx", "dPdy", "offset"], ["sampler", "sampler_vec", "vec2", "vec2", "sampler_ivec_offset"], "vec4"),
		"textureProj": _create_multi_func("textureProj", ["sampler", "coord", "bias"], ["sampler", "sampler_vec", "float"], "vec4"),
		"textureProjLod": _create_multi_func("textureProjLod", ["sampler", "coord", "lod"], ["sampler", "sampler_vec", "float"], "vec4"),
		"textureProjLodOffset": _create_multi_func("textureProjLodOffset", ["sampler", "coord", "lod", "offset"], ["sampler", "sampler_vec", "float", "sampler_ivec_offset"], "vec4"),
		"textureProjGrad": _create_multi_func("textureProjGrad", ["sampler", "coord", "dPdx", "dPdy"], ["sampler", "sampler_vec", "vec2", "vec2"], "vec4"),
		"texelFetch": _create_multi_func("texelFetch", ["sampler", "coord", "lod"], ["sampler", "sampler_ivec", "int"], "vec4"),
		"texelFetchOffset": _create_multi_func("texelFetch", ["sampler", "coord", "lod", "offset"], ["sampler", "sampler_ivec", "int", "sampler_ivec_offset"], "vec4"),
		"textureSize": _create_multi_func("textureSize", ["sampler", "lod"], ["sampler", "int"], "sampler_ivec_offset"),
#endregion
		
#region Screen-space derivatives
		"dFdx": _create_multi_func("dFdx", ["x"], [""]),
		"dFdy": _create_multi_func("dFdy", ["x"], [""]),
		"fwidth": _create_multi_func("fwidth", ["x"], [""]),
#endregion
		
#region Bit-manipulation
		"isnan": _create_multi_func("isnan", ["x"], ["f"], "b"),
		"isinf": _create_multi_func("isinf", ["x"], ["f"], "b"),
		"intBitsToFloat": _create_multi_func("intBitsToFloat", ["v"], ["i"], "f"),
		"uintBitsToFloat": _create_multi_func("uintBitsToFloat", ["v"], ["u"], "f"),
		"floatBitsToInt": _create_multi_func("floatBitsToInt", ["v"], ["f_no_d"], "i"),
		"floatBitsToUint": _create_multi_func("floatBitsToUint", ["v"], ["f_no_d"], "u"),
		"packSnorm2x16": _create_multi_func("packSnorm2x16", ["v"], ["vec2"], "uint"),
		"packUnorm2x16": _create_multi_func("packUnorm2x16", ["v"], ["vec2"], "uint"),
		"unpackSnorm2x16": _create_multi_func("unpackSnorm2x16", ["p"], ["uint"], "vec2"),
		"unpackUnorm2x16": _create_multi_func("unpackUnorm2x16", ["p"], ["uint"], "vec2"),
#endregion
		
#region Boolean vectors
		"lessThan": _create_multi_func("lessThan", ["x", "y"], ["v_comp"], "bv_comp"),
		"lessThanEqual": _create_multi_func("lessThanEqual", ["x", "y"], ["v_comp"], "bv_comp"),
		"greaterThan": _create_multi_func("greaterThan", ["x", "y"], ["v_comp"], "bv_comp"),
		"greaterThanEqual": _create_multi_func("greaterThanEqual", ["x", "y"], ["v_comp"], "bv_comp"),
		"equal": _create_multi_func("equal", ["x", "y"], ["v_comp"], "bv_comp"),
		"notEqual": _create_multi_func("notEqual", ["x", "y"], ["v_comp"], "bv_comp"),
		"any": _create_multi_func("any", ["x"], ["bv_comp"], "bool"),
		"all": _create_multi_func("all", ["x"], ["bv_comp"], "bool"),
		"not": _create_multi_func("not", ["x"], ["bv_comp"], "bv_comp"),
#endregion
	}
#endregion
	
#region Helper functions
	## Kinda cursed function
	## [br]
	## Input prefixes can either be a raw type, such as [code]float[/code], or a type
	## set defined in [code]_prefix_types[/code]
	## [br]
	## For example, entering [code]f[/code] would result in all versions of the method
	## with a float type, like method(float x), method(vec2 x), method(vec3 x),
	## etc.
	static func _create_multi_func(obj_name: String, arguments: PackedStringArray, input_prefixes: PackedStringArray, output_prefix: String = input_prefixes[0]) -> Array[Function]:
		var in_types: Array[PackedStringArray] = []
		for p in input_prefixes:
			in_types.append(PackedStringArray(_prefix_types.get(p, [p])))
		var out_types: PackedStringArray = _prefix_types.get(output_prefix, [output_prefix])
		var funcs: Array[Function] = []
		var type_count: int = in_types.reduce(
			func(accum: int, types: PackedStringArray) -> int: return maxi(accum, types.size()),
			0
			)
		funcs.resize(type_count)
		
		for i in type_count:
			var typed_args: Array[Variable] = []
			typed_args.resize(arguments.size())
			for typed_arg_i in typed_args.size():
				typed_args[typed_arg_i] = Variable.new(
						arguments[typed_arg_i],
						ArrayUtil.index_wrap(ArrayUtil.index_wrap(in_types, typed_arg_i), i))
			funcs[i] = Function.new(obj_name, ArrayUtil.index_wrap(out_types, i), typed_args)
		return funcs
	
	static func _create_vector(obj_name: String, base_type: String = _prefix_map.get(obj_name[0], "float"), count: int = int(obj_name[-1]), access_sets: PackedStringArray = ["xyzw", "rgba", "stpq"]) -> IndexableStruct:
		var components: Array[Variable] = []
		for access_set in access_sets:
			components.append_array(Array(_generate_permutations(access_set.substr(0, count), 4)).map(
				func(var_name: String):
					var type: String = ""
					if var_name.length() == 1:
						type = base_type
					else:
						type = ("" if base_type == "float" else base_type[0]) + "vec" + str(var_name.length())
					return Variable.new(var_name, type)
			))
		return IndexableStruct.new(obj_name, components, base_type, Icons.create("type_" + obj_name))
	
	static func _create_matrix(obj_name: String, base_type: String = _prefix_map.get(obj_name[0], "float")) -> IndexableStruct:
		#var dim: String = obj_name.right(3) if "x" in obj_name else obj_name.right(1)
		return IndexableStruct.new(obj_name, [], base_type, Icons.create("type_" + obj_name))
	
	static func _generate_single_permutation(sets: String, count: int) -> PackedStringArray:
		if count == 1:
			return sets.split()
		
		var arr: PackedStringArray = []
		for ch in sets:
			var set_prev := _generate_single_permutation(sets, count - 1)
			for b in set_prev.size():
				set_prev[b] = ch + set_prev[b]
			arr.append_array(set_prev)
		return arr
	
	static func _generate_permutations(sets: String, count: int) -> PackedStringArray:
		var arr: PackedStringArray = []
		for new_count in range(1, count + 1):
			arr.append_array(_generate_single_permutation(sets, new_count))
		return arr
#endregion

	var name: String
	var depth: int = 0
	var index: int = -1
	var icon: Texture2D
	
	func _init(_name: String, _depth: int = 0, _icon: Texture2D = null) -> void:
		name = _name
		depth = _depth
		icon = _icon
	
	
	func as_completion_suggestion() -> CodeCompletionSuggestion:
		return CodeCompletionSuggestion.new(_get_type(), name, depth, icon)
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_VARIABLE


class Definition extends Type:
	var value: String
	
	func _init(_name: String, _value: String) -> void:
		name = _name
		value = _value
		icon = Icons.create("definition")
	
	func _to_string() -> String:
		return "%s %s" % [name, value]
	
	static func from_def(def: String) -> Definition:
		def = def.strip_edges()
		var paren_index: int = def.find("(")
		var whitespace_index: int = StringUtil.find_any(def, StringUtil.WHITESPACE)
		if not paren_index == -1 and paren_index < whitespace_index:
			# Macro path
			var macro_name := def.substr(0, paren_index)
			var end_paren_index: int = def.find(")", paren_index)
			var args := StringUtil.substr_pos(def, paren_index + 1, end_paren_index).split(",", false)
			ArrayUtil.map_in_place_s(args, func(string: String) -> String: return string.strip_edges())
			var value := def.substr(end_paren_index + 1).strip_edges()
			return Macro.new(macro_name, value, args)
		else:
			# Normal path
			var def_name := def.substr(0, whitespace_index).strip_edges()
			var value := def.substr(whitespace_index).strip_edges()
			return Definition.new(def_name, value)
		return null
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_CONSTANT


class Macro extends Definition:
	var arguments: PackedStringArray
	
	func _to_string() -> String:
		return "%s(%s) %s" % [name, ", ".join(arguments), value]
	
	func _init(_name: String, _value: String, _arguments: PackedStringArray) -> void:
		name = _name
		value = _value
		arguments = _arguments
		icon = Icons.create("macro")
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_CONSTANT
	
	func as_completion_suggestion() -> CodeCompletionSuggestion:
		return CodeCompletionSuggestion.new(_get_type(), name, depth, icon, name + "(")
	
	func get_expanded(args: PackedStringArray) -> String:
		var last_was_valid: bool = false
		var is_valid: bool = false
		var sb := StringBuilder.new()
		var i: int = 0
		while i < value.length():
			is_valid = value[i].to_lower() in "abcdefghijklmnopqrstuvwxyz_"
			if is_valid and not last_was_valid:
				var b: int = StringUtil.begins_with_any_index(value.substr(i), arguments)
				if not b == -1:
					sb.append(args[b])
					i += arguments[b].length()
					last_was_valid = is_valid
					continue
			sb.append(value[i])
			last_was_valid = is_valid
			i += 1
		return str(sb)


class Function extends Type:
	var type: String
	var arguments: Array[Variable]
	
	func _init(_name: String, _type: String, _arguments: Array[Variable]) -> void:
		name = _name
		type = _type
		arguments = _arguments
		for argument in arguments:
			argument.icon = Icons.create("param")
		icon = Icons.create("function")
	
	func _to_string() -> String:
		return "%s %s(%s)" % [
			type,
			name,
			", ".join(arguments.map(func(arg: Variable): return str(arg)))
		]
	
	func as_completion_suggestion() -> CodeCompletionSuggestion:
		return CodeCompletionSuggestion.new(_get_type(), name, depth, icon, name + "(")
	
	static func from_def(def: String) -> Function:
		var def_split := StringUtil.split_at_sequence(def, [StringUtil.WHITESPACE, ["("]])
		
		var real_indices: int = 0
		for s in def_split:
			if not s.strip_edges().is_empty():
				real_indices += 1
		if real_indices <= 2:
			return null
		
		var return_type := def_split[0].strip_edges()
		var name := def_split[1].strip_edges()
		var args_str := def_split[2].strip_edges().trim_prefix("(").trim_suffix(")").split(",", false)
		
		var args: Array[Variable] = []
		args.resize(args_str.size())
		for i in args_str.size():
			var vars = Variable.from_def(args_str[i].strip_edges())
			if not vars:
				return null
			args[i] = vars[0]
		
		return Function.new(name, return_type, args)
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_FUNCTION



class Struct extends Type:
	var properties: Dictionary = { }
	
	func _init(_name: String, _properties: Array[Variable], _icon: Texture2D = Icons.create("struct")) -> void:
		name = _name
		properties = ArrayUtil.create_dictionary(_properties,
			func(v: Variable):
				v.depth = 255
				v.icon = Icons.create("member")
				return v.name
				)
		icon = _icon
	
	func as_fn() -> Function:
		var args: Array[Variable]
		args.assign(properties.values())
		return Function.new(name, name, args)
	
	func _to_string() -> String:
		return "%s {\n\t%s\n}" % [
			name,
			"\n\t".join(properties.values().map(func(prop: Variable): return prop.to_string()))
		]
	
	static func from_def(def: String) -> Struct:
		var split := StringUtil.splitn_at_sequence(def, [["struct"], StringUtil.WHITESPACE, ["{"]], true, false)
		if not split.size() == 3:
			return null
		split[-1] = split[-1].lstrip("".join(StringUtil.WHITESPACE) + "{").rstrip("".join(StringUtil.WHITESPACE) + "}")
		var name := split[1]
		var vars: Array[Variable] = []
		var v_defs := split[-1].split(";", false)
		for v_def in v_defs:
			var current_vars := Variable.from_def(v_def.strip_edges())
			if current_vars:
				for v in current_vars:
					vars.append(v)
		return Struct.new(name, vars)
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_CLASS


class IndexableStruct extends Struct:
	var element_type: String
	
	func _init(_name: String, _properties: Array[Variable], _element_type: String, _icon: Texture2D = Icons.create("struct")) -> void:
		name = _name
		properties = ArrayUtil.create_dictionary(_properties, func(v): return v.name)
		element_type = _element_type
		icon = _icon
	
	func _to_string() -> String:
		return "%s[%s] {\n%s\n}" % [
			name,
			element_type,
			"\n\t".join(properties.values().map(func(prop: Variable): return prop.to_string()))
		]


class Variable extends Type:
	enum Qualifier {
		NONE = 			0,
		IN = 			1 << 0,
		OUT = 			1 << 1,
		UNIFORM = 		1 << 2,
		CONST =			1 << 3,
		VARYING = 		1 << 4,
		FLAT = 			1 << 5,
		NOPERSPECTIVE = 1 << 6,
	}
	
	static var qualifiers := {
		"none": Qualifier.NONE,
		"in": Qualifier.IN,
		"out": Qualifier.OUT,
		"uniform": Qualifier.UNIFORM,
		"const": Qualifier.CONST,
		"varying": Qualifier.VARYING,
		"flat": Qualifier.FLAT,
		"noperspective": Qualifier.NOPERSPECTIVE,
	}
	
	static var _qualifiers_flipped := DictionaryUtil.flip(qualifiers)
	
	var _qualifier_icons: Dictionary = {
		Qualifier.IN: Icons.create("var_in"),
		Qualifier.OUT: Icons.create("var_out"),
		Qualifier.UNIFORM: Icons.create("var_uniform"),
		Qualifier.CONST: Icons.create("var_const"),
	}
	
	var type: String
	var qualifier: Qualifier
	
	func _init(_name: String, _type: String, _qualifier: Qualifier = Qualifier.NONE) -> void:
		type = _type
		name = _name
		qualifier = _qualifier
		
		icon = _qualifier_icons.get(qualifier, Icons.create("variable"))
	
	func _to_string() -> String:
		var qualifiers_str: String = Variable.get_qualifier_string(qualifier)
		return "%s%s %s" % [qualifiers_str + (" " if qualifiers_str else ""), type, name]
	
	static func from_def(def: String, scope: int = 0) -> Array[Variable]:
		def = def.strip_edges()
		var def_scope_removed := StringUtil.remove_scope(
			# Remove parenthesis
			StringUtil.remove_scope(
				def,
				"(", ")"
			),
			# Remove the "scope" created by the "name0 = ... , name1" chain
			"=",
			",",
			0,
			true
		).strip_edges()
		var split_index: int = def_scope_removed.find(",")
		if split_index == -1:
			split_index = StringUtil.rfind_any(def_scope_removed, StringUtil.WHITESPACE, -1)
		else:
			split_index = StringUtil.rfind_any(
				def_scope_removed,
				StringUtil.WHITESPACE,
				StringUtil.rtrim_index(
					def_scope_removed,
					StringUtil.WHITESPACE,
					posmod(split_index, def_scope_removed.length()),
				),
			)
			split_index = StringUtil.rfind_any(def_scope_removed, StringUtil.WHITESPACE, split_index - 1)
		
		var def_split := StringUtil.split_at(def_scope_removed, split_index)
		var left := StringUtil.split_at_first_any(def_split[0], StringUtil.WHITESPACE, true, false)
		
		var var_names := def_split[1].split(",", false)
		ArrayUtil.map_in_place_s(var_names, func(s: String) -> String: return s.strip_edges())
		
		var type: String = left[-1].strip_edges()
		var qualifiers: Qualifier = Qualifier.NONE
		for q in left.slice(0, -1):
			qualifiers |= Variable.qualifiers.get(q, Qualifier.NONE)
		var vars: Array[Variable] = []
		vars.resize(var_names.size())	
		for i in var_names.size():
			vars[i] = Variable.new(var_names[i].strip_edges(), type, qualifiers)
			vars[i].depth = scope
		return vars
	
	static func get_qualifier_string(qualifiers: Qualifier) -> String:
		var sb: StringBuilder = StringBuilder.new()
		for var_qualifier in _qualifiers_flipped:
			if var_qualifier & qualifiers:
				sb.append(_qualifiers_flipped[var_qualifier])
		return str(sb)
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_VARIABLE
