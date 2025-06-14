#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    
    vec4 gradientStart;
    vec4 gradientEnd;
    
    int direction;
};

void main() {
    float t;
    
    if (direction == 1) {
        t = 1.0 - qt_TexCoord0.y;
    } else {
        t = qt_TexCoord0.y;
    }
    
    vec4 color = mix(gradientStart, gradientEnd, t);
    
    fragColor = color * qt_Opacity;
}
