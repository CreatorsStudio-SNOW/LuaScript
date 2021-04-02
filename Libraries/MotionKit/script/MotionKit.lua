-- Update Date : 191227
-- Writer : Sunggon Hong

require "Queue.lua"

MotionItem = {
  slowStartFrame = nil,
  turningFrame = nil,
  quickEndFrame = nil,
  slowSpeed = nil,
  quickSpeed = nil
}


-- Description
---- Slow and Quick 컨텐츠를 쉽게 만들기 위한 라이브러리 이다.
---- 컨텐츠 특성상(preview frame을 쌓아놓아야 하기 때문에) Slow Play -> Quick Play 순으로 진행하야 한다.

-- MotionItem 파라미터
---- slowStartFrame
------ Slow Play가 시작되는 Frame Index

---- turningFrame
------ Slow Play가 멈추가 Quick Play로 바뀌는 시작하는 Frame Index

---- quickEndFrame
------ Quick Play가 멈추는 Frame Index

---- slowSpeed
------ Slow Play의 속도 (0.5이면 2배 느리게 재생)

---- quickSpeed
------ Quick Play의 속도 (2.0이면 2배 빠르게 재생)

function MotionItem:new(slowStartFrame, turningFrame, quickEndFrame, slowSpeed, quickSpeed)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.slowStartFrame = slowStartFrame
  newInstance.turningFrame = turningFrame
  newInstance.quickEndFrame = quickEndFrame
  newInstance.slowSpeed = slowSpeed
  newInstance.quickSpeed = quickSpeed

  return newInstance
end


MotionKit = {
  TIME_PER_FRAME = 50.0, -- 20fps
  scene = nil,
  snapshot = nil,
  bufferQueue = nil,
  elapsedTimeQueue = nil,
  drawModel = nil,
  displayShaderNode = nil,
  totalElapsedTime = 0.0,
  motionItems = {},
  bufferPool = {},
  bufferCount = 0,
  bufferScale = 1.0
}

function MotionKit:new(scene, snapshot, motionItems, bufferScale)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance.snapshot = snapshot
  newInstance.motionItems = motionItems
  newInstance.bufferScale = bufferScale
  newInstance.bufferPool = {}
  newInstance.bufferCount = 0
  newInstance:init()

  return newInstance
end

function MotionKit:init()
  self.bufferQueue = Queue:new()
  self.elapsedTimeQueue = Queue:new()

  local frameMesh = Mesh.createQuadFullscreen()

  self.drawModel = Model.create(frameMesh)
  frameMesh:release()

  local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

  material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
  material:getParameter("u_texture"):setSampler(self.snapshot:getSampler())
  self.drawModel:setMaterial(material, -1)
  material:release()

  self.displayShaderNode = KuruShaderFilterNode.createWithFragmentShaderFile("res/shaders/passthrough.frag", false)
  self.displayShaderNode:getMaterial():getParameter("u_texture"):setSampler(self.snapshot:getSampler())
  self.scene:addNodeAndRelease(self.displayShaderNode)
end

function MotionKit:frameReady(elapsedTime)
  self.totalElapsedTime = self.totalElapsedTime + elapsedTime

  local motionItem = nil
  local currentFrame = 0

  for i = 1, #self.motionItems do
    local startFrame = self.motionItems[i].slowStartFrame
    local endFrame = self.motionItems[i].quickEndFrame

    currentFrame = math.floor(self.totalElapsedTime / self.TIME_PER_FRAME)

    if (startFrame <= currentFrame and endFrame > currentFrame) then
      motionItem = self.motionItems[i]

      break
    end
  end

  if (motionItem == nil) then
    self.displayShaderNode:getMaterial():getParameter("u_texture"):setSampler(self.snapshot:getSampler())
    self:clearBuffers()

    return
  end

  local poolLastIndex = #self.bufferPool
  local frameBuffer = self.bufferPool[poolLastIndex]

  self.bufferPool[poolLastIndex] = nil

  if (frameBuffer ~= nil) then
    local bufferRatio = frameBuffer:getWidth() / frameBuffer:getHeight()
    local sceneRes = self.scene:getResolution()
    local sceneRatio = sceneRes.x / sceneRes.y

    if (sceneRatio / bufferRatio > 1.05 or sceneRatio / bufferRatio < 0.95) then
      frameBuffer:release()
      frameBuffer = nil
    end
  end

  local state = FrameBufferBindingState.create()

  if (frameBuffer == nil) then
    local resolution = self.scene:getResolution()
    local bufferScaleX = math.floor(resolution.x * self.bufferScale)
    local bufferScaleY = math.floor(resolution.y * self.bufferScale)
    local bufferID = "STORED_FB_ " .. tostring(self.bufferCount)

    frameBuffer = FrameBuffer.create(bufferID, bufferScaleX, bufferScaleY, TextureFormat.RGBA)
    self.bufferCount = self.bufferCount + 1
  end

  frameBuffer:bindWithViewport(true)
  self.drawModel:draw()
  state:restore()

  self.bufferQueue:push(frameBuffer, false)
  self.elapsedTimeQueue:push(elapsedTime, false)

  local speed = (currentFrame < motionItem.turningFrame) and motionItem.slowSpeed or motionItem.quickSpeed

  self:triggerSlowmotion(speed, elapsedTime)
end

function MotionKit:triggerSlowmotion(speed, elapsedTime)
  local motionElapsedTime = elapsedTime * speed
  local slowFrameBuffer = self:getFrameBuffer(motionElapsedTime)

  if (slowFrameBuffer == nil) then
    self.displayShaderNode:getMaterial():getParameter("u_texture"):setSampler(self.snapshot:getSampler())
    self:clearBuffers()

    return
  end
    local frameSampler = TextureSampler.createWithTexture(slowFrameBuffer:getRenderTarget(0):getTexture())

    if frameSampler ~= nil then
      self.displayShaderNode:getMaterial():getParameter("u_texture"):setSampler(frameSampler)
      frameSampler:release()
    end
end

function MotionKit:getFrameBuffer(elapsedTime)
  local bufferElapsedTime = self.elapsedTimeQueue:retrieveLast()

  if (bufferElapsedTime == nil) then
    return nil
  end

  local gapElapsed = bufferElapsedTime - elapsedTime

  if (gapElapsed > 0.0) then
    self.elapsedTimeQueue:updateLast(gapElapsed)

    return self.bufferQueue:retrieveLast()
  else
    local frameBuffer = self.bufferQueue:pop(false)

    self.bufferPool[#self.bufferPool + 1] = frameBuffer
    self.elapsedTimeQueue:pop(false)

    return self:getFrameBuffer(-gapElapsed)
  end
end

function MotionKit:reset()
  self.totalElapsedTime = 0.0
  self.displayShaderNode:getMaterial():getParameter("u_texture"):setSampler(self.snapshot:getSampler())
  self:clearBuffers()
end

function MotionKit:clearBuffers()
  self.bufferQueue:retrieveAll(
  function(element)
    self.bufferPool[#self.bufferPool + 1] = element
  end)

  self.bufferQueue:clear(false)
  self.elapsedTimeQueue:clear(false)
end

function MotionKit:release()
  self:clearBuffers()

  if (self.drawModel ~= nil) then
    self.drawModel:release()
  end

  for i = 1, #self.bufferPool do
    if (self.bufferPool[i] ~= nil) then
      self.bufferPool[i]:release()
      self.bufferPool[i] = nil
    end
  end
end
