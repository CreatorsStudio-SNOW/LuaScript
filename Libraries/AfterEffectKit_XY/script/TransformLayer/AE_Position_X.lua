AE_Position_X = {
  COMPOSITION = nil
}


function AE_Position_X:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

  setmetatable(newObject, self)
  self.__index = self
  newObject.key = "position_x"

  return newObject
end

function AE_Position_X:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress

  self.nodes[1]:getMaterial():getParameter("u_postPosition_x"):setFloat(0.5)

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toPosition = toKeyframe.value
    local fromPosition = fromKeyframe.value

    local x = AE_Layer.calculateStepByProgress(progress, fromPosition or 0.5, toPosition or 0.5)

    positionX = x / COMPOSITION.SIZE.WIDTH

    self.nodes[1]:getMaterial():getParameter("u_position_x"):setFloat(positionX)

    if self.COMPOSITION.MotionBlur == true then
      self:renderMotionBlur(currentFrame)
    end
  else
    self.nodes[1]:getMaterial():getParameter("u_position_x"):setFloat(0.5)
  end
end

function AE_Position_X:renderMotionBlur(currentFrame)
  local posConfigInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame + 1, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = posConfigInfo.fromKeyframe
  local toKeyframe = posConfigInfo.toKeyframe
  local progress = posConfigInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    local toPosition = toKeyframe.value
    local fromPosition = fromKeyframe.value

    local x = AE_Layer.calculateStepByProgress(progress, fromPosition or 0.5, toPosition or 0.5)

    local posPositionX = x / COMPOSITION.SIZE.WIDTH

    self.nodes[1]:getMaterial():getParameter("u_postPosition_x"):setFloat(posPositionX)
  end
end
