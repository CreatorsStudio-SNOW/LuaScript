uniform mat4 u_worldViewProjectionMatrix;

void main()
{
    gl_Position = u_worldViewProjectionMatrix * a_position;
    v_texCoord = a_texCoord;
}
