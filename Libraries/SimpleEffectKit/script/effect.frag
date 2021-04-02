uniform int u_effectType;
uniform float u_scale;
uniform vec4 u_bgColor;
uniform vec2 u_offset;

const int DIVIDE_VERTICAL = 1;
const int CUT_TOP         = 2;
const int CUT_BOTTOM      = 3;
const int SCALE           = 4;
const int TRANSLATE       = 6;


void divideVertical(out vec4 fragColor, in vec2 uv)
{
    if (uv.y > 0.5)
    {
        uv.y -= 0.25;
        fragColor = texture(iChannel0, uv);
    }
    else
    {
        uv.y += 0.25;
        fragColor = texture(iChannel0, uv);
    }
}

void cutTop(out vec4 fragColor, in vec2 uv)
{
    uv.y -= 0.25;
    
    if (uv.y < 0.25 || uv.y > 0.75)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    else
    {
        fragColor = texture(iChannel0, uv);
    }
}

void cutBottom(out vec4 fragColor, in vec2 uv)
{
    uv.y += 0.25;
    
    if (uv.y < 0.25 || uv.y > 0.75)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    else
    {
        fragColor = texture(iChannel0, uv);
    }
}

void scale(out vec4 fragColor, in vec2 uv)
{
    uv -= 0.5;
    uv /= u_scale;
    uv += 0.5;
    
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
    {
        fragColor = u_bgColor;
    }
    else
    {
        fragColor = texture(iChannel0, uv);
    }
}

void move(out vec4 fragColor, in vec2 uv)
{
    fragColor = texture2D(iChannel0, uv + u_offset);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    if (u_effectType == DIVIDE_VERTICAL)
    {
        divideVertical(fragColor, uv);
    }
    else if (u_effectType == CUT_TOP)
    {
        cutTop(fragColor, uv);
    }
    else if (u_effectType == CUT_BOTTOM)
    {
        cutBottom(fragColor, uv);
    }
    else if (u_effectType == SCALE)
    {
        scale(fragColor, uv);
    }
    else if (u_effectType == TRANSLATE)
    {
        move(fragColor, uv);
    }
}
