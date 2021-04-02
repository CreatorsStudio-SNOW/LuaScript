

uniform float texelWidth;
uniform float texelHeight;

varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;
varying vec2 topTextureCoordinate;
varying vec2 topLeftTextureCoordinate;
varying vec2 topRightTextureCoordinate;
varying vec2 bottomTextureCoordinate;
varying vec2 bottomLeftTextureCoordinate;
varying vec2 bottomRightTextureCoordinate;

void main()
{
    gl_Position = a_position;
    
    vec2 widthStep = vec2(texelWidth, 0.0);
    vec2 heightStep = vec2(0.0, texelHeight);
    vec2 widthHeightStep = vec2(texelWidth, texelHeight);
    vec2 widthNegativeHeightStep = vec2(texelWidth, -texelHeight);
    
    v_texCoord = a_texCoord;
    leftTextureCoordinate = a_texCoord - widthStep;
    rightTextureCoordinate = a_texCoord + widthStep;
    topTextureCoordinate = a_texCoord - heightStep;
    topLeftTextureCoordinate = a_texCoord - widthHeightStep;
    topRightTextureCoordinate = a_texCoord + widthNegativeHeightStep;
    bottomTextureCoordinate = a_texCoord + heightStep;
    bottomLeftTextureCoordinate = a_texCoord - widthNegativeHeightStep;
    bottomRightTextureCoordinate = a_texCoord + widthHeightStep;
}
