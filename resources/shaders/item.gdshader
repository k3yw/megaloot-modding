shader_type canvas_item;

uniform float alpha: hint_range(0.0, 1.0) = 1.0;
uniform vec3 modulate: source_color = vec3(1.0);
uniform float strength: hint_range(0., 1.0) = 0.0;
uniform float speed: hint_range(0.0, 10.) = 0.5;

uniform float wobble: hint_range(0.0, 10.0, 0.1);

uniform float angle : hint_range(0.0, 360.0) = 0.0;
uniform sampler2D hue_tex: repeat_enable;



vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float sine = sin(rotation * (PI / 180.0));
	float cosine = cos(rotation * (PI / 180.0));

	uv -= pivot;
	uv.x = uv.x * cosine - uv.y * sine;
	uv.y = uv.x * sine + uv.y * cosine;
	uv += pivot;

	return uv;
}



void fragment() {
	vec2 original_uv = UV;
	vec2 uv = UV;
	vec2 final_uv = UV;


	if (wobble > 0.0){

			uv = (uv - 0.5) + 0.5;

			uv.x += sin((uv.y * 35.0) + (TIME * 5.0)) * 0.01;

			final_uv = mix(original_uv, uv, wobble);

	}

	vec3 hue = texture(hue_tex, rotateUV(UV, vec2(0.5), angle) + ((fract(TIME * speed) * 2.0) - 1.0)).rgb;
	vec4 color = texture(TEXTURE, final_uv);

	COLOR.rgb *= modulate;
	COLOR.rgb *= mix(vec3(1.0), 1.0 + hue, strength);

	COLOR.a *= alpha;
}