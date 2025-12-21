shader_type canvas_item;

uniform vec3 outline_modulate: source_color = vec3(0.0);
uniform vec3 modulate: source_color = vec3(1.0);

uniform float alpha: hint_range(0.0, 1.0, 0.05) = 1.0;


void fragment() {
	vec4 tex = texture(TEXTURE, UV);


	if (tex.rgb == vec3(1.0, 0.0, 0.0)){
		COLOR.rgb = vec3(modulate);
	}

	if (tex.rgb == vec3(1.0)){
		COLOR.rgb = vec3(outline_modulate);
	}


	COLOR.a = tex.a * alpha;


}
