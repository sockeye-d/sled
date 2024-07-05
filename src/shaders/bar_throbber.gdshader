shader_type canvas_item;

uniform float lumpiness;
uniform float lump_speed;
uniform float speed;
uniform float wavelength;
uniform vec3 color: source_color;
uniform float edge_0;
uniform float edge_1;

float parabola(float x) { return x - x * x; }
float parabola2(vec2 x) { return parabola(x.x) * parabola(x.y); }

void fragment() {
	COLOR.rgb = color;
	float x = TIME * speed;
	x += exp(lumpiness * sin(x * lump_speed));
	// threw together a bunch of stuff but it looks pretty good
	COLOR.a = exp2(10.0 * smoothstep(edge_0, edge_1, sin(UV.x * wavelength + x)*0.5+0.5) * parabola2(UV)) - 1.0;
}
