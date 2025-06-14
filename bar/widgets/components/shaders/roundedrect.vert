#version 440

layout(location = 0) in vec4 qt_VertexPosition;
layout(location = 1) in vec2 qt_VertexTexCoord;

layout(location = 0) out vec2 uv;

layout(std140, binding = 0) uniform buf {
    vec2 sourceSize;
    float radius;
    float borderWidth;
    vec4 color;
    vec4 borderColor;
};

void main() {
    uv = qt_VertexTexCoord;
    gl_Position = qt_VertexPosition;
}
