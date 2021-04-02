#define MAX_COUNT 8

#ifdef OPENGL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

uniform sampler2D u_texture;
uniform sampler2D u_samplers[MAX_COUNT];
varying vec2 v_texCoord;

uniform int u_count;
uniform vec4 u_bgColor;
uniform vec2 u_positions[MAX_COUNT];
uniform vec2 u_sizes[MAX_COUNT];
uniform vec2 u_anchors[MAX_COUNT];
uniform vec2 u_scales[MAX_COUNT];
/* uniform mat4 u_maxtrix[MAX_COUNT]; */

void main()
{
  for(int i = 0; i < u_count; i++)
  {
    float maxX = u_positions[i].x + u_sizes[i].x;
    float maxY = u_positions[i].y + u_sizes[i].y;

    if(v_texCoord.x >= u_positions[i].x && v_texCoord.y >= u_positions[i].y
      && v_texCoord.x < maxX && v_texCoord.y < maxY)
    {
      vec2 fragUV = v_texCoord;
      /* fragUV.x -= u_positions[i].x;
      fragUV.y -= u_positions[i].y; */

      fragUV.x -= u_positions[i].x;
      fragUV.y -= u_positions[i].y;

      fragUV /= u_scales[i];

      fragUV += 0.5;
      fragUV.x -= u_sizes[i].x / u_scales[i].x / 2.0;
      fragUV.y -= u_sizes[i].y / u_scales[i].y / 2.0;

      fragUV.x += u_anchors[i].x;
      fragUV.y += u_anchors[i].y;

      gl_FragColor = texture2D(u_samplers[i], fragUV);
      return;
    }
    /* vec4 fragUV = u_fragMat * vec4(v_texCoord, 0.0, 1.0); */
    /* gl_FragColor = texture2D(u_texture, v_texCoord); */
      /* gl_FragColor = vec4(u_bgColor, 1.0); */
  }

  gl_FragColor = u_bgColor;
}
