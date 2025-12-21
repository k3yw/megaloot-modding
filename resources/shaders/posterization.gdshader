shader_type canvas_item;

global uniform vec4 background_color: source_color;
global uniform vec4 border_color: source_color;
global uniform vec4 darker_border_color: source_color;

void fragment(){
	vec3 palette[] = {background_color.rgb, border_color.rgb, darker_border_color.rgb}; // Can be any list of RGB colors, but there must be at least one.
	vec3 color = texture(TEXTURE,UV).rgb;
	vec3 new_color = palette[0];
	for (int i = 0; i<palette.length(); i++){
		if (distance(palette[i],color) < distance(new_color, color)){
			new_color = palette[i];
		}
		COLOR.rgb = new_color;
		COLOR.a  = texture(TEXTURE,UV).a;
	}
}