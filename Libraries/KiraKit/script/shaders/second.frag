
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 topLeftTextureCoordinate;
varying vec2 topRightTextureCoordinate;
varying vec2 bottomTextureCoordinate;
varying vec2 bottomLeftTextureCoordinate;
varying vec2 bottomRightTextureCoordinate;
uniform float threshold;
uniform float edgeStrength;

uniform bool u_isFaceMasking;
uniform sampler2D u_faceMaskTexture;
uniform int u_maskAlpha;
uniform sampler2D u_maskTexture;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ratio = iResolution.x / iResolution.y;
    float xPosition = fract(v_texCoord.x * 30.0);
    float yPosition = fract(v_texCoord.y * (15.0 / ratio));

    if (xPosition + yPosition < 1.65)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);

        return;
    }
    
    if (u_isFaceMasking)
    {
        vec4 faceMaskColor = texture2D(u_faceMaskTexture, v_texCoord);
        
        if (faceMaskColor.a > 0.0)
        {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    if (u_maskAlpha == 1)
    {
        vec4 maskColor = texture2D(u_maskTexture, v_texCoord);
        
        if (maskColor.a == 1.0)
        {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    if (u_maskAlpha == 0)
    {
        vec4 maskColor = texture2D(u_maskTexture, v_texCoord);
        
        if (maskColor.a == 0.0)
        {
            fragColor = vec4(0.0, 0.0, 0.0, 1.0);
            
            return;
        }
    }
    
    float bottomLeftIntensity = texture2D(iChannel0, bottomLeftTextureCoordinate).r;
    float topRightIntensity = texture2D(iChannel0, topRightTextureCoordinate).r;
    float topLeftIntensity = texture2D(iChannel0, topLeftTextureCoordinate).r;
    float bottomRightIntensity = texture2D(iChannel0, bottomRightTextureCoordinate).r;
    float leftIntensity = texture2D(iChannel0, leftTextureCoordinate).r;
    float rightIntensity = texture2D(iChannel0, rightTextureCoordinate).r;
    float bottomIntensity = texture2D(iChannel0, bottomTextureCoordinate).r;
    float topIntensity = texture2D(iChannel0, topTextureCoordinate).r;
    float h = -topLeftIntensity - 2.0 * topIntensity - topRightIntensity + bottomLeftIntensity + 2.0 * bottomIntensity + bottomRightIntensity; h = max(0.0, h);
    float v = -bottomLeftIntensity - 2.0 * leftIntensity - topLeftIntensity + bottomRightIntensity + 2.0 * rightIntensity + topRightIntensity; v = max(0.0, v);
    float mag = length(vec2(h, v)) * edgeStrength;
    
    mag = step(threshold, mag);
    
    fragColor = vec4(vec3(mag) * 1.5, 1.0);
}
