#ifndef GLSLLANGUAGEPARSER_H
#define GLSLLANGUAGEPARSER_H

#include "godot_cpp/classes/ref_counted.hpp"

class GLSLLanguageParser : public godot::RefCounted {
	GDCLASS(GLSLLanguageParser, godot::RefCounted)

protected:
	static void _bind_methods();

public:
	GLSLLanguageParser();
	~GLSLLanguageParser() override;

	void parse(godot::String content);
};

#endif // GLSLLANGUAGEPARSER_H
