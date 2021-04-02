require "FaceMaterialKit/FaceMaterialKit.lua"
require "KuruNodeKit/KuruNodeKit.lua"

maxFaceCount = 3

function initialize(scene)
  touchExtension = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  touchExtension:getTouchDownEvent():addEventHandler(onTouchDown)

  FaceMaterialKit.init(scene)
  local originSnap = KuruSnapshotNode.create()
  scene:addNodeAndRelease(originSnap)

  local maskBuffer = addNodeAndRelease(scene, KuruFrameBufferNode.create())
  maskBuffer:addChildAndRelease(KuruClearNode.create(Vector4.create(1, 1, 1, 1)))

  local mask = addChildAndRelease(maskBuffer, KuruNodeKit.createSkinExNode("mask.png", {}))
  local maskShader = addChildAndRelease(maskBuffer, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "mask.frag", true))
  maskShader:setChannel1(originSnap:getSampler())

  fireNode_R = KaleFaceParticleNode.create(BASE_DIRECTORY .."fire.particle")
  fireNode_R:setLocationType(StickerItemLocationType.EYE_RB)
  fireNode_R:start()

  fireNode_L = KaleFaceParticleNode.create(BASE_DIRECTORY .."fire.particle")
  fireNode_L:setLocationType(StickerItemLocationType.EYE_LB)
  fireNode_L:start()

  myModelNode = KaleFaceModelNode.create(BASE_DIRECTORY .. "model/box_faces.gpb")
  myModelNode:setFlipHorizontally(false)
  myModelNode:getStickerItem():getConfig().faceOffset = Vector3.create(0.0, -0.5, -0.14)
  myModelNode:setScale(0.6, 0.6, 0.6)

  planeNode = FaceMaterialKit.createPlaneNode()
  planeNode:getStickerItem():getConfig().faceOffset = Vector3.create(0.0, 0.0, 0.1)
  planeNode:getStickerItem().faceLocationType = StickerItemLocationType.EYE_LB
  planeNode:getStickerItem().translateXYZ = Vector3.create(23.0, 0, 0.0)
  planeNode:setScale(0.4, 0.4, 0.4)

  stickerNode = KuruNodeKit.createStickerNode("sticker.png", {locationType = StickerItemLocationType.EYE_LB, translateX = 1.4, scale = 3.0})

  -- particle 샘플러에 넣을시 머테리얼명 대신 "FaceMaterialKit.PARTICLE_MAT" 을 추가한다.
  g_facemat1 = FaceMaterialKit:new({FaceMaterialKit.PARTICLE_MAT}, originSnap:getSampler(), 2, maxFaceCount, 1):setOffset(0.235, -0.0475):setFaceChangeMode(false):setIndice(47):bindNode(fireNode_R)
  g_facemat2 = FaceMaterialKit:new({FaceMaterialKit.PARTICLE_MAT}, originSnap:getSampler(), 2, maxFaceCount, 1):setOffset(-0.105, -0.0475):setFaceChangeMode(false):setIndice(40):bindNode(fireNode_L)
  g_facemat3 = FaceMaterialKit:new({"faceMat"}, originSnap:getSampler(), 1.3, maxFaceCount, 1):setOffset(0, -0.053)
  g_facemat4 = FaceMaterialKit:new({"faceMat"}, originSnap:getSampler(), 1.3, maxFaceCount, 1):setFaceChangeMode(false):setIndice(40):bindNode(myModelNode)
  g_facemat5 = FaceMaterialKit:new({"faceSmallMat", "changeFaceMat"}, originSnap:getSampler(), 0.565, maxFaceCount, 1):setOffset(0, -0.053):setFaceChangeMode(true):bindNode(myModelNode)
  g_facemat6 = FaceMaterialKit:new({FaceMaterialKit.STICKER_MAT}, maskBuffer:getSampler(), 0.75, maxFaceCount, 1):setOffset(0, 0.17):setIndice(51):bindNode(stickerNode)


  -- g_facemat6 = FaceMaterialKit:new({FaceMaterialKit.STICKER_MAT}, maskBuffer:getSampler(), 0.8, maxFaceCount, 1)
end

function onPreRender(param)
  g_facemat1:updateSampler(param)
  g_facemat2:updateSampler(param)
  g_facemat3:updateSampler(param)
  g_facemat4:updateSampler(param)
  g_facemat5:updateSampler(param)
  g_facemat6:updateSampler(param)
end


function frameReady(scene, elapsedTime)
  local s = PropertyConfig.instance():getNumber("num1", 0.0) + 1.0
  local x = PropertyConfig.instance():getNumber("num2", 0.0) * 0.5
  local y = PropertyConfig.instance():getNumber("num3", -0.2) * 0.5
  --
  --
  -- g_facemat2:updateFaceScale(s)
  -- g_facemat2:setOffset(x, y)

end


function onTouchDown(event)
  local enable = myModelNode:isEnabled()
  myModelNode:setEnabled(not enable)
end

function addNodeAndRelease(scene, node)
  scene:addNode(node)
  node:release()
  return node
end

function addChildAndRelease(parent, child)
  parent:addChild(child)
  child:release()
  return child
end

function finalize(scene)
  touchExtension:getTouchDownEvent():removeEventHandler(onTouchDown)
end
