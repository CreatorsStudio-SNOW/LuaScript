#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

uniform sampler2D u_texture;
uniform mat4 u_fragMat;
uniform float cropL;
uniform float cropR;

varying vec2 v_texCoord;

void main()
{
    vec4 fragUV = u_fragMat * vec4(v_texCoord, 0.0, 1.0);
    vec4 color =  texture2D(u_texture, fragUV.xy);
    if (fragUV.x < cropL || fragUV.x > cropR){
      color.a = 0.0;
    }
    gl_FragColor =  color;
}
