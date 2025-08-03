#include "glsl_language_parser.h"

using namespace godot;

void GLSLLanguageParser::_bind_methods() {
	ClassDB::bind_method(D_METHOD("parse", "content"), &GLSLLanguageParser::parse);
}

GLSLLanguageParser::GLSLLanguageParser() { print_line("constructed :)"); }

GLSLLanguageParser::~GLSLLanguageParser() { print_line("destructed :("); }

void GLSLLanguageParser::parse(const String& p_content) {}
