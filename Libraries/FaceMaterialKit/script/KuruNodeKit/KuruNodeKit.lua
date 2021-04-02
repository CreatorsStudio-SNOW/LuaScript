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
    node = KuruNodeKit.createShaderNode(config.vertFile, config.fragFile, config.usePreDefine, config.matrix, config.samplers)
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
  local translateX = stickerInfo.translateX  or 0.0
  local translateY = stickerInfo.translateY  or 0.0
  local translateZ = stickerInfo.translateZ  or 0.0
  local locationType = stickerInfo.locationType or StickerItemLocationType.FACE
  local anchorType = stickerInfo.anchorType or StickerItemAnchorType.CENTER
  local faceOffsetY = stickerInfo.faceOffsetY or 0.0 -- 8.0.0
  local faceOffsetZ = stickerInfo.faceOffsetZ or 0.0 -- 8.0.0
  local isBillboard = stickerInfo.billboard or false -- 8.0.0
  local cameraPosition = stickerInfo.cameraPosition or StickerItemCameraPositionType.ANY -- 8.1.0
  local aspectRatio = stickerInfo.aspectRatio or Vector2AspectRatioType.ANY

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
  local translateX = stickerInfo.translateX  or 0.0
  local translateY = stickerInfo.translateY  or 0.0
  local translateZ = stickerInfo.translateZ  or 0.0

  local blendMode = stickerInfo.blendMode or BlendMode.None
  local stretchType = stickerInfo.stretchType or KuruBackgroundImageNodeStretch.FILL_HORIZONTAL
  local anchorType = stickerInfo.anchorType or KuruBackgroundImageNodeAnchorType.CENTER
  local variantMode = stickerInfo.variantMode or StickerItemRotationMode.INVARIANT
  local cameraPosition = stickerInfo.cameraPosition or StickerItemCameraPositionType.ANY -- 8.1.0
  local aspectRatio = stickerInfo.aspectRatio or Vector2AspectRatioType.ANY

  local bgNode = KuruBackgroundImageNode.createFromSampler(sampler, blendMode)

  bgNode:setStretch(stretchType)
  bgNode:setAnchorType(anchorType)
  bgNode:setRotationMode(variantMode)

  bgNode:rotateZ(rotate)
  bgNode:setScale(scale, scale, 0)
  bgNode:setTranslation(translateX, translateY, translateZ)
  bgNode:getStickerItem().cameraPosition = cameraPosition -- 8.1.0
  bgNode:getStickerItem().aspectRatio = aspectRatio

  local autoLandscapeScale = stickerInfo.autoLandscapeScale or false

  if autoLandscapeScale == true then
    if variantMode == StickerItemRotationMode.INVARIANT and stretchType == KuruBackgroundImageNodeStretch.FILL_HORIZONTAL then
      local curAspect = KuruEngine.getInstance():getResolution().y / KuruEngine.getInstance():getResolution().x
      local config = KuruEngine.getInstance():getCameraConfig()

      if curAspect < 1.0 then
        bgNode:setStretch(KuruBackgroundImageNodeStretch.FILL)
        if config.deviceOrientation == 270 then
          bgNode:rotateZ(math.pi / 2.0 * 3.0)
        elseif config.deviceOrientation == 90 then
          bgNode:rotateZ(math.pi / 2.0)
        elseif config.deviceOrientation == 180 then
          bgNode:rotateZ(math.pi / 2.0 * 3.0)
        else
          bgNode:rotateZ(math.pi / 2.0)
        end
      else
        if config.deviceOrientation == 90 then
          bgNode:rotateZ(math.pi)
          bgNode:setAnchorType(KuruNodeKit.getRotateAnchorType(anchorType))
        elseif config.deviceOrientation == 180 then
          bgNode:rotateZ(math.pi)
          bgNode:setAnchorType(KuruNodeKit.getRotateAnchorType(anchorType))
        end
      end
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

  if distortionNode ~= nil then
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

  if distortionNode ~= nil then
    headshotBuilder:setDistortionNode(distortionNode)
  end

  local headshotNode = KuruHeadshotNode.createFromBuilder(headshotBuilder)

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

function KuruNodeKit.createShaderNode(vert, frag, usePreDefine, matrix, samplers)
  local mat = matrix or Matrix.identity()
  local predefine = usePreDefine or false

  local node
  if vert then
    node = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. vert, BASE_DIRECTORY .. frag, predefine)
  else
    node = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. frag, predefine)
  end

  if not predefine then
    node:getMaterial():getParameter("u_worldViewProjectionMatrix"):setMatrix(mat)
    node:getMaterial():getParameter("u_texture"):setSampler(samplers)
  else
    if #samplers >= 1 then node:setChannel0(samplers[1]) end
    if #samplers >= 2 then node:setChannel1(samplers[2]) end
    if #samplers >= 3 then node:setChannel2(samplers[3]) end
    if #samplers >= 4 then node:setChannel3(samplers[4]) end
  end

  return node
end

function KuruNodeKit.aspectRatioType()
  local resolution = KuruEngine.getInstance():getResolution()

  return Vector2.create(resolution.x,resolution.y):aspectRatioType()
end
