-- https://wiki.navercorp.com/display/LFS/KuruNodeKit
-- Update Date : 200213
-- Writer : 김승연

DrawType = {
  FACE = 1,
  BACKGROUND = 2,
  SNAPSHOT = 3,
  CLEAR = 4,
  SKIN = 5,
  FACEMODEL = 6,
  SEGMENTATION_SRC = 7,
  SEGMENTATION = 8,
  HEADSHOT = 9,
  SHADER = 10,
  FRAGMENT_SHADER = 11,
  GAUSSIAN_BLUR = 12,
  DISTORTION = 99,
}

KuruNodeKit = {
}
KuruNodeKit.__index = KuruNodeKit

function KuruNodeKit:new(samplers, layoutList, color)
  local newObject = {}
  setmetatable(newObject, KuruNodeKit)

  return newObject
end

function KuruNodeKit.addNodesFromConfigs(scene, configs)
  for idx, config in pairs(configs) do
    local node = KuruNodeKit.createNodeByConfig(config)
    scene:addNodeAndRelease(node)
  end
end

function KuruNodeKit.createNodeByConfig(config)
  local drawType = config["drawType"] or DrawType.FACE
  local node = nil

  if drawType == DrawType.FACE then
    node = KuruNodeKit.createStickerNode(config.resourceName, config)
  elseif drawType == DrawType.BACKGROUND then
    node = KuruNodeKit.createBGNode(config.resourceName, config)
  elseif drawType == DrawType.SNAPSHOT or drawType == DrawType.SEGMENTATION_SRC then
    node = KuruNodeKit.createSnapshotNode(config.buffeScale)
  elseif drawType == DrawType.CLEAR then
    node = KuruNodeKit.createClearNode(config.color)
  elseif drawType == DrawType.DISTORTION then
    node = KuruNodeKit.createBuiltInDistortionNode()
  elseif drawType == DrawType.SKIN then
    node = KuruNodeKit.createSkinExNode(config.resourceName, config)
  elseif drawType == DrawType.FACEMODEL then
    node = KuruNodeKit.createFaceModelNode(config.resourceName)
  elseif drawType == DrawType.SEGMENTATION then
    node = KuruNodeKit.createSegmentationNode(config.sourceSampler, config.distortionNode, config)
  elseif drawType == DrawType.HEADSHOT then
    node = KuruNodeKit.createHeadshotNode(config.maskFilePath, config.sourceSampler, config.distortionNode)
  elseif drawType == DrawType.SHADER then
    node = KuruNodeKit.createShaderNode(config.vertPath, config.fragPath)
  elseif drawType == DrawType.FRAGMENT_SHADER then
    node = KuruNodeKit.createFragmentShaderNode(config.path)
  elseif drawType == DrawType.GAUSSIAN_BLUR then
    node = KuruNodeKit.createGaussianBlurNodeDrawable(config.strength)
  end

  if config.id then
    node:setId(config.id)
  end

  return node
end

function findNode(scene, id)
  local node = scene:findNode(id, true, true)
  return node
end

---- Snapshot Node

function KuruNodeKit.createSnapshotNode(scale)

  local frameBufferScale = scale or 1.0

  local node = KuruSnapshotNode.create()
  node:setFrameBufferScale(frameBufferScale, frameBufferScale)
  return node
end


---- Clear Node

function KuruNodeKit.createClearNode(color, isDepthBufferClear)
  local isDBClear = isDepthBufferClear or false

  local clearNode
  if isDBClear then
    clearNode = KuruClearNode.create(color) -- Vector4
  else -- 8.1.0
    clearNode = KuruClearNode.createWithFlags(color, GameClearFlags.CLEAR_COLOR) -- Vector4
  end

  return clearNode
end

---- Builtin Distortion
function KuruNodeKit.createBuiltInDistortionNode() -- 7.6.0
  EngineStatus.instance():setBoolean("useBuiltInDistortionInScript", true)
  local distortionNode = KaleFaceDistortionNode.create()
  distortionNode:loadDistortionFromString(SceneConfig.instance().distortionJson)

  return distortionNode
end


---- Sticker Node
function KuruNodeKit.createStickerNode(filePath, stickerInfo)
  local fps = stickerInfo.fps or 20
  local repeatCount = stickerInfo.repeatCount or 0
  local sampler = KuruNodeKit.createAnimationSampler(filePath, fps, repeatCount)
  local node = KuruNodeKit.createStickerNodeFromSampler(sampler, stickerInfo)
  sampler:release()

  return node
end

function KuruNodeKit.createStickerNodeFromSampler(sampler, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local fps = stickerInfo.fps or 20
  local blendMode = stickerInfo.blendMode or BlendMode.None
  local flip = stickerInfo.flip or false
  local scale = stickerInfo.scale or 1.0
  local rotate = stickerInfo.rotate or 0.0
  local translateX = stickerInfo.translateX or 0.0
  local translateY = stickerInfo.translateY or 0.0
  local translateZ = stickerInfo.translateZ or 0.0
  local locationType = stickerInfo.locationType or StickerItemLocationType.FACE
  local anchorType = stickerInfo.anchorType or StickerItemAnchorType.CENTER
  local faceOffsetY = stickerInfo.faceOffsetY or 0.0 -- 8.0.0
  local faceOffsetZ = stickerInfo.faceOffsetZ or 0.0 -- 8.0.0
  local isBillboard = stickerInfo.billboard or false -- 8.0.0
  local cameraPosition = stickerInfo.cameraPosition or StickerItemCameraPositionType.ANY -- 8.1.0
  local aspectRatio = stickerInfo.aspectRatio or Vector2AspectRatioType.ANY
  local alpha = stickerInfo.alpha or 1.0

  local node = KaleStickerNode.createFromSampler(sampler, blendMode, 0, 0)

  if flip == true then
    node:setScale(-scale, scale, 0)
  else
    node:setScale(scale, scale, 0)
  end
  node:setTranslation(translateX, translateY, translateZ)
  node:rotateZ(rotate)
  node:setLocationType(locationType)
  node:setAnchorType(anchorType)
  node:getStickerItem():getConfig().faceOffset = Vector3.create(0.0, faceOffsetY, faceOffsetZ) -- 8.0.0
  node:getStickerItem():getConfig().billboard = isBillboard -- 8.0.0
  node:getStickerItem().cameraPosition = cameraPosition -- 8.1.0
  node:getStickerItem().aspectRatio = aspectRatio
  node:getStickerItem().alpha = alpha

  if stickerInfo.locationIndices ~= nil then
    node:setFaceLocationIndices(stickerInfo.locationIndices)
  end

  if stickerInfo.scaleIndices ~= nil then
    node:setFaceScaleIndices(stickerInfo.scaleIndices)
  end

  return node
end


---- Background Node

function KuruNodeKit.createBGNode(filePath, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local fps = stickerInfo.fps or 20
  local repeatCount = stickerInfo.repeatCount or 0
  local sampler = KuruNodeKit.createAnimationSampler(filePath, fps, repeatCount)
  local node = KuruNodeKit.createBGNodeFromSampler(sampler, stickerInfo)
  sampler:release()

  return node
end

function KuruNodeKit.createBGNodeFromSampler(sampler, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local scale = stickerInfo.scale or 1.0
  local rotate = stickerInfo.rotate or 0.0
  local translateX = stickerInfo.translateX or 0.0
  local translateY = stickerInfo.translateY or 0.0
  local translateZ = stickerInfo.translateZ or 0.0

  local blendMode = stickerInfo.blendMode or BlendMode.None
  local stretchType = stickerInfo.stretchType or KuruBackgroundImageNodeStretch.CENTER_CROP
  local anchorType = stickerInfo.anchorType or KuruBackgroundImageNodeAnchorType.CENTER
  local rotationMode = stickerInfo.rotationMode or StickerItemRotationMode.INVARIANT
  local cameraPosition = stickerInfo.cameraPosition or StickerItemCameraPositionType.ANY -- 8.1.0
  local aspectRatio = stickerInfo.aspectRatio or Vector2AspectRatioType.ANY
  local autoPlay = stickerInfo.autoPlay or false
  local alpha = stickerInfo.alpha or 1.0
  local autoLandscapeScale = stickerInfo.autoLandscapeScale or false

  local bgNode = KuruBackgroundImageNode.createFromSampler(sampler, blendMode)

  bgNode.autoScaleOnVariantRotation = true
  bgNode:setStretch(stretchType)
  bgNode:setAnchorType(anchorType)
  bgNode:setRotationMode(rotationMode)

  bgNode:rotateZ(rotate)
  bgNode:setScale(scale, scale, 0)
  bgNode:setTranslation(translateX, translateY, translateZ)
  bgNode:getStickerItem().cameraPosition = cameraPosition -- 8.1.0
  bgNode:getStickerItem().aspectRatio = aspectRatio
  bgNode:getStickerItem().autoPlay = autoPlay
  bgNode:getStickerItem().alpha = alpha

  if autoLandscapeScale == true then
    bgNode:setStretch(KuruBackgroundImageNodeStretch.FILL_HORIZONTAL)
    bgNode:setRotationMode(KuruBackgroundImageNodeStretch.INVARIANT)

    local ratio = KuruEngine.getInstance():getResolution().y / KuruEngine.getInstance():getResolution().x
    if ratio < 1.0 then
      bgNode:setScale(scale * ratio, scale * ratio, 0)
      bgNode:setTranslation(translateX * ratio, translateY * ratio, translateZ)
    end
  end

  return bgNode
end

function KuruNodeKit.getRotateAnchorType(anchorType)
  if anchorType == KuruBackgroundImageNodeAnchorType.TOP then
    return KuruBackgroundImageNodeAnchorType.BOTTOM
  elseif anchorType == KuruBackgroundImageNodeAnchorType.BOTTOM then
    return KuruBackgroundImageNodeAnchorType.TOP
  end

  return anchorType
end

---- SKIN 106 EX Node

function KuruNodeKit.createSkinExNode(filePath, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local fps = stickerInfo.fps or 20
  local repeatCount = stickerInfo.repeatCount or 0
  local sampler = KuruNodeKit.createAnimationSampler(filePath, fps, repeatCount)
  local node = KuruNodeKit.createSkinExNodeFromSampler(sampler, stickerInfo)
  sampler:release()

  return node
end

function KuruNodeKit.createSkinExNodeFromSampler(sampler, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  -- 8.0.0
  local skinType = stickerInfo.skinType or KaleFaceSkinType.FACE_106_EX -- skinType FACE, FACE_EX, FACE_106_EX
  local blendMode = stickerInfo.blendMode or BlendMode.None

  local skinEx = KaleFaceSkinNodeSkinEx.create()

  if skinEx["mode"] ~= nil then -- 8.0.0
    local skinExMode = stickerInfo.skinExMode or StickerItemSkinExMode.NORMAL -- NORMAL, EXTEND, LIP
    skinEx:mode(skinExMode)
  end

  if skinEx["modelType"] ~= nil then -- 8.4.0
    local modelType = stickerInfo.modelType or StickerItemSkinExModelType.ASIAN -- ASIAN, WESTERNER
    skinEx:modelType(modelType)
  end

  local skinExBuilder = KaleFaceSkinNodeBuilder.create()
  skinExBuilder:sampler(sampler)
  skinExBuilder:skinType(skinType)
  skinExBuilder:blendmode(blendMode)
  skinExBuilder:skinEx(skinEx)
  skinExBuilder:build()

  return KaleFaceSkinNode.create(skinExBuilder)
end

---- Segmentation Node

function KuruNodeKit.createSegmentationNode(sourceSampler, distortionNode, stickerInfo)
  local node = KuruSegmentationNode.create()
  if sourceSampler ~= nil then
    node:setSourceSampler(sourceSampler)
  end

  if distortionNode == nil then
    distortionNode = KuruNodeKit.createBuiltInDistortionNode()
    node:setDistortionNode(distortionNode)
    distortionNode:release()
  else
    node:setDistortionNode(distortionNode)
  end

  if stickerInfo ~= nil then
    local item = node:getSegmetationItem()

    local enableEdge = stickerInfo.enableEdge or false
    local textureType = stickerInfo.textureType or SegmentationItemTextureType.FOREGROUND
    local edgeColor = stickerInfo.edgeColor or Vector4.create(1, 1, 1, 1)
    local edgeRatio = stickerInfo.edgeRatio or 0.0
    local edgeType = stickerInfo.edgeType or SegmentationItemEdgeType.OUTSIDE
    local interSpaceRatio = stickerInfo.interSpaceRatio or 0.0
    local outerEdgeColor = stickerInfo.outerEdgeColor or Vector4.create(1, 1, 1, 1)
    local outerEdgeRatio = stickerInfo.outerEdgeRatio or 0.0
    local maskAlphaThreshold = stickerInfo.maskAlphaThreshold or 0.0

    item.enableEdge = enableEdge
    item.textureType = textureType
    item.edgeColor = edgeColor
    item.edgeRatio = edgeRatio
    item.edgeType = edgeType
    item.interSpaceRatio = interSpaceRatio
    item.outerEdgeColor = outerEdgeColor
    item.outerEdgeRatio = outerEdgeRatio
    item.maskAlphaThreshold = maskAlphaThreshold
  end

  return node
end


---- Headshot Node

function KuruNodeKit.createHeadshotNode(maskFilePath, sourceSampler, distortionNode)

  local skinEx = KaleFaceSkinNodeSkinEx.create()

  local headshotBuilder = KuruHeadshotNodeBuilder.create()
  headshotBuilder:setSkinExMetadata(skinEx)
  headshotBuilder:setSkinExPath(BASE_DIRECTORY .. maskFilePath)

  local builtInDistortionNode = nil
  if distortionNode == nil then
    builtInDistortionNode = KuruNodeKit.createBuiltInDistortionNode()
    headshotBuilder:setDistortionNode(builtInDistortionNode)
  else
    headshotBuilder:setDistortionNode(distortionNode)
  end

  local headshotNode = KuruHeadshotNode.createFromBuilder(headshotBuilder)

  if builtInDistortionNode ~= nil then
    builtInDistortionNode:release()
  end

  if sourceSampler ~= nil then
    headshotNode:setSamplerToShow(sourceSampler)
  end

  return headshotNode
end

---- KaleFaceModelNode for 3d contents

function KuruNodeKit.createFaceModelNode(gpbFilePath)

  local node = KaleFaceModelNode.create(BASE_DIRECTORY .. gpbFilePath)
  node:getStickerItem().flipHorizontally = true

  return node
end

function KuruNodeKit.createFaceFittingNode(gpbFilePath, stickerInfo)
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local faceOffset = stickerInfo.faceOffset or Vector3.create(0, 0, 0)

  local node = KaleFaceFittingNode.create(KaleFaceFittingNodeBuilder.create():useNormal(true):fillEye(false):fillMouth(false):path(BASE_DIRECTORY .. gpbFilePath):build())
  node:getStickerItem():getConfig().faceOffset = faceOffset

  return node
end

---- common

function KuruNodeKit.createAnimationSampler(filePath, fps, repeatCount)
  local sampler = KuruAnimationSampler.createFromPath(BASE_DIRECTORY .. filePath, false, false)
  sampler:setRepeatCount(repeatCount)
  sampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)
  sampler:setFPS(fps)
  sampler:play()
  return sampler
end

function KuruNodeKit.createTextureSampler(filePath)
  local sampler = TextureSampler.create(BASE_DIRECTORY .. filePath, false, false)
  sampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)
  return sampler
end

-- passthrough shader & face zoom shader
function KuruNodeKit.createPassthroughWithMatrix(sampler, matrix)
  local mat = matrix or Matrix.identity()

  local node = KuruShaderFilterNode.createWithFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", nil)
  node:getMaterial():getParameter("u_worldViewProjectionMatrix"):setMatrix(mat)
  node:getMaterial():getParameter("u_texture"):setSampler(sampler)

  return node
end

function KuruNodeKit.createShaderNode(vert, frag)
  node = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. vert, BASE_DIRECTORY .. frag, true)
  return node
end

function KuruNodeKit.createFragmentShaderNode(path)
  node = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. path, true)
  return node
end

function KuruNodeKit.createPassthroughWithMatrix(sampler, matrix)
  local mat = matrix or Matrix.identity()

  local node = KuruShaderFilterNode.createWithFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", nil)
  node:getMaterial():getParameter("u_worldViewProjectionMatrix"):setMatrix(mat)
  node:getMaterial():getParameter("u_texture"):setSampler(sampler)

  return node
end


FRAGMENT_MASK_SHADER = [[

uniform float maskRatio;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 maskUV = uv;

  float frameAspect = iResolution.x / iResolution.y;
  float maskFrameAspect = maskRatio / frameAspect;

  float scaleX = 1.0, scaleY = 1.0;
  float offsetX = 0.0, offsetY = 0.0;

  if(frameAspect < 1.0)
  {
    scaleY = maskFrameAspect;
    offsetY = ((1.0 - scaleY) / 2.0);
  }
  else
  {
    scaleX = 1.0 / maskFrameAspect;
    offsetX = ((1.0 - scaleX) / 2.0);
  }

  maskUV = vec2(maskUV.x * scaleX + offsetX, maskUV.y * scaleY + offsetY);

  if (maskUV.x < 0.0 || maskUV.x > 1.0 || maskUV.y < 0.0 || maskUV.y > 1.0)
  {
    discard;
  }

  vec4 orgColor = texture(iChannel0, uv);
  vec4 maskColor = texture(iChannel1, maskUV);

  fragColor = orgColor * maskColor.r;
}
]]

function KuruNodeKit.createMaskNode(sourceSampler, maskFile)

  local maskSampler = KuruNodeKit.createTextureSampler(maskFile)

  local maskNode = KuruNodeKit.createMaskNodeFromSampler(sourceSampler, maskSampler)

  maskSampler:release()

  return maskNode
end


function KuruNodeKit.createMaskNodeFromSampler(sourceSampler, maskSampler)

  local maskTexture = maskSampler:getTexture()
  local maskTextureRatio = 1.0

  if maskTexture ~= nil then
    maskTextureRatio = maskTexture:getWidth() / maskTexture:getHeight()
  else
    local resolution = KuruEngine.getInstance():getResolution()
    maskTextureRatio = resolution.x / resolution.y
  end

  local shaderBuilder = KuruShaderFilterNodeBuilder.create()
  :fragmentShaderString(FRAGMENT_MASK_SHADER)
  :build()

  local node = KuruShaderFilterNode.create(shaderBuilder)

  local stateBlock = node:getMaterial():getStateBlock()
  stateBlock:setBlend(true)
  stateBlock:setBlendSrc(RenderStateBlend.BLEND_ONE)
  stateBlock:setBlendDst(RenderStateBlend.BLEND_ONE_MINUS_SRC_ALPHA)

  node:getMaterial():getParameter("maskRatio"):setFloat(maskTextureRatio)
  node:setChannel0(sourceSampler)
  node:setChannel1(maskSampler)

  return node
end

function KuruNodeKit.createGaussianBlurNodeDrawable(strength)
  local node = KuruGaussianBlurNode.create()
  local drawable = KuruAdjustableGaussianDrawable.cast(node:getDrawable())
  local str = strength or 1.0
  drawable:setStrength(str)
  return node, drawable
end

function KuruNodeKit.aspectRatioType()
  local resolution = KuruEngine.getInstance():getResolution()
  local config = KuruEngine.getInstance():getCameraConfig()

  if not config:isGalleryMode() and config:isOneToOne() == true then
    return Vector2.create(resolution.x, resolution.x):aspectRatioType()
  end

  return Vector2.create(resolution.x, resolution.y):aspectRatioType()
end

function KuruNodeKit.createCartoonNode(lutFile)
  local node = KuruComicFilterNode.create()

  -- 배경 카툰 렌더링의 색 톤을 딥러닝 카툰 얼굴 톤에 맞추는 LUT
  sampler = TextureSampler.create(BASE_DIRECTORY .. lutFile)
  node:setComicMixFaceLutSampler(sampler)
  sampler:release()

  return node
end

function KuruNodeKit.createCartoonGANNode(modelFile, bundlePath, bgSampler)
  local node = KuruCartoonFaceNode.create(BASE_DIRECTORY .. "/" .. modelFile)

  -- 여러 얼굴 동시 카툰 렌더링 하는 옵션 (default : 1)
  local convertFaceMaxCount = 1
  local config = DeviceConfig.instance()

  if CameraConfig:instance():isImageMode() then -- 사진 편집 모드
    convertFaceMaxCount = 10
  else -- 라이브, 영상 편집 모드
    if config:isIOS() then -- ios
      convertFaceMaxCount = 2
    else -- android
      if config["getDeviceLevel"] and config:getDeviceLevel() == DeviceConfigDeviceLevel.S then
        convertFaceMaxCount = 2
      end
    end
  end

  node:setMaxNumOfFaceRendering(convertFaceMaxCount)

  -- 얼굴 모듈 내에서 딥러닝 결과를 보정해주는 Lut
  sampler = TextureSampler.create(BASE_DIRECTORY .. bundlePath .. "/FaceToneLut.png")
  node:setFaceToneLutSampler(sampler)
  sampler:release()

  -- face moudle결과와 배경 이미지를 합성할때 사용하는 마스크
  sampler = TextureSampler.create(BASE_DIRECTORY .. bundlePath .. "/mask.jpg")
  node:setMaskSampler(sampler)
  sampler:release()

  -- 다수 얼굴일때 두번 렌더링 하는데, 두번째 렌더링때 사용하는 얼굴 마스크(겹치는 얼굴의 피해를 최소화)
  sampler = TextureSampler.create(BASE_DIRECTORY .. bundlePath .. "/faceskin_ex_mask_onlyface.jpg")
  node:setFaceMaskSampler(sampler)
  sampler:release()

  if bgSampler ~= nil then
    node:setBackGroundSampler(bgSampler)
  end

  return node
end


function KuruNodeKit.createUVFilterNode(uvFile, sourceSampler)
  local uvNode = KuruUVFilterNode.createWithMode(BASE_DIRECTORY .. uvFile, UVFilterNodeMode.MODE_16BIT_WITHOUT_ALPHA)

  uvNode:setSourceSampler(sourceSampler)
  uvNode:setAlphaThreshold(-1.0)

  return uvNode
end
