FaceDataTrigger = {
  TriggerType = {
    MOUTH_AH = 1,
    HEAD_PITCH = 2,
    BROW_JUMP = 3,
    KISS = 4
  },
  scene = nil,
  startCallBack = nil,
  ingCallBack = nil,
  endCallBack = nil,
  faceDetector = nil,
  maxTrackCount = 1,
  triggerKit = nil,
  prevActivatedMouthAhDict = {},
  prevActivatedHeadPitchDict = {},
  prevActivatedBrowJumpDict = {},
  prevActivatedKissDict = {},
}

function FaceDataTrigger:new(scene, triggerKit, startCallBack, ingCallBack, endCallBack, maxTrackCount)
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
  newInstance.prevActivatedMouthAhDict = {}
  newInstance.prevActivatedHeadPitchDict = {}
  newInstance.prevActivatedBrowJumpDict = {}
  newInstance.prevActivatedKissDict = {}
  scene:activateCountType(EngineStatusCountType.MOUTH_AH)
  scene:activateCountType(EngineStatusCountType.HEAD_PITCH)
  scene:activateCountType(EngineStatusCountType.BROW_JUMP)

  return newInstance
end

function FaceDataTrigger:frameReady()
  local faceCount = self.faceDetector:getFaceCount()

  if (faceCount <= 0) then
    self:postCallBack(FaceDataTrigger.TriggerType.MOUTH_AH, self.endCallBack, self.prevActivatedMouthAhDict)
    self:postCallBack(FaceDataTrigger.TriggerType.HEAD_PITCH, self.endCallBack, self.prevActivatedHeadPitchDict)
    self:postCallBack(FaceDataTrigger.TriggerType.BROW_JUMP, self.endCallBack, self.prevActivatedBrowJumpDict)
    self:postCallBack(FaceDataTrigger.TriggerType.KISS, self.endCallBack, self.prevActivatedKissDict)
    self.prevActivatedMouthAhDict = {}
    self.prevActivatedHeadPitchDict = {}
    self.prevActivatedBrowJumpDict = {}
    self.prevActivatedKissDict = {}

    return
  end

  local trackMaxCount =  math.min(faceCount, self.maxTrackCount)
  local activatedMouthAhFaceDict = {}
  local activatedHeadPitchFaceDict = {}
  local activatedBrowJumpFaceDict = {}
  local activatedKissFaceDict = {}

  for i = 0, trackMaxCount - 1 do
    local faceFeature = KaleFaceFeature.cast(self.faceDetector:getFace(i))
    local faceData = faceFeature:getFaceData()
    local isMouthOpen = faceData:isActionActivated(FaceDataActionType.MOUTH_AH)
    local isHeadUp = faceData:isActionActivated(FaceDataActionType.HEAD_PITCH)
    local isBrowJump = faceData:isActionActivated(FaceDataActionType.BROW_JUMP)
    local isKissed = faceData:isActionActivated(FaceDataActionType.KISS)

    if (isMouthOpen) then
      activatedMouthAhFaceDict[faceData:getTrackId()] = faceData
    elseif (isHeadUp) then
      activatedHeadPitchFaceDict[faceData:getTrackId()] = faceData
    elseif (isBrowJump) then
      activatedBrowJumpFaceDict[faceData:getTrackId()] = faceData
    elseif (isKissed) then
      activatedKissFaceDict[faceData:getTrackId()] = faceData
    end
  end

  local mouthAhActivatedFaceDataDict, mouthAhActivatingFaceDataDict, mouthAhDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedMouthAhFaceDict, self.prevActivatedMouthAhDict)
  local headPitchActivatedFaceDataDict, headPitchActivatingFaceDataDict, headPitchDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedHeadPitchFaceDict, self.prevActivatedHeadPitchDict)
  local browJumpActivatedFaceDataDict, browJumpActivatingFaceDataDict, browJumpDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedBrowJumpFaceDict, self.prevActivatedBrowJumpDict)
  local kissActivatedFaceDataDict, kissActivatingFaceDataDict, kissDeActivatedFaceDataDict = TriggerUtil.getDataDictByUpdated(activatedKissFaceDict, self.prevActivatedKissDict)

  self.prevActivatedMouthAhDict = activatedMouthAhFaceDict
  self.prevActivatedHeadPitchDict = activatedHeadPitchFaceDict
  self.prevActivatedBrowJumpDict = activatedBrowJumpFaceDict
  self.prevActivatedKissDict = activatedKissFaceDict
  self:postCallBacksForType(FaceDataTrigger.TriggerType.MOUTH_AH, mouthAhActivatedFaceDataDict, mouthAhActivatingFaceDataDict, mouthAhDeActivatedFaceDataDict)
  self:postCallBacksForType(FaceDataTrigger.TriggerType.HEAD_PITCH, headPitchActivatedFaceDataDict, headPitchActivatingFaceDataDict, headPitchDeActivatedFaceDataDict)
  self:postCallBacksForType(FaceDataTrigger.TriggerType.BROW_JUMP, browJumpActivatedFaceDataDict, browJumpActivatingFaceDataDict, browJumpDeActivatedFaceDataDict)
  self:postCallBacksForType(FaceDataTrigger.TriggerType.KISS, kissActivatedFaceDataDict, kissActivatingFaceDataDict, kissDeActivatedFaceDataDict)
end

function FaceDataTrigger:postCallBacksForType(triggerType, activatedFaceDataDict, activatingFaceDataDict, deActivatedFaceDataDict)
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

function FaceDataTrigger:postCallBack(triggerType, callBack, faceDataDict)
  if (TriggerUtil.getDictCount(faceDataDict) > 0) then
     callBack(self.triggerKit, triggerType, faceDataDict)
   end
end
