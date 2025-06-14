#version 440

layout(location = 0) in vec2 uv; 
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    vec2 sourceSize;
    float radius;
    float borderWidth;
    vec4 color;
    vec4 borderColor;
};

float roundedRectSDF(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return length(max(d, 0.0)) - r;
}

void main() {
    vec2 halfSize = sourceSize * 0.5;
    vec2 p = uv * sourceSize - halfSize; 
    float dist = roundedRectSDF(p, halfSize - vec2(borderWidth), radius);

    float aa = fwidth(dist);
    float alpha = 1.0 - smoothstep(0.0, aa, dist);

    float outerDist = roundedRectSDF(p, halfSize, radius + borderWidth);
    float borderAlpha = 1.0 - smoothstep(0.0, aa, outerDist);
    float innerAlpha = alpha;
    float finalAlpha = max(borderAlpha, innerAlpha);

    vec4 base = mix(borderColor, color, alpha);
    fragColor = vec4(base.rgb, base.a * finalAlpha);
}
