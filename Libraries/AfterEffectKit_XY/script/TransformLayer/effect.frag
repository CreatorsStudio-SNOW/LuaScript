uniform bool u_repeTile;
uniform float u_opacity;

varying vec2 v_motionVector;
uniform bool u_motionBlur;

vec4 bgColor(vec2 uv)
{
    vec2 cur_uv = uv;
    if(u_repeTile == true) {

        if(uv[0] < 0.0 || uv[0] >= 1.0)
        {
            cur_uv[0] = mod(1.0 - uv[0], 1.0);
        }
        if(uv[1] < 0.0 || uv[1] >= 1.0)
        {
            cur_uv[1] = mod(1.0 - uv[1], 1.0);
        }
    }
    if(u_repeTile == false && (uv[0] < 0.0 || uv[0] >= 1.0 || uv[1] < 0.0 || uv[1] >= 1.0))
    {
        return vec4(0.0);
    }
    return texture(iChannel0, cur_uv);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = v_texCoord.xy;
    const int step_size = 16;
    float totalWeight = 0.0;
    vec4 color = vec4(0.0);
    fragColor = vec4(bgColor(uv));
    
    if(u_motionBlur)
    {
        for(int i = 0; i < step_size; i++)
        {
            float weight = float(step_size - i) / float(step_size);
            vec2 pos = uv + float(i) * v_motionVector / float(step_size);

            color += weight * bgColor(pos);
            totalWeight += weight;
        }
        fragColor = color / vec4(totalWeight);
    }
    fragColor *= u_opacity;
}
