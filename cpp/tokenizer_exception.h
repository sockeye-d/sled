#ifndef ERROR_EXCEPTION_H
#define ERROR_EXCEPTION_H
#include <exception>

#include "godot_cpp/variant/string.hpp"

class TokenizerException : public std::exception {
	int64_t source_index{};
	godot::String message{};

public:
	[[nodiscard]] int64_t get_source_index() const;
	[[nodiscard]] const godot::String& get_message() const;
	TokenizerException(int64_t p_source_index, const godot::String& p_message);
};

#endif // ERROR_EXCEPTION_H
