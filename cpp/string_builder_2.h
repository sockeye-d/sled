#ifndef STRING_BUILDER_H
#define STRING_BUILDER_H

#include "godot_cpp/variant/packed_string_array.hpp"

class StringBuilder2 {
	godot::PackedStringArray strings{};

public:
	void clear();
	void append(godot::String p_string);
	[[nodiscard]] godot::String string() const;
};

#endif // STRING_BUILDER_H
