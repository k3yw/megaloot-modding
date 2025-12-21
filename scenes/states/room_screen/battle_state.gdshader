shader_type canvas_item;

uniform float intensity: hint_range(0.0, 1.0, 0.1);
uniform float zoom: hint_range(0.0, 1.0, 0.01);

void fragment() {
	if (intensity > 0.0){
		vec2 original_uv = UV;
		vec2 uv = UV;
		
		uv = ((uv - 0.5) * (1.0 - zoom)) + 0.5;
		
		
		uv.x += sin((uv.y * 35.0) + (TIME * 5.0)) * 0.01;
		
		vec2 final_uv = mix(original_uv, uv, intensity);
		
		
		vec3 tex = texture(TEXTURE, final_uv).rgb;
		
		COLOR.rgb = tex;
		
	}
	
	else {COLOR.rgb = texture(TEXTURE, UV).rgb;}
	
}
