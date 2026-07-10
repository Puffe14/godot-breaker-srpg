shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float new_color = color.r * 0.1 + color.g * 0.1 + color.b * 0.8;
	COLOR = vec4(vec3(new_color), color.a);
}