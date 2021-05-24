require "TriggerKit/TriggerUtil.lua"
require "TriggerKit/FaceDataTrigger.lua"
require "TriggerKit/BlendShapeTrigger.lua"
require "TriggerKit/HandDataTrigger.lua"

TriggerType = {
  SMILE = 1, -- VISION_FACE 모델 필요
  BLINK = 2, -- VISION_FACE 모델 필요
  LEFT_WINK = 3, -- VISION_FACE 모델 필요
  RIGHT_WINK = 4, -- VISION_FACE 모델 필요
  MOUTH_AH = 5,
  HEAD_PITCH = 6,
  BROW_JUMP = 7,
  KISS = 8,
  HAND_OK = 9, -- SENSE_HAND_2D 모델 필요
  HAND_SCISSOR = 10, -- SENSE_HAND_2D 모델 필요
  HAND_GOOD = 11, -- SENSE_HAND_2D 모델 필요
  HAND_PALM = 12, -- SENSE_HAND_2D 모델 필요
  HAND_PISTOL = 13, -- SENSE_HAND_2D 모델 필요
  HAND_LOVE = 14, -- SENSE_HAND_2D 모델 필요
  HAND_HOLD_UP = 15, -- SENSE_HAND_2D 모델 필요
  HAND_CONGRATULATE = 16, -- SENSE_HAND_2D 모델 필요
  HAND_HEART = 17, -- SENSE_HAND_2D 모델 필요
  HAND_INDEX = 18, -- SENSE_HAND_2D 모델 필요
  HAND_FIST = 19, -- SENSE_HAND_2D 모델 필요
}

TriggerItem = {
  triggerType = nil,
  startCallBack = nil,
  ingCallBack = nil,
  endCallBack = nil,
}

function TriggerItem:new(triggerType, startCallBack, ingCallBack, endCallBack)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.triggerType = triggerType
  newInstance.startCallBack = startCallBack
  newInstance.ingCallBack = ingCallBack
  newInstance.endCallBack = endCallBack

  return newInstance
end

function TriggerItem:isFaceDataItem()
  local triggerType = self.triggerType
  local result = false

  if (triggerType >= TriggerType.MOUTH_AH and triggerType <= TriggerType.KISS) then
    result = true
  end

  return result
end

function TriggerItem:isBlendShapeItem()
  local triggerType = self.triggerType
  local result = false

  if (triggerType >= TriggerType.SMILE and triggerType <= TriggerType.RIGHT_WINK) then
    result = true
  end

  return result
end

function TriggerItem:isHandDataItem()
  local triggerType = self.triggerType
  local result = false

  if (triggerType >= TriggerType.HAND_OK and triggerType <= TriggerType.HAND_FIST) then
    result = true
  end

  return result
end

function TriggerItem:postStartCallBack(triggerType, dataDict)
  self:postCallBack(self.startCallBack, triggerType, dataDict)
end

function TriggerItem:postIngCallBack(triggerType, dataDict)
  self:postCallBack(self.ingCallBack, triggerType, dataDict)
end

function TriggerItem:postEndCallBack(triggerType, dataDict)
  self:postCallBack(self.endCallBack, triggerType, dataDict)
end

function TriggerItem:postCallBack(callback, triggerType, dataDict)
  if (self.triggerType == triggerType and callback ~= nil) then
    callback(dataDict)
  end
end

TriggerKit = {
  scene = nil,
  callBack = nil,
  faceDetector = nil,
  maxTrackCount = 1,
  faceDataTrigger = nil,
  blendShapeTrigger = nil
}

function TriggerKit:new(scene, triggerItems, maxTrackCount)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance.triggerItems = triggerItems
  newInstance.maxTrackCount = (maxTrackCount == nil) and 5 or maxTrackCount
  newInstance.faceDataTrigger = nil
  newInstance.blendShapeTrigger = nil
  newInstance.handDataTrigger = nil
  newInstance:init()

  return newInstance
end

function TriggerKit:frameReady()
  if (self.faceDataTrigger ~= nil) then
    self.faceDataTrigger:frameReady()
  end

  if (self.blendShapeTrigger ~= nil) then
    self.blendShapeTrigger:frameReady()
  end

  if (self.handDataTrigger ~= nil) then
    self.handDataTrigger:frameReady()
  end
end

function TriggerKit:init()
  local hasFaceDataItem = false
  local hasBlendShapeItem = false
  local hasHandDataItem = false

  for i = 1, #self.triggerItems do
    local triggerItem = self.triggerItems[i]

    if (triggerItem:isFaceDataItem()) then
      hasFaceDataItem = true
    end

    if (triggerItem:isBlendShapeItem()) then
      hasBlendShapeItem = true
    end

    if (triggerItem:isHandDataItem()) then
      hasHandDataItem = true
    end
  end

  if (hasFaceDataItem) then
    self.faceDataTrigger = FaceDataTrigger:new(self.scene, self, TriggerKit.faceDataTriggerStartCallBack, TriggerKit.faceDataTriggerIngCallBack, TriggerKit.faceDataTriggerEndCallBack, self.maxTrackCount)
  end

  if (hasBlendShapeItem) then
    self.blendShapeTrigger = BlendShapeTrigger:new(self.scene, self, TriggerKit.blendShapeTriggerStartCallBack, TriggerKit.blendShapeTriggerIngCallBack, TriggerKit.blendShapeTriggerEndCallBack, self.maxTrackCount)
  end

  if (hasHandDataItem) then
    self.handDataTrigger = HandDataTrigger:new(self.scene, self, TriggerKit.handDataTriggerStartCallBack, TriggerKit.handDataTriggerIngCallBack, TriggerKit.handDataTriggerEndCallBack, self.maxTrackCount)
  end
end

function TriggerKit.faceDataTriggerStartCallBack(self, faceDataTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromFaceDataTriggerType(faceDataTriggerType)

  self:postStartCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.faceDataTriggerIngCallBack(self, faceDataTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromFaceDataTriggerType(faceDataTriggerType)

  self:postIngCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.faceDataTriggerEndCallBack(self, faceDataTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromFaceDataTriggerType(faceDataTriggerType)

  self:postEndCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.blendShapeTriggerStartCallBack(self, blendShapeTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromBlendShapeTriggerType(blendShapeTriggerType)

  self:postStartCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.blendShapeTriggerIngCallBack(self, blendShapeTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromBlendShapeTriggerType(blendShapeTriggerType)

  self:postIngCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.blendShapeTriggerEndCallBack(self, blendShapeTriggerType, faceDataDict)
  local triggerType = self:getTriggerTypeFromBlendShapeTriggerType(blendShapeTriggerType)

  self:postEndCallBackForTriggerType(triggerType, faceDataDict)
end

function TriggerKit.handDataTriggerStartCallBack(self, handDataTriggerType, handDataDict)
  local triggerType = self:getTriggerTypeFromHandDataTriggerType(handDataTriggerType)

  self:postStartCallBackForTriggerType(triggerType, handDataDict)
end

function TriggerKit.handDataTriggerIngCallBack(self, handDataTriggerType, handDataDict)
  local triggerType = self:getTriggerTypeFromHandDataTriggerType(handDataTriggerType)

  self:postIngCallBackForTriggerType(triggerType, handDataDict)
end

function TriggerKit.handDataTriggerEndCallBack(self, handDataTriggerType, handDataDict)
  local triggerType = self:getTriggerTypeFromHandDataTriggerType(handDataTriggerType)

  self:postEndCallBackForTriggerType(triggerType, handDataDict)
end

function TriggerKit:postStartCallBackForTriggerType(triggerType, dataDict)
  for i = 1, #self.triggerItems do
    local triggerItem = self.triggerItems[i]

    triggerItem:postStartCallBack(triggerType, dataDict)
  end
end

function TriggerKit:postIngCallBackForTriggerType(triggerType, dataDict)
  for i = 1, #self.triggerItems do
    local triggerItem = self.triggerItems[i]

    triggerItem:postIngCallBack(triggerType, dataDict)
  end
end

function TriggerKit:postEndCallBackForTriggerType(triggerType, dataDict)
  for i = 1, #self.triggerItems do
    local triggerItem = self.triggerItems[i]

    triggerItem:postEndCallBack(triggerType, dataDict)
  end
end

function TriggerKit:getTriggerTypeFromFaceDataTriggerType(faceDataTriggerType)
  if (faceDataTriggerType == FaceDataTrigger.TriggerType.MOUTH_AH) then
    return TriggerType.MOUTH_AH
  elseif (faceDataTriggerType == FaceDataTrigger.TriggerType.HEAD_PITCH) then
    return TriggerType.HEAD_PITCH
  elseif (faceDataTriggerType == FaceDataTrigger.TriggerType.BROW_JUMP) then
    return TriggerType.BROW_JUMP
  elseif (faceDataTriggerType == FaceDataTrigger.TriggerType.KISS) then
    return TriggerType.KISS
  end

  return nil
end

function TriggerKit:getTriggerTypeFromBlendShapeTriggerType(blendShapeTriggerType)
  if (blendShapeTriggerType == BlendShapeTrigger.TriggerType.SMILE) then
    return TriggerType.SMILE
  elseif (blendShapeTriggerType == BlendShapeTrigger.TriggerType.BLINK) then
    return TriggerType.BLINK
  elseif (blendShapeTriggerType == BlendShapeTrigger.TriggerType.LEFT_WINK) then
    return TriggerType.LEFT_WINK
  elseif (blendShapeTriggerType == BlendShapeTrigger.TriggerType.RIGHT_WINK) then
    return TriggerType.RIGHT_WINK
  end

  return nil
end

function TriggerKit:getTriggerTypeFromHandDataTriggerType(handDataTriggerType)
  if (handDataTriggerType == HandDataTrigger.TriggerType.OK) then
    return TriggerType.HAND_OK
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.SCISSOR) then
    return TriggerType.HAND_SCISSOR
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.GOOD) then
    return TriggerType.HAND_GOOD
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.PALM) then
    return TriggerType.HAND_PALM
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.PISTOL) then
    return TriggerType.HAND_PISTOL
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.LOVE) then
    return TriggerType.HAND_LOVE
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.HOLD_UP) then
    return TriggerType.HAND_HOLD_UP
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.CONGRATULATE) then
    return TriggerType.HAND_CONGRATULATE
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.FINGER_HEART) then
    return TriggerType.HAND_HEART
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.FINGER_INDEX) then
    return TriggerType.HAND_INDEX
  elseif (handDataTriggerType == HandDataTrigger.TriggerType.FIST) then
    return TriggerType.HAND_FIST
  end

  return nil
end
