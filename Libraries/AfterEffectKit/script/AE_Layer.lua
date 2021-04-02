AE_Layer = {
  keyframes = {},
  nodes = {},
  key = "",
  fromKeyframe = nil,
  toKeyframe = nil
}

function AE_Layer:create(keyframes)
  local newObject = {}

  setmetatable(newObject, self)
  self.__index = self

  newObject.keyframes = keyframes
  newObject.fromKeyframe = nil
  newObject.toKeyframe = nil
  newObject.key = ""
  newObject.nodes = {}

  return newObject
end


function AE_Layer.calculateStepByProgress(progress, startValue, endValue)
  return progress * endValue + (1.0 - progress) * startValue
end

function math.clamp(x, min, max)
  return math.min(math.max(x, min), max)
end

function AE_Layer:frameReady(currentFrame)
  print("frameReady AE_Layer")
end

function AE_Layer.getCurrentConfigInfo(keyframes, currentFrame, fromKeyframe, toKeyframe)
  local result = {
    fromKeyframe = fromKeyframe,
    toKeyframe = toKeyframe,
    progress = 0
  }
  if result.toKeyframe ~= nil and result.toKeyframe.frame >= currentFrame and result.fromKeyframe ~= nil and result.fromKeyframe.frame <= currentFrame then
    result.progress = AE_Layer.buildStrength(result.fromKeyframe, result.toKeyframe, currentFrame)
    return result
  else
    result.fromKeyframe = nil
    result.toKeyframe = nil
  end

  for idx, keyframe in ipairs(keyframes) do
    if keyframe.frame <= currentFrame then
      result.fromKeyframe = keyframes[idx]
      result.toKeyframe = keyframes[idx + 1]

      if result.toKeyframe == nil then
        result.toKeyframe = result.fromKeyframe
      end
    else
      if idx == 1 then
        result.fromKeyframe = keyframes[idx]
        result.toKeyframe = result.fromKeyframe
      end

      break
    end
  end

  if result.toKeyframe == nil and #keyframes then
    result.toKeyframe = keyframes[#keyframes]
    result.fromKeyframe = result.toKeyframe
  end

  -- result.progress = AE_Layer.buildStrength(result.fromKeyframe, result.toKeyframe, currentFrame)
  return result
end

function AE_Layer:getLayerConfigInfo(currentFrame)
  local result = {}

  return result
end

function AE_Layer.buildStrength(fromKeyframe, toKeyframe, frame)
  local easingType = toKeyframe.easingType or EasingType.LINEAR

  local progress = 0
  local startFrame = fromKeyframe.frame
  local endFrame = toKeyframe.frame

  progress = (frame - startFrame) / (endFrame - startFrame)
  if endFrame == startFrame then
    progress = 1.0
  end
  progress = math.clamp(progress, 0, 1)
  local easingFunc = getEasingFunction(easingType)

  return easingFunc(progress, 0, 1, 1)
end
