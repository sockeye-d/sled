//
// Created by fish on 8/1/25.
//

#ifndef GLSLLANGUAGEPARSER_H
#define GLSLLANGUAGEPARSER_H

#include "godot_cpp/classes/ref_counted.hpp"

using namespace godot;

class GLSLLanguageParser : public RefCounted {
	GDCLASS(GLSLLanguageParser, RefCounted)

protected:
	static void _bind_methods();

public:
	GLSLLanguageParser();
	~GLSLLanguageParser() override;

	void parse(String content);
};


#endif // GLSLLANGUAGEPARSER_H
