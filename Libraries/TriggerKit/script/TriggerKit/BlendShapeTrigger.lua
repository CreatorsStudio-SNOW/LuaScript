BlendShapeTrigger = {
  TriggerType = {
    SMILE = 1,
    BLINK = 2,
    LEFT_WINK = 3,
    RIGHT_WINK = 4,
  },
  scene = nil,
  startCallBack = nil,
  ingCallBack = nil,
  endCallBack = nil,
  faceDetector = nil,
  maxTrackCount = 1,
  triggerKit = nil,
  prevActivatedSmiledDict = {},
  prevActivatedBlinkedDict = {},
  prevActivatedLeftWinkedDict = {},
  prevActivatedRightWinkedDict = {},
}

function BlendShapeTrigger:new(scene, triggerKit, startCallBack, ingCallBack, endCallBack, maxTrackCount)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance.startCallBack = startCallBack
  newInstance.ingCallBack = ingCallBack
  newInstance.endCallBack = endCallBack
  newInstance.faceDetector = KuruFaceDetectorExtension.cast(KuruEngine.getInstance():getExtension("KuruFaceDetector"))
  newInstance.maxTrackCount = (maxTrackCount == nil) and 5 or maxTrackCount
  newInstance.triggerKit = triggerKit
  newInstance.prevActivatedSmiledDict = {}
  newInstance.prevActivatedBlinkedDict = {}
  newInstance.prevActivatedLeftWinkedDict = {}
  newInstance.prevActivatedRightWinkedDict = {}
  newInstance:init()

  return newInstance
end

function BlendShapeTrigger:init()
  self.scene:activateCountType(EngineStatusCountType.BLEND_SHAPE)
  self.scene:activateCountType(EngineStatusCountType.DISABLE_BEAUTY_OPTIMIZE)
end

function BlendShapeTrigger:frameReady()
  local faceCount = self.faceDetector:getFaceCount()

  if (faceCount <= 0) then
    self:postCallBack(BlendShapeTrigger.TriggerType.SMILE, self.endCallBack, self.prevActivatedSmiledDict)
    self:postCallBack(BlendShapeTrigger.TriggerType.BLINK, self.endCallBack, self.prevActivatedBlinkedDict)
    self:postCallBack(BlendShapeTrigger.TriggerType.LEFT_WINK, self.endCallBack, self.prevActivatedLeftWinkedDict)
    self:postCallBack(BlendShapeTrigger.TriggerType.RIGHT_WINK, self.endCallBack, self.prevActivatedRightWinkedDict)
    self.prevActivatedSmiledDict = {}
    self.prevActivatedBlinkedDict = {}
    self.prevActivatedLeftWinkedDict = {}
    self.prevActivatedRightWinkedDict = {}

    return
  end

  local trackMaxCount = math.min(faceCount, self.maxTrackCount)
  local activatedSmileFaceDict = {}
  local activatedBlinkFaceDict = {}
  local activatedLeftWinkFaceDict = {}
  local activatedRightWinkFaceDict = {}

  for i = 0, trackMaxCount - 1 do
    local faceFeature = KaleFaceFeature.cast(self.faceDetector:getFace(i))
    local faceData = faceFeature:getFaceData()
    local smileLeft = faceData:getBlendShapeCoefficient(FaceDataBlendShapeType.mouthSmile_L)
    local smileRight = faceData:getBlendShapeCoefficient(FaceDataBlendShapeType.mouthSmile_R)

    if (smileLeft > 0.125 and smileRight > 0.125) then
      activatedSmileFaceDict[faceData:getTrackId()] = faceData
    else
      local winkLeft = faceData:getBlendShapeCoefficient(FaceDataBlendShapeType.eyeBlink_L)
      local winkRight = faceData:getBlendShapeCoefficient(FaceDataBlendShapeType.eyeBlink_R)

      if (winkLeft > 0.25 and winkRight > 0.25) then
        activatedBlinkFaceDict[faceData:getTrackId()] = faceData
      else
        if (winkLeft > 0.25 and winkRight < 0.1) then
          activatedLeftWinkFaceDict[faceData:getTrackId()] = faceData
        elseif (winkRight > 0.25 and winkLeft < 0.1) then
          activatedRightWinkFaceDict[faceData:getTrackId()] = faceData
        end
      end
    end
  end

  local smileActivatedFaceDataDict, smileActivatingFaceDataDict, smileDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedSmileFaceDict, self.prevActivatedSmiledDict)
  local blinkActivatedFaceDataDict, blinkActivatingFaceDataDict, blinkDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedBlinkFaceDict, self.prevActivatedBlinkedDict)
  local leftWinkActivatedFaceDataDict, leftWinkActivatingFaceDataDict, leftWinkDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedLeftWinkFaceDict, self.prevActivatedLeftWinkedDict)
  local rightWinkActivatedFaceDataDict, rightWinkActivatingFaceDataDict, rightWinkDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedRightWinkFaceDict, self.prevActivatedRightWinkedDict)

  self.prevActivatedSmiledDict = activatedSmileFaceDict
  self.prevActivatedBlinkedDict = activatedBlinkFaceDict
  self.prevActivatedLeftWinkedDict = activatedLeftWinkFaceDict
  self.prevActivatedRightWinkedDict = activatedRightWinkFaceDict
  self:postCallBacksForType(BlendShapeTrigger.TriggerType.SMILE, smileActivatedFaceDataDict, smileActivatingFaceDataDict, smileDeActivatedFaceDataDict)
  self:postCallBacksForType(BlendShapeTrigger.TriggerType.BLINK, blinkActivatedFaceDataDict, blinkActivatingFaceDataDict, blinkDeActivatedFaceDataDict)
  self:postCallBacksForType(BlendShapeTrigger.TriggerType.LEFT_WINK, leftWinkActivatedFaceDataDict, leftWinkActivatingFaceDataDict, leftWinkDeActivatedFaceDataDict)
  self:postCallBacksForType(BlendShapeTrigger.TriggerType.RIGHT_WINK, rightWinkActivatedFaceDataDict, rightWinkActivatingFaceDataDict, rightWinkDeActivatedFaceDataDict)
end

function BlendShapeTrigger:postCallBacksForType(triggerType, activatedFaceDataDict, activatingFaceDataDict, deActivatedFaceDataDict)
  if (self.startCallBack ~= nil) then
    self:postCallBack(triggerType, self.startCallBack, activatedFaceDataDict)
  end

  if (self.ingCallBack ~= nil) then
    self:postCallBack(triggerType, self.ingCallBack, activatingFaceDataDict)
  end

  if (self.endCallBack ~= nil) then
    self:postCallBack(triggerType, self.endCallBack, deActivatedFaceDataDict)
  end
end

function BlendShapeTrigger:postCallBack(triggerType, callBack, faceDataDict)
   if (TriggerUtil.getDictCount(faceDataDict) > 0) then
     callBack(self.triggerKit, triggerType, faceDataDict)
   end
end
