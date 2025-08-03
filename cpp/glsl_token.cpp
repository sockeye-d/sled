#include "glsl_token.h"

using namespace godot;

void GLSLToken::set_type(const Type p_type) { type = p_type; }

GLSLToken::Type GLSLToken::get_type() const { return type; }

void GLSLToken::set_content(const String& p_content) { content = p_content; }

String GLSLToken::get_content() const { return content; }

void GLSLToken::set_source_index(const int64_t p_source_index) { source_index = p_source_index; }

int64_t GLSLToken::get_source_index() const { return source_index; }

// void GLSLToken::_bind_methods() {
// 	ClassDB::bind_method(D_METHOD("get_type"), &GLSLToken::get_type);
// 	ClassDB::bind_method(D_METHOD("set_type", "type"), &GLSLToken::set_type);
// 	ADD_PROPERTY(PropertyInfo(Variant::INT, "type", PROPERTY_HINT_NONE), "set_type", "get_type");
//
// 	ClassDB::bind_method(D_METHOD("get_content"), &GLSLToken::get_content);
// 	ClassDB::bind_method(D_METHOD("set_content", "content"), &GLSLToken::set_content);
// 	ADD_PROPERTY(PropertyInfo(Variant::STRING, "content", PROPERTY_HINT_NONE), "set_content", "get_content");
//
// 	ClassDB::bind_static_method("GLSLToken", D_METHOD("get_type_name", "type"), &GLSLToken::get_type_name);
//
// 	BIND_ENUM_CONSTANT(TYPE_IDENTIFIER)
// 	BIND_ENUM_CONSTANT(TYPE_LITERAL)
// 	BIND_ENUM_CONSTANT(TYPE_WHITESPACE)
//
// 	BIND_ENUM_CONSTANT(TYPE_PREPROCESSOR_KEYWORD)
// 	BIND_ENUM_CONSTANT(TYPE_PREPROCESSOR_CONTENT)
//
// 	BIND_ENUM_CONSTANT(TYPE_OPEN_PAREN)
// 	BIND_ENUM_CONSTANT(TYPE_CLOSE_PAREN)
// 	BIND_ENUM_CONSTANT(TYPE_OPEN_BRACKET)
// 	BIND_ENUM_CONSTANT(TYPE_CLOSE_BRACKET)
// 	BIND_ENUM_CONSTANT(TYPE_OPEN_BRACE)
// 	BIND_ENUM_CONSTANT(TYPE_CLOSE_BRACE)
// 	BIND_ENUM_CONSTANT(TYPE_DOT)
// 	BIND_ENUM_CONSTANT(TYPE_COMMA)
// 	BIND_ENUM_CONSTANT(TYPE_SEMICOLON)
//
// 	BIND_ENUM_CONSTANT(TYPE_ADD)
// 	BIND_ENUM_CONSTANT(TYPE_MUL)
// 	BIND_ENUM_CONSTANT(TYPE_DIV)
// 	BIND_ENUM_CONSTANT(TYPE_SUB)
// 	BIND_ENUM_CONSTANT(TYPE_ADD_ADD)
// 	BIND_ENUM_CONSTANT(TYPE_SUB_SUB)
// 	BIND_ENUM_CONSTANT(TYPE_ADD_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_MUL_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_SUB_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_DIV_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_LESS_THAN)
// 	BIND_ENUM_CONSTANT(TYPE_GREATER_THAN)
// 	BIND_ENUM_CONSTANT(TYPE_LESS_THAN_EQ)
// 	BIND_ENUM_CONSTANT(TYPE_GREATER_THAN_EQ)
//
// 	BIND_ENUM_CONSTANT(TYPE_SHIFT_LEFT)
// 	BIND_ENUM_CONSTANT(TYPE_SHIFT_RIGHT)
// 	BIND_ENUM_CONSTANT(TYPE_SHIFT_RIGHT_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_SHIFT_LEFT_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_NOT)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_NOT_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_NOT)
// 	BIND_ENUM_CONSTANT(TYPE_NOT_EQUAL)
// 	BIND_ENUM_CONSTANT(TYPE_ASSIGN)
// 	BIND_ENUM_CONSTANT(TYPE_EQUALS)
//
// 	BIND_ENUM_CONSTANT(TYPE_MOD)
// 	BIND_ENUM_CONSTANT(TYPE_MOD_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_AND)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_AND)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_AND_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_XOR)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_XOR)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_XOR_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_OR)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_OR)
// 	BIND_ENUM_CONSTANT(TYPE_BITWISE_OR_ASSIGN)
//
// 	BIND_ENUM_CONSTANT(TYPE_TERNARY_CONDITION)
// 	BIND_ENUM_CONSTANT(TYPE_TERNARY_SWITCH)
//
// 	BIND_ENUM_CONSTANT(TYPE_ATTRIBUTE)
// 	BIND_ENUM_CONSTANT(TYPE_CONST)
// 	BIND_ENUM_CONSTANT(TYPE_UNIFORM)
// 	BIND_ENUM_CONSTANT(TYPE_VARYING)
// 	BIND_ENUM_CONSTANT(TYPE_LAYOUT)
// 	BIND_ENUM_CONSTANT(TYPE_CENTROID)
// 	BIND_ENUM_CONSTANT(TYPE_FLAT)
// 	BIND_ENUM_CONSTANT(TYPE_SMOOTH)
// 	BIND_ENUM_CONSTANT(TYPE_NOPERSPECTIVE)
// 	BIND_ENUM_CONSTANT(TYPE_BREAK)
// 	BIND_ENUM_CONSTANT(TYPE_CONTINUE)
// 	BIND_ENUM_CONSTANT(TYPE_DO)
// 	BIND_ENUM_CONSTANT(TYPE_FOR)
// 	BIND_ENUM_CONSTANT(TYPE_WHILE)
// 	BIND_ENUM_CONSTANT(TYPE_SWITCH)
// 	BIND_ENUM_CONSTANT(TYPE_CASE)
// 	BIND_ENUM_CONSTANT(TYPE_DEFAULT)
// 	BIND_ENUM_CONSTANT(TYPE_IF)
// 	BIND_ENUM_CONSTANT(TYPE_ELSE)
// 	BIND_ENUM_CONSTANT(TYPE_IN)
// 	BIND_ENUM_CONSTANT(TYPE_OUT)
// 	BIND_ENUM_CONSTANT(TYPE_INOUT)
// 	BIND_ENUM_CONSTANT(TYPE_VOID)
// 	BIND_ENUM_CONSTANT(TYPE_TRUE)
// 	BIND_ENUM_CONSTANT(TYPE_FALSE)
// 	BIND_ENUM_CONSTANT(TYPE_INVARIANT)
// 	BIND_ENUM_CONSTANT(TYPE_DISCARD)
// 	BIND_ENUM_CONSTANT(TYPE_RETURN)
// 	BIND_ENUM_CONSTANT(TYPE_LOWP)
// 	BIND_ENUM_CONSTANT(TYPE_MEDIUMP)
// 	BIND_ENUM_CONSTANT(TYPE_HIGHP)
// 	BIND_ENUM_CONSTANT(TYPE_PRECISION)
// 	BIND_ENUM_CONSTANT(TYPE_STRUCT)
//
// 	BIND_ENUM_CONSTANT(TYPE_COMMENT)
// 	BIND_ENUM_CONSTANT(TYPE_MULTILINE_COMMENT)
//
// 	BIND_ENUM_CONSTANT(TYPE_EOF)
//
// 	BIND_ENUM_CONSTANT(TYPE_UNKNOWN)
// }

bool GLSLToken::is_type(const Type p_type) const { return type == p_type; }

String GLSLToken::get_type_name(const Type p_type) {
	if (p_type == TYPE_IDENTIFIER) {
		return "IDENTIFIER";
	}
	if (p_type == TYPE_STR_LITERAL) {
		return "LITERAL";
	}
	if (p_type == TYPE_WHITESPACE) {
		return "WHITESPACE";
	}

	if (p_type == TYPE_PREPROCESSOR_KEYWORD) {
		return "PREPROCESSOR_KEYWORD";
	}
	if (p_type == TYPE_PREPROCESSOR_CONTENT) {
		return "PREPROCESSOR_CONTENT";
	}

	if (p_type == TYPE_OPEN_PAREN) {
		return "OPEN_PAREN";
	}
	if (p_type == TYPE_CLOSE_PAREN) {
		return "CLOSE_PAREN";
	}
	if (p_type == TYPE_OPEN_BRACKET) {
		return "OPEN_BRACKET";
	}
	if (p_type == TYPE_CLOSE_BRACKET) {
		return "CLOSE_BRACKET";
	}
	if (p_type == TYPE_OPEN_BRACE) {
		return "OPEN_BRACE";
	}
	if (p_type == TYPE_CLOSE_BRACE) {
		return "CLOSE_BRACE";
	}
	if (p_type == TYPE_DOT) {
		return "DOT";
	}
	if (p_type == TYPE_COMMA) {
		return "COMMA";
	}
	if (p_type == TYPE_SEMICOLON) {
		return "SEMICOLON";
	}

	if (p_type == TYPE_ADD) {
		return "ADD";
	}
	if (p_type == TYPE_MUL) {
		return "MUL";
	}
	if (p_type == TYPE_DIV) {
		return "DIV";
	}
	if (p_type == TYPE_SUB) {
		return "SUB";
	}
	if (p_type == TYPE_ADD_ADD) {
		return "ADD_ADD";
	}
	if (p_type == TYPE_SUB_SUB) {
		return "SUB_SUB";
	}
	if (p_type == TYPE_ADD_ASSIGN) {
		return "ADD_ASSIGN";
	}
	if (p_type == TYPE_MUL_ASSIGN) {
		return "MUL_ASSIGN";
	}
	if (p_type == TYPE_SUB_ASSIGN) {
		return "SUB_ASSIGN";
	}
	if (p_type == TYPE_DIV_ASSIGN) {
		return "DIV_ASSIGN";
	}

	if (p_type == TYPE_LESS_THAN) {
		return "LESS_THAN";
	}
	if (p_type == TYPE_GREATER_THAN) {
		return "GREATER_THAN";
	}
	if (p_type == TYPE_LESS_THAN_EQ) {
		return "LESS_THAN_EQ";
	}
	if (p_type == TYPE_GREATER_THAN_EQ) {
		return "GREATER_THAN_EQ";
	}

	if (p_type == TYPE_SHIFT_LEFT) {
		return "SHIFT_LEFT";
	}
	if (p_type == TYPE_SHIFT_RIGHT) {
		return "SHIFT_RIGHT";
	}
	if (p_type == TYPE_SHIFT_RIGHT_ASSIGN) {
		return "SHIFT_RIGHT_ASSIGN";
	}
	if (p_type == TYPE_SHIFT_LEFT_ASSIGN) {
		return "SHIFT_LEFT_ASSIGN";
	}

	if (p_type == TYPE_BITWISE_NOT) {
		return "BITWISE_NOT";
	}
	if (p_type == TYPE_BITWISE_NOT_ASSIGN) {
		return "BITWISE_NOT_ASSIGN";
	}
	if (p_type == TYPE_NOT) {
		return "NOT";
	}
	if (p_type == TYPE_NOT_EQUAL) {
		return "NOT_EQUAL";
	}
	if (p_type == TYPE_ASSIGN) {
		return "ASSIGN";
	}
	if (p_type == TYPE_EQUALS) {
		return "EQUALS";
	}

	if (p_type == TYPE_MOD) {
		return "MOD";
	}
	if (p_type == TYPE_MOD_ASSIGN) {
		return "MOD_ASSIGN";
	}

	if (p_type == TYPE_AND) {
		return "AND";
	}
	if (p_type == TYPE_BITWISE_AND) {
		return "BITWISE_AND";
	}
	if (p_type == TYPE_BITWISE_AND_ASSIGN) {
		return "BITWISE_AND_ASSIGN";
	}

	if (p_type == TYPE_XOR) {
		return "XOR";
	}
	if (p_type == TYPE_BITWISE_XOR) {
		return "BITWISE_XOR";
	}
	if (p_type == TYPE_BITWISE_XOR_ASSIGN) {
		return "BITWISE_XOR_ASSIGN";
	}

	if (p_type == TYPE_OR) {
		return "OR";
	}
	if (p_type == TYPE_BITWISE_OR) {
		return "BITWISE_OR";
	}
	if (p_type == TYPE_BITWISE_OR_ASSIGN) {
		return "BITWISE_OR_ASSIGN";
	}

	if (p_type == TYPE_TERNARY_CONDITION) {
		return "TERNARY_CONDITION";
	}
	if (p_type == TYPE_TERNARY_SWITCH) {
		return "TERNARY_SWITCH";
	}

	if (p_type == TYPE_ATTRIBUTE) {
		return "ATTRIBUTE";
	}
	if (p_type == TYPE_CONST) {
		return "CONST";
	}
	if (p_type == TYPE_UNIFORM) {
		return "UNIFORM";
	}
	if (p_type == TYPE_VARYING) {
		return "VARYING";
	}
	if (p_type == TYPE_LAYOUT) {
		return "LAYOUT";
	}
	if (p_type == TYPE_CENTROID) {
		return "CENTROID";
	}
	if (p_type == TYPE_FLAT) {
		return "FLAT";
	}
	if (p_type == TYPE_SMOOTH) {
		return "SMOOTH";
	}
	if (p_type == TYPE_NOPERSPECTIVE) {
		return "NOPERSPECTIVE";
	}
	if (p_type == TYPE_BREAK) {
		return "BREAK";
	}
	if (p_type == TYPE_CONTINUE) {
		return "CONTINUE";
	}
	if (p_type == TYPE_DO) {
		return "DO";
	}
	if (p_type == TYPE_FOR) {
		return "FOR";
	}
	if (p_type == TYPE_WHILE) {
		return "WHILE";
	}
	if (p_type == TYPE_SWITCH) {
		return "SWITCH";
	}
	if (p_type == TYPE_CASE) {
		return "CASE";
	}
	if (p_type == TYPE_DEFAULT) {
		return "DEFAULT";
	}
	if (p_type == TYPE_IF) {
		return "IF";
	}
	if (p_type == TYPE_ELSE) {
		return "ELSE";
	}
	if (p_type == TYPE_IN) {
		return "IN";
	}
	if (p_type == TYPE_OUT) {
		return "OUT";
	}
	if (p_type == TYPE_INOUT) {
		return "INOUT";
	}
	if (p_type == TYPE_VOID) {
		return "VOID";
	}
	if (p_type == TYPE_TRUE) {
		return "TRUE";
	}
	if (p_type == TYPE_FALSE) {
		return "FALSE";
	}
	if (p_type == TYPE_INVARIANT) {
		return "INVARIANT";
	}
	if (p_type == TYPE_DISCARD) {
		return "DISCARD";
	}
	if (p_type == TYPE_RETURN) {
		return "RETURN";
	}
	if (p_type == TYPE_LOWP) {
		return "LOWP";
	}
	if (p_type == TYPE_MEDIUMP) {
		return "MEDIUMP";
	}
	if (p_type == TYPE_HIGHP) {
		return "HIGHP";
	}
	if (p_type == TYPE_PRECISION) {
		return "PRECISION";
	}
	if (p_type == TYPE_STRUCT) {
		return "STRUCT";
	}

	if (p_type == TYPE_COMMENT) {
		return "COMMENT";
	}
	if (p_type == TYPE_MULTILINE_COMMENT) {
		return "MULTILINE_COMMENT";
	}

	if (p_type == TYPE_EOF) {
		return "EOF";
	}

	return "UNKNOWN";
}

GLSLToken GLSLToken::create(const Type p_type, const int64_t p_source_index, const String& p_content) {
	GLSLToken inst;
	inst.type = p_type;
	inst.content = p_content;
	inst.source_index = p_source_index;
	return inst;
}

Vector<GLSLToken> GLSLToken::as_vector() const {
	Vector<GLSLToken> inst;
	inst.resize(1);
	GLSLToken copy{};
	copy.content = content;
	copy.source_index = source_index;
	copy.type = type;
	inst.set(0, copy);
	return inst;
}
