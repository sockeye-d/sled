#include "tokenizer_exception.h"

int64_t TokenizerException::get_source_index() const { return source_index; }

const godot::String& TokenizerException::get_message() const { return message; }

TokenizerException::TokenizerException(const int64_t p_source_index, const godot::String& p_message) : source_index(p_source_index), message(p_message) {}
