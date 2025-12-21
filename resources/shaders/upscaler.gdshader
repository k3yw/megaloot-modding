shader_type canvas_item;

/*
Made with a whole lot of nightmare fuel.
Logic's Under Pressure and Bobby Tarantino II Albums was in rotation during
the making process.
Hope you enjoy!

You're auto-friended to me if you're a Logic fan
RattPack all day!
*/

//upscaling multiplier amount
const float SCALE = 10.0;

//image mipmap level, for base upscaling
const int ML = 0;

//equality threshold of 2 colors before forming lines
uniform float THRESHOLD = 0.001;

//anti aliasing scaling, smaller value make lines more blurry
uniform float AA_SCALE = 11.0;


//draw diagonal line connecting 2 pixels if within threshold
vec4 diag(vec4 sum, vec2 uv, vec2 p1, vec2 p2, vec4 c1, vec4 c2, float LINE_THICKNESS) {
    if (length(c1 - c2) < THRESHOLD) {
        vec2 dir = p2-p1,
            lp = uv-(floor(uv+p1)+.5);
        dir = normalize(vec2(dir.y,-dir.x));
        float l = clamp((LINE_THICKNESS-dot(lp,dir))*AA_SCALE,0.,1.);
        sum = mix(sum,c1,l);
    }
    return sum;
}

void fragment()
{
    float LINE_THICKNESS = 0.8;
    vec2 ip = UV;
    ip = UV * (1.0 / TEXTURE_PIXEL_SIZE);

        vec4 texCenter = texelFetch(TEXTURE,ivec2(ip),ML);
        vec4 texLeft = texelFetch(TEXTURE,ivec2(ip+vec2(-1,0)),ML);
        vec4 texUp = texelFetch(TEXTURE,ivec2(ip+vec2(0,1)),ML);
        vec4 texRight = texelFetch(TEXTURE,ivec2(ip+vec2(1,0)),ML);
        vec4 texDown = texelFetch(TEXTURE,ivec2(ip+vec2(0,-1)),ML);

        //start with nearest pixel as 'background'
        vec4 s = texCenter;

        //draw anti aliased diagonal lines of surrounding pixels as 'foreground'
        s = diag(s,ip,vec2(-1,0),vec2(0,1), texLeft, texUp, LINE_THICKNESS);
        s = diag(s,ip,vec2(0,1),vec2(1,0), texUp, texRight, LINE_THICKNESS);
        s = diag(s,ip,vec2(1,0),vec2(0,-1), texRight, texDown, LINE_THICKNESS);
        s = diag(s,ip,vec2(0,-1),vec2(-1,0), texDown, texLeft, LINE_THICKNESS);

        COLOR = s;
}
