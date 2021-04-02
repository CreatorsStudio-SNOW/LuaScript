AE_Position = {
  COMPOSITION = nil
}

function AE_Position:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

  setmetatable(newObject, self)
  self.__index = self
  newObject.key = "position"

  return newObject
end

function AE_Position:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress

  self.nodes[1]:getMaterial():getParameter("u_postPosition_x"):setFloat(0.5)
  self.nodes[1]:getMaterial():getParameter("u_postPosition_y"):setFloat(0.5)

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toPosition = toKeyframe.value
    local fromPosition = fromKeyframe.value

    local x = AE_Layer.calculateStepByProgress(progress, fromPosition['x'] or 0.5, toPosition['x'] or 0.5)
    local y = AE_Layer.calculateStepByProgress(progress, fromPosition['y'] or 0.5, toPosition['y'] or 0.5)

    positionVector = Vector2.create(x / COMPOSITION.SIZE.WIDTH, (COMPOSITION.SIZE.HEIGHT - y) / COMPOSITION.SIZE.HEIGHT)

    self.nodes[1]:getMaterial():getParameter("u_position_x"):setFloat(positionVector.x)
    self.nodes[1]:getMaterial():getParameter("u_position_y"):setFloat(positionVector.y)

    if self.COMPOSITION.MotionBlur == true then
      self:renderMotionBlur(currentFrame)
    end
  else
    self.nodes[1]:getMaterial():getParameter("u_position_x"):setFloat(0.5)
    self.nodes[1]:getMaterial():getParameter("u_position_y"):setFloat(0.5)
  end
end

function AE_Position:renderMotionBlur(currentFrame)
  local posConfigInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame + 1, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = posConfigInfo.fromKeyframe
  local toKeyframe = posConfigInfo.toKeyframe
  local progress = posConfigInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    local toPosition = toKeyframe.value
    local fromPosition = fromKeyframe.value

    local x = AE_Layer.calculateStepByProgress(progress, (fromPosition['x'] or 0.5), (toPosition['x'] or 0.5))
    local y = AE_Layer.calculateStepByProgress(progress, (fromPosition['y'] or 0.5), (toPosition['y'] or 0.5))

    local posPositionVector = Vector2.create(x / COMPOSITION.SIZE.WIDTH, (COMPOSITION.SIZE.HEIGHT - y) / COMPOSITION.SIZE.HEIGHT)

    self.nodes[1]:getMaterial():getParameter("u_postPosition_x"):setFloat(posPositionVector.x)
    self.nodes[1]:getMaterial():getParameter("u_postPosition_y"):setFloat(posPositionVector.y)
  end
end
