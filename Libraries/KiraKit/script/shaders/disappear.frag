
uniform float u_disappearStrength;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 kira = texture2D(iChannel0, uv);
    vec4 prevKira = texture(iChannel1, uv) * u_disappearStrength;
    
    fragColor = vec4(kira.rgb + prevKira.rgb, kira.a + prevKira.a - kira.a * prevKira.a);
}
