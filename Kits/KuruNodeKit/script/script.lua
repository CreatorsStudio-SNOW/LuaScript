require "KuruNodeKit/KuruNodeKit.lua" -- ResTransfer.lua 포함 (사용법은 기존과 동일)

function initialize(scene)
  kuruTouch = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  kuruTouch:getTouchDownEvent():addEventHandler(onTouchDown)

  scene:addNodeAndRelease(KuruNodeKit.createClearNode(Vector4.create(0, 0, 0, 0), true))

  g_segExtension = KuruSegmentationExtension.cast(KuruEngine.getInstance():getExtension("KuruSegmentation"))
  g_segType = SegType.SKIN -- fill seg type 
  scene:activateCountType(g_segExtension:getCountType(g_segType))
  local sampler = g_segExtension:getSampler(g_segType) -- move to frameReady

  alphaNode = HandyShaderFilterNodeBuilder.instance():build(HandyShaderFilterNodeBuilderFilterType.PASS)
  scene:addNodeAndRelease(alphaNode)
  alphaNode:setStrength(1.0)

  scene:addNodeAndRelease(KuruNodeKit.createStickerNode("mask.png", {
    rotate = math.rad(45),
    rotateByDegree = 90
  }))

  g_touchFlag = false
end

function frameReady(scene, elapsedTime)
  local sampler = g_segExtension:getSampler(g_segType)
  alphaNode:setChannel0(sampler)
end

function finalize(scene)
  kuruTouch:getTouchDownEvent():removeEventHandler(onTouchDown)
end

function onTouchDown(event)
  g_touchFlag = not g_touchFlag
end
