AE_Rotation = {
  COMPOSITION = nil
}


function AE_Rotation:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

   setmetatable(newObject, self)
   self.__index = self
  newObject.key = "rotation"
  
  return newObject
end

function AE_Rotation:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress

  self.nodes[1]:getMaterial():getParameter("u_postRadian"):setFloat(0.0)
  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toRotation = toKeyframe.value
    local fromRotation = fromKeyframe.value
    rotationScalar =  AE_Layer.calculateStepByProgress(progress, fromRotation, toRotation) / -180.0 * math.pi

    self.nodes[1]:getMaterial():getParameter("u_radian"):setFloat(rotationScalar)
    if self.COMPOSITION.MotionBlur == true then
      self:renderMotionBlur(currentFrame)
    end
  else
    self.nodes[1]:getMaterial():getParameter("u_radian"):setFloat(0.0)
  end
end
function AE_Rotation:renderMotionBlur(currentFrame)
  local posConfigInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame + 1, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = posConfigInfo.fromKeyframe
  local toKeyframe = posConfigInfo.toKeyframe
  local progress = posConfigInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    local toRotation = toKeyframe.value
    local fromRotation = fromKeyframe.value
    posRotationScalar =  AE_Layer.calculateStepByProgress(progress, fromRotation, toRotation) / -180.0 * math.pi

    self.nodes[1]:getMaterial():getParameter("u_postRadian"):setFloat(posRotationScalar)
  end
end
