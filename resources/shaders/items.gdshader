shader_type canvas_item;

uniform vec4 colors[5]: source_color;

uniform vec4 line_color :source_color = vec4(1);
uniform float line_thickness : hint_range(0, 10) = 1.0;


void fragment(){
	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	vec4 color = texture(TEXTURE,UV);
	vec4 new_color = colors[0];

	for (int i = 0; i<colors.length(); i++){
		if (distance(colors[i],color) < distance(new_color, color)){
			new_color = colors[i];
		}
	}

	color.rgb = new_color.rgb;

	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);

	COLOR = mix(color, line_color, outline - color.a);
}