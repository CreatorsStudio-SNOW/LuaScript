uniform float u_speed;
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = v_texCoord; // vec2 uv = fragCoord.xy/iResolution.xy;
  float angle = iGlobalTime*u_speed;
  float s = sin(angle);
  float c = cos(angle);
  
  mat2 rotationMatrix = mat2(c, s,
                            -s, c);
  
  vec2 pivot = vec2(0.5, 0.5);
  uv = rotationMatrix * (uv - pivot)+pivot;

  vec3 rg = mix(vec3(1.0,0.0,0.0), vec3(0.0,1.0,0.0), uv.x);
  vec3 yb = mix(vec3(1.0,1.0,0.0), vec3(0.0,0.0,1.0), uv.x);
  vec3 result = mix(yb, rg, uv.y);
  fragColor = vec4(result, 1.0);
}
