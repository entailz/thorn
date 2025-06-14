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

void main() {
    vec2 uv = qt_TexCoord0;

    vec2 scaledUV = (uv - origin) * aspectRatio;
    float distance = length(scaledUV);

    vec2 maxVec = max(origin, vec2(1.0) - origin) * aspectRatio;
    float maxDistance = length(maxVec);

    float threshold = progress * maxDistance;

    if (distance < threshold) {
        fragColor = texture(toImage, uv) * qt_Opacity;
    } else {
        fragColor = texture(fromImage, uv) * qt_Opacity;
    }
}
