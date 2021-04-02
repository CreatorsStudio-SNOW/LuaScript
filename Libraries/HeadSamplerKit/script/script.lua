--[[
   create at 2020-10-12 16:37:02
   author: Hong Sung Gon
   @brief:
--]]

require "HeadSamplerKit/HeadSamplerKit.lua"

HEAD_SCALE = 7.0

g_headSamplerKit = nil
g_headNode = nil
g_prevRatio = 0.0

function initialize(scene)
  g_headSamplerKit = HeadSamplerKit:new(scene)
  g_headNode = getStickerNodeFromSampler(g_headSamplerKit:getHeadSampler(), HEAD_SCALE, KaleStickerNodeLocationType.FACE, KaleStickerNodeAnchorType.CENTER, 0.0, -0.3, 0.0)
  scene:addNodeAndRelease(g_headNode)
end

function onPreRender(param)
  if param:getType() == RenderArgsType.FACE then
    faceParam = FacePreRenderArgs.cast(param)

    if faceParam:getNode():equals(g_headNode) then
      faceParam:setResult(faceParam:getFaceData().id == g_headSamplerKit.activeFaceId)
    end
  end
end

function frameReady(scene, elapsedTime)
  g_headSamplerKit:frameReady()

  local resolution = scene:getResolution()
  local ratio = resolution.x / resolution.y

  if (g_prevRatio ~= ratio) then
    g_prevRatio = ratio
    updateHeadNode(scene)
  end
end

function finalize(scene)
  g_headSamplerKit:finalize()
end

function updateHeadNode(scene)
  if (g_headNode ~= nil) then
    scene:removeNode(g_headNode)
  end

  g_headNode = getStickerNodeFromSampler(g_headSamplerKit:getHeadSampler(), HEAD_SCALE, KaleStickerNodeLocationType.FACE, KaleStickerNodeAnchorType.CENTER, 0.0, -0.3, 0.0)
  scene:addNodeAndRelease(g_headNode)
  g_headNode:getStickerItem():getConfig().faceOffset = Vector3.create(0, 0, 0.4)
end

function getStickerNodeFromSampler(sampler, scale, loactionType, anchorType, translateX, translateY, translateZ)
  local node = KaleStickerNode.createFromSampler(sampler, BlendMode.Normal, 0, 0)

  node:setId("sticker")
  node:setLocationType(loactionType)
  node:setAnchorType(anchorType)
  node:setScale(scale, scale, 1.0)
  node:setTranslation(translateX, translateY, translateZ)

  return node
end
