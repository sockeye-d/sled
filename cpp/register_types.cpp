#include "register_types.h"


#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

// #include "glsl_language_parser.h"
// #include "glsl_token.h"
// #include "glsl_tokenizer.h"

using namespace godot;

void initialize_sled(const ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}

	// GDREGISTER_CLASS(GLSLLanguageParser);
	// GDREGISTER_CLASS(GLSLToken);
	// GDREGISTER_CLASS(GLSLTokenizer);
}

void uninitialize_sled(const ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {
// Initialization.
GDExtensionBool GDE_EXPORT sled_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
									 const GDExtensionClassLibraryPtr p_library,
									 GDExtensionInitialization* r_initialization) {
	const GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_sled);
	init_obj.register_terminator(uninitialize_sled);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}
