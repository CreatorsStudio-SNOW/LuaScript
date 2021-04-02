uniform vec2 viewPosition;
uniform vec2 viewSize;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    if (uv.x >= viewPosition.x && uv.x <= viewPosition.x + viewSize.x && uv.y >= viewPosition.y && uv.y <= viewPosition.y + viewSize.y)
    {
        fragColor = texture2D(iChannel0, uv);
    }
    else
    {
        fragColor = texture2D(iChannel1, uv);
    }
 }
