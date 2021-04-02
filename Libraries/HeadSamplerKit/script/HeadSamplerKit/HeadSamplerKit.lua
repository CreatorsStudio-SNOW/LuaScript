--[[
   create at 2020-10-12 16:37:02
   author: Hong Sung Gon
   @brief:
--]]

HeadSamplerKit = {
  FACE_CENTER_INDEX = 30,
  LEFT_EYE_INDEX = 45,
  RIGHT_EYE_INDEX = 36,
  scene = nil,
  zoomNode = nil,
  displayNode = nil,
  headshotMaskBuffer = nil,
  kuruFace = nil,
  hairSegExtension = nil,
  activeFaceId = -1
}

function HeadSamplerKit:new(scene)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance:init()

  return newInstance
end

function HeadSamplerKit:init()
  EngineStatus.instance():increase(EngineStatusCountType.HAIR_SEGMENTATION)
  self.kuruFace = KuruFaceDetectorExtension.cast(KuruEngine.getInstance():getExtension("KuruFaceDetector"))

  local hairSegExtension = KuruEngine.getInstance():getExtension("KuruHairSegmentation")

  self.hairSegExtension = KuruHairSegmentationExtension.cast(hairSegExtension)

  local cameraSnapshot = KuruSnapshotNode.create()

  self.scene:addNodeAndRelease(cameraSnapshot)


  self.headshotMaskBuffer = KuruFrameBufferNode.createWithScale(1.0, 1.0)
  self.scene:addNodeAndRelease(self.headshotMaskBuffer)
  self.headshotMaskBuffer:addChildAndRelease(KuruClearNode.create(Vector4.create(0.0, 0.0, 0.0, 0.0)))

  local skinLineNode = KaleFaceSkinNode.create(KaleFaceSkinNodeBuilder.create():path(BASE_DIRECTORY .. "HeadSamplerKit/skin_line.png")
  :skinType(KaleFaceSkinType.FACE_EX):skinEx(KaleFaceSkinNodeSkinEx.create()
  :fillInMouth(true))
  :blendmode(BlendMode.None):build())

  self.headshotMaskBuffer:addChildAndRelease(skinLineNode)

  local faceMaskSnpashot = KuruSnapshotNode.create()

  self.headshotMaskBuffer:addChildAndRelease(faceMaskSnpashot)
  self.headshotMaskBuffer:addChildAndRelease(KuruClearNode.create(Vector4.create(0.0, 0.0, 0.0, 0.0)))
  self.headshotMaskBuffer:addChildAndRelease(self:createSegNode(cameraSnapshot))

  self.displayNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "HeadSamplerKit/display.frag", true)
  self.headshotMaskBuffer:addChildAndRelease(self.displayNode)
  self.displayNode:setChannel1(cameraSnapshot:getSnapshot())
  self.displayNode:setChannel2(self.hairSegExtension:getMaskSampler())
  self.displayNode:setChannel3(faceMaskSnpashot:getSnapshot())

  local maskSnapshot = KuruSnapshotNode.create()

  self.headshotMaskBuffer:addChildAndRelease(maskSnapshot)
  self.headshotMaskBuffer:addChildAndRelease(KuruClearNode.create(Vector4.create(1.0, 1.0, 1.0, 0.0)))

  self.zoomNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "HeadSamplerKit/cameraZoom.vert", BASE_DIRECTORY .. "HeadSamplerKit/zoomPassthrough.frag", true)
  self.zoomNode:getMaterial():getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
  self.zoomNode:setChannel0(maskSnapshot:getSampler())
  self.headshotMaskBuffer:addChildAndRelease(self.zoomNode)
end

function HeadSamplerKit:frameReady()
  local faceCount = self.kuruFace:getFaceCount()

  if(faceCount > 0) then
    local maxEyeDist = 0.0
    local faceCenterPos = nil
    local faceHeight = nil
    local relativeRoll = nil

    self.activeFaceId = -1

    for i = 0, faceCount - 1 do
      local faceFeature = KaleFaceFeature.cast(self.kuruFace:getFace(i))
      local faceData = faceFeature:getFaceData()
      local leftEyePos = faceData:getUlseeVertexShape(HeadSamplerKit.LEFT_EYE_INDEX)
      local rightEyePos = faceData:getUlseeVertexShape(HeadSamplerKit.RIGHT_EYE_INDEX)
      local eyeDist = self:distanceBetween(leftEyePos, rightEyePos)

      if (eyeDist > maxEyeDist) then
        self.activeFaceId = i
        maxEyeDist = eyeDist
        faceCenterPos = faceData:getUlseeVertexShape(HeadSamplerKit.FACE_CENTER_INDEX)
        faceHeight = faceData.vertexFaceRect.height
        relativeRoll = faceData.relativeRoll
      end
    end

    local zoomMat = Matrix.createFromMatrix(Matrix.identity())
    local scale = 2.0 / (maxEyeDist * 6.0)
    local resolution = self.scene:getResolution()
    local ratio = resolution.x / resolution.y

    zoomMat:translate(-faceCenterPos.x, -faceCenterPos.y - 0.05, 0.0)
    zoomMat:postScale(scale, scale / ratio, scale)
    zoomMat:postRotateZ(-relativeRoll / 180.0 * math.pi)
    zoomMat:postScale(1.0, ratio, 1.0)
    self.zoomNode:getMaterial():getParameter("u_worldViewProjectionMatrix"):setMatrix(zoomMat)

    if self.hairSegExtension:getMaskSampler() then
      self.displayNode:setChannel2(self.hairSegExtension:getMaskSampler())
    end
  end
end

function HeadSamplerKit:finalize()
  EngineStatus.instance():decrease(EngineStatusCountType.HAIR_SEGMENTATION)
end

function HeadSamplerKit:getHeadSampler()
  return self.headshotMaskBuffer:getSampler()
end

function HeadSamplerKit:distanceBetween(pos1, pos2)
  local xDistance = (pos1.x - pos2.x)
  local yDistance = (pos1.y - pos2.y)

  return math.sqrt((xDistance * xDistance) + (yDistance * yDistance))
end

function HeadSamplerKit:createSegNode(snapshotNode)
  local seg = KuruSegmentationNode.create()

  seg:setSourceSampler(snapshotNode:getSnapshot())

  return seg
end
