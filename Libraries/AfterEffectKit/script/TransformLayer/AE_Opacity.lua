AE_Opacity = {
}


function AE_Opacity:create(keyframes)
  local newObject = AE_Layer:create(keyframes)

   setmetatable(newObject, self)
   self.__index = self
  newObject.key = "opacity"
  
  return newObject
end

function AE_Opacity:frameReady(currentFrame)
  local configInfo = AE_Layer.getCurrentConfigInfo(self.keyframes, currentFrame, self.fromKeyframe, self.toKeyframe)

  local fromKeyframe = configInfo.fromKeyframe
  local toKeyframe = configInfo.toKeyframe
  local progress = configInfo.progress

  if fromKeyframe ~= nil and toKeyframe ~= nil and #self.keyframes > 0 then
    self.toKeyframe = toKeyframe
    self.fromKeyframe = fromKeyframe

    local toOpacity = toKeyframe.value
    local fromOpacity = fromKeyframe.value
    opacityScalar =  AE_Layer.calculateStepByProgress(progress, fromOpacity, toOpacity)

    self.nodes[1]:getMaterial():getParameter("u_opacity"):setFloat(opacityScalar)
  else
    self.nodes[1]:getMaterial():getParameter("u_opacity"):setFloat(1.0)
  end
end
