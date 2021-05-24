void mainImage(out vec4 fragColor, in vec2 fragCoord){
  vec2 uv = v_texCoord;
  vec2 originUV = uv;
  uv = fract(uv * 2.0);
  if (originUV.x < 0.5 && originUV.y < 0.5){ 
    fragColor = texture2D(iChannel0, uv); //Not Delayed
  }
  else if(originUV.x >= 0.5 && originUV.y < 0.5){
    fragColor = texture2D(iChannel1, uv); //Delay1
  }
  else if(originUV.x < 0.5 && originUV.y >= 0.5){
    fragColor = texture2D(iChannel2, uv); //Delay2
  }
  else{
    fragColor = texture2D(iChannel3, uv); //Delay3
  }
}
