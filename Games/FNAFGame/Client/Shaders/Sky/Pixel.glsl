uniform vec4 sky_top;
uniform vec4 sky_bottom;

vec4 lerp(vec4 a, vec4 b, float x) {
    return (b-a)*x+a;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    // vec4 texcolor = Texel(tex, texture_coords);
    // vec4 pixelColor = texcolor * color;

    float colorAlpha = color.w;
    float alpha = screen_coords.y/love_ScreenSize.y;
    color *= lerp(sky_top, sky_bottom, alpha);

    return color;
}