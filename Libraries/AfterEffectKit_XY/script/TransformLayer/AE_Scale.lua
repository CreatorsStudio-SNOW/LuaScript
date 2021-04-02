AE_Scale = {
  COMPOSITION = nil
}


function AE_Scale:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

   setmetatable(newObject, self)
   self.__index = self
  newObject.key = "scale"
  
  return newObject
end

function AE_Scale:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress

  self.nodes[1]:getMaterial():getParameter("u_postScale"):setFloat(1.0)
  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toScale = toKeyframe.value
    local fromScale = fromKeyframe.value
    scaleScalar = AE_Layer.calculateStepByProgress(progress, fromScale, toScale)

    self.nodes[1]:getMaterial():getParameter("u_scale"):setFloat(scaleScalar / 100.0)

    if self.COMPOSITION.MotionBlur == true then
      self:renderMotionBlur(currentFrame)
    end
  else
    self.nodes[1]:getMaterial():getParameter("u_scale"):setFloat(1.0)
  end
end
function AE_Scale:renderMotionBlur(currentFrame)
  local posConfigInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame + 1, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = posConfigInfo.fromKeyframe
  local toKeyframe = posConfigInfo.toKeyframe
  local progress = posConfigInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    local toScale = toKeyframe.value
    local fromScale = fromKeyframe.value
    local posScaleScalar = AE_Layer.calculateStepByProgress(progress, fromScale, toScale)
    self.nodes[1]:getMaterial():getParameter("u_postScale"):setFloat(posScaleScalar / 100.0)
  end
end
