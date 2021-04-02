
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 camera = texture(iChannel1, uv);
    vec4 prevKira = texture(iChannel0, uv);
    
    fragColor = vec4(camera.rgb + prevKira.rgb, 1.0);
}
