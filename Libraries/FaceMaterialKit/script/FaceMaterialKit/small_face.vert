uniform mat4 faceMat;

attribute vec4 a_position;
attribute vec2 a_texCoord;


///////////////////////////////////////////////////////////
// Uniforms

///////////////////////////////////////////////////////////
// Varyings
varying vec2 v_texCoord;

void main()
{

 gl_Position = a_position;
 v_texCoord = (faceMat * vec4(a_texCoord, 0.0, 1.0)).xy;

}
