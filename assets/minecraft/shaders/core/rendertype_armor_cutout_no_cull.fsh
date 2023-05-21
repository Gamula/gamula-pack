#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 tintColor;
in vec4 lightColor;
in vec4 overlayColor;
in vec2 uv;
in vec4 normal;
in vec3 screenLocation;

out vec4 fragColor;

#moj_import <portal.glsl>

void main() {
    vec4 color = texture(Sampler0, uv);
    if (color.a < 0.1) discard;

    if (int(color.a*255.5) == 253) {
        vec2 screenSize = gl_FragCoord.xy / (screenLocation.xy/screenLocation.z*0.5+0.5);
        color.rgb = COLORS[0] * vec3(0.463, 0.337, 0.647);
        for (int i = 0; i < PORTAL_DEPTH; i++) {
            vec4 proj = vec4(gl_FragCoord.xy/screenSize, 0, 1) * end_portal_layer(float(i + 1));
            float pixel = hash12(floor(fract(proj.xy/proj.w)*256.0));
            color.rgb += (step(0.95, pixel)* 0.2 + step(0.99, pixel) * 0.8) * (COLORS[i]);
        }
        color *= vertexColor * ColorModulator * 0.7 + 0.3;
    }

    color *= tintColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= vertexColor * lightColor; //shading
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}