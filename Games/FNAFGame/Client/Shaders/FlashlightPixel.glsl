vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 texcolor = Texel(tex, texture_coords);
    vec4 pixelColor = texcolor * color;
    
    vec2 center = vec2(0.5, 0.5);
    vec2 diff = (texture_coords-center)/center;
    
    float circle = (diff.x * diff.x + diff.y * diff.y);
    pixelColor.w *= pow(1-circle, 3);

    // pixelColor.xy *= texture_coords;

    return pixelColor;
}