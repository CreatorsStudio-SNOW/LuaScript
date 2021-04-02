
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = texture2D(iChannel0, v_texCoord);
 }
