shader_type canvas_item;


void fragment() {
	vec4 col = texture(TEXTURE, UV);

	COLOR.rgb = col.rgb;

	if (col.rgb == vec3(1.0, 0.0, 0.0)){
		COLOR.a = 0.0;
	}

}
