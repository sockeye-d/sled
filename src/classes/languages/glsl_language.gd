class_name GLSLLanguage extends Language


static func _static_init() -> void:
	comment_regions = ["//", "/* */"]
	string_regions = ["\"", "\'"]
	
	keywords = _create_icons([
		"attribute",
		"const",
		"uniform",
		"varying",
		"layout",
		"centroid",
		"flat",
		"smooth",
		"noperspective",
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
		"in",
		"out",
		"inout",
		"float",
		"int",
		"void",
		"bool",
		"true",
		"false",
		"invariant",
		"discard",
		"return",
		"lowp",
		"mediump",
		"highp",
		"precision",
		"struct",
	])

## Used to cache the results of get_file_contents() calls, keys are file paths
static var contents_cache: Dictionary[String, FileContents]


static func _create_icons(arr: PackedStringArray) -> Dictionary[String, IconTexture2D]:
	var dict: Dictionary[String, IconTexture2D]
	for item in arr:
		var icon: IconTexture2D
		if item.begins_with("#"):
			icon = Icons.create("keyword_definition")
		else:
			icon = Icons.create("keyword_" + item, true)
			if not icon:
				icon = Icons.create("keyword")
		dict[item] = icon
	return dict


static func get_code_completion_suggestions(path: String, file: String, line: int = -1, col: int = -1, base_path: String = path, contents: FileContents = null) -> Array[CodeCompletionSuggestion]:
	if not contents:
		contents = Language.FileContents.new()
	contents = get_file_contents(path, file, 0, base_path, true)
	contents.merge(Language.FileContents.built_in_contents)
	var caret_index := StringUtil.get_index(file, line, col)
	return contents.as_suggestions(caret_index, file)

## spaghetti code mess 🥖🍝
static func get_file_contents(path: String, file: String, depth: int = 0, base_path: String = "", currently_edited_file: bool = false, visited_files: PackedStringArray = []) -> Language.FileContents:
	visited_files.append(path)
	if not currently_edited_file and contents_cache.has(path):
		# NOTE: determine whether shallow duplication is necessary
		# because get_code_completion_suggestions merges it with the built-in
		# types
		return contents_cache[path]
	var contents := Language.FileContents.new()
	
	return contents


class Tokenizer:
	var file: String
	var current_index: int
	
	
	func _init(_file: String) -> void:
		file = _file
	
	
	func tokenize() -> Array[Token]:
		var tokens: Array[Token]
		while current_index < file.length():
			var tk := get_token()
			if tk:
				tokens.append_array(tk)
		return tokens
	
	
	func get_token() -> Array[Token]:
		var c := current()
		var next_word := get_next_word()
		var next_digit := get_next_word()
		var tk: Array[Token]
		match c:
			"(":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			")":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			"[":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			"]":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			"{":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			"}":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			".":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			",":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			";":
				tk.append(token(Token.Type.SEPARATOR, consume()))
			"/":
				if peek() == "/":
					consume(2)
					var s := ""
					while valid() and current() != "\n":
						s += consume()
					tk.append(token(Token.Type.COMMENT, s))
				elif peek() == "*":
					consume(2)
					var s := ""
					while valid(2) and current(2) != "*/":
						s += consume()
					if valid(2):
						consume(2)
					tk.append(token(Token.Type.MULTILINE_COMMENT, s))
				else:
					var length := 1
					if peek() == "=":
						length = 2
					tk.append(token(Token.Type.OPERATOR, consume(length)))
			"*":
				var length := 1
				if peek() == "=":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"+":
				var length := 1
				if peek() == "=":
					length = 2
				if peek() == "+":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"-":
				var length := 1
				if peek() == "=":
					length = 2
				if peek() == "-":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			">":
				var length := 1
				if peek() == "=":
					length = 2
				elif peek(2) == ">=":
					length = 3
				elif peek() == ">":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"<":
				var length := 1
				if peek() == "=":
					length = 2
				elif peek(2) == "<=":
					length = 3
				elif peek() == "<":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"~":
				var length := 1
				if peek() == "=":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"!":
				var length := 1
				if peek() == "=":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"=":
				var length := 1
				if peek() == "=":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"%":
				var length := 1
				if peek() == "=":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"&":
				var length := 1
				if peek() == "=":
					length = 2
				elif peek() == "&":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"^":
				var length := 1
				if peek() == "=":
					length = 2
				elif peek() == "^":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"|":
				var length := 1
				if peek() == "=":
					length = 2
				elif peek() == "|":
					length = 2
				tk.append(token(Token.Type.OPERATOR, consume(length)))
			"?":
				tk.append(token(Token.Type.OPERATOR, consume()))
			":":
				tk.append(token(Token.Type.OPERATOR, consume()))
			"#":
				#tk.append(token(Token.Type.PREPROCESSOR_KEYWORD, consume()))
				consume()
				consume_whitespace()
				tk.append(token(Token.Type.PREPROCESSOR_KEYWORD, consume_word()))
				consume_whitespace()
				tk.append(token(Token.Type.IDENTIFIER, consume_word()))
				if current() == "(":
					tk.append(token(Token.Type.SEPARATOR, consume()))
					while current() != ")":
						consume_whitespace()
						tk.append(token(Token.Type.IDENTIFIER, consume_word()))
						consume_whitespace()
						var comma := consume_word([","])
						if comma:
							tk.append(token(Token.Type.SEPARATOR, comma))
					tk.append(token(Token.Type.SEPARATOR, consume()))
				consume_whitespace()
				tk.append(token(Token.Type.PREPROCESSOR_CONTENT, consume(find_next_nl())))
			_ when c in StringUtil.NUMBERS:
				var allowed_chars := StringUtil.NUMBERS
				var s := StringBuilder.new()
				if current(2).to_lower() == "0x":
					allowed_chars = [
						"a", "b", "c", "d", "e", "f",
						"A", "B", "C", "D", "E", "F",
					] + StringUtil.NUMBERS
					s.append(consume(2))
				elif current() == "0":
					s.append(consume())
				while current() in allowed_chars:
					s.append(consume())
					if current() == ".":
						s.append(consume())
				if current() == "e":
					s.append(consume())
					while current() in allowed_chars:
						s.append(consume())
				if current().to_lower() == "u":
					s.append(consume())
				tk.append(token(Token.Type.LITERAL, s.to_string()))
			_ when next_word in GLSLLanguage.keywords:
				tk.append(token(Token.Type.KEYWORD, consume(next_word.length())))
			_ when is_valid_identifier(next_word):
				tk.append(token(Token.Type.IDENTIFIER, consume(next_word.length())))
			_ when current() in StringUtil.WHITESPACE:
				tk.append(token(Token.Type.WHITESPACE, consume()))
			_:
				tk.append(token(Token.Type.UNKNOWN, consume()))
		
		return tk
	
	
	func current(length := 1) -> String:
		return file.substr(current_index, length)
	
	
	func valid(length := 1) -> bool:
		return current_index + length - 1 < file.length()
	
	
	func peek(offset := 1, length := 1) -> String:
		return file.substr(current_index + offset, length)
	
	
	func consume(length := 1) -> String:
		current_index += length
		return file.substr(current_index - length, length)
	
	
	func consume_word(allowed_chars := StringUtil.NUMBERS + StringUtil.ALPHABET) -> String:
		return consume(get_next_word_length(0, allowed_chars))
	
	
	func consume_whitespace() -> String:
		return consume_word(StringUtil.WHITESPACE)
	
	## returns [b]offset[/b] not index
	func find_next(what: String) -> int:
		return get_offset(file.find(what, current_index))
	
	## returns [b]offset[/b] not index
	func find_next_nl(offset := 0) -> int:
		var index := offset
		while valid(index) and not is_line_break(index):
			index += 1
		return index
	
	
	func is_line_break(offset := 0) -> bool:
		if peek(offset) != "\n":
			return false
		if peek(offset - 1) == "\\":
			return false
		return true
	
	
	func get_offset(index: int) -> int:
		return index - current_index
	
	
	func is_valid_identifier(string: String) -> bool:
		if not string:
			return false
		if string[0] in StringUtil.NUMBERS:
			return false
		if StringUtil.find_any(string, StringUtil.WHITESPACE) != -1:
			return false
		return true
	
	
	func get_next_word(offset := 0, allowed_chars := StringUtil.NUMBERS + StringUtil.ALPHABET) -> String:
		var index := offset
		while file[current_index + index] in allowed_chars:
			index += 1
			if not valid(index):
				break
		return file.substr(current_index, index)
	
	
	func get_next_word_length(offset := 0, allowed_chars := StringUtil.NUMBERS + StringUtil.ALPHABET) -> int:
		var index := offset
		while file[current_index + index] in allowed_chars:
			index += 1
			if not valid(index):
				break
		return index
	
	
	func token(type: Token.Type, content: String) -> Token:
		return Token.new(type, content, current_index)
	
	class Token:
		enum Type {
			IDENTIFIER,
			KEYWORD,
			PREPROCESSOR_KEYWORD,
			PREPROCESSOR_CONTENT,
			SEPARATOR,
			OPERATOR,
			LITERAL,
			WHITESPACE,
			COMMENT,
			MULTILINE_COMMENT,
			UNKNOWN,
		}
		
		var type: Type
		var content: String
		var source_index: int
		
		
		func _init(_type: Type, _content: String, _source_index: int) -> void:
			self.type = _type
			self.content = _content
			self.source_index = _source_index
		
		
		func _to_string() -> String:
			return "%s '%s' @ %s" % [Type.find_key(type), content.c_escape(), source_index]


class Parser:
	class ASTNode:
		var parent: ASTNode
		var children: Array[ASTNode]
	
	class Function extends ASTNode:
		var return_type: String
		var parameters: Array[Variable]
	
	class Assignment extends ASTNode:
		var variable: Variable
	
	class Variable:
		var type: String
		var name: String
