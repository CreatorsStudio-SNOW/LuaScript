AE_AnchorPoint = {
  COMPOSITION = nil
}


function AE_AnchorPoint:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

   setmetatable(newObject, self)
   self.__index = self
   newObject.key = "anchorPoint"
  
  return newObject
end

function AE_AnchorPoint:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress


  self.nodes[1]:getMaterial():getParameter("u_postAnchorPosition"):setVector2(Vector2.create(0.5, 0.5))
  
  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toAnchorPoint = toKeyframe.value
    local fromAnchorPoint = fromKeyframe.value

    local x =  AE_Layer.calculateStepByProgress(progress, fromAnchorPoint['x'] or 0.5, toAnchorPoint['x'] or 0.5)
    local y =  AE_Layer.calculateStepByProgress(progress, fromAnchorPoint['y'] or 0.5, toAnchorPoint['y'] or 0.5)

    anchorPointVector = Vector2.create(x / COMPOSITION.SIZE.WIDTH, (COMPOSITION.SIZE.HEIGHT - y) / COMPOSITION.SIZE.HEIGHT)

    self.nodes[1]:getMaterial():getParameter("u_anchorPosition"):setVector2(anchorPointVector)
    if self.COMPOSITION.MotionBlur == true then
      self:renderMotionBlur(currentFrame)
    end
  else
    self.nodes[1]:getMaterial():getParameter("u_anchorPosition"):setVector2(Vector2.create(0.5, 0.5))
  end
end
function AE_AnchorPoint:renderMotionBlur(currentFrame)
  local posConfigInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame + 1, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = posConfigInfo.fromKeyframe
  local toKeyframe = posConfigInfo.toKeyframe
  local progress = posConfigInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    local toAnchorPoint = toKeyframe.value
    local fromAnchorPoint = fromKeyframe.value

    local x =  AE_Layer.calculateStepByProgress(progress, (fromAnchorPoint['x'] or 0.5), (toAnchorPoint['x'] or 0.5))
    local y =  AE_Layer.calculateStepByProgress(progress, (fromAnchorPoint['y'] or 0.5), (toAnchorPoint['y'] or 0.5))

    local posAnchorPointVector = Vector2.create(x / COMPOSITION.SIZE.WIDTH, (COMPOSITION.SIZE.HEIGHT - y) / COMPOSITION.SIZE.HEIGHT)

    self.nodes[1]:getMaterial():getParameter("u_postAnchorPosition"):setVector2(posAnchorPointVector)
  end
end
