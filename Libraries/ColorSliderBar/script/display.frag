
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv *= 2.0;
    
    if (uv.x >= 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)
    {
        fragColor = texture2D(iChannel1, uv);
    }
    else
    {
        fragColor = texture2D(iChannel0, fragCoord.xy / iResolution.xy);
    }
}


