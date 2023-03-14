#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform float GameTime;

in float vertexDistance;
in float vertexOrigin;
in vec4 vertexColor;
in vec4 baseColor;
in vec2 corner;
in float isGui;
in vec4 screenPos;
in float isShadow;
in vec2 texCoord0;

in vec3 ipos1;
in vec3 ipos2;
in vec3 ipos3;

in vec3 uvpos1;
in vec3 uvpos2;
in vec3 uvpos3;

#define TEXT_EFFECTS_FSH
#moj_import<text_effects.glsl>
TEXT_EFFECTS_CONFIG_START
#moj_import<text_effects_config.glsl>
TEXT_EFFECTS_CONFIG_END

out vec4 fragColor;

bool isScoreboardNumber(vec4 color) {
    return color.r == 0.988235294 && color.g == 0.329411765 && color.b == 0.329411765 && color.a == 1.0;
}

void main() {
    textData.isShadow = isShadow > 0.5;
    textData.backColor = vec4(0.0);
    textData.topColor = vec4(0.0);
    textData.doTextureLookup = true;

    bool didApply = false;

    if(isGui > 0.5) {
        textData.color = baseColor;

        vec2 ip1 = ipos1.xy / ipos1.z;
        vec2 ip2 = ipos2.xy / ipos2.z;
        vec2 ip3 = ipos3.xy / ipos3.z;
        vec2 innerMin = min(ip1.xy,min(ip2.xy,ip3.xy));
        vec2 innerMax = max(ip1.xy,max(ip2.xy,ip3.xy));
        vec2 innerSize = innerMax - innerMin;
        
        vec2 uvp1 = uvpos1.xy / uvpos1.z;
        vec2 uvp2 = uvpos2.xy / uvpos2.z;
        vec2 uvp3 = uvpos3.xy / uvpos3.z;
        vec2 uvMin = min(uvp1.xy,min(uvp2.xy,uvp3.xy));
        vec2 uvMax = max(uvp1.xy,max(uvp2.xy,uvp3.xy));
        vec2 uvSize = uvMax - uvMin;

        textData.uvMin = uvMin;
        textData.uvMax = uvMax;
        textData.uvCenter = uvMin + 0.25 * uvSize;

        textData.localPosition = ((screenPos.xy - innerMin) / innerSize);
        textData.localPosition.y = 1.0 - textData.localPosition.y;
        textData.uv = textData.localPosition * uvSize + uvMin;

        textData.position = screenPos.xy * uvSize * 256.0 / innerSize;
        textData.characterPosition = 0.5 * (innerMin + innerMax) * uvSize * 256.0 / innerSize;
        if(textData.isShadow) { 
            textData.characterPosition += vec2(-1.0, 1.0);
            textData.position += vec2(-1.0, 1.0);
        }

        didApply = applyTextEffects() == 1;

        if(textData.uv.x < uvMin.x || textData.uv.y < uvMin.y || textData.uv.x > uvMax.x || textData.uv.y > uvMax.y) textData.doTextureLookup = false;
    }else{
        textData.uv = texCoord0;
        textData.color = vertexColor;
    }
    
    vec4 textureSample = texture(Sampler0, textData.uv);
    if(!textData.doTextureLookup) textureSample = vec4(0.0);

    fragColor = mix(vec4(textData.backColor.rgb, textData.backColor.a * textData.color.a), textureSample * textData.color, didApply ? textureSample.a : 1);
    fragColor.rgb = mix(fragColor.rgb, textData.topColor.rgb, textData.topColor.a);
    fragColor *= ColorModulator;

    if(fragColor.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(fragColor, vertexDistance, FogStart, FogEnd, FogColor);
    if(vertexOrigin > 2020.0 && isScoreboardNumber(fragColor) && abs(screenPos.x / screenPos.w - 0.9875) < 0.08) {
        discard;
    }
}
