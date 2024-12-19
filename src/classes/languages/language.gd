class_name Language extends Object


static var base_types: PackedStringArray
static var keywords: Dictionary[String, IconTexture2D]
static var comment_regions: PackedStringArray
static var string_regions: PackedStringArray


static func get_file_contents(path: String, file: String, depth: int = 0, base_path: String = "", currently_edited_file: bool = false, visited_files: PackedStringArray = []) -> Language.FileContents:
	push_error("you're not supposed to be here!")
	return null

class Definition extends Type:
	var value: String
	
	func _init(_name: String, _value: String) -> void:
		name = _name
		value = _value
		icon = Icons.create("definition")
	
	func _to_string() -> String:
		return "%s %s" % [name, value]
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_CONSTANT


class FileContents:
	static var built_in_contents: FileContents = null:
		set(value):
			built_in_contents = value
		get:
			if not built_in_contents:
				built_in_contents = FileContents.new()
				built_in_contents.add_depth(CodeEdit.LOCATION_OTHER)
			return built_in_contents
	
	var structs: Dictionary[String, Type]
	var variables: Array[Scope]
	## Dictionary[String, Array[Function]]
	var funcs: Dictionary[String, Array]
	var defs: Dictionary[String, Definition]
	
	func add(_obj: Type) -> void:
		if not _obj:
			return
		if _obj is Definition:
			var obj := _obj as Definition
			defs[obj.name] = obj
		if _obj is Struct:
			var obj := _obj as Struct
			structs[obj.name] = obj
			add((obj as Struct).as_fn())
		if _obj is Function:
			var obj := _obj as Function
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
			for f: Function in funcs[key]:
				f.depth += depth
		for d: Definition in defs.values():
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
	
	func find(what: String) -> Variant:
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
		var structs_merged: Dictionary = structs#.merged(Type.built_in_structs)
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
		if index >= text.length() - 1:
			return ""
		var simple_word_bounds := StringUtil.get_word(text, index)
		if not simple_word_bounds:
			return ""
		var simple_word: String = StringUtil.substr_posv(text, simple_word_bounds).strip_edges()
		var i: int = simple_word_bounds[1]
		while true:
			#i += 1
			if i > text.length() - 1:
				i = -1
				break
			if text[i] in StringUtil.WHITESPACE:
				continue
			if text[i] == "(":
				break
			i = -1
			break
		if i != -1:
			if simple_word in defs and defs[simple_word] is Macro:
				var args: PackedStringArray = StringUtil.split_scoped(StringUtil.substr_pos(text, simple_word_bounds[1] + 1, StringUtil.find_scope_end(text, i + 1, "(", ")")), ",", "(", ")")
				ArrayUtil.map_in_place_s(args, func(arg: String) -> String: return arg.strip_edges())
				return str(defs[simple_word]) + "\n\n" + (defs[simple_word] as Macro).get_expanded(args)
			var m_funcs: Dictionary[String, Array] = funcs.merged(FileContents.built_in_contents.funcs)
			#print(m_funcs)
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
	var variables: Dictionary[String, Variable] = { }
	
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
		variables.assign(DictionaryUtil.untype(variables).merged(with_variables))
	
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
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_FUNCTION


class Struct extends Type:
	var properties: Dictionary[String, Variable] = { }
	
	func _init(_name: String, _properties: Array[Variable], _icon: Texture2D = Icons.create("struct")) -> void:
		name = _name
		properties = ArrayUtil.create_dictionary(_properties,
			func(v: Variable) -> String:
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
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_CLASS


class IndexableStruct extends Struct:
	var element_type: String
	
	func _init(_name: String, _properties: Array[Variable], _element_type: String, _icon: Texture2D = Icons.create("struct")) -> void:
		name = _name
		properties.assign(ArrayUtil.create_dictionary(_properties, func(v): return v.name))
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
	
	var _qualifier_icons: Dictionary[String, IconTexture2D] = {
		"in": Icons.create("var_in"),
		"out": Icons.create("var_out"),
		"uniform": Icons.create("var_uniform"),
		"const": Icons.create("var_const"),
	}
	
	var type: String
	var qualifiers: PackedStringArray
	
	func _init(_name: String, _type: String, _qualifiers: PackedStringArray = []) -> void:
		type = _type
		name = _name
		qualifiers = _qualifiers
		
		icon = _qualifier_icons.get(qualifiers, Icons.create("variable"))
	
	func _to_string() -> String:
		var qualifiers_str: String = " ".join(qualifiers)
		return "%s%s %s" % [qualifiers_str + (" " if qualifiers_str else ""), type, name]
	
	func _get_type() -> CodeEdit.CodeCompletionKind:
		return CodeEdit.KIND_VARIABLE
