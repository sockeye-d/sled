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
		"void",
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


class Tokenizer:
	var file: String
	var current_index: int
	var skip_whitespace: bool = false
	
	
	func _init(_file: String) -> void:
		file = _file
	
	
	func tokenize() -> Array[Token]:
		var tokens: Array[Token]
		while current_index < file.length():
			var tks := get_token()
			if tks:
				for tk in tks:
					if skip_whitespace and tk.type == Token.Type.WHITESPACE:
						continue
					tokens.append(tk)
		tokens.append(token(Token.Type.EOF))
		return tokens
	
	
	func get_token() -> Array[Token]:
		var c := current()
		var next_word := get_next_word()
		var next_digit := get_next_word()
		var tk: Array[Token]
		match c:
			"(":
				tk.append(token(Token.Type.OPEN_PAREN, consume()))
			")":
				tk.append(token(Token.Type.CLOSE_PAREN, consume()))
			"[":
				tk.append(token(Token.Type.OPEN_BRACKET, consume()))
			"]":
				tk.append(token(Token.Type.CLOSE_BRACKET, consume()))
			"{":
				tk.append(token(Token.Type.OPEN_BRACE, consume()))
			"}":
				tk.append(token(Token.Type.CLOSE_BRACE, consume()))
			".":
				tk.append(token(Token.Type.DOT, consume()))
			",":
				tk.append(token(Token.Type.COMMA, consume()))
			";":
				tk.append(token(Token.Type.SEMICOLON, consume()))
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
					if peek() == "=":
						tk.append(token(Token.Type.DIV_ASSIGN, consume(2)))
					else:
						tk.append(token(Token.Type.DIV, consume(1)))
			"*":
				if peek() == "=":
					tk.append(token(Token.Type.MUL_ASSIGN, consume(2)))
				else:
					tk.append(token(Token.Type.MUL, consume()))
			"+":
				if peek() == "=":
					tk.append(token(Token.Type.ADD_ASSIGN, consume(2)))
				elif peek() == "+":
					tk.append(token(Token.Type.ADD_ADD, consume(2)))
				else:
					tk.append(token(Token.Type.ADD, consume()))
			"-":
				if peek() == "=":
					tk.append(token(Token.Type.SUB_ASSIGN, consume(2)))
				elif peek() == "-":
					tk.append(token(Token.Type.SUB_SUB, consume(2)))
				else:
					tk.append(token(Token.Type.SUB, consume()))
			">":
				if peek() == "=":
					# > =
					tk.append(token(Token.Type.GREATER_THAN_EQ, consume(2)))
				elif peek() == ">":
					# > >
					tk.append(token(Token.Type.SHIFT_RIGHT, consume(2)))
				elif peek(2) == ">=":
					# > > =
					tk.append(token(Token.Type.SHIFT_RIGHT_ASSIGN, consume(3)))
				else:
					# >
					tk.append(token(Token.Type.GREATER_THAN, consume()))
			"<":
				if peek() == "=":
					tk.append(token(Token.Type.LESS_THAN_EQ, consume(2)))
				elif peek() == "<":
					tk.append(token(Token.Type.SHIFT_LEFT, consume(2)))
				elif peek(2) == "<=":
					tk.append(token(Token.Type.SHIFT_LEFT_ASSIGN, consume(3)))
				else:
					tk.append(token(Token.Type.LESS_THAN, consume()))
			"~":
				if peek() == "=":
					tk.append(token(Token.Type.BITWISE_NOT_ASSIGN, consume(2)))
				else:
					tk.append(token(Token.Type.BITWISE_NOT, consume()))
			"!":
				if peek() == "=":
					tk.append(token(Token.Type.NOT_EQUAL, consume(2)))
				else:
					tk.append(token(Token.Type.NOT, consume()))
			"=":
				if peek() == "=":
					tk.append(token(Token.Type.EQUALS, consume(2)))
				else:
					tk.append(token(Token.Type.ASSIGN, consume()))
			"%":
				if peek() == "=":
					tk.append(token(Token.Type.MOD_ASSIGN, consume(2)))
				else:
					tk.append(token(Token.Type.MOD, consume()))
			"&":
				if peek() == "=":
					tk.append(token(Token.Type.BITWISE_AND_ASSIGN, consume(2)))
				elif peek() == "&":
					tk.append(token(Token.Type.AND, consume(2)))
				else:
					tk.append(token(Token.Type.BITWISE_AND, consume()))
			"^":
				if peek() == "=":
					tk.append(token(Token.Type.BITWISE_XOR_ASSIGN, consume(2)))
				elif peek() == "^":
					tk.append(token(Token.Type.XOR, consume(2)))
				else:
					tk.append(token(Token.Type.BITWISE_XOR, consume()))
			"|":
				if peek() == "=":
					tk.append(token(Token.Type.BITWISE_OR_ASSIGN, consume(2)))
				elif peek() == "|":
					tk.append(token(Token.Type.OR, consume(2)))
				else:
					tk.append(token(Token.Type.BITWISE_OR, consume()))
			"?":
				tk.append(token(Token.Type.TERNARY_CONDITION, consume()))
			":":
				tk.append(token(Token.Type.TERNARY_SWITCH, consume()))
			"#":
				#tk.append(token(Token.Type.PREPROCESSOR_KEYWORD, consume()))
				consume()
				consume_whitespace()
				tk.append(token(Token.Type.PREPROCESSOR_KEYWORD, consume_word()))
				consume_whitespace()
				tk.append(token(Token.Type.IDENTIFIER, consume_word()))
				if current() == "(":
					tk.append(token(Token.Type.OPEN_PAREN, consume()))
					while current() != ")":
						consume_whitespace()
						tk.append(token(Token.Type.IDENTIFIER, consume_word()))
						consume_whitespace()
						var comma := consume_word([","])
						if comma:
							tk.append(token(Token.Type.COMMA, comma))
					tk.append(token(Token.Type.CLOSE_PAREN, consume()))
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
				match next_word:
					"attribute":
						tk.append(token(Token.Type.ATTRIBUTE, consume(9)))
					"const":
						tk.append(token(Token.Type.CONST, consume(5)))
					"uniform":
						tk.append(token(Token.Type.UNIFORM, consume(7)))
					"varying":
						tk.append(token(Token.Type.VARYING, consume(7)))
					"layout":
						tk.append(token(Token.Type.LAYOUT, consume(6)))
					"centroid":
						tk.append(token(Token.Type.CENTROID, consume(8)))
					"flat":
						tk.append(token(Token.Type.FLAT, consume(4)))
					"smooth":
						tk.append(token(Token.Type.SMOOTH, consume(6)))
					"noperspective":
						tk.append(token(Token.Type.NOPERSPECTIVE, consume(13)))
					"break":
						tk.append(token(Token.Type.BREAK, consume(5)))
					"continue":
						tk.append(token(Token.Type.CONTINUE, consume(8)))
					"do":
						tk.append(token(Token.Type.DO, consume(2)))
					"for":
						tk.append(token(Token.Type.FOR, consume(3)))
					"while":
						tk.append(token(Token.Type.WHILE, consume(5)))
					"switch":
						tk.append(token(Token.Type.SWITCH, consume(6)))
					"case":
						tk.append(token(Token.Type.CASE, consume(4)))
					"default":
						tk.append(token(Token.Type.DEFAULT, consume(7)))
					"if":
						tk.append(token(Token.Type.IF, consume(2)))
					"else":
						tk.append(token(Token.Type.ELSE, consume(4)))
					"in":
						tk.append(token(Token.Type.IN, consume(2)))
					"out":
						tk.append(token(Token.Type.OUT, consume(3)))
					"inout":
						tk.append(token(Token.Type.INOUT, consume(5)))
					"void":
						tk.append(token(Token.Type.VOID, consume(4)))
					"true":
						tk.append(token(Token.Type.TRUE, consume(4)))
					"false":
						tk.append(token(Token.Type.FALSE, consume(5)))
					"invariant":
						tk.append(token(Token.Type.INVARIANT, consume(9)))
					"discard":
						tk.append(token(Token.Type.DISCARD, consume(7)))
					"return":
						tk.append(token(Token.Type.RETURN, consume(6)))
					"lowp":
						tk.append(token(Token.Type.LOWP, consume(4)))
					"mediump":
						tk.append(token(Token.Type.MEDIUMP, consume(7)))
					"highp":
						tk.append(token(Token.Type.HIGHP, consume(5)))
					"precision":
						tk.append(token(Token.Type.PRECISION, consume(9)))
					"struct":
						tk.append(token(Token.Type.STRUCT, consume(6)))
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
			if not valid(index + 1):
				break
		return file.substr(current_index, index)
	
	
	func get_next_word_length(offset := 0, allowed_chars := StringUtil.NUMBERS + StringUtil.ALPHABET) -> int:
		var index := offset
		while file[current_index + index] in allowed_chars:
			index += 1
			if not valid(index):
				break
		return index
	
	
	func token(type: Token.Type, content: String = "") -> Token:
		return Token.new(type, content, current_index)
	
class Token:
	enum Type {
		IDENTIFIER,
		LITERAL,
		WHITESPACE,
		
		PREPROCESSOR_KEYWORD,
		PREPROCESSOR_CONTENT,
		
		OPEN_PAREN,
		CLOSE_PAREN,
		OPEN_BRACKET,
		CLOSE_BRACKET,
		OPEN_BRACE,
		CLOSE_BRACE,
		DOT,
		COMMA,
		SEMICOLON,

		ADD,
		MUL,
		DIV,
		SUB,
		ADD_ADD,
		SUB_SUB,
		ADD_ASSIGN,
		MUL_ASSIGN,
		SUB_ASSIGN,
		DIV_ASSIGN,

		LESS_THAN,
		GREATER_THAN,
		LESS_THAN_EQ,
		GREATER_THAN_EQ,

		SHIFT_LEFT,
		SHIFT_RIGHT,
		SHIFT_RIGHT_ASSIGN,
		SHIFT_LEFT_ASSIGN,

		BITWISE_NOT,
		BITWISE_NOT_ASSIGN,
		NOT,
		NOT_EQUAL,
		ASSIGN,
		EQUALS,

		MOD,
		MOD_ASSIGN,

		AND,
		BITWISE_AND,
		BITWISE_AND_ASSIGN,

		XOR,
		BITWISE_XOR,
		BITWISE_XOR_ASSIGN,

		OR,
		BITWISE_OR,
		BITWISE_OR_ASSIGN,

		TERNARY_CONDITION,
		TERNARY_SWITCH,

		ATTRIBUTE,
		CONST,
		UNIFORM,
		VARYING,
		LAYOUT,
		CENTROID,
		FLAT,
		SMOOTH,
		NOPERSPECTIVE,
		BREAK,
		CONTINUE,
		DO,
		FOR,
		WHILE,
		SWITCH,
		CASE,
		DEFAULT,
		IF,
		ELSE,
		IN,
		OUT,
		INOUT,
		VOID,
		TRUE,
		FALSE,
		INVARIANT,
		DISCARD,
		RETURN,
		LOWP,
		MEDIUMP,
		HIGHP,
		PRECISION,
		STRUCT,
		
		COMMENT,
		MULTILINE_COMMENT,
		
		EOF,

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
	
	
	func is_type(compare_type: Type) -> bool:
		return type == compare_type

# expression	-> equality
# equality		-> comparison ( ( "!=" | "==" ) comparison )*
# comparison	-> term ( ( ">" | ">=" | "<" | "<=" ) term )*
# term			-> factor ( ( "-" | "+" ) factor )*
# factor		-> unary ( ( "/" | "*" ) unary )*
# unary			-> ( "!" | "-" ) unary | primary
# primary		-> NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")"

static func parse(string: String) -> Language.Expr:
	var tokenizer := Tokenizer.new(string)
	tokenizer.skip_whitespace = true
	var tokens: Array[Token] = tokenizer.tokenize()
	
	# this does like debug print stuff
	if true:
		var bbc_escape := func(t: String) -> String: return t.replace("[", "🥔👈").replace("]", "👉🥔").replace("🥔👈", "[lb]").replace("👉🥔", "[rb]")
		const CELL = "[cell padding=1,0,1,0 border=#AAAAAA12]"
		# ????
		print_rich(
			# header
			"[table={3}]" + CELL + "Type[/cell]" + CELL + "Content[/cell]" + CELL + "Character index[/cell]"
			+ "\n".join(tokens.map(
				func(e: GLSLLanguage.Token) -> String:
					return (CELL + "%s[/cell]" + CELL + "%s[/cell]" + CELL + "%s[/cell]") % [
						GLSLLanguage.Token.Type.find_key(e.type), "'" + bbc_escape.call(e.content.c_escape()) + "'", e.source_index
					], # <- comma magically fixes errors
			)) + "[/table]"
		)
	
	return Parser.new(tokens).parse()



class Parser:
	var tokens: Array[Token]
	var current: int = 0
	
	func _init(tokens: Array[Token] = []) -> void:
		self.tokens = tokens
	
	func parse() -> Language.Expr:
		return expression()
	
	func expression() -> Language.Expr:
		return assignment()
	
	func assignment() -> Language.Expr:
		var expr := selection()
		if match_any_tk([
				Token.Type.ASSIGN,
				Token.Type.ADD_ASSIGN,
				Token.Type.MUL_ASSIGN,
				Token.Type.SUB_ASSIGN,
				Token.Type.DIV_ASSIGN,
				Token.Type.SHIFT_RIGHT_ASSIGN,
				Token.Type.SHIFT_LEFT_ASSIGN,
				Token.Type.BITWISE_NOT_ASSIGN,
				Token.Type.MOD_ASSIGN,
				Token.Type.BITWISE_AND_ASSIGN,
				Token.Type.BITWISE_XOR_ASSIGN,
				Token.Type.BITWISE_OR_ASSIGN,
			]):
			
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), expression())
		return expr
	
	func selection() -> Language.Expr:
		var expr := logical_or()
		if match_tk(Token.Type.TERNARY_CONDITION):
			var on_true := expression()
			assert(match_tk(Token.Type.TERNARY_SWITCH), "Expected ':' after ternary")
			var on_false := selection()
			expr = Language.TernaryExpr.new(expr, on_true, on_false)
		return expr
	
	func logical_or() -> Language.Expr:
		var expr := logical_xor()
		while match_tk(Token.Type.OR):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.OR, logical_xor())
		return expr
	
	func logical_xor() -> Language.Expr:
		var expr := logical_and()
		while match_tk(Token.Type.XOR):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.XOR, logical_and())
		return expr
	
	func logical_and() -> Language.Expr:
		var expr := bitwise_xor()
		while match_tk(Token.Type.AND):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.AND, bitwise_xor())
		return expr
	
	func bitwise_xor() -> Language.Expr:
		var expr := bitwise_or()
		while match_tk(Token.Type.BITWISE_XOR):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.BITWISE_XOR, bitwise_or())
		return expr
	
	func bitwise_or() -> Language.Expr:
		var expr := bitwise_and()
		while match_tk(Token.Type.BITWISE_OR):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.BITWISE_OR, bitwise_and())
		return expr
	
	func bitwise_and() -> Language.Expr:
		var expr := equality()
		while match_tk(Token.Type.BITWISE_AND):
			expr = Language.BinaryExpr.new(expr, Language.BinaryExpr.Op.BITWISE_AND, equality())
		return expr
	
	func equality() -> Language.Expr:
		var expr := comparison()
		while match_any_tk([Token.Type.NOT_EQUAL, Token.Type.EQUALS]):
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), comparison())
		return expr
	
	func comparison() -> Language.Expr:
		var expr := bitshift()
		while match_any_tk([
				Token.Type.LESS_THAN, Token.Type.LESS_THAN_EQ,
				Token.Type.GREATER_THAN, Token.Type.GREATER_THAN_EQ,
			]):
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), bitshift())
		return expr
	
	func bitshift() -> Language.Expr:
		var expr := term()
		while match_any_tk([Token.Type.SHIFT_LEFT, Token.Type.SHIFT_RIGHT]):
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), term())
		return expr
	
	func term() -> Language.Expr:
		var expr := factor()
		while match_any_tk([Token.Type.ADD, Token.Type.SUB]):
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), factor())
		return expr
	
	func factor() -> Language.Expr:
		var expr := left_unary()
		while match_any_tk([Token.Type.MUL, Token.Type.DIV, Token.Type.MOD]):
			expr = Language.BinaryExpr.new(expr, tk2binaryop(previous().type), left_unary())
		return expr
	
	func left_unary() -> Language.Expr:
		if match_any_tk([
				Token.Type.SUB, Token.Type.ADD,
				Token.Type.SUB_SUB, Token.Type.ADD_ADD,
				Token.Type.NOT, Token.Type.BITWISE_NOT
		]):
			var op := tk2unaryleftop(previous().type)
			return Language.LeftUnaryExpr.new(right_unary(), op)
		return right_unary()
	
	func right_unary() -> Language.Expr:
		var expr := fn_call()
		if match_any_tk([Token.Type.SUB_SUB, Token.Type.ADD_ADD]):
			var op := tk2unaryrightop(previous().type)
			expr = Language.RightUnaryExpr.new(expr, op)
		elif match_tk(Token.Type.OPEN_BRACKET):
			expr = Language.SubscriptExpr.new(expr, expression())
			assert(match_tk(Token.Type.CLOSE_BRACKET), "Expect ']' after subscription operator")
		elif match_tk(Token.Type.DOT):
			expr = Language.FieldAccessExpr.new(expr, right_unary())
		return expr
	
	func fn_call() -> Language.Expr:
		var expr := primary()
		if match_tk(Token.Type.OPEN_PAREN):
			assert(expr is Language.Identifier, "Function name expected")
			var args: Array[Language.Expr] = []
			if peek().type != Token.Type.CLOSE_PAREN:
				args = argument()
			expr = Language.FunctionCallExpr.new(expr, args)
			assert(match_tk(Token.Type.CLOSE_PAREN), "Expect ')' after function call")
		return expr
	
	func primary() -> Language.Expr:
		if match_tk(Token.Type.LITERAL):
			return Language.NumberLiteral.new(previous().content)
		elif match_tk(Token.Type.TRUE):
			return Language.BooleanLiteral.new(true)
		elif match_tk(Token.Type.FALSE):
			return Language.BooleanLiteral.new(false)
		elif match_tk(Token.Type.OPEN_PAREN):
			var expr := expression()
			
			# need real error solution; see panic mode
			assert(match_tk(Token.Type.CLOSE_PAREN), "Must have closing parenthesis")
			return expr
		elif match_tk(Token.Type.IDENTIFIER):
			return Language.Identifier.new(previous().content)
		assert(false, "Unknown token type")
		return null
	
	func argument() -> Array[Language.Expr]:
		var exprs: Array[Language.Expr] = [expression()]
		while match_tk(Token.Type.COMMA):
			exprs.append(expression())
		return exprs
	
	func match_tk(token_type: Token.Type) -> bool:
		if check(token_type):
			advance()
			return true
		return false
	
	func match_any_tk(token_types: Array[Token.Type]) -> bool:
		for token_type in token_types:
			if check(token_type):
				advance()
				return true
		return false
	
	func advance() -> void:
		current += 1
	
	func peek() -> Token:
		return tokens[current]
	
	func check(token_type: Token.Type) -> bool:
		return peek().type == token_type
	
	func is_at_end() -> bool:
		return peek().type == Token.Type.EOF
	
	func previous() -> Token:
		return tokens[current - 1]
	
	func tk2binaryop(token_type: Token.Type) -> Language.BinaryExpr.Op:
		const map: Dictionary[Token.Type, Language.BinaryExpr.Op] = {
			Token.Type.ADD: Language.BinaryExpr.Op.ADD,
			Token.Type.MUL: Language.BinaryExpr.Op.MUL,
			Token.Type.DIV: Language.BinaryExpr.Op.DIV,
			Token.Type.SUB: Language.BinaryExpr.Op.SUB,

			Token.Type.ADD_ASSIGN: Language.BinaryExpr.Op.ADD_ASSIGN,
			Token.Type.MUL_ASSIGN: Language.BinaryExpr.Op.MUL_ASSIGN,
			Token.Type.SUB_ASSIGN: Language.BinaryExpr.Op.SUB_ASSIGN,
			Token.Type.DIV_ASSIGN: Language.BinaryExpr.Op.DIV_ASSIGN,

			Token.Type.LESS_THAN: Language.BinaryExpr.Op.LESS_THAN,
			Token.Type.GREATER_THAN: Language.BinaryExpr.Op.GREATER_THAN,
			Token.Type.LESS_THAN_EQ: Language.BinaryExpr.Op.LESS_THAN_EQ,
			Token.Type.GREATER_THAN_EQ: Language.BinaryExpr.Op.GREATER_THAN_EQ,

			Token.Type.SHIFT_LEFT: Language.BinaryExpr.Op.SHIFT_LEFT,
			Token.Type.SHIFT_RIGHT: Language.BinaryExpr.Op.SHIFT_RIGHT,
			Token.Type.SHIFT_RIGHT_ASSIGN: Language.BinaryExpr.Op.SHIFT_RIGHT_ASSIGN,
			Token.Type.SHIFT_LEFT_ASSIGN: Language.BinaryExpr.Op.SHIFT_LEFT_ASSIGN,

			Token.Type.BITWISE_NOT_ASSIGN: Language.BinaryExpr.Op.BITWISE_NOT_ASSIGN,
			Token.Type.NOT_EQUAL: Language.BinaryExpr.Op.NOT_EQUAL,
			Token.Type.ASSIGN: Language.BinaryExpr.Op.ASSIGN,
			Token.Type.EQUALS: Language.BinaryExpr.Op.EQUALS,

			Token.Type.MOD: Language.BinaryExpr.Op.MOD,
			Token.Type.MOD_ASSIGN: Language.BinaryExpr.Op.MOD_ASSIGN,

			Token.Type.AND: Language.BinaryExpr.Op.AND,
			Token.Type.BITWISE_AND: Language.BinaryExpr.Op.BITWISE_AND,
			Token.Type.BITWISE_AND_ASSIGN: Language.BinaryExpr.Op.BITWISE_AND_ASSIGN,

			Token.Type.XOR: Language.BinaryExpr.Op.XOR,
			Token.Type.BITWISE_XOR: Language.BinaryExpr.Op.BITWISE_XOR,
			Token.Type.BITWISE_XOR_ASSIGN: Language.BinaryExpr.Op.BITWISE_XOR_ASSIGN,

			Token.Type.OR: Language.BinaryExpr.Op.OR,
			Token.Type.BITWISE_OR: Language.BinaryExpr.Op.BITWISE_OR,
			Token.Type.BITWISE_OR_ASSIGN: Language.BinaryExpr.Op.BITWISE_OR_ASSIGN,
		}
		return map[token_type]
	
	func tk2unaryleftop(token_type: Token.Type) -> Language.LeftUnaryExpr.Op:
		const map: Dictionary[Token.Type, Language.LeftUnaryExpr.Op] = {
			Token.Type.NOT: Language.LeftUnaryExpr.Op.NOT,
			Token.Type.SUB: Language.LeftUnaryExpr.Op.SUB,
			Token.Type.ADD_ADD: Language.LeftUnaryExpr.Op.ADD_ADD,
			Token.Type.SUB_SUB: Language.LeftUnaryExpr.Op.SUB_SUB,
		}
		return map[token_type]
	
	func tk2unaryrightop(token_type: Token.Type) -> Language.RightUnaryExpr.Op:
		const map: Dictionary[Token.Type, Language.RightUnaryExpr.Op] = {
			Token.Type.ADD_ADD: Language.RightUnaryExpr.Op.ADD_ADD,
			Token.Type.SUB_SUB: Language.RightUnaryExpr.Op.SUB_SUB,
		}
		return map[token_type]
