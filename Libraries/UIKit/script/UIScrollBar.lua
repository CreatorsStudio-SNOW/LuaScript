-- strength 0~1.0

require "UIScrollBarResource/Version.lua"

UIScrollBar = {
  NUM_WIDTH = 36.0,
  NUM_HEIGHT = 46,
  NUM_START_X = 10.0,
  BAR_WIDTH = 100.0,
  BAR_HEIGHT = 640.0,
  STRENGTH_MAX_CEIL_FACTOR = 0.95,
  NCLICK_AREA_CODE = "tak_scr",
  scene = nil,
  barNode = nil,
  gaugeNode = nil,
  numNodes = {},
  numSamplers = {},
  numFrameBuffer = nil,
  numDisplayNode = nil,
  controlNode = nil,
  prevYPosition = 0.0,
  position = nil,
  isDragging = false,
  numAlpha = 0.0,
  numAlphaVelocity = 0.15,
  prevStrengthNum = 0,
  enableNClick = false,
  stickerID = -1,
  utilExtension = nil,
  isPrevRenderModePreview = true,
  didSendNClickOnTouchUp = false,
  preRes,
}

-- CONTROL_RANGE = self:is9to16 and 3.0/4.0 * 0.62 or 0.62
CONTROL_RANGE = 0.595
scrollBarInsetInited = false

local function MyScrollNumber(initial, filepath)
  -- the new instance
  local self = {
    -- public fields go in the instance table
    number = 0
  }

  function self.init()
    local file = io.open(filepath, "r")
    if file == nil then
        return  0
    end
    local line = file:read()
    file:close()
    self.number = tonumber(line)
  end

  function self.sync()
    local file = io.open(filepath, "w")
    file:write(tostring(self.number))
    file:close()
  end

  self.number = initial
  self:init()
  return self
end

function UIScrollBar:getNumStartXPosition(digitCount)
  if (digitCount == 1) then
    return 71.0
  elseif (digitCount == 2) then
    return 58.5
  else
    return 49.0
  end
end

function UIScrollBar:hasFunction(cUserData, funcName)
  for k, v in pairs(getmetatable(cUserData)) do
    if k == funcName and type(v) == "function" then
      return true
    end
  end
  return false
end

function UIScrollBar:getYInset(resolution)
  if isOverOrSameVersion(7, 8, 0) then
    previewRectExceptMenu = CameraConfig.instance():getPreviewRectExceptMenus()

    local height = 1440.0
    -- local ratio = 1.0

    local ratio = resolution.x / resolution.y
    local yRatio = 1.0

    if ratio > 0.5 and ratio < 0.6 then
        yRatio = 4/3
    end

    return height - (previewRectExceptMenu.y + previewRectExceptMenu.height) * height * yRatio
  else
    return 0
  end
end

function UIScrollBar:addOrUpdateNumAndGuageUI()
  local currentStrengthNum = self:getStrengthNum()

  if (self.prevStrengthNum == currentStrengthNum) then
    return
  end

  self.prevStrengthNum = currentStrengthNum

  for i = 1, #self.numNodes do
    if (self.numNodes[i] ~= nil) then
      self.numFrameBuffer:removeChild(self.numNodes[i])
      self.numNodes[i] = nil
    end
  end

  local ratio = self:is9to16() and 3.0/4.0 or 1.0

  local yPosition = 0.0
  -- yPosition = 1100.0

  if scrollBarYInset > 0 then
    yPosition = self:is9to16() and 998.56 or 918.56
    yPosition = yPosition + scrollBarYInset
  else
    yPosition = self:is9to16() and 1180.0 or 1100.0
    -- yPosition = 1100.0
  end

  local digitCount = self:digitCount(currentStrengthNum)
  local startXPosition = self:getNumStartXPosition(digitCount)

  startXPosition = startXPosition + self.NUM_WIDTH

  for i = 1, digitCount do
    local digitNum = self:digitNum(currentStrengthNum, digitCount - i + 1)
    local xPosition = 1080.0 - startXPosition - (digitCount - i) * (self.NUM_WIDTH - 15.0)

    self.numNodes[i] = self:floatingImageWithSampler(self.numSamplers[digitNum], xPosition, yPosition, self.NUM_WIDTH, self.NUM_HEIGHT * ratio, BlendMode.None)
    self:addChildNodeAndRelease(self.numFrameBuffer, self.numNodes[i])
  end

  self:addOrUpdateGuageUI()
end

function UIScrollBar:addOrUpdateGuageUI()
  if (self.gaugeNode ~= nil) then
    self.scene:removeNode(self.gaugeNode)
    self.gaugeNode = nil
  end

  local ratio = self:is9to16() and 3.0/4.0 or 1.0

  local gauge = self.prevStrengthNum / 100.0

  local yPosition = self:is9to16() and 700.0 or 450.0

  if scrollBarYInset > 0 then
    yPosition = self:is9to16() and 518.56 or 268.56
    yPosition = yPosition + scrollBarYInset
  end

  yPosition = yPosition + 92 * ratio * (1.0 - gauge)

  self.gaugeNode = self:addNodeAndRelease(self:floatingImage("UIScrollBarResource/gauge.png", 1080.0 - 38.88 - self.BAR_WIDTH, yPosition, self.BAR_WIDTH , self.BAR_HEIGHT * ratio * gauge, BlendMode.None))
end

function UIScrollBar:addOrUpdateBarUI()
  if (self.barNode ~= nil) then
    self.scene:removeNode(self.barNode)
    self.barNode = nil
  end

  local ratio = self:is9to16() and 3.0/4.0 or 1.0

  local yPosition = self:is9to16() and 700.0 or 450.0

  if scrollBarYInset > 0 then
    yPosition = self:is9to16() and 518.56 or 268.56
    yPosition = yPosition + scrollBarYInset
  end

  self.barNode = self:addNodeAndRelease(self:floatingImage("UIScrollBarResource/bar.png", 1080.0 - 38.88 - self.BAR_WIDTH, yPosition, self.BAR_WIDTH, self.BAR_HEIGHT * ratio, BlendMode.None))

  yPosition = self:is9to16() and 748.0 or 514.72

  if scrollBarYInset > 0 then
    yPosition = self:is9to16() and 566.56 or 333.28
    yPosition = yPosition + scrollBarYInset
  end

  if (self.controlNode ~= nil) then
    self.scene:removeNode(self.controlNode)
    self.controlNode = nil
  end

  self.controlNode = self:addNodeAndRelease(self:floatingImage("UIScrollBarResource/circle.png", 1080.0 - 50 - self.BAR_WIDTH * 0.75, yPosition, self.BAR_WIDTH * 0.75, self.BAR_WIDTH * ratio * 0.75, BlendMode.None))
  self.controlNode:setTranslationY(self.position.number * self:getControlRange())

  if (isOverOrSameVersion(7, 6, 0) and self.enableTouchRect) then
    EngineStatus.instance():setTouchRect(0, self.barNode:getTouchRect())
  end
end

function UIScrollBar:init(scene, defaultValue, enableTouchRect, enableNClick, stickerID)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  local ratio = scene:getResolution().x / scene:getResolution().y

  -- print( ">>> ratio " .. ratio)

  if ratio > 1.05 then
    ratio = 4.0 / 3.0
  else
    ratio = 1.0
  end

  newInstance.NUM_WIDTH = newInstance.NUM_WIDTH / ratio
  newInstance.BAR_WIDTH = newInstance.BAR_WIDTH / ratio

  scrollBarYInset = self:getYInset(scene:getResolution())

  newInstance.scene = scene
  newInstance.preRes = scene:getResolution()
  newInstance.numNodes = {}
  newInstance.numSamplers = {}
  newInstance.position = MyScrollNumber(defaultValue, BASE_DIRECTORY .. "position.txt")
  newInstance:addOrUpdateBarUI()
  newInstance:setupNumTextures()
  newInstance.numFrameBuffer = newInstance:addNodeAndRelease(KuruFrameBufferNode.create())
  newInstance:addChildNodeAndRelease(newInstance.numFrameBuffer, KuruClearNode.create(Vector4.create(0.0, 0.0, 0.0, 0.0)))
  newInstance.numDisplayNode = newInstance:addNodeAndRelease(newInstance:getFragNode("UIScrollBarResource/alphaBlend.frag"))
  newInstance.numDisplayNode:setChannel1(newInstance.numFrameBuffer:getSampler())
  newInstance.enableTouchRect = enableTouchRect
  newInstance.enableNClick = enableNClick
  newInstance.stickerID = stickerID
  newInstance.didSendNClickOnTouchUp = false

  if (enableNClick) then
    newInstance.utilExtension = KuruUtilExtension.cast(KuruEngine.getInstance():getExtension("KuruUtil"))
  end

  return newInstance
end

function UIScrollBar:checkYInset()
  if self.scene:getResolution().x > 0 and scrollBarInsetInited == false then
    scrollBarYInset = self:getYInset(self.scene:getResolution())
    scrollBarInsetInited = true
  end
end

function UIScrollBar:frameReady()
  self:checkYInset()

  self:addOrUpdateNumAndGuageUI()
  self:updateNumAlpha()

  if (self:isChangedFrame()) then
    self:addOrUpdateBarUI()
    self:addOrUpdateGuageUI()
  end

  if SceneRenderConfig.instance():isRenderModePreview() then
    self.controlNode:setEnabled(true)
    self.barNode:setEnabled(true)
    self.gaugeNode:setEnabled(true)
    self:setNumNodesEnabled(true)

    self.isPrevRenderModePreview = true
  else
    if (self.isPrevRenderModePreview) then
      self.isPrevRenderModePreview = false

      local nClickDocID = self.stickerID .. "," .. self:getStrength()
      self:sendNClick("scriptshuttercomplete", nClickDocID)
    end
    self.controlNode:setEnabled(false)
    self.barNode:setEnabled(false)
    self.gaugeNode:setEnabled(false)
    self:setNumNodesEnabled(false)
  end
end

function UIScrollBar:updateNumAlpha()
  if (self.isDragging) then
    self.numAlpha = math.min(1.0, self.numAlpha + self.numAlphaVelocity)
  else
    self.numAlpha = math.max(0.0, self.numAlpha - self.numAlphaVelocity)
  end

  self.numDisplayNode:getMaterial():getParameter("alpha"):setFloat(math.min(self.numAlpha, 1.0))
end

function UIScrollBar:finalize()
  for i = 0, #self.numSamplers - 1 do
    local sampler = self.numSamplers[i]

    if (sampler ~= nil) then
      sampler:release()
    end
  end
end

function UIScrollBar:getFragNode(filePath)
  return KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. filePath, true)
end

function UIScrollBar:addChildNodeAndRelease(parent, child)
  parent:addChild(child)
  child:release()

  return child
end

function UIScrollBar:setupNumTextures()
  for i = 0, 9 do
    local imagePath = "UIScrollBarResource/number/" .. i .. ".png"

    self.numSamplers[i] = TextureSampler.create(BASE_DIRECTORY .. imagePath, false, false)
    self.numSamplers[i]:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)
  end
end

function UIScrollBar:setNumNodesEnabled(enabled)
  for i = 1, #self.numNodes do
    local numNode = self.numNodes[i]

    if (numNode ~= nil) then
      numNode:setEnabled(enabled)
    end
  end
end

-- return strength 0.0~1.0

function UIScrollBar:getStrength()
  local transY = self.controlNode:getTranslationY()
  local strength = transY / self:getControlRange()

  return strength > self.STRENGTH_MAX_CEIL_FACTOR and 1.0 or strength
end

function UIScrollBar:setStrength(str)
  local transY = str * self:getControlRange()
  self.prevYPosition = transY
  self:moveControlNode(transY)
  self.position.number = self:getStrength()
  self.position:sync()
end

function UIScrollBar:getStrengthNum()
  return math.floor(self:getStrength() * 100.0)
end

function UIScrollBar:addNodeAndRelease(node)
  self.scene:addNode(node)
  node:release()

  return node
end

function UIScrollBar:onTouchDown(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  self.isDragging = true
  self.prevYPosition = pos.y
end

function UIScrollBar:onTouchMove(event)
    local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()
    local prevTransY = self.controlNode:getTranslationY()
    local gapY = self.prevYPosition - pos.y
    local translationY = prevTransY + gapY

    self.prevYPosition = pos.y

    self:moveControlNode(translationY)
    self.position.number = self:getStrength()
end

function UIScrollBar:onTouchUp(event)
  self.isDragging = false
  self.numAlpha = self.numAlpha + 5.0
  self.position:sync()

  if (not self.didSendNClickOnTouchUp) then
    self:sendNClick("scriptslidetouchup", self.stickerID)
    self.didSendNClickOnTouchUp = true
  end
end

function UIScrollBar:sendNClick(nClickCode, docID)
  if (isOverOrSameVersion(7, 6, 0) and self.enableNClick) then
    self.utilExtension:sendClick(self.NCLICK_AREA_CODE, nClickCode, docID)
  end
end

function UIScrollBar:moveControlNode(translationY)
  if (translationY < 0.0 or translationY > self:getControlRange()) then
    return
  end

  self.controlNode:setTranslationY(translationY)

end

function UIScrollBar:floatingImage(filePath, x, y, width, height, blendMode)
  local imageX = (x - 540.0) / 540.0
  local imageY = (y - 720.0) / 720.0
  local imageWidth = width * 2 / 1080.0
  local imageHeight = height * 2 / 1440.0
  return KuruFloatingImageNode.create(BASE_DIRECTORY .. filePath,
    imageX, imageY, imageWidth, imageHeight, blendMode
  )
end

function UIScrollBar:floatingImageWithSampler(sampler, x, y, width, height, blendMode)
  local imageX = (x - 540.0) / 540.0
  local imageY = (y - 720.0) / 720.0
  local imageWidth = width * 2 / 1080.0
  local imageHeight = height * 2 / 1440.0
  return KuruFloatingImageNode.createFromSampler(sampler,
    imageX, imageY, imageWidth, imageHeight, blendMode
  )
end

function UIScrollBar:isChangedFrame()
    local curRes = self.scene:getResolution()
    if self.preRes == nil or (curRes ~= nil and (curRes.x ~= self.preRes.x or curRes.y ~= self.preRes.y)) then
        self.preRes = curRes
        return true
    end
    return false
end

function UIScrollBar:is9to16()
  local ratio = self.preRes.x / self.preRes.y

  if ratio > 0.5 and ratio < 0.6 then
      return true
  end

  return false
end

function UIScrollBar:getControlRange()
  return self:is9to16() and CONTROL_RANGE * 3.0/4.0 or CONTROL_RANGE
end

function UIScrollBar:digitCount(n)
    local i = 1

    while n >= 10^i do
        i = i + 1
    end

    return i
end

function UIScrollBar:digitNum(num, th)
    return math.floor((num % 10^th) / 10^(th - 1));
end
