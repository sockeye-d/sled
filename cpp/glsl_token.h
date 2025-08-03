#ifndef GLSL_TOKEN_H
#define GLSL_TOKEN_H

#include "godot_cpp/classes/ref_counted.hpp"

class GLSLToken {
	// GDCLASS(GLSLToken, godot::RefCounted)

public:
	enum Type {
		TYPE_IDENTIFIER,
		TYPE_STR_LITERAL,
		TYPE_INT_LITERAL,
		TYPE_UINT_LITERAL,
		TYPE_HEX_LITERAL,
		TYPE_OCT_LITERAL,
		TYPE_FLT_LITERAL,
		TYPE_SCI_LITERAL,
		TYPE_WHITESPACE,

		TYPE_PREPROCESSOR_KEYWORD,
		TYPE_PREPROCESSOR_CONTENT,

		TYPE_OPEN_PAREN,
		TYPE_CLOSE_PAREN,
		TYPE_OPEN_BRACKET,
		TYPE_CLOSE_BRACKET,
		TYPE_OPEN_BRACE,
		TYPE_CLOSE_BRACE,
		TYPE_DOT,
		TYPE_COMMA,
		TYPE_SEMICOLON,

		TYPE_ADD,
		TYPE_MUL,
		TYPE_DIV,
		TYPE_SUB,
		TYPE_ADD_ADD,
		TYPE_SUB_SUB,
		TYPE_ADD_ASSIGN,
		TYPE_MUL_ASSIGN,
		TYPE_SUB_ASSIGN,
		TYPE_DIV_ASSIGN,

		TYPE_LESS_THAN,
		TYPE_GREATER_THAN,
		TYPE_LESS_THAN_EQ,
		TYPE_GREATER_THAN_EQ,

		TYPE_SHIFT_LEFT,
		TYPE_SHIFT_RIGHT,
		TYPE_SHIFT_RIGHT_ASSIGN,
		TYPE_SHIFT_LEFT_ASSIGN,

		TYPE_BITWISE_NOT,
		TYPE_BITWISE_NOT_ASSIGN,
		TYPE_NOT,
		TYPE_NOT_EQUAL,
		TYPE_ASSIGN,
		TYPE_EQUALS,

		TYPE_MOD,
		TYPE_MOD_ASSIGN,

		TYPE_AND,
		TYPE_BITWISE_AND,
		TYPE_BITWISE_AND_ASSIGN,

		TYPE_XOR,
		TYPE_BITWISE_XOR,
		TYPE_BITWISE_XOR_ASSIGN,

		TYPE_OR,
		TYPE_BITWISE_OR,
		TYPE_BITWISE_OR_ASSIGN,

		TYPE_TERNARY_CONDITION,
		TYPE_TERNARY_SWITCH,

		TYPE_ATTRIBUTE,
		TYPE_CONST,
		TYPE_UNIFORM,
		TYPE_VARYING,
		TYPE_LAYOUT,
		TYPE_CENTROID,
		TYPE_FLAT,
		TYPE_SMOOTH,
		TYPE_NOPERSPECTIVE,
		TYPE_BREAK,
		TYPE_CONTINUE,
		TYPE_DO,
		TYPE_FOR,
		TYPE_WHILE,
		TYPE_SWITCH,
		TYPE_CASE,
		TYPE_DEFAULT,
		TYPE_IF,
		TYPE_ELSE,
		TYPE_IN,
		TYPE_OUT,
		TYPE_INOUT,
		TYPE_VOID,
		TYPE_TRUE,
		TYPE_FALSE,
		TYPE_INVARIANT,
		TYPE_DISCARD,
		TYPE_RETURN,
		TYPE_LOWP,
		TYPE_MEDIUMP,
		TYPE_HIGHP,
		TYPE_PRECISION,
		TYPE_STRUCT,

		TYPE_COMMENT,
		TYPE_MULTILINE_COMMENT,

		TYPE_EOF,

		TYPE_UNKNOWN,
	};

private:
	Type type{TYPE_UNKNOWN};

public:
	void set_type(Type p_type);
	[[nodiscard]] Type get_type() const;

private:
	godot::String content{};

public:
	void set_content(const godot::String& p_content);
	[[nodiscard]] godot::String get_content() const;

private:
	int64_t source_index{};

public:
	void set_source_index(int64_t p_source_index);
	[[nodiscard]] int64_t get_source_index() const;

	[[nodiscard]] bool is_type(Type p_type) const;
	static godot::String get_type_name(Type p_type);

	static GLSLToken create(Type p_type, int64_t p_source_index, const godot::String& p_content = godot::String());

	[[nodiscard]] godot::Vector <GLSLToken> as_vector() const;
};

VARIANT_ENUM_CAST(GLSLToken::Type)

#endif // GLSL_TOKEN_H
