shader_type canvas_item;
render_mode blend_add;

uniform vec4 color: source_color = vec4(1.0);
uniform vec2 texture_offset;



float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}


void vertex() {
	VERTEX += texture_offset;
}


void fragment(){

	float outer = circle(vec2(UV.x, UV.y), 0.35, 0.015);

	float fade_effect = sin(TIME) * 0.025;

	float inner = 1.0 - circle(vec2(UV.x, UV.y), 0.225, 0.15 - fade_effect );

	COLOR = color;
	COLOR.a -= outer + inner;

}