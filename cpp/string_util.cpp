#include "string_util.h"

const godot::PackedStringArray& StringUtil::whitespace() {
	const static godot::PackedStringArray data{"\n", " ", "\r"};
	return data;
}

const godot::PackedStringArray& StringUtil::numbers() {
	const static godot::PackedStringArray data{"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"};
	return data;
}

const godot::PackedStringArray& StringUtil::lowercase_alphabet() {
	const static godot::PackedStringArray data{
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	};
	return data;
}

const godot::PackedStringArray& StringUtil::uppercase_alphabet() {
	const static godot::PackedStringArray data{
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	};
	return data;
}

const godot::PackedStringArray& StringUtil::alphabet() {
	const static godot::PackedStringArray data = lowercase_alphabet() + uppercase_alphabet();
	return data;
}

const godot::PackedStringArray& StringUtil::lower_alphanum() {
	const static godot::PackedStringArray data = numbers() + lowercase_alphabet();
	return data;
}

const godot::PackedStringArray& StringUtil::upper_alphanum() {
	const static godot::PackedStringArray data = numbers() + uppercase_alphabet();
	return data;
}

const godot::PackedStringArray& StringUtil::alphanum() {
	const static godot::PackedStringArray data = numbers() + alphabet();
	return data;
}

int64_t StringUtil::find_any(const godot::String& p_str, const godot::PackedStringArray& p_what,
							 const int64_t p_start) {
	int64_t min_index = -1;
	for (const godot::String& what : p_what) {
		const int64_t found_index = p_str.find(what, p_start);
		if (found_index != -1 && (found_index < min_index || min_index == -1)) {
			min_index = found_index;
		}
	}
	return min_index;
}

godot::String StringUtil::i(const godot::String& p_str, const int64_t p_index) {
	return godot::String::chr(p_str[p_index]);
}

godot::String StringUtil::operator""_s(const char* p_str, size_t size) {
	return {p_str};
}
