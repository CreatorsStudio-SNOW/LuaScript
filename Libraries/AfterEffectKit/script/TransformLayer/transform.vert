uniform float u_radian;
uniform vec2 u_poistion;
uniform vec2 u_anchorPosition;
uniform float u_scale;

uniform float u_ratio;

uniform float u_postRadian;
uniform vec2 u_postPoistion;
uniform vec2 u_postAnchorPosition;
uniform float u_postScale;

uniform float u_motionBlurSize;

varying vec2 v_motionVector;
uniform bool u_motionBlur;

void main(){
    gl_Position = a_position;
    vec2 newTex = a_texCoord.xy;
    vec2 postTex = a_texCoord.xy;
    
    newTex -= u_poistion;
    newTex /= vec2(1.0, u_ratio);
    newTex /= u_scale;
    
    mat4 transformMat = mat4(
                vec4(cos(u_radian), -sin(u_radian), 0, 0),
                vec4(sin(u_radian), cos(u_radian), 0, 0),
                vec4(0, 0, 1, 0),
                vec4(0, 0, 0, 1)
            );
    
    vec2 rotate = (transformMat * vec4(newTex, 0, 1)).xy;
    
    v_texCoord = rotate * vec2(1.0, u_ratio) + u_anchorPosition;
    v_motionVector = v_texCoord;
    
    if(u_motionBlur == true) {
        postTex -= u_postPoistion;
        postTex /= vec2(1.0, u_ratio);
        postTex /= u_postScale;
        
        mat4 postTransformMat = mat4(
                    vec4(cos(u_postRadian), -sin(u_postRadian), 0, 0),
                    vec4(sin(u_postRadian), cos(u_postRadian), 0, 0),
                    vec4(0, 0, 1, 0),
                    vec4(0, 0, 0, 1)
                );
        vec2 postRotate = (postTransformMat * vec4(postTex, 0, 1)).xy;
        
        vec2 postVector = postRotate * vec2(1.0, u_ratio) + u_postAnchorPosition;
        v_motionVector = (v_texCoord - postVector) * u_motionBlurSize;
    }
}
