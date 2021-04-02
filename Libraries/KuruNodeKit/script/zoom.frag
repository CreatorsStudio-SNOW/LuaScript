
void mainImage(out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = v_texCoord;
    if(uv.x < 0.5 && uv.y < 0.5){
      uv *= 2.0;
      vec4 a = texture(iChannel0, uv);
      fragColor = a;
    } else if(uv.x >= 0.5 && uv.y < 0.5) {
      uv.x -= 0.5;
      uv *= 2.0;
      vec4 b = texture(iChannel1, uv);
      fragColor = b;
    } else if(uv.x < 0.5 && uv.y > 0.5) {
      uv.y -= 0.5;
      uv *= 2.0;
      vec4 c = texture(iChannel2, uv);
      fragColor = c;
    } else {
      uv.x -= 0.5;
      uv.y -= 0.5;
      uv *= 2.0;
      vec4 d = texture(iChannel3, uv);
      fragColor = d;
    }
}
