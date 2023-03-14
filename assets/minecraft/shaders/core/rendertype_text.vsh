#version 150

#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;

out float vertexDistance;
out float vertexOrigin;
out vec4 vertexColor;
out vec4 baseColor;
out vec2 texCoord0;
out vec2 corner;
out vec4 screenPos;
out float isGui;
out float isShadow;

out vec3 ipos1;
out vec3 ipos2;
out vec3 ipos3;

out vec3 uvpos1;
out vec3 uvpos2;
out vec3 uvpos3;

#moj_import<text_effects.glsl>
TEXT_EFFECTS_CONFIG_START
#moj_import<text_effects_config.glsl>
TEXT_EFFECTS_CONFIG_END

const vec2[] corners = vec2[](
    vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0)
);

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    corner = corners[gl_VertexID % 4];

    isShadow = fract(Position.z) < 0.01 ? 1.0 : 0.0;
    isGui = ModelViewMat[3][2] < -1500.0 ? 1.0 : 0.0;

    textData.isShadow = isShadow > 0.5;
    textData.color = Color;
    if(!shouldApplyTextEffects()) {
        if(Position.z == 0.0 && textData.isShadow) {
            textData.isShadow = false;
            if(shouldApplyTextEffects()) {
                isShadow = 0.0;
            }else {
                isGui = 0.0;
            }
        }else{
            isGui = 0.0;
        }
    } 

    if(isGui > 0.5) {
        uvpos1 = uvpos2 = uvpos3 = ipos1 = ipos2 = ipos3 = vec3(0.0);
        switch (gl_VertexID % 4) {
            case 0: ipos1 = vec3(gl_Position.xy, 1.0); uvpos1 = vec3(UV0.xy, 1.0); break;
            case 1: ipos2 = vec3(gl_Position.xy, 1.0); uvpos2 = vec3(UV0.xy, 1.0); break;
            case 2: ipos3 = vec3(gl_Position.xy, 1.0); uvpos3 = vec3(UV0.xy, 1.0); break;
        }

        gl_Position.xy += corner * 0.01;
    }

    screenPos = gl_Position;
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexOrigin = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    baseColor = Color;
    texCoord0 = UV0;
}
