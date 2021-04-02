-- Update Date : 200117
-- Writer : Sunggon Hong

CEAnimationSampler = {
  scene = nil,
  sampler = nil,
  totalElapsedTime = 0.0,
  isPlaying = false,
  repeatCount = -1,
  SPF = 50.0,
  prevSceneTotalElapsedTime = 0.0,
  totalFrameCount = 0,
  isSetFrames = false,
}


function CEAnimationSampler.create(scene, filePath, fps, repeatCount)
  local newSampler = {}

  setmetatable(newSampler, CEAnimationSampler)
  CEAnimationSampler.__index = CEAnimationSampler

  newSampler.isPlaying = false
  newSampler.totalElapsedTime = 0.0
  newSampler.repeatCount = (repeatCount == nil) and -1 or repeatCount
  newSampler.SPF = (fps == nil) and 50.0 or 1000.0 / fps
  newSampler.sampler = CEAnimationSampler.createSampler(filePath)
  newSampler.scene = scene
  newSampler.prevSceneTotalElapsedTime = 0.0
  newSampler.totalFrameCount = newSampler.sampler:getFrameCount()
  newSampler.isSetFrames = false

  return newSampler
end

function CEAnimationSampler.createFromFrames(scene, filePath, fps, startOffSet, endOffSet, repeatStartOffSet, repeatEndOffSet, repeatCount, startDelayFrame, endDelayFrame)
  if (repeatCount == 0) then 
    return CEAnimationSampler.create(scene, filePath, fps, repeatCount)
  end

  local newSampler = {}

  setmetatable(newSampler, CEAnimationSampler)
  CEAnimationSampler.__index = CEAnimationSampler

  newSampler.isPlaying = true
  newSampler.totalElapsedTime = 0.0
  newSampler.repeatCount = (repeatCount == nil) and 0 or repeatCount
  newSampler.SPF = (fps == nil) and 50.0 or 1000.0 / fps
  newSampler.sampler = CEAnimationSampler.createSampler(filePath)
  newSampler.scene = scene
  newSampler.prevSceneTotalElapsedTime = 0.0
  newSampler.isSetFrames = true
  newSampler.keyFrames = {}

  local samplerFrameCount = newSampler.sampler:getFrameCount()

  newSampler.startOffSet = startOffSet
   
  if (newSampler.startOffSet == nil) then 
    newSampler.startOffSet = 0
  elseif (newSampler.startOffSet >= samplerFrameCount) then 
    newSampler.startOffSet = samplerFrameCount - 1
  end 

  newSampler.endOffSet = endOffSet

  if (newSampler.endOffSet == nil or newSampler.endOffSet <= 0 or newSampler.endOffSet >= samplerFrameCount) then 
    newSampler.endOffSet = samplerFrameCount - 1
  end 

  newSampler.repeatStartOffSet = repeatStartOffSet

  if (newSampler.repeatStartOffSet == nil) then 
    newSampler.repeatStartOffSet = 0
  elseif (newSampler.repeatStartOffSet >= samplerFrameCount) then 
    newSampler.repeatStartOffSet = samplerFrameCount - 1
  end 

  newSampler.repeatEndOffSet = repeatEndOffSet

  if (newSampler.repeatEndOffSet == nil or newSampler.repeatEndOffSet <= 0 or newSampler.repeatEndOffSet >= samplerFrameCount) then 
    newSampler.repeatEndOffSet = samplerFrameCount - 1
  end 

  newSampler.startDelayFrame = startDelayFrame

  if (newSampler.startDelayFrame == nil) then 
    newSampler.startDelayFrame = 0
  end 

  newSampler.endDelayFrame = endDelayFrame

  if (newSampler.endDelayFrame == nil) then 
    newSampler.endDelayFrame = 0
  end 

  local repeatFrameCount = newSampler.repeatEndOffSet - newSampler.repeatStartOffSet

  if (newSampler.repeatEndOffSet > 0) then 
    repeatFrameCount = repeatFrameCount + 1
  end

  newSampler.totalFrameCount = ((newSampler.endOffSet - newSampler.startOffSet + 1) - repeatFrameCount) + repeatFrameCount * newSampler.repeatCount + newSampler.startDelayFrame + newSampler.endDelayFrame

  print("totalFrameCount : " .. newSampler.totalFrameCount)
  local valueIndex = 0 

  for i = 0, newSampler.startDelayFrame - 1 do
    newSampler.keyFrames[valueIndex] = -1 
    valueIndex = valueIndex + 1
  end

  for i = newSampler.startOffSet, newSampler.repeatStartOffSet - 1 do
    newSampler.keyFrames[valueIndex] = i
    valueIndex = valueIndex + 1
  end

  for repeatIndex = 0, newSampler.repeatCount - 1 do 
    for i = newSampler.repeatStartOffSet, newSampler.repeatEndOffSet do 
      newSampler.keyFrames[valueIndex] = i 
      valueIndex = valueIndex + 1
    end
  end

  for i = newSampler.repeatEndOffSet + 1, newSampler.endOffSet do
    newSampler.keyFrames[valueIndex] = i 
    valueIndex = valueIndex + 1
  end

  for i = 0, newSampler.endDelayFrame - 1 do 
    newSampler.keyFrames[valueIndex] = -1
    valueIndex = valueIndex + 1
  end

  print("key frames : ")
  for i = 0, #newSampler.keyFrames do 
    print(newSampler.keyFrames[i] .. ", ")
  end

  return newSampler
end

function CEAnimationSampler.createSampler(filePath)
  local sampler = KuruAnimationSampler.createFromPath(BASE_DIRECTORY .. filePath, false, false)

  sampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  return sampler
end

function CEAnimationSampler:play()
  self:stop()
  self.isPlaying = true
end

function CEAnimationSampler:stop()
  self.isPlaying = false
  self.sampler:setFrameIndex(0)
  self.totalElapsedTime = 0.0
end

function CEAnimationSampler:resume()
  self.isPlaying = true
end

function CEAnimationSampler:pause()
  self.isPlaying = false
end

function CEAnimationSampler:setFrameIndex(index)
  self.totalElapsedTime = self.SPF * index
end

function CEAnimationSampler:release()
  if (self.sampler ~= nil) then
    self.sampler:release()
  end
end

function CEAnimationSampler:frameReady()
  local currentTotalElapsedTime = self.scene:getTotalElapsedTime()
  local deltaElapsedTime = currentTotalElapsedTime - self.prevSceneTotalElapsedTime

  self.prevSceneTotalElapsedTime = currentTotalElapsedTime

  if (self.isPlaying) then
    self.totalElapsedTime = self.totalElapsedTime + deltaElapsedTime
  end

  local frameIndex = math.floor(self.totalElapsedTime / self.SPF)

  if (self.isSetFrames) then
    if (self.repeatCount <= 0) then
      frameIndex = frameIndex % self.totalFrameCount
    else 
      frameIndex = math.min(frameIndex, self.totalFrameCount - 1)
    end
    
    print("frameIndex!! : " .. frameIndex)
    frameIndex = self.keyFrames[frameIndex]
  else
    if (self.repeatCount >= 1) then
      local maxFrameIndex = (self.totalFrameCount * self.repeatCount) - 1

      if (frameIndex > maxFrameIndex) then
        frameIndex = -1
      else
        frameIndex = math.min(frameIndex, maxFrameIndex)
        frameIndex = frameIndex % self.totalFrameCount
      end
    else
      frameIndex = frameIndex % self.totalFrameCount
    end

    print("frameIndex2222 : " .. frameIndex)
  end

  self.sampler:setFrameIndex(frameIndex)
end

function CEAnimationSampler:getSampler()
  return self.sampler
end

function CEAnimationSampler:reset()
  self.isPlaying = false
  self.sampler:setFrameIndex(0)
  self.totalElapsedTime = 0.0
  self.prevSceneTotalElapsedTime = 0.0
  print("reset!!!")
end
