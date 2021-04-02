
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 pickerColor = texture2D(iChannel0, vec2(0.5, 0.5));
    vec4 circleColor = texture2D(iChannel1, uv);
    
    fragColor = mix(vec4(1.0, 1.0, 1.0, 1.0), pickerColor, circleColor.g);
    fragColor = fragColor * circleColor.a;
}


