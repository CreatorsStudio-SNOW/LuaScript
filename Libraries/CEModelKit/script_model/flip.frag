uniform float colorEdgeL;
uniform float colorEdgeM;
uniform float dir;
uniform float contrast;
uniform float lightness;

vec3 hsl2rgb( vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}



float czm_luminance(vec3 rgb){
    const vec3 W = vec3(0.2125, 0.7154, 0.0721);
    return dot(rgb, W);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = fragCoord/iResolution.xy;
  vec2 orgUv = uv;
  uv.y = 1. - uv.y;
  uv.x = 1. - uv.x;
  orgUv.y = 1. - orgUv.y;
  orgUv.x = 1. - orgUv.x;

  uv.y -= .5;
  uv.y /= (iResolution.y/iResolution.x);
  uv.y += .5;

  float grad = (1. - step(.5, dir)) * uv.x + step(.5, dir) * (1. - step(1.5, dir)) * uv.y + step(1.5, dir) * distance(vec2(.5), uv);
  grad = smoothstep(colorEdgeL, colorEdgeM, grad);
  vec4 hsl = vec4(grad, 1., lightness, 1.);
  vec4 colorMapSampler = vec4(hsl2rgb(hsl.rgb), 1.);

  vec4 c = texture(iChannel0, uv);
  vec4 k = texture(iChannel1, uv);
  k.a = k.r;
  // fragColor = c * k * colorMapSampler;
  fragColor = c * k;

}
