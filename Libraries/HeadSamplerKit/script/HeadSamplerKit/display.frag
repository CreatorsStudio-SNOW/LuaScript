

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 uv = (fragCoord.xy / iResolution.xy);
    vec4 cameraColor = texture2D(iChannel1, uv);
    vec4 headMaskColor = texture2D(iChannel2, uv);
    vec4 segColor = texture2D(iChannel0, uv);
    vec4 faceMaskColor = texture2D(iChannel3, uv);
    float hairMaskAlpha = headMaskColor.a;
    
    fragColor = mix(vec4(hairMaskAlpha, hairMaskAlpha, hairMaskAlpha, hairMaskAlpha), segColor, faceMaskColor.a);
    fragColor.a = headMaskColor.a + segColor.a - (1.0 - faceMaskColor.a);
    fragColor = cameraColor * min(1.0, fragColor.a * 1.3);
}
