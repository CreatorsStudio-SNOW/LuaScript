g_kuruTouchExtension = nil

TapTriggerKit = {
  FILE_NAME = "touchIdx.dat",
  sharedInstance
}



function TapTriggerKit.init(isPersistent, totalCount, updateCallback)
  local newInstance = {}

  setmetatable(newInstance, TapTriggerKit)
  TapTriggerKit.__index = TapTriggerKit

  TapTriggerKit.sharedInstance = newInstance

  newInstance.isPersistent = isPersistent
  newInstance.updateCallback = updateCallback

  newInstance.currentTouchIdx = 1
  newInstance.totalCount = totalCount

  g_kuruTouchExtension = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  g_kuruTouchExtension:getTouchDownEvent():addEventHandler(TapTriggerKit_onTouchDown)

  if isPersistent == true then
    local file = io.open(BASE_DIRECTORY .. TapTriggerKit.FILE_NAME, "r")
    if file ~= nil then
      newInstance.currentTouchIdx = tonumber(file:read())
      file:close()
    end
  end

  return newInstance
end

function TapTriggerKit.getCurrentTouchIndex()
  return TapTriggerKit.sharedInstance.currentTouchIdx
end

function TapTriggerKit_onTouchDown(event)
  local touchIdx = TapTriggerKit.sharedInstance.currentTouchIdx
  local totalCount = TapTriggerKit.sharedInstance.totalCount
  touchIdx = (touchIdx % totalCount) + 1

  TapTriggerKit.sharedInstance.currentTouchIdx = touchIdx

  TapTriggerKit.sharedInstance.updateCallback(touchIdx, event)

  if TapTriggerKit.sharedInstance.isPersistent == true then
    local file = io.open(BASE_DIRECTORY .. TapTriggerKit.FILE_NAME, "w")
    if file ~= nil then
      file:write(tostring(touchIdx))
      file:close()
    end
  end
end

function TapTriggerKit.finalize()
  g_kuruTouchExtension:getTouchDownEvent():removeEventHandler(TapTriggerKit_onTouchDown)
end
