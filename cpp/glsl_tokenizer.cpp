#include "glsl_tokenizer.h"

#include <unordered_set>

#include "godot_cpp/core/class_db.hpp"
#include "string_builder.h"

using namespace godot;

void GLSLTokenizer::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_file"), &GLSLTokenizer::get_file);
	ClassDB::bind_method(D_METHOD("tokenize"), &GLSLTokenizer::tokenize);
	ClassDB::bind_method(D_METHOD("debug_print"), &GLSLTokenizer::debug_print);

	ClassDB::bind_static_method("GLSLTokenizer", D_METHOD("create", "file", "skip_whitespace"), &GLSLTokenizer::create,
								DEFVAL(false));
}

bool GLSLTokenizer::valid(const int64_t p_length) const { return current_index + p_length - 1 < file.length(); }

String GLSLTokenizer::current(const int64_t p_length) const { return peek(0, p_length); }

String GLSLTokenizer::peek(const int64_t p_offset, const int64_t p_length) const {
	return file.substr(current_index + p_offset, p_length);
}

String GLSLTokenizer::consume(int64_t p_length) {
	const int64_t old_index = current_index;
	current_index += p_length;
	return file.substr(old_index, p_length);
}

String GLSLTokenizer::consume_word(const PackedStringArray& p_allowed_chars) {
	return consume(next_word_length(0, p_allowed_chars));
}

String GLSLTokenizer::consume_whitespace() { return consume_word(StringUtil::whitespace); }

int64_t GLSLTokenizer::next_word_length(int64_t p_offset, const PackedStringArray& p_allowed_chars) const {
	while (p_allowed_chars.has(StringUtil::i(file, current_index + p_offset++))) {
		if (!valid(p_offset)) {
			break;
		}
	}
	return p_offset;
}

String GLSLTokenizer::next_word(int64_t p_offset, const PackedStringArray& p_allowed_chars) const {
	return file.substr(current_index + p_offset, next_word_length(p_offset, p_allowed_chars));
}

int64_t GLSLTokenizer::find_next_nl() const {
	int64_t offset = 0;
	for (; valid(offset); offset++) {
		if (peek(offset) == "\n" || peek(offset) == "\\") {
			break;
		}
	}
	return offset;
}

bool GLSLTokenizer::is_valid_identifier(const String& p_string) {
	// empty strings are invalid identifiers...
	// ...
	// ...or are they? 🤨 vsauce music
	if (p_string.is_empty()) {
		return false;
	}
	if (StringUtil::numbers.has(StringUtil::i(p_string, 0))) {
		return false;
	}
	if (StringUtil::find_any(p_string, StringUtil::whitespace)) {
		return false;
	}
	return true;
}

GLSLToken GLSLTokenizer::token(const GLSLToken::Type p_type, const String& p_string) const {
	return GLSLToken::create(p_type, current_index, p_string);
}

GLSLTokenizer* GLSLTokenizer::create(const String& p_file, const bool p_skip_whitespace) {
	GLSLTokenizer* tokenizer = memnew(GLSLTokenizer);
	tokenizer->file = p_file;
	tokenizer->skip_whitespace = p_skip_whitespace;
	return tokenizer;
}

String GLSLTokenizer::get_file() const { return file; }

String bbc_escape(const String& t) {
	return t.replace("[", "🥔👈").replace("]", "👉🥔").replace("🥔👈", "[lb]").replace("👉🥔", "[rb]");
}

void GLSLTokenizer::debug_print() const {
	const static String cell = "[cell padding=1,0,1,0 border=#AAAAAA12]";
	PackedStringArray token_strs{};
	token_strs.resize(tokens.size());
	for (int i = 0; i < tokens.size(); i++) {
		GLSLToken tk = tokens[i];
		token_strs[i] = ("" + cell + "%s[/cell]" + cell + "%s[/cell]" + cell + "%s[/cell]") %
			PackedStringArray{{GLSLToken::get_type_name(tk.get_type()), tk.get_content().c_escape()}};
	}
	print_line_rich("[table={3}]" + cell + "Type[/cell]" + cell + "Content[/cell]" + cell + "Character index[/cell]" +
					String("\n").join(token_strs) + "[/table]");
}

void GLSLTokenizer::tokenize() {
	const int64_t fileLen = file.length();
	while (current_index < fileLen) {
		for (const GLSLToken& token : get_tokens()) {
			if (skip_whitespace && token.get_type() == GLSLToken::TYPE_WHITESPACE) {
				continue;
			}
			tokens.append(token);
		}
	}
	tokens.append(token(GLSLToken::TYPE_EOF));
}

#define SWITCH_TK(token) if (current_char == (token))
#define SINGLE_TK(token_type) return {token(GLSLToken::token_type, consume())}
#define MULTI_TK(token_type, token_length) return {token(GLSLToken::token_type, consume(token_length))}

Vector<GLSLToken> GLSLTokenizer::get_tokens() {
	using enum GLSLToken::Type;
	const String current_char = current();
	SWITCH_TK("(") { SINGLE_TK(TYPE_OPEN_BRACE); }
	SWITCH_TK(")") { SINGLE_TK(TYPE_CLOSE_PAREN); }
	SWITCH_TK("[") { SINGLE_TK(TYPE_OPEN_BRACKET); }
	SWITCH_TK("]") { SINGLE_TK(TYPE_CLOSE_BRACKET); }
	SWITCH_TK("{") { SINGLE_TK(TYPE_OPEN_BRACE); }
	SWITCH_TK("}") { SINGLE_TK(TYPE_CLOSE_BRACE); }
	SWITCH_TK(".") { SINGLE_TK(TYPE_DOT); }
	SWITCH_TK(";") { SINGLE_TK(TYPE_SEMICOLON); }
	SWITCH_TK("/") {
		Vector<GLSLToken> new_tokens{};
		if (peek() == "/") {
			consume(2);
			String s{};
			while (valid() and peek() != "\n") {
				s += consume();
			}
			new_tokens.append(token(TYPE_COMMENT, s));
		} else if (peek() == "*") {
			consume(2);
			String s{};
			while (valid(2) and peek(2) != "*/") {
				s += consume();
			}
			if (valid(2)) {
				consume(2);
			}
			new_tokens.append(token(TYPE_MULTILINE_COMMENT, s));
		} else if (peek() == "=") {
			new_tokens.append(token(TYPE_DIV_ASSIGN, consume(2)));
		} else {
			new_tokens.append(token(TYPE_DIV, consume(1)));
		}
		return new_tokens;
	}
	SWITCH_TK("*") {
		if (peek() == "=") {
			return {token(TYPE_MUL_ASSIGN, consume(2))};
		}
		return {token(TYPE_MUL)};
	}
	SWITCH_TK("+") {
		if (peek() == "=") {
			return {token(TYPE_ADD_ASSIGN, consume(2))};
		}
		if (peek() == "+") {
			return {token(TYPE_ADD_ADD, consume(2))};
		}
		return {token(TYPE_ADD, consume())};
	}
	SWITCH_TK("-") {
		if (peek() == "=") {
			return {token(TYPE_SUB_ASSIGN, consume(2))};
		}
		if (peek() == "-") {
			return {token(TYPE_SUB_SUB, consume(2))};
		}
		return {token(TYPE_SUB, consume())};
	}
	SWITCH_TK(">") {
		if (peek() == "=") { // >=
			return {token(TYPE_GREATER_THAN_EQ, consume(2))};
		}
		if (peek() == ">") { // >>
			return {token(TYPE_SHIFT_RIGHT, consume(2))};
		}
		if (peek(2) == ">=") { // >>=
			return {token(TYPE_SHIFT_RIGHT_ASSIGN, consume(2))};
		}
		return {token(TYPE_GREATER_THAN, consume())};
	}
	SWITCH_TK("<") {
		if (peek() == "=") { // <=
			return {token(TYPE_LESS_THAN_EQ, consume(2))};
		}
		if (peek() == "<") { // <
			return {token(TYPE_SHIFT_LEFT, consume(2))};
		}
		if (peek(2) == "<=") { // <<=
			return {token(TYPE_SHIFT_LEFT_ASSIGN, consume(2))};
		}
		return {token(TYPE_LESS_THAN, consume())};
	}
	SWITCH_TK("~") {
		if (peek() == "=") {
			return {token(TYPE_BITWISE_NOT_ASSIGN, consume(2))};
		}
		return {token(TYPE_BITWISE_NOT, consume())};
	}
	SWITCH_TK("!") {
		if (peek() == "=") {
			return {token(TYPE_NOT_EQUAL, consume(2))};
		}
		return {token(TYPE_NOT, consume())};
	}
	SWITCH_TK("=") {
		if (peek() == "=") {
			return {token(TYPE_EQUALS, consume(2))};
		}
		return {token(TYPE_ASSIGN, consume())};
	}
	SWITCH_TK("%") {
		if (peek() == "=") {
			return {token(TYPE_MOD_ASSIGN, consume(2))};
		}
		return {token(TYPE_MOD, consume())};
	}
	SWITCH_TK("&") {
		if (peek() == "=") {
			return {token(TYPE_BITWISE_AND_ASSIGN, consume(2))};
		}
		if (peek() == "&") {
			return {token(TYPE_AND, consume(2))};
		}
		return {token(TYPE_BITWISE_AND, consume())};
	}
	SWITCH_TK("^") {
		if (peek() == "=") {
			return {token(TYPE_BITWISE_XOR_ASSIGN, consume(2))};
		}
		if (peek() == "^") {
			return {token(TYPE_XOR, consume(2))};
		}
		return {token(TYPE_BITWISE_XOR, consume())};
	}
	SWITCH_TK("|") {
		if (peek() == "=") {
			return {token(TYPE_BITWISE_OR_ASSIGN, consume(2))};
		}
		if (peek() == "|") {
			return {token(TYPE_OR, consume(2))};
		}
		return {token(TYPE_BITWISE_OR, consume())};
	}
	SWITCH_TK("?") { SINGLE_TK(TYPE_TERNARY_CONDITION); }
	SWITCH_TK(":") { SINGLE_TK(TYPE_TERNARY_SWITCH); }
	SWITCH_TK("#") {
		Vector<GLSLToken> new_tokens{};
		consume();
		consume_whitespace();
		new_tokens.append(token(TYPE_PREPROCESSOR_KEYWORD, consume_word()));
		consume_whitespace();
		new_tokens.append(token(TYPE_IDENTIFIER, consume_word()));
		if (current() == "(") {
			new_tokens.append(token(TYPE_OPEN_PAREN, consume()));
			while (current() != ")") {
				consume_whitespace();
				new_tokens.append(token(TYPE_IDENTIFIER, consume_word()));
				consume_whitespace();
				if (String comma = consume_word({","}); !comma.is_empty()) {
					new_tokens.append(token(TYPE_COMMA, comma));
				}
			}
			new_tokens.append(token(TYPE_CLOSE_PAREN, consume()));
		}
		consume_whitespace();
		new_tokens.append(token(TYPE_PREPROCESSOR_CONTENT, consume(find_next_nl())));
		return new_tokens;
	}
	if (StringUtil::numbers.has(current_char)) {
		PackedStringArray allowed_chars{};
		StringBuilder builder{};
		if (current(2) == "0x") {

		}
	}

	return {};
}
