shader_type canvas_item;

uniform float lumpiness;
uniform float lump_speed;
uniform float speed;
uniform float wavelength;
uniform vec3 color: source_color;
uniform float edge_0;
uniform float edge_1;

void fragment() {
	COLOR.rgb = color;
	float x = TIME * speed;
	x += exp(lumpiness * sin(x * lump_speed));
	// threw together a bunch of stuff but it looks pretty good
	COLOR.a = exp2(5.0 * smoothstep(edge_0 * 2.0 - 1.0, edge_1 * 2.0 - 1.0, sin(UV.x * wavelength + x)) * (1.0 - UV.y) * (UV.x) * (1.0 - UV.x))-1.0;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
