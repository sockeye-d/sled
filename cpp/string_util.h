#ifndef STRING_UTIL_H
#define STRING_UTIL_H
#include "godot_cpp/variant/packed_string_array.hpp"

namespace StringUtil {
const godot::PackedStringArray& whitespace();
const godot::PackedStringArray& numbers();
const godot::PackedStringArray& lowercase_alphabet();
const godot::PackedStringArray& uppercase_alphabet();
const godot::PackedStringArray& alphabet();
const godot::PackedStringArray& lower_alphanum();
const godot::PackedStringArray& upper_alphanum();
const godot::PackedStringArray& alphanum();

int64_t find_any(const godot::String& p_str, const godot::PackedStringArray& p_what, int64_t p_start = 0);
godot::String i(const godot::String& p_str, int64_t p_index);
godot::String operator""_s(const char* p_str, size_t size);

} // namespace StringUtil

#endif // STRING_UTIL_H
