//
// Created by fish on 8/1/25.
//

#include "glsl_language_parser.h"
void GLSLLanguageParser::_bind_methods() {
	ClassDB::bind_method(D_METHOD("parse", "content"), &GLSLLanguageParser::parse);
}
GLSLLanguageParser::GLSLLanguageParser() { print_line("constructed :)"); }
GLSLLanguageParser::~GLSLLanguageParser() { print_line("destructed :("); }
void GLSLLanguageParser::parse(String content) {
	print_line("hi");
}
