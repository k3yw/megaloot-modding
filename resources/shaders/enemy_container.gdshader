shader_type canvas_item;


uniform bool damage_flicker;
uniform int start_frame = 0;
uniform int current_frame = 0;
uniform float mix_ratio = 1.0;
uniform float alpha: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float brightness: hint_range(-1.0, 1.0, 0.05);

uniform vec2 texture_offset;


uniform vec3 colors[6]: source_color;

group_uniforms ice;
uniform float ice_alpha: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float ice_height: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec4 ice_color: source_color;
uniform vec2 ice_offset;


group_uniforms;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 1.2;    // thickness of the line
uniform float angle: hint_range(0., 360.) = 0.;



uniform float strength: hint_range(0., 1.) = 0.5;
uniform float speed: hint_range(0., 10.) = 0.5;


uniform bool enabled = true;




uniform sampler2D hue_tex: repeat_enable;



vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

vec2 noise_random(vec2 uv){
    uv = vec2( dot(uv, vec2(127.1,311.7) ),
               dot(uv, vec2(269.5,183.3) ) );
    return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( noise_random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( noise_random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( noise_random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( noise_random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


float worley(vec2 uv, float columns, float rows) {

	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));

	float minimum_dist = 1.0;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}

	return minimum_dist;
}


vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
    float cosa = cos(radians(rotation));
    float sina = sin(radians(rotation));
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x
    ) + pivot;
}


void vertex() {
	VERTEX += texture_offset;
}

vec4 overlay(vec4 base, vec4 blend){
	vec4 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}


float get_outline_alpha(sampler2D tex ,vec2 uv, vec2 pos){
	vec4 o_tex = texture(tex, uv + pos);

	if (o_tex.rgb == vec3(1, 0, 0)){
		o_tex.a = 0.0;
	}

	return o_tex.a;
}

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 pass_1 = COLOR;



	//color.rgb = mix(color.rgb, shift_color.rgb, UV.y);

	vec2 ice_uv = vec2(UV.x, pow(UV.y, (1.5 - ice_height) * 2.0) ) + ice_offset;
	float ice = worley((ice_uv * 1.75) + vec2(0.0, TIME * 0.025), 7.0, 5.0 - (1.0 - ice_height));
	float ice_strength = pow(ice_uv.y + 0.05 , 1.75);
	vec3 ice_col = mix(color.rgb, ice_color.rgb, clamp(ice_strength, 0.0, 1.0));
	ice_col += clamp(ice_strength * pow(ice, 2.5), 0.0, 1.0);

	color.rgb = mix(color.rgb, ice_col, ice_alpha);




	if (enabled == true){
		vec2 size = TEXTURE_PIXEL_SIZE * line_scale;

		float outline = get_outline_alpha(TEXTURE, UV, vec2(-size.x, 0));
		outline += get_outline_alpha(TEXTURE, UV, vec2(0, size.y));
		outline += get_outline_alpha(TEXTURE, UV, vec2(size.x, 0));
		outline += get_outline_alpha(TEXTURE, UV, vec2(0, -size.y));
		outline += get_outline_alpha(TEXTURE, UV, vec2(-size.x, size.y));
		outline += get_outline_alpha(TEXTURE, UV, vec2(size.x, size.y));
		outline += get_outline_alpha(TEXTURE, UV, vec2(-size.x, -size.y));
		outline += get_outline_alpha(TEXTURE, UV, vec2(size.x, -size.y));
		outline = min(outline, 1.0);


		float outline_alpha = (abs(sin(TIME * 0.9)) * 0.3) + (1.0 - (1.0 * 0.3));

		vec4 outline_col = mix(color, line_color , (outline - color.a) * outline_alpha);



		vec2 uv = rotateUV(UV, vec2(0.5), angle);
		vec3 hue = texture(hue_tex, uv + (speed * TIME)).rgb;

		vec4 mix_0 = mix(outline_col, overlay(outline_col, vec4(hue, outline_col.a)), strength);
		color = mix(mix_0, vec4(hue, outline_col.a), strength);
	}

	color.rgb *= 1.0 + vec3(brightness);

	COLOR.rgb = color.rgb;
	COLOR.a = color.a * alpha;




	if (damage_flicker == true){
		float curr_brightness = dot(COLOR.rgb, vec3(0.2126, 0.7152, 0.0722));
		// Calculate the starting frame based on brightness
		int offset = 0;
		if (curr_brightness > 0.75) {
			offset = 2;
		} else if (curr_brightness > 0.25) {
			offset = 1;
		}
		// Get the color, wrapping around at the end of the array
		int color_index = (start_frame + current_frame + offset) % colors.length();
		vec3 color = colors[color_index];
		// Apply the color to the sprite
		COLOR = vec4(mix(pass_1.rgb, color, mix_ratio), pass_1.a * alpha);
	}


	if (texture(TEXTURE, UV).rgb == vec3(1.0, 0.0, 0.0)){
		COLOR.a = 0.0;
	}
}
