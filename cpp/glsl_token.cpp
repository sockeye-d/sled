#include "glsl_token.h"

using namespace godot;

void GLSLToken::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_type"), &GLSLToken::get_type);
	ClassDB::bind_method(D_METHOD("set_type", "type"), &GLSLToken::set_type);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "type", PROPERTY_HINT_NONE), "set_type", "get_type");

	ClassDB::bind_method(D_METHOD("get_content"), &GLSLToken::get_content);
	ClassDB::bind_method(D_METHOD("set_content", "content"), &GLSLToken::set_content);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "content", PROPERTY_HINT_NONE), "set_content", "get_content");

	ClassDB::bind_method(D_METHOD("get_source_index"), &GLSLToken::get_source_index);
	ClassDB::bind_method(D_METHOD("set_source_index", "source_index"), &GLSLToken::set_source_index);
	ADD_PROPERTY(PropertyInfo(Variant::INT, "source_index", PROPERTY_HINT_NONE), "set_source_index", "get_source_index");

	ClassDB::bind_method(D_METHOD("is_type", "type"), &GLSLToken::is_type);

	ClassDB::bind_static_method("GLSLToken", D_METHOD("get_type_name", "type"), &GLSLToken::get_type_name);
	ClassDB::bind_static_method("GLSLToken", D_METHOD("create", "type", "source_index", "content"), &GLSLToken::create);

	BIND_ENUM_CONSTANT(TYPE_IDENTIFIER);
	BIND_ENUM_CONSTANT(TYPE_STR_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_INT_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_UINT_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_HEX_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_OCT_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_FLT_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_SCI_LITERAL);
	BIND_ENUM_CONSTANT(TYPE_WHITESPACE);

	BIND_ENUM_CONSTANT(TYPE_PREPROCESSOR_KEYWORD);
	BIND_ENUM_CONSTANT(TYPE_PREPROCESSOR_CONTENT);

	BIND_ENUM_CONSTANT(TYPE_OPEN_PAREN);
	BIND_ENUM_CONSTANT(TYPE_CLOSE_PAREN);
	BIND_ENUM_CONSTANT(TYPE_OPEN_BRACKET);
	BIND_ENUM_CONSTANT(TYPE_CLOSE_BRACKET);
	BIND_ENUM_CONSTANT(TYPE_OPEN_BRACE);
	BIND_ENUM_CONSTANT(TYPE_CLOSE_BRACE);
	BIND_ENUM_CONSTANT(TYPE_DOT);
	BIND_ENUM_CONSTANT(TYPE_COMMA);
	BIND_ENUM_CONSTANT(TYPE_SEMICOLON);

	BIND_ENUM_CONSTANT(TYPE_ADD);
	BIND_ENUM_CONSTANT(TYPE_MUL);
	BIND_ENUM_CONSTANT(TYPE_DIV);
	BIND_ENUM_CONSTANT(TYPE_SUB);
	BIND_ENUM_CONSTANT(TYPE_ADD_ADD);
	BIND_ENUM_CONSTANT(TYPE_SUB_SUB);
	BIND_ENUM_CONSTANT(TYPE_ADD_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_MUL_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_SUB_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_DIV_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_LESS_THAN);
	BIND_ENUM_CONSTANT(TYPE_GREATER_THAN);
	BIND_ENUM_CONSTANT(TYPE_LESS_THAN_EQ);
	BIND_ENUM_CONSTANT(TYPE_GREATER_THAN_EQ);

	BIND_ENUM_CONSTANT(TYPE_SHIFT_LEFT);
	BIND_ENUM_CONSTANT(TYPE_SHIFT_RIGHT);
	BIND_ENUM_CONSTANT(TYPE_SHIFT_RIGHT_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_SHIFT_LEFT_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_BITWISE_NOT);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_NOT_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_NOT);
	BIND_ENUM_CONSTANT(TYPE_NOT_EQUAL);
	BIND_ENUM_CONSTANT(TYPE_ASSIGN);
	BIND_ENUM_CONSTANT(TYPE_EQUALS);

	BIND_ENUM_CONSTANT(TYPE_MOD);
	BIND_ENUM_CONSTANT(TYPE_MOD_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_AND);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_AND);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_AND_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_XOR);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_XOR);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_XOR_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_OR);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_OR);
	BIND_ENUM_CONSTANT(TYPE_BITWISE_OR_ASSIGN);

	BIND_ENUM_CONSTANT(TYPE_TERNARY_CONDITION);
	BIND_ENUM_CONSTANT(TYPE_TERNARY_SWITCH);

	BIND_ENUM_CONSTANT(TYPE_KW_ATTRIBUTE);
	BIND_ENUM_CONSTANT(TYPE_KW_CONST);
	BIND_ENUM_CONSTANT(TYPE_KW_UNIFORM);
	BIND_ENUM_CONSTANT(TYPE_KW_VARYING);
	BIND_ENUM_CONSTANT(TYPE_KW_LAYOUT);
	BIND_ENUM_CONSTANT(TYPE_KW_CENTROID);
	BIND_ENUM_CONSTANT(TYPE_KW_FLAT);
	BIND_ENUM_CONSTANT(TYPE_KW_SMOOTH);
	BIND_ENUM_CONSTANT(TYPE_KW_NOPERSPECTIVE);
	BIND_ENUM_CONSTANT(TYPE_KW_BREAK);
	BIND_ENUM_CONSTANT(TYPE_KW_CONTINUE);
	BIND_ENUM_CONSTANT(TYPE_KW_DO);
	BIND_ENUM_CONSTANT(TYPE_KW_FOR);
	BIND_ENUM_CONSTANT(TYPE_KW_WHILE);
	BIND_ENUM_CONSTANT(TYPE_KW_SWITCH);
	BIND_ENUM_CONSTANT(TYPE_KW_CASE);
	BIND_ENUM_CONSTANT(TYPE_KW_DEFAULT);
	BIND_ENUM_CONSTANT(TYPE_KW_IF);
	BIND_ENUM_CONSTANT(TYPE_KW_ELSE);
	BIND_ENUM_CONSTANT(TYPE_KW_IN);
	BIND_ENUM_CONSTANT(TYPE_KW_OUT);
	BIND_ENUM_CONSTANT(TYPE_KW_INOUT);
	BIND_ENUM_CONSTANT(TYPE_KW_VOID);
	BIND_ENUM_CONSTANT(TYPE_KW_TRUE);
	BIND_ENUM_CONSTANT(TYPE_KW_FALSE);
	BIND_ENUM_CONSTANT(TYPE_KW_INVARIANT);
	BIND_ENUM_CONSTANT(TYPE_KW_DISCARD);
	BIND_ENUM_CONSTANT(TYPE_KW_RETURN);
	BIND_ENUM_CONSTANT(TYPE_KW_LOWP);
	BIND_ENUM_CONSTANT(TYPE_KW_MEDIUMP);
	BIND_ENUM_CONSTANT(TYPE_KW_HIGHP);
	BIND_ENUM_CONSTANT(TYPE_KW_PRECISION);
	BIND_ENUM_CONSTANT(TYPE_KW_STRUCT);

	BIND_ENUM_CONSTANT(TYPE_COMMENT);
	BIND_ENUM_CONSTANT(TYPE_MULTILINE_COMMENT);

	BIND_ENUM_CONSTANT(TYPE_EOF);

	BIND_ENUM_CONSTANT(TYPE_UNKNOWN);
}

void GLSLToken::set_type(const Type p_type) { type = p_type; }

GLSLToken::Type GLSLToken::get_type() const { return type; }

void GLSLToken::set_content(const String& p_content) { content = p_content; }

String GLSLToken::get_content() const { return content; }

void GLSLToken::set_source_index(const int64_t p_source_index) { source_index = p_source_index; }

int64_t GLSLToken::get_source_index() const { return source_index; }

bool GLSLToken::is_type(const Type p_type) const { return type == p_type; }

#define STRINGIFY_TYPE(type)                                                                                           \
	if (p_type == TYPE_##type) {                                                                                       \
		return #type;                                                                                                  \
	}

String GLSLToken::get_type_name(const Type p_type) {
	STRINGIFY_TYPE(IDENTIFIER)
	STRINGIFY_TYPE(STR_LITERAL)
	STRINGIFY_TYPE(INT_LITERAL)
	STRINGIFY_TYPE(UINT_LITERAL)
	STRINGIFY_TYPE(HEX_LITERAL)
	STRINGIFY_TYPE(OCT_LITERAL)
	STRINGIFY_TYPE(FLT_LITERAL)
	STRINGIFY_TYPE(SCI_LITERAL)
	STRINGIFY_TYPE(WHITESPACE)

	STRINGIFY_TYPE(PREPROCESSOR_KEYWORD)
	STRINGIFY_TYPE(PREPROCESSOR_CONTENT)

	STRINGIFY_TYPE(OPEN_PAREN)
	STRINGIFY_TYPE(CLOSE_PAREN)
	STRINGIFY_TYPE(OPEN_BRACKET)
	STRINGIFY_TYPE(CLOSE_BRACKET)
	STRINGIFY_TYPE(OPEN_BRACE)
	STRINGIFY_TYPE(CLOSE_BRACE)
	STRINGIFY_TYPE(DOT)
	STRINGIFY_TYPE(COMMA)
	STRINGIFY_TYPE(SEMICOLON)

	STRINGIFY_TYPE(ADD)
	STRINGIFY_TYPE(MUL)
	STRINGIFY_TYPE(DIV)
	STRINGIFY_TYPE(SUB)
	STRINGIFY_TYPE(ADD_ADD)
	STRINGIFY_TYPE(SUB_SUB)
	STRINGIFY_TYPE(ADD_ASSIGN)
	STRINGIFY_TYPE(MUL_ASSIGN)
	STRINGIFY_TYPE(SUB_ASSIGN)
	STRINGIFY_TYPE(DIV_ASSIGN)

	STRINGIFY_TYPE(LESS_THAN)
	STRINGIFY_TYPE(GREATER_THAN)
	STRINGIFY_TYPE(LESS_THAN_EQ)
	STRINGIFY_TYPE(GREATER_THAN_EQ)

	STRINGIFY_TYPE(SHIFT_LEFT)
	STRINGIFY_TYPE(SHIFT_RIGHT)
	STRINGIFY_TYPE(SHIFT_RIGHT_ASSIGN)
	STRINGIFY_TYPE(SHIFT_LEFT_ASSIGN)

	STRINGIFY_TYPE(BITWISE_NOT)
	STRINGIFY_TYPE(BITWISE_NOT_ASSIGN)
	STRINGIFY_TYPE(NOT)
	STRINGIFY_TYPE(NOT_EQUAL)
	STRINGIFY_TYPE(ASSIGN)
	STRINGIFY_TYPE(EQUALS)

	STRINGIFY_TYPE(MOD)
	STRINGIFY_TYPE(MOD_ASSIGN)

	STRINGIFY_TYPE(AND)
	STRINGIFY_TYPE(BITWISE_AND)
	STRINGIFY_TYPE(BITWISE_AND_ASSIGN)

	STRINGIFY_TYPE(XOR)
	STRINGIFY_TYPE(BITWISE_XOR)
	STRINGIFY_TYPE(BITWISE_XOR_ASSIGN)

	STRINGIFY_TYPE(OR)
	STRINGIFY_TYPE(BITWISE_OR)
	STRINGIFY_TYPE(BITWISE_OR_ASSIGN)

	STRINGIFY_TYPE(TERNARY_CONDITION)
	STRINGIFY_TYPE(TERNARY_SWITCH)

	STRINGIFY_TYPE(KW_ATTRIBUTE)
	STRINGIFY_TYPE(KW_CONST)
	STRINGIFY_TYPE(KW_UNIFORM)
	STRINGIFY_TYPE(KW_VARYING)
	STRINGIFY_TYPE(KW_LAYOUT)
	STRINGIFY_TYPE(KW_CENTROID)
	STRINGIFY_TYPE(KW_FLAT)
	STRINGIFY_TYPE(KW_SMOOTH)
	STRINGIFY_TYPE(KW_NOPERSPECTIVE)
	STRINGIFY_TYPE(KW_BREAK)
	STRINGIFY_TYPE(KW_CONTINUE)
	STRINGIFY_TYPE(KW_DO)
	STRINGIFY_TYPE(KW_FOR)
	STRINGIFY_TYPE(KW_WHILE)
	STRINGIFY_TYPE(KW_SWITCH)
	STRINGIFY_TYPE(KW_CASE)
	STRINGIFY_TYPE(KW_DEFAULT)
	STRINGIFY_TYPE(KW_IF)
	STRINGIFY_TYPE(KW_ELSE)
	STRINGIFY_TYPE(KW_IN)
	STRINGIFY_TYPE(KW_OUT)
	STRINGIFY_TYPE(KW_INOUT)
	STRINGIFY_TYPE(KW_VOID)
	STRINGIFY_TYPE(KW_TRUE)
	STRINGIFY_TYPE(KW_FALSE)
	STRINGIFY_TYPE(KW_INVARIANT)
	STRINGIFY_TYPE(KW_DISCARD)
	STRINGIFY_TYPE(KW_RETURN)
	STRINGIFY_TYPE(KW_LOWP)
	STRINGIFY_TYPE(KW_MEDIUMP)
	STRINGIFY_TYPE(KW_HIGHP)
	STRINGIFY_TYPE(KW_PRECISION)
	STRINGIFY_TYPE(KW_STRUCT)

	STRINGIFY_TYPE(COMMENT)
	STRINGIFY_TYPE(MULTILINE_COMMENT)

	STRINGIFY_TYPE(EOF)

	return "UNKNOWN";
}

#undef STRINGIFY_TYPE

GLSLToken* GLSLToken::create(const Type p_type, const int64_t p_source_index, const String& p_content) {
	GLSLToken *inst = memnew(GLSLToken);
	inst->type = p_type;
	inst->content = p_content;
	inst->source_index = p_source_index;
	return inst;
}

GLSLToken::Type GLSLToken::get_kw_type(const String& p_type, int& out_kw_length) {
	if (p_type == "attribute") {
		out_kw_length = 9;
		return TYPE_KW_ATTRIBUTE;
	}
	if (p_type == "const") {
		out_kw_length = 5;
		return TYPE_KW_CONST;
	}
	if (p_type == "uniform") {
		out_kw_length = 7;
		return TYPE_KW_UNIFORM;
	}
	if (p_type == "varying") {
		out_kw_length = 7;
		return TYPE_KW_VARYING;
	}
	if (p_type == "layout") {
		out_kw_length = 6;
		return TYPE_KW_LAYOUT;
	}
	if (p_type == "centroid") {
		out_kw_length = 8;
		return TYPE_KW_CENTROID;
	}
	if (p_type == "flat") {
		out_kw_length = 4;
		return TYPE_KW_FLAT;
	}
	if (p_type == "smooth") {
		out_kw_length = 6;
		return TYPE_KW_SMOOTH;
	}
	if (p_type == "noperspective") {
		out_kw_length = 13;
		return TYPE_KW_NOPERSPECTIVE;
	}
	if (p_type == "break") {
		out_kw_length = 5;
		return TYPE_KW_BREAK;
	}
	if (p_type == "continue") {
		out_kw_length = 8;
		return TYPE_KW_CONTINUE;
	}
	if (p_type == "do") {
		out_kw_length = 2;
		return TYPE_KW_DO;
	}
	if (p_type == "for") {
		out_kw_length = 3;
		return TYPE_KW_FOR;
	}
	if (p_type == "while") {
		out_kw_length = 5;
		return TYPE_KW_WHILE;
	}
	if (p_type == "switch") {
		out_kw_length = 6;
		return TYPE_KW_SWITCH;
	}
	if (p_type == "case") {
		out_kw_length = 4;
		return TYPE_KW_CASE;
	}
	if (p_type == "default") {
		out_kw_length = 7;
		return TYPE_KW_DEFAULT;
	}
	if (p_type == "if") {
		out_kw_length = 2;
		return TYPE_KW_IF;
	}
	if (p_type == "else") {
		out_kw_length = 4;
		return TYPE_KW_ELSE;
	}
	if (p_type == "in") {
		out_kw_length = 2;
		return TYPE_KW_IN;
	}
	if (p_type == "out") {
		out_kw_length = 3;
		return TYPE_KW_OUT;
	}
	if (p_type == "inout") {
		out_kw_length = 5;
		return TYPE_KW_INOUT;
	}
	if (p_type == "void") {
		out_kw_length = 4;
		return TYPE_KW_VOID;
	}
	if (p_type == "true") {
		out_kw_length = 4;
		return TYPE_KW_TRUE;
	}
	if (p_type == "false") {
		out_kw_length = 5;
		return TYPE_KW_FALSE;
	}
	if (p_type == "invariant") {
		out_kw_length = 9;
		return TYPE_KW_INVARIANT;
	}
	if (p_type == "discard") {
		out_kw_length = 7;
		return TYPE_KW_DISCARD;
	}
	if (p_type == "return") {
		out_kw_length = 6;
		return TYPE_KW_RETURN;
	}
	if (p_type == "lowp") {
		out_kw_length = 4;
		return TYPE_KW_LOWP;
	}
	if (p_type == "mediump") {
		out_kw_length = 7;
		return TYPE_KW_MEDIUMP;
	}
	if (p_type == "highp") {
		out_kw_length = 5;
		return TYPE_KW_HIGHP;
	}
	if (p_type == "precision") {
		out_kw_length = 9;
		return TYPE_KW_PRECISION;
	}
	if (p_type == "struct") {
		out_kw_length = 6;
		return TYPE_KW_STRUCT;
	}
	return TYPE_UNKNOWN;
}
