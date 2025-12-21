shader_type canvas_item;

global uniform vec4 background_color: source_color;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

uniform float alpha = 1.0;




vec4 mixcolor(vec4 colA, vec4 colB)  {
	return vec4((colA.rgb + colB.a * (colB.rgb - colA.rgb)), colA.a + colB.a);
}



void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.a *= alpha;
}