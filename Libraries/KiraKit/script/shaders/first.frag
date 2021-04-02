
const vec3 W = vec3(0.2125, 0.7154, 0.0721);


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 textureColor = texture2D(iChannel0, v_texCoord);
    float luminance = dot(textureColor.rgb, W);
    
    fragColor = vec4(vec3(luminance), textureColor.a);
}
