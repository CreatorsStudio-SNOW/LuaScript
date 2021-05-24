
HandDataTrigger = {
  TriggerType = {
    OK = 1,
    SCISSOR = 2,
    GOOD = 3,
    PALM = 4,
    PISTOL = 5,
    LOVE = 6,
    HOLD_UP = 7,
    CONGRATULATE = 8,
    FINGER_HEART = 9,
    FINGER_INDEX = 10,
    FIST = 11,
  },
  scene = nil,
  startCallBack = nil,
  ingCallBack = nil,
  endCallBack = nil,
  bodyAction = nil,
  maxTrackCount = 1,
  triggerKit = nil,
  prevActivatedOKDict = {},
  prevActivatedScissorDict = {},
  prevActivatedGoodDict = {},
  prevActivatedPalmDict = {},
  prevActivatedPistolDict = {},
  prevActivatedLoveDict = {},
  prevActivatedHoldUpDict = {},
  prevActivatedCongratulateDict = {},
  prevActivatedFingerHeartDict = {},
  prevActivatedFingerIndexDict = {},
  prevActivatedFistDict = {},
}

function HandDataTrigger:new(scene, triggerKit, startCallBack, ingCallBack, endCallBack, maxTrackCount)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance.startCallBack = startCallBack
  newInstance.ingCallBack = ingCallBack
  newInstance.endCallBack = endCallBack
  newInstance.bodyAction = KuruHumanActionExtension.cast(KuruEngine.getInstance():getExtension("KuruHumanAction"))
  newInstance.maxTrackCount = (maxTrackCount == nil) and 5 or maxTrackCount
  newInstance.triggerKit = triggerKit
  newInstance.prevActivatedOKDict = {}
  newInstance.prevActivatedScissorDict = {}
  newInstance.prevActivatedGoodDict = {}
  newInstance.prevActivatedPalmDict = {}
  newInstance.prevActivatedPistolDict = {}
  newInstance.prevActivatedLoveDict = {}
  newInstance.prevActivatedHoldUpDict = {}
  newInstance.prevActivatedCongratulateDict = {}
  newInstance.prevActivatedFingerHeartDict = {}
  newInstance.prevActivatedFingerIndexDict = {}
  newInstance.prevActivatedFistDict = {}
  newInstance:init()

  return newInstance
end

function HandDataTrigger:init()
  self.scene:getInternalScene():setHandDetection(true)
end

function HandDataTrigger:frameReady()
  local handCount = self.bodyAction:getHandCount()

  if (handCount == 0) then
    self:postCallBack(HandDataTrigger.TriggerType.OK, self.endCallBack, self.prevActivatedOKDict)
    self:postCallBack(HandDataTrigger.TriggerType.SCISSOR, self.endCallBack, self.prevActivatedScissorDict)
    self:postCallBack(HandDataTrigger.TriggerType.GOOD, self.endCallBack, self.prevActivatedGoodDict)
    self:postCallBack(HandDataTrigger.TriggerType.PALM, self.endCallBack, self.prevActivatedPalmDict)
    self:postCallBack(HandDataTrigger.TriggerType.PISTOL, self.endCallBack, self.prevActivatedPistolDict)
    self:postCallBack(HandDataTrigger.TriggerType.LOVE, self.endCallBack, self.prevActivatedLoveDict)
    self:postCallBack(HandDataTrigger.TriggerType.HOLD_UP, self.endCallBack,  self.prevActivatedHoldUpDict)
    self:postCallBack(HandDataTrigger.TriggerType.CONGRATULATE, self.endCallBack, self.prevActivatedCongratulateDict)
    self:postCallBack(HandDataTrigger.TriggerType.FINGER_HEART, self.endCallBack, self.prevActivatedFingerHeartDict)
    self:postCallBack(HandDataTrigger.TriggerType.FINGER_INDEX, self.endCallBack, self.prevActivatedFingerIndexDict)
    self:postCallBack(HandDataTrigger.TriggerType.FIST, self.endCallBack, self.prevActivatedFistDict)
    self.prevActivatedOKDict = {}
    self.prevActivatedScissorDict = {}
    self.prevActivatedGoodDict = {}
    self.prevActivatedPalmDict = {}
    self.prevActivatedPistolDict = {}
    self.prevActivatedLoveDict = {}
    self.prevActivatedHoldUpDict = {}
    self.prevActivatedCongratulateDict = {}
    self.prevActivatedFingerHeartDict = {}
    self.prevActivatedFingerIndexDict = {}
    self.prevActivatedFistDict = {}

    return
  end

  local trackMaxCount =  math.min(handCount, self.maxTrackCount)
  local activatedOKHandDict = {}
  local activatedScissorHandDict = {}
  local activatedGoodHandDict = {}
  local activatedPalmHandDict = {}
  local activatedPistolHandDict = {}
  local activatedLoveHandDict = {}
  local activatedHoldUpHandDict = {}
  local activatedCongratulateHandDict = {}
  local activatedFingerHeartHandDict = {}
  local activatedFingerIndexHandDict = {}
  local activatedFistHandDict = {}

  for i = 0, trackMaxCount - 1 do
    local handData = self.bodyAction:getHandData(i)
    local isOK = handData:isOK()
    local isScissor = handData:isScissor()
    local isGood = handData:isGood()
    local isPalm = handData:isPalm()
    local isPistol = handData:isPistol()
    local isLove = handData:isLove()
    local isHoldUp = handData:isHoldUp()
    local isCongratulate = handData:isCongratulate()
    local isFingerHeart = handData:isFingerHeart()
    local isFingerIndex = handData:isFingerIndex()
    local isFist = handData:isFist()

    if (isOK) then
      activatedOKHandDict[handData:getTrackId()] = handData
    elseif (isScissor) then
      activatedScissorHandDict[handData:getTrackId()] = handData
    elseif (isGood) then
      activatedGoodHandDict[handData:getTrackId()] = handData
    elseif (isPalm) then
      activatedPalmHandDict[handData:getTrackId()] = handData
    elseif (isPistol) then
      activatedPistolHandDict[handData:getTrackId()] = handData
    elseif (isLove) then
      activatedLoveHandDict[handData:getTrackId()] = handData
    elseif (isHoldUp) then
      activatedHoldUpHandDict[handData:getTrackId()] = handData
    elseif (isCongratulate) then
      activatedCongratulateHandDict[handData:getTrackId()] = handData
    elseif (isFingerHeart) then
      activatedFingerHeartHandDict[handData:getTrackId()] = handData
    elseif (isFingerIndex) then
      activatedFingerIndexHandDict[handData:getTrackId()] = handData
    elseif (isFist) then
      activatedFistHandDict[handData:getTrackId()] = handData
    end
  end

  local okActivatedHandDataDict, okActivatingHandDataDict, okDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedOKHandDict, self.prevActivatedOKDict)
  local scissorActivatedHandDataDict, scissorActivatingHandDataDict, scissorDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedScissorHandDict, self.prevActivatedScissorDict)
  local goodActivatedHandDataDict, goodActivatingHandDataDict, goodDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedGoodHandDict, self.prevActivatedGoodDict)
  local palmActivatedHandDataDict, palmActivatingHandDataDict, palmDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedPalmHandDict, self.prevActivatedPalmDict)
  local pistolActivatedHandDataDict, pistolActivatingHandDataDict, pistolDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedPistolHandDict, self.prevActivatedPistolDict)
  local loveActivatedHandDataDict, loveActivatingHandDataDict, loveDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedLoveHandDict, self.prevActivatedLoveDict)
  local holdUpActivatedHandDataDict, holdUpActivatingHandDataDict, holdUpDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedHoldUpHandDict, self.prevActivatedHoldUpDict)
  local congratulateActivatedHandDataDict, congratulateActivatingHandDataDict, congratulateDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedCongratulateHandDict, self.prevActivatedCongratulateDict)
  local fingerHeartActivatedHandDataDict, fingerHeartActivatingHandDataDict, fingerHeartDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedFingerHeartHandDict, self.prevActivatedFingerHeartDict)
  local fingerIndexActivatedHandDataDict, fingerIndexActivatingHandDataDict, fingerIndexDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedFingerIndexHandDict, self.prevActivatedFingerIndexDict)
  local fistActivatedHandDataDict, fistActivatingHandDataDict, fistDeActivatedHandDataDict = TriggerUtil.getDataDictByUpdated(activatedFistHandDict, self.prevActivatedFistDict)

  self.prevActivatedOKDict = activatedOKHandDict
  self.prevActivatedScissorDict = activatedScissorHandDict
  self.prevActivatedGoodDict = activatedGoodHandDict
  self.prevActivatedPalmDict = activatedPalmHandDict
  self.prevActivatedPistolDict = activatedPistolHandDict
  self.prevActivatedLoveDict = activatedLoveHandDict
  self.prevActivatedHoldUpDict = activatedHoldUpHandDict
  self.prevActivatedCongratulateDict = activatedCongratulateHandDict
  self.prevActivatedFingerHeartDict = activatedFingerHeartHandDict
  self.prevActivatedFingerIndexDict = activatedFingerIndexHandDict
  self.prevActivatedFistDict = activatedFistHandDict
  self:postCallBacksForType(HandDataTrigger.TriggerType.OK, okActivatedHandDataDict, okActivatingHandDataDict, okDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.SCISSOR, scissorActivatedHandDataDict, scissorActivatingHandDataDict, scissorDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.GOOD, goodActivatedHandDataDict, goodActivatingHandDataDict, goodDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.PALM, palmActivatedHandDataDict, palmActivatingHandDataDict, palmDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.PISTOL, pistolActivatedHandDataDict, pistolActivatingHandDataDict, pistolDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.LOVE, loveActivatedHandDataDict, loveActivatingHandDataDict, loveDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.HOLD_UP, holdUpActivatedHandDataDict, holdUpActivatingHandDataDict, holdUpDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.CONGRATULATE, congratulateActivatedHandDataDict, congratulateActivatingHandDataDict, congratulateDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.FINGER_HEART, fingerHeartActivatedHandDataDict, fingerHeartActivatingHandDataDict, fingerHeartDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.FINGER_INDEX, fingerIndexActivatedHandDataDict, fingerIndexActivatingHandDataDict, fingerIndexDeActivatedHandDataDict)
  self:postCallBacksForType(HandDataTrigger.TriggerType.FIST, fistActivatedHandDataDict, fistActivatingHandDataDict, fistDeActivatedHandDataDict)
end

function HandDataTrigger:postCallBacksForType(triggerType, activatedHandDataDict, activatingHandDataDict, deActivatedHandDataDict)
  if (self.startCallBack ~= nil) then
    self:postCallBack(triggerType, self.startCallBack, activatedHandDataDict)
  end

  if (self.ingCallBack ~= nil) then
    self:postCallBack(triggerType, self.ingCallBack, activatingHandDataDict)
  end

  if (self.endCallBack ~= nil) then
    self:postCallBack(triggerType, self.endCallBack, deActivatedHandDataDict)
  end
end

function HandDataTrigger:postCallBack(triggerType, callBack, handDataDict)
  if (TriggerUtil.getDictCount(handDataDict) > 0) then
     callBack(self.triggerKit, triggerType, handDataDict)
   end
end
