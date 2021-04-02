// float threshold = 0.85;
float threshold = 0.5;
float scalar = 1.5;
// float HLVig = 0.3;
float HLVig = 0.55;
uniform int u_grayScale;
const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);

//uniform int u_isFaceFront;
uniform int u_useNoise;
uniform int u_maskAlpha;
uniform float u_strength;
uniform float u_time;

uniform sampler2D u_texture;
uniform sampler2D u_blurTexture;
uniform sampler2D u_maskTexture;
uniform bool u_isFaceMasking;
uniform sampler2D u_faceMaskTexture;

varying vec2 v_texCoord;

uniform float u_threshold;

vec4 permute(vec4 x){
    return mod(((x*34.0)+1.0)*x, 289.0);
}

vec4 taylorInvSqrt(vec4 r){
    return 1.79284291400159 - 0.85373472095314 * r;
}

vec3 fade(vec3 t){
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float cnoise(vec3 P){

    vec3 Pi0 = floor(P);
    vec3 Pi1 = Pi0 + vec3(1.0);

    Pi0 = mod(Pi0, 289.0);
    Pi1 = mod(Pi1, 289.0);

    vec3 Pf0 = fract(P);
    vec3 Pf1 = Pf0 - vec3(1.0);
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);
    vec4 gx0 = ixy0 / 7.0;
    vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;

    gx0 = fract(gx0);

    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));

    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);

    vec4 gx1 = ixy1 / 7.0;
    vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;

    gx1 = fract(gx1);

    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));

    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);

    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));

    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;

    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111))); g001 *= norm1.x;

    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);

    return 2.2 * n_xyz;
}

void main()
{

    vec2 uv = v_texCoord;
    
    if (u_isFaceMasking)
    {
        vec4 faceMaskColor = texture2D(u_faceMaskTexture, v_texCoord);
        
        if (faceMaskColor.a > 0.0)
        {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    if (u_maskAlpha == 1)
    {
        vec4 maskColor = texture2D(u_maskTexture, v_texCoord);
        
        if (maskColor.a == 1.0)
        {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    if (u_maskAlpha == 0)
    {
        vec4 maskColor = texture2D(u_maskTexture, v_texCoord);
        
        if (maskColor.a == 0.0)
        {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    vec3 col=texture2D(u_texture, v_texCoord).rgb;
    vec3 blu=texture2D(u_blurTexture, v_texCoord).rgb;
    float ratio = uv.x / uv.y;
    float n = 0.0;

    if(u_useNoise == 1){
        n = cnoise(vec3(uv.x*10000.0, u_time, uv.y*10000.0*ratio))*0.2;
    }

//    if (u_isFaceFront == 1){
//        HLVig -= 0.1;
//        //threshold = 0.5;
//    }

    HLVig = HLVig - 0.15 * u_strength;

    if(u_grayScale>0){
        float v=col.r*0.299+col.g*0.587+col.b*0.114;
        float v2=blu.r*0.299+blu.g*0.587+blu.b*0.114+HLVig;
        float th=max(threshold,v2)+n;

        if(v - v2 >  u_threshold){
            //v=(v-th)/(1.0-th)*scalar;

            if(u_grayScale==2){
                gl_FragColor=vec4(blu, 1)*v;
            }else{
                gl_FragColor=vec4(v,v,v,1.0);
            }
        }else{
            gl_FragColor=vec4(0.0,0.0,0.0,1.0);
        }
    }else{
        vec3 thc=max(vec3(threshold),blu+HLVig)+n;

        col.r=(col.r>thc.r)?((col.r-thc.r)/(1.0- thc.r)*scalar):0.0;
        col.g=(col.g>thc.g)?((col.g-thc.g)/(1.0-thc.g)*scalar):0.0;
        col.b=(col.b>thc.b)?((col.b-thc.b)/(1.0-thc.b)*scalar):0.0;

        if(u_grayScale==-1){
            float v=max(max(col.r,col.g),col.b);
            gl_FragColor=vec4(blu,1)*v;
        }else{
            gl_FragColor=vec4(col,1.0);
        }
    }
}
