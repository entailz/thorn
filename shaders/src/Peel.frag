#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float progress;
};

layout(binding = 1) uniform sampler2D fromImage;
layout(binding = 2) uniform sampler2D toImage;

void main() {
    vec2 uv = qt_TexCoord0;
    float threshold = progress;
    float diagonal = (uv.x + uv.y) / 2.0;
    
    if (diagonal < threshold) {
        fragColor = texture(toImage, uv) * qt_Opacity;
    } else {
        vec2 newUv = uv - vec2(progress * 0.2);
        fragColor = texture(fromImage, newUv) * qt_Opacity;
    }
}
