-- strength 0~1.0

UIScrollBar = {
  sharedInstance,
  NUM_WIDTH = 12.0,
  NUM_HEIGHT = 16.0,
  BAR_WIDTH = 11,
  BAR_HEIGHT = 180,
  CIRCLE_SIZE = 21,
  scene = nil,
  barNode = nil,
  controlNode = nil,
  prevYPosition = 0.0,
  position = nil,
  isDragging = false,
  preRes,
}

CONTROL_RANGE = UIScrollBar.BAR_HEIGHT / 667.0 * 2.0

local function MyScrollNumber(initial, filepath)
  local self = {
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

function UIScrollBar:addOrUpdateBarUI()
  if (self.barNode ~= nil) then
    self.scene:removeNode(self.barNode)
    self.barNode = nil
  end

  local ratio = self:is9to16() and 1.0 or 4.0/3.0
  local yPosition = self:is9to16() and 354.5 or 354.5 - 166.75
  local baseHeight = self:is9to16() and 667.0 or 500.25

  self.barNode = self:addNodeAndRelease(self:floatingImage("UIScrollBarResource/bar.png", 375.0 - 23.0 - self.BAR_WIDTH, yPosition, self.BAR_WIDTH, self.BAR_HEIGHT, BlendMode.None, baseHeight))

  yPosition = self:is9to16() and 344.5 or 344.5 - 166.75

  if (self.controlNode ~= nil) then
    self.scene:removeNode(self.controlNode)
    self.controlNode = nil
  end

  self.controlNode = self:addNodeAndRelease(self:floatingImageWithSampler(self.circleBufferNode:getSampler(), 375.0 - 18.0 - self.CIRCLE_SIZE, yPosition, self.CIRCLE_SIZE, self.CIRCLE_SIZE, BlendMode.None, baseHeight))
  self.controlNode:setTranslationY(self.position.number * self:getControlRange())
end

function UIScrollBar:init(scene, defaultValue)
  local newInstance = {}

  setmetatable(newInstance, self)
  self.__index = self

  UIScrollBar.sharedInstance = newInstance

  newInstance.scene = scene
  newInstance.preRes = scene:getResolution()
  newInstance.defaultValue = defaultValue or 1.0

  newInstance:addEventHandler()
  newInstance.position = MyScrollNumber(defaultValue, BASE_DIRECTORY .. "UIScrollBarResource/position.txt")

  local pickerSampler = TextureSampler.create(BASE_DIRECTORY .. "UIScrollBarResource/bar.png", false, false)
  pickerSampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)
  local circleSampler = TextureSampler.create(BASE_DIRECTORY .. "UIScrollBarResource/circle.png", false, false)
  circleSampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  newInstance.pickedColorBufferNode = newInstance:addNodeAndRelease(KuruFrameBufferNode.createWithSize(1, 1))
  newInstance.pickColorShaderNode = newInstance:getFragNode("UIScrollBarResource/pickColor.frag")
  newInstance.pickColorShaderNode:getMaterial():getParameter("u_location"):setFloat(newInstance:getColorPickNum())
  newInstance.pickColorShaderNode:setChannel0(pickerSampler)
  newInstance:addChildNodeAndRelease(newInstance.pickedColorBufferNode, newInstance.pickColorShaderNode)
  newInstance.circleBufferNode = newInstance:addNodeAndRelease(KuruFrameBufferNode.createWithSize(69, 69))
  newInstance.circleColorShaderNode = newInstance:getFragNode("UIScrollBarResource/circleColor.frag")
  newInstance.circleColorShaderNode:setChannel0(newInstance.pickedColorBufferNode:getSampler())
  newInstance.circleColorShaderNode:setChannel1(circleSampler)
  newInstance:addChildNodeAndRelease(newInstance.circleBufferNode, newInstance.circleColorShaderNode)
  newInstance:addOrUpdateBarUI()

  pickerSampler:release()
  circleSampler:release()

  return newInstance
end

function UIScrollBar:getColorPickNum()
  return (self.position.number * 0.97) + 0.015
end

function UIScrollBar:getPickerColorSampler()
  return self.pickedColorBufferNode:getSampler()
end

function UIScrollBar:addEventHandler()
  local kuruEngineInstance = KuruEngine.getInstance()

  self.kuruTouch = KuruTouchExtension.cast(kuruEngineInstance:getExtension("KuruTouch"))
  self.kuruTouch:getTouchDownEvent():addEventHandler(UIScrollBar_onTouchDown)
  self.kuruTouch:getTouchMoveEvent():addEventHandler(UIScrollBar_onTouchMove)
  self.kuruTouch:getTouchUpEvent():addEventHandler(UIScrollBar_onTouchUp)
end

function UIScrollBar:removeEventHandler()
  self.kuruTouch:getTouchDownEvent():removeEventHandler(UIScrollBar_onTouchDown)
  self.kuruTouch:getTouchMoveEvent():removeEventHandler(UIScrollBar_onTouchMove)
  self.kuruTouch:getTouchUpEvent():removeEventHandler(UIScrollBar_onTouchUp)
end

function UIScrollBar:frameReady()
  self.pickColorShaderNode:getMaterial():getParameter("u_location"):setFloat(self:getColorPickNum())

  if (self:isChangedFrame()) then
    self:addOrUpdateBarUI()
  end

  if SceneRenderConfig.instance():isRenderModePreview() then
    self.controlNode:setEnabled(true)
    self.barNode:setEnabled(true)
  else
    self.controlNode:setEnabled(false)
    self.barNode:setEnabled(false)
  end
end

function UIScrollBar:finalize()
  self:removeEventHandler()
end

function UIScrollBar:getFragNode(filePath)
  return KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. filePath, true)
end

function UIScrollBar:addChildNodeAndRelease(parent, child)
  parent:addChild(child)
  child:release()

  return child
end

function UIScrollBar:getStrength()
  local transY = self.controlNode:getTranslationY()
  local strength = transY / self:getControlRange()

  return strength
end

function UIScrollBar:setStrength(str)
  local transY = str * self:getControlRange()
  self.prevYPosition = transY
  self:moveControlNode(transY)
  self.position.number = self:getStrength()
  self.position:sync()
end

function UIScrollBar:addNodeAndRelease(node)
  self.scene:addNode(node)
  node:release()

  return node
end

function UIScrollBar_onTouchDown(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  UIScrollBar.sharedInstance.isDragging = true
  UIScrollBar.sharedInstance.prevYPosition = pos.y
end

function UIScrollBar_onTouchMove(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()
  local prevTransY = UIScrollBar.sharedInstance.controlNode:getTranslationY()
  local gapY = UIScrollBar.sharedInstance.prevYPosition - pos.y
  local translationY = prevTransY + (gapY * 1.7)

  UIScrollBar.sharedInstance.prevYPosition = pos.y

  UIScrollBar.sharedInstance:moveControlNode(translationY)
  UIScrollBar.sharedInstance.position.number = UIScrollBar.sharedInstance:getStrength()
end

function UIScrollBar_onTouchUp(event)
  UIScrollBar.sharedInstance.isDragging = false
  UIScrollBar.sharedInstance.position:sync()
end

function UIScrollBar:moveControlNode(translationY)
  if (translationY < 0.0 or translationY > self:getControlRange()) then
    return
  end

  self.controlNode:setTranslationY(translationY)
end

function UIScrollBar:floatingImage(filePath, x, y, width, height, blendMode, baseHeight)
  local halfHeight = baseHeight / 2.0
  local imageX = (x - 187.5) / 187.5
  local imageY = (y - halfHeight) / halfHeight
  local imageWidth = width * 2 / 375.0
  local imageHeight = height * 2 / baseHeight
  return KuruFloatingImageNode.create(BASE_DIRECTORY .. filePath,
    imageX, imageY, imageWidth, imageHeight, blendMode
  )
end

function UIScrollBar:floatingImageWithSampler(sampler, x, y, width, height, blendMode, baseHeight)
  local halfHeight = baseHeight / 2.0
  local imageX = (x - 187.5) / 187.5
  local imageY = (y - halfHeight) / halfHeight
  local imageWidth = width * 2 / 375.0
  local imageHeight = height * 2 / baseHeight
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
  return self:is9to16() and CONTROL_RANGE or CONTROL_RANGE * (4.0 / 3.0)
end

function UIScrollBar:digitCount(n)
    local i = 1

    while n >= 10^i do
        i = i + 1
    end

    return i
end
