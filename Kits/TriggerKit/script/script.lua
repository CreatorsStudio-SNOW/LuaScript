
require "TriggerKit/TriggerKit.lua"

function initialize(scene)
  -- Callback을 순서대로 "트리거 발동, 트리거 발동 후 지속, 트리거 끝남"을 의미
  ---- ex) TriggerType.SMILE
  ------ smileCallBack : 처음 웃을때 한번 호출
  ------ ingSmileCallBack : 계속 웃고 있으면 매 프레임마다 계속 호출
  ------ endSmileCallBack : 웃다가 안웃으면 한번 호출

  -- 자신이 쓰고 싶은 트리거 타입과 CallBack만 지정해서 사용하면 된다. 아래는 테스트 용이라 모든 타입, 모든 CallBack을 임의로 등록한 것임.

  -- 쓰고 싶은 트리거 타입마다 Admin에서 모델 타입을 등록해줘야 하는 경우가 있다.
  ---- VISION_FACE 모델 필요타입
  ------ SMILE, BLINK, LEFT_WINK, RIGHT_WINK
  ---- SENSE_HAND_2D 모델 필요타입
  ------ HAND_OK, HAND_SCISSOR, HAND_GOOD, HAND_PALM, HAND_PISTOL, HAND_LOVE, HAND_HOLD_UP, HAND_CONGRATULATE, HAND_HEART, HAND_INDEX, HAND_FIST

  local triggerItems = {
    TriggerItem:new(TriggerType.SMILE, smileCallBack, ingSmileCallBack, endSmileCallBack),
    TriggerItem:new(TriggerType.BLINK, blinkCallBack, ingBlinkCallBack, endBlinkCallBack),
    TriggerItem:new(TriggerType.LEFT_WINK, leftWinkCallBack, ingLeftWinkCallBack, endLeftWinkCallBack),
    TriggerItem:new(TriggerType.RIGHT_WINK, rightWinkCallBack, ingRightWinkCallBack, endRightWinkCallBack),
    TriggerItem:new(TriggerType.MOUTH_AH, mouthAhCallBack, ingMouthAhCallBack, endMouthAhCallBack),
    TriggerItem:new(TriggerType.HEAD_PITCH, headPitchCallBack, ingHeadPitchCallBack, endHeadPitchCallBack),
    TriggerItem:new(TriggerType.BROW_JUMP, browJumpCallBack, ingBrowJumpCallBack, endBrowJumpCallBack),
    TriggerItem:new(TriggerType.KISS, kissCallBack, ingKissCallBack, endKissCallBack),
    TriggerItem:new(TriggerType.HAND_OK, handOKCallBack, ingHandOKCallBack, endHandOKCallBack),
    TriggerItem:new(TriggerType.HAND_SCISSOR, handScissorCallBack, ingHandScissorCallBack, endHandScissorCallBack),
    TriggerItem:new(TriggerType.HAND_GOOD, handGoodCallBack, ingHandGoodCallBack, endHandGoodCallBack),
    TriggerItem:new(TriggerType.HAND_PALM, handPalmCallBack, ingHandPalmCallBack, endHandPalmCallBack),
    TriggerItem:new(TriggerType.HAND_PISTOL, handPistolCallBack, ingHandPistolCallBack, endHandPistolCallBack),
    TriggerItem:new(TriggerType.HAND_LOVE, handLoveCallBack, ingHandLoveCallBack, endHandLoveCallBack),
    TriggerItem:new(TriggerType.HAND_HOLD_UP, handHoldUpCallBack, ingHandHoldUpCallBack, endHandHoldUpCallBack),
    TriggerItem:new(TriggerType.HAND_CONGRATULATE, handCongratulateCallBack, ingHandCongratulateCallBack, endHandCongratulateCallBack),
    TriggerItem:new(TriggerType.HAND_HEART, handHeartCallBack, ingHandHeartCallBack, endHandHeartCallBack),
    TriggerItem:new(TriggerType.HAND_INDEX, handIndexCallBack, ingHandIndexCallBack, endHandIndexCallBack),
    TriggerItem:new(TriggerType.HAND_FIST, handFistCallBack, ingHandFistCallBack, endHandFistCallBack),
  }

  g_triggerKit = TriggerKit:new(scene, triggerItems)
end

function frameReady(scene, elapsedTime)
  g_triggerKit:frameReady()
end

function reset(scene)
end

function finalize(scene)
end

function smileCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] smile : " .. resultString)
end

function ingSmileCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing smile : " .. resultString)
end

function endSmileCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end smile : " .. resultString)
end

function blinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] blink : " .. resultString)
end

function ingBlinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing blink : " .. resultString)
end

function endBlinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end blink : " .. resultString)
end

function leftWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] left wink : " .. resultString)
end

function ingLeftWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing left wink : " .. resultString)
end

function endLeftWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end left wink : " .. resultString)
end

function rightWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] right wink : " .. resultString)
end

function ingRightWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing right wink : " .. resultString)
end

function endRightWinkCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end right wink : " .. resultString)
end

function mouthAhCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] mouth Ah : " .. resultString)
end

function ingMouthAhCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing mouth Ah : " .. resultString)
end

function endMouthAhCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end mouth Ah : " .. resultString)
end

function headPitchCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] head Pitch : " .. resultString)
end

function ingHeadPitchCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing head Pitch : " .. resultString)
end

function endHeadPitchCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end head Pitch : " .. resultString)
end

function browJumpCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] brow Jump : " .. resultString)
end

function ingBrowJumpCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing brow Jump : " .. resultString)
end

function endBrowJumpCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end brow Jump : " .. resultString)
end

function kissCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] kiss : " .. resultString)
end

function ingKissCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] ing kiss : " .. resultString)
end

function endKissCallBack(faceDataDict)
  local resultString = ""

  for key in pairs(faceDataDict) do
      if faceDataDict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] end kiss : " .. resultString)
end

function handOKCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand ok : " .. string)
end

function ingHandOKCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand ok : " .. string)
end

function endHandOKCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand ok : " .. string)
end

function handScissorCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand scissor : " .. string)
end

function ingHandScissorCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand scissor : " .. string)
end

function endHandScissorCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand scissor : " .. string)
end

function handGoodCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand good : " .. string)
end

function ingHandGoodCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand good : " .. string)
end

function endHandGoodCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand good : " .. string)
end

function handPalmCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand palm : " .. string)
end

function ingHandPalmCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand palm : " .. string)
end

function endHandPalmCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand palm : " .. string)
end

function handPistolCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand pistol : " .. string)
end

function ingHandPistolCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand pistol : " .. string)
end

function endHandPistolCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand pistol : " .. string)
end

function handLoveCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand love : " .. string)
end

function ingHandLoveCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand love : " .. string)
end

function endHandLoveCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand love : " .. string)
end

function handHoldUpCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand hold up : " .. string)
end

function ingHandHoldUpCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand hold up : " .. string)
end

function endHandHoldUpCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand hold up : " .. string)
end

function handCongratulateCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand congratulate : " .. string)
end

function ingHandCongratulateCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand congratulate : " .. string)
end

function endHandCongratulateCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand congratulate : " .. string)
end

function handHeartCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand heart : " .. string)
end

function ingHandHeartCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand heart : " .. string)
end

function endHandHeartCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand heart : " .. string)
end

function handIndexCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand index : " .. string)
end

function ingHandIndexCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand index : " .. string)
end

function endHandIndexCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand index : " .. string)
end

function handFistCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] hand fist : " .. string)
end

function ingHandFistCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] ing hand fist : " .. string)
end

function endHandFistCallBack(handDataDict)
  local string = ""

  for key in pairs(handDataDict) do
      if handDataDict[key] ~= nil then
        string = string .. ", " .. key
      end
  end

  print("[script] end hand fist : " .. string)
end
