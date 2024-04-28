shader_type canvas_item;

uniform float start: hint_range(0.0, 1.0);
uniform float end: hint_range(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.a *= smoothstep(start, end, SCREEN_UV.x);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
