#ifndef GLSLLANGUAGEPARSER_H
#define GLSLLANGUAGEPARSER_H

#include "glsl_token.h"
#include "godot_cpp/classes/ref_counted.hpp"

class GLSLParser : public godot::RefCounted {
	GDCLASS(GLSLParser, godot::RefCounted);

protected:
	static void _bind_methods();

public:
	GLSLParser();
	~GLSLParser() override;

	void parse(godot::Array tokens);
};

class NumberLiteral2 : public godot::RefCounted {
	GDCLASS(NumberLiteral2, godot::RefCounted);

	godot::String value{};

protected:
	static void _bind_methods();

public:
	void set_value(const godot::String p_value) { value = p_value; }

	[[nodiscard]] godot::String get_value() const { return value; }
};

#endif // GLSLLANGUAGEPARSER_H
