require "DelayFrameKit/Queue.lua"
DelayFrameKit = {
  scene = nil,
  snapshot = nil,
  bufferQueue = nil,
  elapsedTimeQueue = nil,
  drawModel = nil,
  maxRecordingTime = 0.0,
  totalRecordingTime = 0.0,
  bufferScale = 1.0,
  state = nil,
  SPF = 0.0,
  timeSequence = nil,
  capturePassedTime = 0.0
}

-- 최근 maxRecordingTime 만큼 녹화해서 FrameBuffer에 저장해 놓는다.
function DelayFrameKit:new(scene, snapshot, maxRecordingTime, bufferScale, fps)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  newInstance.scene = scene
  newInstance.snapshot = snapshot
  newInstance.maxRecordingTime = maxRecordingTime
  newInstance.bufferScale = bufferScale
  newInstance.state = nil
  newInstance.count = 0
  newInstance.bufferPool = {}
  newInstance.SPF = (fps == nil) and 0.0 or 1000.0 / fps
  newInstance.capturePassedTime = 0.0
  newInstance:init()

  return newInstance
end

function DelayFrameKit:init()
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
end

function DelayFrameKit:frameReady(elapsedTime)
  if (self.snapshot:getSampler():getTexture() == nil) then 
    return
  end

  if (self.SPF > self.capturePassedTime) then 
    self.capturePassedTime = self.capturePassedTime + elapsedTime

    return
  end

  self.totalRecordingTime = self.totalRecordingTime + self.capturePassedTime + elapsedTime
  self.state = FrameBufferBindingState.create()

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

  if (frameBuffer == nil) then
    local resolution = self.scene:getResolution()
    local bufferScaleX = math.floor(resolution.x * self.bufferScale)
    local bufferScaleY = math.floor(resolution.y * self.bufferScale)
    local bufferID = "STORED_FB_ " .. tostring(self.count)

    frameBuffer = FrameBuffer.create(bufferID, bufferScaleX, bufferScaleY, TextureFormat.RGBA)
    self.count = self.count + 1
  end

  frameBuffer:bindWithViewport(true)
  self.drawModel:draw()
  self.state:restore()
  self.bufferQueue:push(frameBuffer, false)
  self.elapsedTimeQueue:push(self.capturePassedTime + elapsedTime, false)
  self:popIfNeeded()
  self.capturePassedTime = 0.0
end

function DelayFrameKit:popIfNeeded()
  if (self.totalRecordingTime <= self.maxRecordingTime) then
    return
  end

  local frameBuffer = self.bufferQueue:pop(false)

  self.bufferPool[#self.bufferPool + 1] = frameBuffer

  local lastElapsedTime = self.elapsedTimeQueue:pop(false)

  self.totalRecordingTime = self.totalRecordingTime - lastElapsedTime
  self:popIfNeeded()
end

-- elapsedTimeAgo 시간만큼 전의 FrameBuffer의 sampler를 생성한다. 사용 직후 반드시 release 해주어야 한다.
function DelayFrameKit:createSampler(elapsedTimeAgo)
  local frameBuffer = self:getFrameBuffer(elapsedTimeAgo)
  local texture = nil

  if (frameBuffer == nil) then
    texture = self.snapshot:getSampler():getTexture()
  else 
    texture = frameBuffer:getRenderTarget(0):getTexture()
  end

  return TextureSampler.createWithTexture(texture)
end

function DelayFrameKit:getFrameBuffer(elapsedTimeAgo)
  local frontIndex = self.elapsedTimeQueue.front
  local rearIndex = self.elapsedTimeQueue.rear
  local sumElapsed = 0.0

  for i = frontIndex, rearIndex do
    local elapsedTime = self.elapsedTimeQueue:retrieve(i)

    sumElapsed = sumElapsed + elapsedTime

    if (sumElapsed > elapsedTimeAgo) then
      return self.bufferQueue:retrieve(i)
    end
  end

  return nil
end

function DelayFrameKit:reset()
  self.totalRecordingTime = 0.0
  self.capturePassedTime = 0.0 
  self:clearBuffers()
end

function DelayFrameKit:clearBuffers()

  self.bufferQueue:retrieveAll(
  function(element)
    self.bufferPool[#self.bufferPool + 1] = element
  end)

  self.bufferQueue:clear(false)
  self.elapsedTimeQueue:clear(false)
end

function DelayFrameKit:release()
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
