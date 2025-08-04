#include "glsl_tokenizer.h"

#include <unordered_set>

#include "godot_cpp/core/class_db.hpp"
#include "string_builder_2.h"
#include "tokenizer_exception.h"
#include "string_util.h"

using namespace godot;

void GLSLTokenizer::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_file"), &GLSLTokenizer::get_file);
	ClassDB::bind_method(D_METHOD("tokenize"), &GLSLTokenizer::tokenize);
	ClassDB::bind_method(D_METHOD("debug_print"), &GLSLTokenizer::debug_print);
	ClassDB::bind_method(D_METHOD("has_error"), &GLSLTokenizer::has_error);
	ClassDB::bind_method(D_METHOD("get_error_message"), &GLSLTokenizer::get_error_message);
	ClassDB::bind_method(D_METHOD("get_tokens"), &GLSLTokenizer::get_tokens);

	ClassDB::bind_method(D_METHOD("get_skip_whitespace"), &GLSLTokenizer::get_skip_whitespace);
	ClassDB::bind_method(D_METHOD("set_skip_whitespace", "skip_whitespace"), &GLSLTokenizer::set_skip_whitespace);
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "skip_whitespace", PROPERTY_HINT_NONE), "set_skip_whitespace", "get_skip_whitespace");

	ClassDB::bind_static_method("GLSLTokenizer", D_METHOD("create", "file", "skip_whitespace"), &GLSLTokenizer::create,
								DEFVAL(false));
}

bool GLSLTokenizer::valid(const int64_t p_length) const { return current_index + p_length - 1 < file.length(); }

String GLSLTokenizer::current(const int64_t p_length) const { return peek(0, p_length); }

String GLSLTokenizer::peek(const int64_t p_offset, const int64_t p_length) const {
	return file.substr(current_index + p_offset, p_length);
}

String GLSLTokenizer::consume(const int64_t p_length) {
	const int64_t old_index = current_index;
	current_index += p_length;
	return file.substr(old_index, p_length);
}

String GLSLTokenizer::consume_word(const PackedStringArray& p_allowed_chars) {
	return consume(next_word_length(0, p_allowed_chars));
}

String GLSLTokenizer::consume_whitespace() { return consume_word(StringUtil::whitespace()); }

int64_t GLSLTokenizer::next_word_length(int64_t p_offset, const PackedStringArray& p_allowed_chars) const {
	while (p_allowed_chars.has(StringUtil::i(file, current_index + p_offset++))) {
		if (!valid(p_offset)) {
			break;
		}
	}
	return p_offset - 1;
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
		print_line("was empty :( ", p_string);
		return false;
	}
	if (StringUtil::numbers().has(StringUtil::i(p_string, 0))) {
		print_line("started with a number :( ", p_string);
		return false;
	}
	if (StringUtil::find_any(p_string, StringUtil::whitespace()) != -1) {
		print_line("contained whitespace :( ", "'" + p_string + "'");
		return false;
	}
	print_line("good :) ", p_string);
	return true;
}

GLSLToken* GLSLTokenizer::token(int p_type, const String& p_string) const {
	return GLSLToken::create(static_cast<GLSLToken::Type>(p_type), current_index, p_string);
}

bool GLSLTokenizer::has_error() const { return error; }

String GLSLTokenizer::get_error_message() const { return error_message; }

GLSLTokenizer* GLSLTokenizer::create(const String& p_file, const bool p_skip_whitespace) {
	GLSLTokenizer* tokenizer = memnew(GLSLTokenizer);
	tokenizer->file = p_file;
	tokenizer->skip_whitespace = p_skip_whitespace;
	return tokenizer;
}

String GLSLTokenizer::get_file() const { return file; }

bool GLSLTokenizer::get_skip_whitespace() const {
	return skip_whitespace;
}

String bbc_escape(const String& t) {
	return t.replace("[", "🥔👈").replace("]", "👉🥔").replace("🥔👈", "[lb]").replace("👉🥔", "[rb]");
}

void GLSLTokenizer::set_skip_whitespace(const bool p_skip_whitespace) {
	skip_whitespace = p_skip_whitespace;
}

void GLSLTokenizer::debug_print() const {
	using namespace StringUtil;
	const static String& cell = "[cell padding=1,0,1,0 border=#AAAAAA12]";
	const static String& fmt_str = cell + "%s[/cell]"_s + cell + "%s[/cell]"_s + cell + "%s[/cell]"_s;
	PackedStringArray token_strs{};
	token_strs.resize(tokens.size());
	for (int i = 0; i < tokens.size(); i++) {
		const GLSLToken* tk = tokens[i];
		token_strs[i] = vformat(fmt_str, GLSLToken::get_type_name(tk->get_type()), "'"_s + bbc_escape(tk->get_content().c_escape()) + "'"_s, itos(tk->get_source_index()));
	}

	print_line_rich("[table=3]"_s + cell + "Type[/cell]"_s + cell + "Content[/cell]"_s + cell + "Character index[/cell]"_s + "\n"_s.join(token_strs) + "[/table]"_s);
}

void GLSLTokenizer::tokenize() {
	const int64_t file_len = file.length();
	tokens.clear();
	error = false;
	current_index = 0;
	while (current_index < file_len) {
		try {
			for (GLSLToken* token : get_partial_tokens()) {
				if (skip_whitespace && token->get_type() == GLSLToken::TYPE_WHITESPACE) {
					continue;
				}
				tokens.append(token);
			}
		} catch (const TokenizerException& e) {
			print_line(String("%s @%s") % PackedStringArray{{e.get_message(), e.get_source_index()}});
			error = true;
			error_message = e.get_message();
		}
	}
	tokens.append(token(GLSLToken::TYPE_EOF));
}

#define SWITCH_TK(token) if (current_char == (token))
#define SINGLE_TK(token_type)                                                                                          \
	return { token(GLSLToken::token_type, consume()) }
#define MULTI_TK(token_type, token_length)                                                                             \
	return { token(GLSLToken::token_type, consume(token_length)) }

Vector<GLSLToken*> GLSLTokenizer::get_partial_tokens() {
	using enum GLSLToken::Type;
	const String current_char = current();
	SWITCH_TK("(") { SINGLE_TK(TYPE_OPEN_PAREN); }
	SWITCH_TK(")") { SINGLE_TK(TYPE_CLOSE_PAREN); }
	SWITCH_TK("[") { SINGLE_TK(TYPE_OPEN_BRACKET); }
	SWITCH_TK("]") { SINGLE_TK(TYPE_CLOSE_BRACKET); }
	SWITCH_TK("{") { SINGLE_TK(TYPE_OPEN_BRACE); }
	SWITCH_TK("}") { SINGLE_TK(TYPE_CLOSE_BRACE); }
	SWITCH_TK(".") { SINGLE_TK(TYPE_DOT); }
	SWITCH_TK(";") { SINGLE_TK(TYPE_SEMICOLON); }
	SWITCH_TK("/") {
		Vector<GLSLToken*> new_tokens{};
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
		Vector<GLSLToken*> new_tokens{};
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
	if (StringUtil::numbers().has(current_char)) {
		PackedStringArray allowed_chars = StringUtil::numbers();
		PackedStringArray disallowed_chars = StringUtil::alphanum() + PackedStringArray{{"."}};
		StringBuilder2 builder{};
		GLSLToken::Type target_type = TYPE_UNKNOWN;
		if (current(2) == "0x") {
			// hexadecimal literal
			allowed_chars.append_array({"a", "b", "c", "d", "e", "f", "A", "B", "C", "D", "E", "F"});
			builder.append(consume(2));
			target_type = TYPE_HEX_LITERAL;
		} else if (current() == "0") {
			// octal literal
			builder.append(consume());
			target_type = TYPE_OCT_LITERAL;
		}

		while (valid() && allowed_chars.has(current())) {
			builder.append(consume());
			if (current() == ".") {
				builder.append(consume());
				if (target_type != TYPE_UNKNOWN) {
					throw TokenizerException(current_index, "unexpected '.'");
				}
				target_type = TYPE_FLT_LITERAL;
			}
		}

		if (current() == "e") {
			target_type = TYPE_SCI_LITERAL;

			builder.append(consume());
			while (valid() && allowed_chars.has(current())) {
				builder.append(consume());
			}

			if (disallowed_chars.has(current())) {
				throw TokenizerException(current_index, String("unexpected '%s'") % current());
			}

			return {token(target_type, builder.string())};
		}

		if (current() == "u") {
			target_type = TYPE_UINT_LITERAL;
			builder.append(consume());
			if (disallowed_chars.has(current())) {
				throw TokenizerException(current_index, String("unexpected '%s'") % current());
			}
			return {token(target_type, builder.string())};
		}

		if (disallowed_chars.has(current())) {
			throw TokenizerException(current_index, String("unexpected '%s'") % current());
		}

		if (target_type == TYPE_UNKNOWN) {
			target_type = TYPE_INT_LITERAL;
		}

		return {token(target_type, builder.string())};
	}
	const String next_word_str = next_word();
	int next_kw_type_len{};
	const GLSLToken::Type next_kw_type = GLSLToken::get_kw_type(next_word_str, next_kw_type_len);
	if (next_kw_type != TYPE_UNKNOWN) {
		return {token(next_kw_type, consume(next_kw_type_len))};
	}
	if (is_valid_identifier(next_word_str)) {
		return {token(TYPE_IDENTIFIER, consume(next_word_str.length()))};
	}
	if (StringUtil::whitespace().has(current_char)) {
		return {token(TYPE_WHITESPACE, consume())};
	}

	return {token(TYPE_UNKNOWN, consume())};
}

Array GLSLTokenizer::get_tokens() const {
	Array new_tokens{};
	new_tokens.resize(tokens.size());
	for (int64_t i = 0; i < tokens.size(); ++i) {
		new_tokens[i] = tokens[i];
	}
	return new_tokens;
}
