
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 originUV = uv;
    
    uv = fract(uv * 2.0);
    
    if (originUV.x < 0.5 && originUV.y < 0.5)
    {
        vec4 prevColor1 = texture2D(iChannel1, uv);
        
        fragColor = prevColor1;
    }
    else if(originUV.x >= 0.5 && originUV.y < 0.5)
    {
        vec4 previewColor = texture2D(iChannel0, uv);
        
        fragColor = previewColor;
    }
    else if(originUV.x < 0.5 && originUV.y >= 0.5)
    {
        vec4 prevColor3 = texture2D(iChannel3, uv);
        
        fragColor = prevColor3;
    }
    else
    {
        vec4 prevColor2 = texture2D(iChannel2, uv);
        
        fragColor = prevColor2;
    }
}
