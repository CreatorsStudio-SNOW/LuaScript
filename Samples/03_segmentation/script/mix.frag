uniform vec4 u_edgeColor;
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = v_texCoord;
  vec4 bgColor = texture(iChannel0, uv);
  vec4 segColor = texture(iChannel1, uv);
  vec4 originColor = texture(iChannel2, uv);

  if(all(equal(segColor, u_edgeColor))){
    fragColor = mix(originColor, bgColor, segColor.a);
    return;  
  }
  fragColor = originColor;
}
