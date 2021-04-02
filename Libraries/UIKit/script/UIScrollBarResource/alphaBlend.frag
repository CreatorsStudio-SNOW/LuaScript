uniform float alpha;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy / iResolution.xy);
    vec4 color = texture(iChannel0, uv.xy);
    vec4 textureColor = texture(iChannel1, uv.xy);

    fragColor = vec4(color.rgb * (1.0 - alpha * textureColor.a) + textureColor.rgb * alpha, 1.0);
}
