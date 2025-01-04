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
flat in vec2 size;
flat in int n;
flat in int i;


out vec4 fragColor;

#moj_import <portal.glsl>

void main() {
    vec4 color = texture(Sampler0, uv);
    if (color.a < 0.1) discard;

    float time = GameTime*1200;
    vec2 anim = vec2(0);
    vec4 overlay = vec4(0);
    switch (int(color.a*255.5)) {
        case 249: //stars
            anim = vec2(time*3)/size;
            overlay = texture(Sampler0, mod(uv + anim, vec2(0.25, 0.5/n)));
            color.rgb = mix(color.rgb, overlay.rgb, overlay.a);
            break;
        case 250: //water
            anim = vec2(sin(time/2)*20, -time*3)/size;
            overlay = texture(Sampler0, mod(uv + anim, vec2(0.25, 0.5/n)) + vec2(0.25, 0));
            color.rgb = mix(color.rgb, overlay.rgb, overlay.a);
            break;
        case 251: //arrow
            anim = vec2(0, -time*10)/size;
            overlay = texture(Sampler0, mod(uv + anim, vec2(0.25, 0.5/n)) + vec2(0.5, 0));
            color.rgb = mix(color.rgb, overlay.rgb, overlay.a);
            break;
        case 252: //lightning
            anim = floor(vec2(floor(time/2)*vec2(123.4567, 567.89123)))/size;
            overlay = texture(Sampler0, mod(uv + anim, vec2(0.25, 0.5/n)) + vec2(0.75, 0));
            color.rgb = color.rgb += overlay.rgb * (1-fract(time/2));
            break;
        case 253: //portal
            vec2 screenSize = gl_FragCoord.xy / (screenLocation.xy/screenLocation.z*0.5+0.5);
            color.rgb = COLORS[0] * vec3(0.463, 0.337, 0.647);
            for (int i = 0; i < PORTAL_DEPTH; i++) {
                vec4 proj = vec4(gl_FragCoord.xy/screenSize, 0, 1) * end_portal_layer(float(i + 1));
                float pixel = hash12(floor(fract(proj.xy/proj.w)*256.0));
                color.rgb += (step(0.95, pixel)* 0.2 + step(0.99, pixel) * 0.8) * (COLORS[i]);
            }
            break;
    }
    color *= tintColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= vertexColor * lightColor; //shading
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
