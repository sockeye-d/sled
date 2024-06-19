shader_type canvas_item;

uniform int filter;

float mip_level(vec2 uv, vec2 tex_size) {
	vec2 dx = dFdx( uv * tex_size );
	vec2 dy = dFdy( uv * tex_size );
	float d = max( dot( dx, dx ), dot( dy, dy ) );
	    
	float mipLevel = 0.5 * log2(d);
	mipLevel = floor(mipLevel);   

	return max(0.0, mipLevel);
}

vec4 texture_nearest(sampler2D t, vec2 uv, int lod) {
	vec2 size = vec2(textureSize(t, lod));
	uv = round(uv * size) / size;
	return textureLod(t, uv, float(lod));
}

vec4 texture_nearest_lod(sampler2D t, vec2 uv, float lod) {
	return mix(texture_nearest(t, uv, int(lod)), texture_nearest(t, uv, int(lod) + 1), fract(lod));
}

vec4 texture_linear(sampler2D t, vec2 uv, float lod) {
	return textureLod(t, uv, lod);
}

vec4 cubic(float v)
{
    vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
    vec4 s = n * n * n;
    float x = s.x;
    float y = s.y - 4.0 * s.x;
    float z = s.z - 4.0 * s.y + 6.0 * s.x;
    float w = 6.0 - x - y - z;
    return vec4(x, y, z, w) * (1.0/6.0);
}

vec4 texture_bicubic(sampler2D sampler, vec2 texCoords, int lod)
{
	vec2 texSize = vec2(textureSize(sampler, lod));
	vec2 invTexSize = 1.0 / texSize;

	texCoords = texCoords * texSize - 0.5;


	vec2 fxy = fract(texCoords);
	texCoords -= fxy;

	vec4 xcubic = cubic(fxy.x);
	vec4 ycubic = cubic(fxy.y);

	vec4 c = texCoords.xxyy + vec2 (-0.5, +1.5).xyxy;

	vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
	vec4 offset = c + vec4 (xcubic.yw, ycubic.yw) / s;

	offset *= invTexSize.xxyy;

	vec4 sample0 = textureLod(sampler, offset.xz, float(lod));
	vec4 sample1 = textureLod(sampler, offset.yz, float(lod));
	vec4 sample2 = textureLod(sampler, offset.xw, float(lod));
	vec4 sample3 = textureLod(sampler, offset.yw, float(lod));

	float sx = s.x / (s.x + s.y);
	float sy = s.z / (s.z + s.w);

	return mix(mix(sample3, sample2, sx), mix(sample1, sample0, sx), sy);
}

vec4 texture_bicubic_lod(sampler2D sampler, vec2 texCoords, float lod) {
	return mix(texture_bicubic(sampler, texCoords, int(lod)), texture_bicubic(sampler, texCoords, int(lod) + 1), fract(lod));
}

void fragment() {
	float lod = mip_level(UV, vec2(textureSize(TEXTURE, 0)));
	vec4 t;
	switch(filter) {
		case 0:
			t = texture_nearest_lod(TEXTURE, UV, lod);
			break;
		case 1:
			t = texture_linear(TEXTURE, UV, lod);
			break;
		case 2:
			t = texture_bicubic_lod(TEXTURE, UV, lod);
			break;
	}
	COLOR = t;
}