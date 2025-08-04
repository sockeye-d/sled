#include "string_builder_2.h"

#include "godot_cpp/variant/string.hpp"

void StringBuilder2::clear() {
	strings.clear();
}

void StringBuilder2::append(godot::String p_string) {
	strings.append(p_string);
}

godot::String StringBuilder2::string() const {
	return godot::String("").join(strings);
}
