require "KuruNodeKit/KuruNodeKit.lua" -- ResTransfer.lua 포함 (사용법은 기존과 동일)

snapshotNode = {}

function initialize(scene)
  kuruTouch = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  kuruTouch:getTouchDownEvent():addEventHandler(onTouchDown)
  kuruFace = KuruFaceDetectorExtension.cast(KuruEngine.getInstance():getExtension("KuruFaceDetector"))

  KuruNodeKit.addNodeAndRelease(scene, KuruNodeKit.createClearNode(Vector4.create(0, 0, 0, 0), true))

  g_segExtension = KuruSegmentationExtension.cast(KuruEngine.getInstance():getExtension("KuruSegmentation"))
  g_segType = SegType.SKIN -- fill seg type 
  scene:activateCountType(g_segExtension:getCountType(g_segType))
  local sampler = g_segExtension:getSampler(g_segType) -- move to frameReady

  alphaNode = HandyShaderFilterNodeBuilder.instance():build(HandyShaderFilterNodeBuilderFilterType.PASS)
  scene:addNodeAndRelease(alphaNode)
  alphaNode:setStrength(1.0)

  KuruNodeKit.addNodeAndRelease(scene, KuruNodeKit.createStickerNode("mask.png", {
    rotate = 45*math.pi/180,
    rotateByDegree = 90
  }))
end

function frameReady(scene, elapsedTime)
  local sampler = g_segExtension:getSampler(g_segType) -- move to frameReady
  alphaNode:setChannel0(sampler)
end

function onAspectRatioChanged(scene)
end

function finalize(scene)
  kuruTouch:getTouchDownEvent():removeEventHandler(onTouchDown)
end

isTouch = false
function onTouchDown(event)
  isTouch = not isTouch
end
