shader_type canvas_item;


uniform float height: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float width: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform vec4 modulate: source_color = vec4(1.0);


void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	float shrink_width = 2.0 / width;
	float shrink_height = 2.0 / height;
	float dist = distance(vec2(UV.x * shrink_width, UV.y * shrink_height), vec2(0.5 * shrink_width, 0.5 * shrink_height));
	tex.a = 1.0 - floor(dist);

	tex = tex * modulate;

	COLOR = tex;
}
