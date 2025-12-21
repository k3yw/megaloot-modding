shader_type canvas_item;


global uniform vec4 background_color: source_color;
global uniform vec4 border_color: source_color;
global uniform vec4 darker_border_color: source_color;
global uniform vec4 primary_color: source_color;
global uniform vec4 secondary_color: source_color;
global uniform vec4 accent_color: source_color;
global uniform vec4 darker_accent_color: source_color;
global uniform vec4 highlight_color: source_color;
global uniform vec4 positive_color: source_color;


uniform int type: hint_range(0, 8, 1) = 0;
uniform vec4 modulate: source_color = vec4(1.0);
uniform float strength: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float alpha: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform vec2 texture_offset;
uniform int scale_mode = 0;
uniform float scale = 1.0;
uniform float saturation: hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float brightness: hint_range(-1.0, 1.0, 0.05);
uniform bool use_screen_texture = false;
uniform bool fill = false;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

group_uniforms Label;
uniform bool label_mode = false;
uniform int outline_type: hint_range(0, 8, 1) = 0;
uniform vec4 outline_color : source_color = vec4(1.0);
uniform int outline_pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool add_margins = false; // only useful when inside is false
uniform float width : hint_range(0, 10) = 0.0;
uniform bool flip_colors = false;
uniform bool inside = false;

group_uniforms Dither;
uniform bool enable_dither = false;
uniform int dither_colors[3];

group_uniforms Gradient;
uniform sampler2D gradient: repeat_enable;
uniform float angle : hint_range(0.0, 360.0) = 0.0;
uniform bool enable_gradient = false;
uniform int gradient_blend_mode = 0;
uniform float gradient_speed = 1.0;
uniform float gradient_size = 1.0;
uniform bool gradient_animated = false;
uniform float gradient_time = 0.0;

varying vec2 label_uv;


void vertex() {
	if (add_margins) {
		VERTEX += (UV * 2.0 - 1.0) * width;
	}

	if (scale_mode == 0){
		VERTEX -= vec2(0.5) / TEXTURE_PIXEL_SIZE;
	}

	VERTEX *= scale;
	if (scale_mode == 0){
		VERTEX += vec2(0.5) / TEXTURE_PIXEL_SIZE;
	}

	VERTEX += texture_offset;
	label_uv = VERTEX.xy;
}


vec3 color_dodge(vec4 base, vec4 blend){
	return base.rgb / (1.0 - (blend.rgb * blend.a));
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;

		switch(outline_pattern) {
			case 0: offset = width - abs(x); break;
			case 1: offset = floor(sqrt(pow(width + 0.5, 2) - x * x)); break;
			case 2: offset = width; break;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
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



vec4 from_type(vec4 tex, int arg_type){
	switch (arg_type){
		case 1: return background_color;
		case 2: return border_color;
		case 3: return darker_border_color;
		case 4: return primary_color;
		case 5: return secondary_color;
		case 6: return accent_color;
		case 7: return darker_accent_color;
		case 8: return highlight_color;
		case 9: return positive_color;
	}
	return tex;
}


void fragment() {
	vec4 new_outline_color = outline_color;
	vec4 new_modulate = modulate;
	vec2 uv = UV;


	new_outline_color = from_type(new_outline_color, outline_type);
	new_modulate = from_type(new_modulate, type);

	if (flip_colors){
		vec4 original_outline_color = new_outline_color;
		new_outline_color = new_modulate;
		new_modulate = original_outline_color;
	}

	vec4 original_tex = texture(TEXTURE, UV);

	if (use_screen_texture){
		original_tex = texture(SCREEN_TEXTURE, SCREEN_UV);
	}

	vec2 gradient_uv = UV / gradient_size;

	if (label_mode){
		gradient_uv = label_uv / (20.0 * gradient_size);
	}

	if (use_screen_texture){
		gradient_uv = ((UV * SCREEN_PIXEL_SIZE) / gradient_size) * 10.0;
	}

	vec4 gradient_col;

	if (enable_gradient){
		float time = TIME;
		if (gradient_animated){
			time = gradient_time;
			}
		gradient_col = texture(gradient, rotateUV(gradient_uv, vec2(0.5), angle) + ((fract(time * gradient_speed) * 2.0) - 1.0));
	}


	vec4 tex = original_tex * new_modulate;

	if (fill){
		tex.rgb = modulate.rgb;
	}


	if (enable_dither){
		vec4 dithered_tex = from_type(tex, dither_colors[0]);
		for (int i = 0; i<dither_colors.length(); i++){
			vec4 dither_color = from_type(tex, dither_colors[i]);
			if (distance(dither_color,tex) < distance(dithered_tex, tex)){
				dithered_tex = dither_color;
			}
		}
		tex.rgb = dithered_tex.rgb;
	}



	if (type > 0){
		tex.rgb = original_tex.rgb * mix(vec3(1.0), new_modulate.rgb, strength);
		if (fill){
			tex.rgb = mix(original_tex.rgb, new_modulate.rgb, strength);
		}

	}



	tex.rgb = mix(vec3(dot(tex.rgb, vec3(0.299, 0.587, 0.114))), tex.rgb, saturation);
	tex.rgb *= 1.0 + vec3(brightness);


	if (enable_gradient){
		switch (gradient_blend_mode){
			case 0:
				tex.rgb = gradient_col.rgb;
				break;

			case 1:
				tex.rgb *= gradient_col.rgb;
				break;

			case 2:
				tex.rgb += gradient_col.rgb * gradient_col.a;
				break;

			case 3:
				tex.rgb = color_dodge(tex, gradient_col);
				break;
		};
	}


	if (width > 0.0){
		//WIP
		if (add_margins) {
			vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2(width * 2.0));

			uv = (uv - texture_pixel_size * width) * TEXTURE_PIXEL_SIZE / texture_pixel_size;

			if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
				tex.a = 0.0;
			}
		}

		if ((tex.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
			tex.rgb = inside ? mix(tex.rgb , new_outline_color.rgb, new_outline_color.a) : new_outline_color.rgb ;
			tex.a += (1.0 - tex.a) * new_outline_color.a;
		}
	}


	COLOR = tex;
	COLOR.a *= alpha;
}