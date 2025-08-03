#include "string_builder.h"

#include "godot_cpp/variant/string.hpp"

void StringBuilder::clear() {
	strings.clear();
}

void StringBuilder::append(godot::String p_string) {
	strings.append(p_string);
}

godot::String StringBuilder::string() const {
	return godot::String("").join(strings);
}
