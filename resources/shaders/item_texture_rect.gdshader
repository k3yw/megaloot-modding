shader_type canvas_item;

uniform vec4 gray_scale_overlay: source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float saturation: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float alpha: hint_range(0.0, 1.0) = 1.0;
uniform vec3 modulate: source_color = vec3(1.0);
uniform float strength: hint_range(0., 1.0) = 0.5;
uniform float speed: hint_range(0.0, 10.) = 0.5;
uniform float ratio: hint_range(0.0, 1.0, 0.1);
uniform float wobble: hint_range(0.0, 10.0, 0.1);
uniform sampler2D hue_tex: repeat_enable;
uniform bool disabled = false;





vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// All components are in the range [0…1], including hue.
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}






vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
	float sine = sin(rotation * (PI / 180.0));
	float cosine = cos(rotation * (PI / 180.0));

	uv -= pivot;
	uv.x = uv.x * cosine - uv.y * sine;
	uv.y = uv.x * sine + uv.y * cosine;
	uv += pivot;

	return uv;
}

vec3 color_dodge(vec4 base, vec4 blend){
	return base.rgb / (1.0 - (blend.rgb * blend.a));
}


vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}



// tolerance‐based test (better for real textures)
bool is_approx_grayscale(vec3 c) {
    float maxc = max(max(c.r, c.g), c.b);
    float minc = min(min(c.r, c.g), c.b);
    return (maxc - minc) < 0.01;
}



void fragment() {

if (disabled == false){
	vec2 original_uv = UV;
	vec2 uv = UV;
	vec2 final_uv = UV;


	if (wobble > 0.0){

			uv = (uv - 0.5) + 0.5;

			uv.x += sin((uv.y * 35.0) + (TIME * 5.0)) * 0.01;

			final_uv = mix(original_uv, uv, wobble);

	}




	vec2 hue_uv = rotateUV(UV, vec2(0.5), 45.0);
	vec4 hue = texture(hue_tex, hue_uv + (speed * TIME));

	vec4 color = texture(TEXTURE, final_uv);

	if (is_approx_grayscale(color.rgb)) {
		color = overlay(color, gray_scale_overlay);
	}


	color.rgb = mix(vec3(dot(color.rgb, vec3(0.299, 0.587, 0.114))), color.rgb, saturation);

	COLOR.rgb = mix(color.rgb, color_dodge(color, hue), strength * ratio);
	COLOR.rgb *= modulate;
	COLOR.a = color.a * alpha;

}
}
