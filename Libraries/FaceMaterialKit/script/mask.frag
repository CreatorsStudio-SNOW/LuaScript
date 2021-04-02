
void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec4 mask = texture(iChannel0, uv);
  vec4 origin = texture(iChannel1, uv);
  fragColor = mix(origin, vec4(0.), mask.r);
}
