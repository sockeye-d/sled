@tool
class_name ThemeImporter extends Object


static func import_theme(
		code_edit: CodeEdit,
		path: String,
		keywords: PackedStringArray = [
#region All GLSL keywords (there are many)
			"attribute", "uniform", "varying", "layout", "centroid", "flat", "smooth", "noperspective", "patch", "sample", "subroutine", "in", "out", "inout", "invariant", "discard", "mat2", "mat3", "mat4", "dmat2", "dmat3", "dmat4", "mat2x2", "mat2x3", "mat2x4", "dmat2x2", "dmat2x3", "dmat2x4", "mat3x2", "mat3x3", "mat3x4", "dmat3x2", "dmat3x3", "dmat3x4", "mat4x2", "mat4x3", "mat4x4", "dmat4x2", "dmat4x3", "dmat4x4", "vec2", "vec3", "vec4", "ivec2", "ivec3", "ivec4", "bvec2", "bvec3", "bvec4", "dvec2", "dvec3", "dvec4", "uvec2", "uvec3", "uvec4", "lowp", "mediump", "highp", "precision", "sampler1D", "sampler2D", "sampler3D", "samplerCube", "sampler1DShadow", "sampler2DShadow", "samplerCubeShadow", "sampler1DArray", "sampler2DArray", "sampler1DArrayShadow", "sampler2DArrayShadow", "isampler1D", "isampler2D", "isampler3D", "isamplerCube", "isampler1DArray", "isampler2DArray", "usampler1D", "usampler2D", "usampler3D", "usamplerCube", "usampler1DArray", "usampler2DArray", "sampler2DRect", "sampler2DRectShadow", "isampler2DRect", "usampler2DRect", "samplerBuffer", "isamplerBuffer", "usamplerBuffer", "sampler2DMS", "isampler2DMS", "usampler2DMS", "sampler2DMSArray", "isampler2DMSArray", "usampler2DMSArray", "samplerCubeArray", "samplerCubeArrayShadow", "isamplerCubeArray", "usamplerCubeArray", "common", "partition", "active", "asm", "class", "union", "enum", "typedef", "template", "this", "packed", "goto", "inline", "noinline", "volatile", "public", "static", "extern", "external", "interface", "long", "short", "half", "fixed", "unsigned", "superp", "input", "output", "hvec2", "hvec3", "hvec4", "fvec2", "fvec3", "fvec4", "sampler3DRect", "filter", "image1D", "image2D", "image3D", "imageCube", "iimage1D", "iimage2D", "iimage3D", "iimageCube", "uimage1D", "uimage2D", "uimage3D", "uimageCube", "image1DArray", "image2DArray", "iimage1DArray", "iimage2DArray", "uimage1DArray", "uimage2DArray", "image1DShadow", "image2DShadow", "image1DArrayShadow", "image2DArrayShadow", "imageBuffer", "iimageBuffer", "uimageBuffer", "sizeof", "cast", "namespace", "using", "row_major"
#endregion
			],
		comment_regions: PackedStringArray = ["//", "/* */"],
		string_regions: PackedStringArray = ['" "', "' '"],
		) -> void:

	var file = FileAccess.open(path, FileAccess.READ).get_as_text(true)
	var theme: TextEditorTheme = TextEditorTheme.new()
	var highlighter = CodeHighlighter.new()

	var theme_dict: Dictionary = {}
	var theme_overrides: Dictionary = {}
	for line in file.split("\n", false).slice(1):
		var key_value: PackedStringArray = line.replace(" ", "") .split("=")
		if not key_value.size() == 2:
			continue
		var value = Color(key_value[1].trim_prefix('"').trim_suffix('"'))
		theme_dict[key_value[0]] = value
		if highlighter.get(key_value[0]) == null:
			theme_overrides[key_value[0]] = value
		else:
			highlighter.set(key_value[0], value)

	for key in theme_overrides:
		code_edit.add_theme_color_override(key, theme_overrides[key])

	for keyword in keywords:
		highlighter.add_member_keyword_color(keyword, theme_dict.keyword_color)
	for region in comment_regions:
		var region_split = region.split(" ")
		var single_line = not " " in region
		highlighter.add_color_region(region_split[0], "" if single_line else region_split[-1], theme_dict.comment_color, single_line)
	for region in string_regions:
		highlighter.add_color_region(region.get_slice(" ", 0), region.get_slice(" ", 1), theme_dict.string_color)
	code_edit.syntax_highlighter = highlighter
