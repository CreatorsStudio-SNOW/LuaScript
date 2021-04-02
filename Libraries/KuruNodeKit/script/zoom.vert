uniform mat4 faceMat;

void main(){
    gl_Position = faceMat * a_position;
    v_texCoord = a_texCoord;
}
