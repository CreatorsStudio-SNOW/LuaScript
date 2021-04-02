
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    vec2 uv = fragCoord.xy / iResolution.xy;
    // vec4 camera = texture(iChannel1, uv);
    vec4 prevKira = texture(iChannel0, uv);
    vec4 aniKira = texture(iChannel2, uv);

    fragColor = vec4(vec3(0.) + prevKira.rgb + aniKira.rgb, 1.0);
}
