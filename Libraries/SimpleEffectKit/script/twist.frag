uniform float u_waveStrength;

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv =  fragCoord.xy / iResolution.xy;

  uv.x += sin(uv.y * u_waveStrength) / 10.0;

  fragColor = texture2D(iChannel0, vec2(uv.x, uv.y));
}
