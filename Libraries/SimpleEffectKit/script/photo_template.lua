-- Update Date : 191129
-- Writer : Sunggon Hong

require "easing.lua"

PhotoTemplate = {
  snapshot = nil,
  scene = nil,
  activeIdx = 0,
  shaderNodes = {},
  progress = 0,
  items = {},
  effect = nil,
}

function math.clamp(n, low,high)
  return math.min(math.max(n, low), high)
end

function PhotoTemplate:new(scene, snapshot, items)
  local newObject = {}

  setmetatable(newObject, self)
  self.__index = self
  newObject.snapshot = snapshot
  newObject.scene = scene
  newObject.items = items
  newObject.shaderNodes = {}
  newObject.progress = 0
  newObject.activeIdx = 0
  newObject:init()

  return newObject
end

function PhotoTemplate:init()
  if (self.snapshot ~= nil) then
    self:buildBgNode(self.snapshot:getSampler())
  end

  for i = 1, #self.items do
    local item = self.items[i]
    local effect = item.effect

    if self.shaderNodes[effect] == nil then
      local effectShaderNodes = {}

      if (effect == EffectType.ROTATE) then
        effectShaderNodes[1] = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "rotate.frag", true)
      elseif (effect == EffectType.TWIST) then
        effectShaderNodes[1] = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "twist.frag", true)
      elseif (effect == EffectType.SEPARATION) then
        effectShaderNodes[1] =  KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "separation.frag", true)
      elseif (effect == EffectType.ROLLING) then
        effectShaderNodes[1] = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "roll.frag", true)
      else
        effectShaderNodes[1] = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "effect.frag", true)
      end
      self.shaderNodes[effect] = effectShaderNodes
    end
  end

  for effect,shaders in pairs(self.shaderNodes) do
    for i = 1, #self.shaderNodes[effect] do
      self.scene:addNodeAndRelease(self.shaderNodes[effect][i])
      self.shaderNodes[effect][i]:setEnabled(false)

      local stateBlock = self.shaderNodes[effect][i]:getMaterial():getStateBlock()
      stateBlock:setBlend(true)
      stateBlock:setBlendSrc(RenderStateBlend.BLEND_ONE)
      stateBlock:setBlendDst(RenderStateBlend.BLEND_ONE_MINUS_SRC_ALPHA)
    end
  end
end

function PhotoTemplate:clear()
  self:removeShaderNodes()
end

function PhotoTemplate:removeShaderNodes()
  for effect,_ in ipairs(self.shaderNodes) do
    for i = 1, #self.shaderNodes[effect] do
      self.shaderNodes[effect][i]:setEnabled(false)
    end
  end
end

function PhotoTemplate:buildBgNode(sampler)
  local bg = KuruBackgroundImageNode.createFromSampler(sampler)

  bg:setStretch(KuruBackgroundImageNodeStretch.FIT_CENTER)
  self.scene:addNodeAndRelease(bg)
end

function mod(a, b)
    return (a - math.floor(a / b) * b)
end

function PhotoTemplate:getCurrentFrameIndex()
    local currentFrameIndex = math.floor(self.scene:getTotalElapsedTime() / TIME_PER_FRAME)

    return mod(currentFrameIndex, TOTAL_FRAME)
end

function PhotoTemplate:buildProgress(item)
  if (item.duration == 0) then
    return 1.0
  end

  local duration = item.duration
  local startTime = item.frameIndex

  local progress = (self.scene:getTotalElapsedTime()/TIME_PER_FRAME - startTime) / duration
   progress = math.clamp(progress, 0, 1)

  local easingFunc = getEasingFunction(item.easing)

  return easingFunc(progress, 0, 1, 1)
end

function PhotoTemplate:release()
end

function PhotoTemplate:checkFrame()
  local currentIdx = 0

  for i = #self.items, 1, -1  do
    local item = self.items[i]
    local currentFrameIndex = self:getCurrentFrameIndex()

    if currentFrameIndex >= item.frameIndex then
      currentIdx = i

      break
    end
  end

  if (currentIdx == 0) then
    return
  end

  if self.activeIdx ~= currentIdx then
    self.activeIdx = currentIdx
    self:applyEffect()
  end

  self:updateEffect()
end

function PhotoTemplate:reset()
  self.activeIdx = 0
  self:clear()
  self.effect = nil
end

function PhotoTemplate:updateShaders()
  self:removeShaderNodes()

  local item = self.items[self.activeIdx]

  for i=1, #self.shaderNodes[item.effect] do
    self.shaderNodes[item.effect][i]:setEnabled(true)
    print("updateShaders " .. tostring(i) .. "  item.effett " .. tostring(item.effect))
  end
end

function PhotoTemplate:updateEffect()
  local item = self.items[self.activeIdx]

  self.progress = self:buildProgress(item)

  if (self.effect == EffectType.ROTATE) then
    local rotationMat = self:getRotationMat(item)

    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_textureMat"):setMatrix(rotationMat)
    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_bgColor"):setVector4(BG_COLOR)
  elseif (self.effect == EffectType.TWIST) then

    local startStrength = item.config["startStrength"]
    local endStrength = item.config["endStrength"]

    local strength = (endStrength - startStrength) * self.progress + startStrength

    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_waveStrength"):setFloat(strength * 30.0)
  elseif (self.effect == EffectType.SEPARATION) then
    local startStrength = item.config["startStrength"]
    local endStrength = item.config["endStrength"]
    local strength = (endStrength - startStrength) * self.progress + startStrength

    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_strength"):setFloat(strength)
  elseif (self.effect == EffectType.ROLLING) then
    local startRolling = item.config["startRolling"]
    local endRolling = item.config["endRolling"]
    local duration = endRolling - startRolling

    local u_progress = self.progress * duration + startRolling

    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_progress"):setFloat((u_progress - 640.0)/640.0)
  else
    self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_effectType"):setInt(item.effect)

    if (self.effect == EffectType.SCALE) then
      local startScale = item.config["startScale"]
      local endScale = item.config["endScale"]
      local duration = endScale - startScale
      local scale = (duration * self.progress) + startScale

      self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_scale"):setFloat(scale)
      self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_bgColor"):setVector4(BG_COLOR)
    end
    if (self.effect == EffectType.TRANSLATE) then
      local startPosition = item.config["startPosition"]
      local endPosition = item.config["endPosition"]

      local offeSetX = (endPosition["x"] - startPosition["x"]) * self.progress + startPosition["x"]
      local offeSetY = (endPosition["y"] - startPosition["y"]) * self.progress + startPosition["y"]

      self.shaderNodes[self.effect][1]:getMaterial():getParameter("u_offset"):setVector2(Vector2.create((offeSetX - 360.0) / 360.0, (offeSetY - 640.0)/640.0))
    end
  end
end

function PhotoTemplate:applyEffect()
  local item = self.items[self.activeIdx]
  if self.effect == item.effect then
    return
  end
  self.effect = item.effect
  self:updateShaders()
end

function PhotoTemplate:getRotationMat(item)
  local rotateMat = Matrix.createFromMatrix(Matrix.identity())
  local startDegree = item.config["startDegree"]
  local endDegree = item.config["endDegree"]
  local duration = endDegree - startDegree
  local degree = startDegree + (duration * self.progress)
  local sceneResolution = self.scene:getResolution()
  local sceneRatio = sceneResolution.x / sceneResolution.y

  rotateMat:translate(-0.5, -0.5, 0.0)
  rotateMat:postScale(1.0, 1.0 / sceneRatio, 1.0)
  rotateMat:postRotateZ(math.rad(degree))
  rotateMat:postScale(1.0, sceneRatio, 1.0)
  rotateMat:postTranslate(0.5, 0.5, 0.0)
  rotateMat:invert()

  return rotateMat
end
