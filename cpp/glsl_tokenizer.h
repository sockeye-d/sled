#ifndef GLSL_TOKENIZER_H
#define GLSL_TOKENIZER_H

#include "glsl_token.h"
#include "godot_cpp/classes/ref_counted.hpp"
#include "string_util.h"

class GLSLTokenizer : public godot::RefCounted {
	GDCLASS(GLSLTokenizer, godot::RefCounted)

	godot::String file{};
	int64_t current_index{0};
	bool skip_whitespace{false};
	godot::Vector<GLSLToken*> tokens{};
	bool error{};
	godot::String error_message{};

protected:
	static void _bind_methods();
	[[nodiscard]] bool valid(int64_t p_length = 1) const;
	[[nodiscard]] godot::String current(int64_t p_length = 1) const;
	[[nodiscard]] godot::String peek(int64_t p_offset = 1, int64_t p_length = 1) const;
	godot::String consume(int64_t p_length = 1);
	godot::String consume_word(const godot::PackedStringArray& p_allowed_chars = StringUtil::alphanum);
	godot::String consume_whitespace();
	[[nodiscard]] int64_t
	next_word_length(int64_t p_offset = 0,
					 const godot::PackedStringArray& p_allowed_chars = StringUtil::alphanum) const;
	[[nodiscard]] godot::String next_word(int64_t p_offset = 0,
										  const godot::PackedStringArray& p_allowed_chars = StringUtil::alphanum) const;
	[[nodiscard]] int64_t find_next_nl() const;
	[[nodiscard]] static bool is_valid_identifier(const godot::String& p_string);
	[[nodiscard]] GLSLToken* token(int p_type, const godot::String& p_string = "") const;

public:
	[[nodiscard]] bool has_error() const;
	[[nodiscard]] godot::String get_error_message() const;

	static GLSLTokenizer* create(const godot::String& p_file, bool p_skip_whitespace = false);
	[[nodiscard]] godot::String get_file() const;
	void debug_print() const;
	void tokenize();
	godot::Vector<GLSLToken*> get_tokens();

	GLSLTokenizer() = default;
	~GLSLTokenizer() override = default;
};

#endif // GLSL_TOKENIZER_H
