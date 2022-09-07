#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 glpos;

out vec4 fragColor;

bool isScoreboardNumber(vec4 color) {
    return color.r == 0.988235294 && color.g == 0.329411765 && color.b == 0.329411765 && color.a == 1.0;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if(color.a < 0.1) discard;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    //1080p 2 GUI: 2187
    if(vertexDistance > 2020.0 && isScoreboardNumber(fragColor) && abs(glpos.x / glpos.w - 0.9875) < 0.08) discard;
}
