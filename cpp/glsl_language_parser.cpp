#include "glsl_language_parser.h"

using namespace godot;

void GLSLParser::_bind_methods() {
	ClassDB::bind_method(D_METHOD("parse", "content"), &GLSLParser::parse);
}

GLSLParser::GLSLParser() { print_line("constructed :)"); }

GLSLParser::~GLSLParser() { print_line("destructed :("); }

void GLSLParser::parse(Array tokens) {}

void NumberLiteral2::_bind_methods() {
	ClassDB::bind_method(D_METHOD("get_value"), &NumberLiteral2::get_value);
	ClassDB::bind_method(D_METHOD("set_value", "value"), &NumberLiteral2::set_value);
	ADD_PROPERTY(PropertyInfo(Variant::STRING, "value", PROPERTY_HINT_NONE), "set_value", "get_value");
}
