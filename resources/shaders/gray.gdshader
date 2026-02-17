shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float gray = color.r * 0.3 + color.g * 0.6 + color.b * 0.1;
	COLOR = vec4(vec3(gray), color.a);
}