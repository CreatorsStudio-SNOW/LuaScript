uniform float u_progress;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    float yPos = mod(uv.y + u_progress, 1.0);
    
    fragColor = texture2D(iChannel0, vec2(uv.x, yPos));
}
