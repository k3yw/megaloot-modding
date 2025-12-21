shader_type canvas_item;

uniform vec4 main_col: source_color;
uniform vec4 new_col: source_color;
uniform float scale = 1.0;
uniform float col_mix: hint_range(0.0, 1.0, 0.1);
uniform float brightness: hint_range(-1.0, 1.0, 0.05);


void vertex() {
	VERTEX -= vec2(0.5) / TEXTURE_PIXEL_SIZE;
	VERTEX *= scale;
	VERTEX += vec2(0.5) / TEXTURE_PIXEL_SIZE;
}


void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	tex.rgb *= mix(main_col.rgb, new_col.rgb, col_mix);

	tex.rgb *= 1.0 + vec3(brightness);

	COLOR.rgb = tex.rgb;

}