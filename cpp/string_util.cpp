#include "string_util.h"

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
