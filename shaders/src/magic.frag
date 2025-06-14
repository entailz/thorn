#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
    vec2 aspectRatio;
    vec2 origin;
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

float random(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float getDistance(vec2 uv) {
    vec2 scaled = (uv - origin) * aspectRatio;
    return length(scaled);
}

void main() {
    vec2 uv = qt_TexCoord0;

    float p = clamp(progress, 0.0, 1.0);
    if (p <= 0.0) {
        fragColor = texture(fromImage, uv) * qt_Opacity;
        return;
    }

    if (p >= 1.0) {
        fragColor = texture(toImage, uv) * qt_Opacity;
        return;
    }
    // vec2 wobble = vec2(
    //     sin(uv.y * 40.0 + progress * 30.0),
    //     cos(uv.x * 40.0 + progress * 30.0)
    // ) * 0.001;

    vec2 distortedUV = clamp(uv, 0.0, 1.0);
    vec4 fromColor = texture(toImage, distortedUV);
    vec4 toColor   = texture(fromImage, distortedUV);

    float dist = getDistance(uv);
    vec2 maxVec = max(origin, vec2(1.0) - origin) * aspectRatio;
    float maxDistance = length(maxVec);
    float threshold = p * maxDistance;

    float edgeNoise = smoothstep(0.0, 1.0, random(uv * 150.0)) * 0.12;
    float blend = smoothstep(threshold - 0.05, threshold + edgeNoise, dist);

    fragColor = mix(toColor, fromColor, 1.0 - blend) * qt_Opacity;
}
