#ifndef STRING_UTIL_H
#define STRING_UTIL_H
#include "godot_cpp/variant/packed_string_array.hpp"

namespace StringUtil {
const inline godot::PackedStringArray whitespace{"\n", " ", "\r"};
const inline godot::PackedStringArray numbers{"\n", " ", "\r"};
const inline godot::PackedStringArray lowercase_alphabet{
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
	"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
};
const inline godot::PackedStringArray uppercase_alphabet{
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
	"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
};
const inline godot::PackedStringArray alphabet = lowercase_alphabet + uppercase_alphabet;
const inline godot::PackedStringArray alphanum = numbers + alphabet;

int64_t find_any(const godot::String& p_str, const godot::PackedStringArray& p_what, int64_t p_start = 0);
godot::String i(const godot::String &p_str, int64_t p_index);
} // namespace StringUtil

#endif // STRING_UTIL_H
