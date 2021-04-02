uniform sampler2D u_texture;
varying vec2 v_texCoord;

void main(){
    float a = step(.01, v_texCoord.x) * (1. - step(.99, v_texCoord.x)) * step(.01, v_texCoord.y) * (1. - step(.99, v_texCoord.y));
    vec4 color = texture(u_texture, v_texCoord);

    gl_FragColor = vec4(color.rgb * a, color.a * a);
}
