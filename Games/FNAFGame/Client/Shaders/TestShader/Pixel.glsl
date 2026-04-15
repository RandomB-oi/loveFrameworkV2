uniform float time;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 texcolor = Texel(tex, texture_coords);
    vec4 pixelColor = texcolor * color;

    pixelColor.w *= sin(screen_coords.x/25+time)/2.0f+0.5f;
    // pixelColor.w *= 0.5f;

    return pixelColor;
}