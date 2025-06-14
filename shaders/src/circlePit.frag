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
    vec2 center = vec2(0.5, 0.5); 

    float distance = length(uv - center);

    float threshold = progress; 

    if (distance < threshold) {
        fragColor = texture(toImage, uv) * qt_Opacity;
    } else {
        fragColor = texture(fromImage, uv) * qt_Opacity;
    }
}
