
uniform float u_location;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    fragColor = texture2D(iChannel0, vec2(0.5, u_location));
}


