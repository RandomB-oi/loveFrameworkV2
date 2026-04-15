uniform float fog_start = 0.0f;
uniform float fog_end = 1.0f;
uniform float circle_percent = 0.5f;

float getAlpha(float dist) {
    float minD = pow(fog_start, 2);
    float maxD = pow(fog_end, 2);
    return 1-pow(1-min(max((dist-minD)/(maxD-minD), 0), 1), 1);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 center = love_ScreenSize.xy/2.0f;
    vec2 diff = (screen_coords-center)/center.xy;
    
    float circle = (diff.x * diff.x + diff.y * diff.y);
    float square = max(diff.x * diff.x, diff.y * diff.y);

    float b = fog_end + fog_start;

    float alpha = getAlpha(circle*circle_percent + square * (1.0f-circle_percent));
    color.w *= alpha;
    // color = vec4(screen_coords.x/love_ScreenSize.x, screen_coords.y/love_ScreenSize.y, 0, alpha);

    return color;
}