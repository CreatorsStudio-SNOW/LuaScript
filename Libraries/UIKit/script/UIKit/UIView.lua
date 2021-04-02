------- class variables ---------
-- baseWidth
-- baseHeight
-- scene
---------------------------------

------- member variables --------
-- texture
-- rect
-- node
-- subViews
-- enableOnlyPreview
-- enabled
-- enableDeliverNextResponder
---------------------------------

UIView = {
  baseWidth = 0.0, -- static variable
  baseHeight = 0.0, -- static variable
  tag = nil
}


function UIView:new(rect, texturePath, enableOnlyPreview, enabled, enableDeliverNextResponder, tag)
  local newView = {}

  setmetatable(newView, self)
  self.__index = self

  newView.rect = rect or nil

  if (texturePath == nil) then
    newView.texture = nil
  else
    newView.texture = Texture.create(BASE_DIRECTORY .. texturePath)
  end

  newView.subViews = {}
  newView.enabled = (enabled == nil) and true or enabled
  newView.enableOnlyPreview = (enableOnlyPreview == nil) and true or enableOnlyPreview
  newView.enableDeliverNextResponder = (enableDeliverNextResponder == nil) and true or enableDeliverNextResponder
  newView.tag = tag

  return newView
end

function UIView:addSubView(subView)
  self.subViews[#self.subViews + 1] = subView
end

function UIView:frameReady(elapsedTime)
  if (not self.enabled) then
    return
  end

  if (self.enableOnlyPreview) then
    local enabled = SceneRenderConfig.instance():isRenderModePreview()

    if (self.node ~= nil) then
      self.node:setEnabled(enabled)
    end
  end

  for i = 1, #self.subViews do
    local subView = self.subViews[i]

    if (subView ~= nil) then
      subView:frameReady(elapsedTime)
    end
  end
end

function UIView:setEnabled(enabled)
  self.enabled = enabled

  if (self.node ~= nil) then
    self.node:setEnabled(self.enabled)
  end
end

function UIView:addSubViewsToScene()
  local rect = self.rect

  for i = 1, #self.subViews do
    local subView = self.subViews[i]

    if (subView ~= nil) then
      subView:addToScene(rect.x, rect.y)
    end
  end
end

-- alpha는 7.8.0 이상
function UIView:addToScene(parentX, parentY)
  if (self.texture) then
    self.node = self:getFloatingImageNode(parentX, parentY)
    self:addNodeAndRelease(self.node)
  end

  self:addSubViewsToScene()
end

function UIView:getFloatingImageNode(parentX, parentY)
  local rect = self.rect
  local rectOnScene = UIRect:new(rect.x + parentX, rect.y + parentY, rect.width, rect.height)

  rectOnScene:normalizeToVertex(self.baseWidth, self.baseHeight)

  local node = KuruFloatingImageNode.createFromTexture(self.texture,
    rectOnScene.x, rectOnScene.y, rectOnScene.width, rectOnScene.height, BlendMode.None
  )

  node:getSampler():setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  return node
end

function UIView:updateLayout(parentX, parentY)
  if (self.node ~= nil) then
    local vertexRect = self:getVertexRect(parentX, parentY)

    self.node:setRect(vertexRect.x, vertexRect.y, vertexRect.width, vertexRect.height)
  end

  local rect = self.rect

  for i = 1, #self.subViews do
    local subView = self.subViews[i]

    if (subView ~= nil) then
      subView:updateLayout(rect.x, rect.y)
    end
  end
end

function UIView:getVertexRect(parentX, parentY)
  local rect = self.rect
  local rectOnScene = UIRect:new(rect.x + parentX, rect.y + parentY, rect.width, rect.height)

  rectOnScene:normalizeToVertex(self.baseWidth, self.baseHeight)

  return rectOnScene
end

function UIView:onTouchDown(event)
  self:deliverTouchDownIfNeeded(event)
end

function UIView:onTouchMove(event)
  self:deliverTouchMoveIfNeeded(event)
end

function UIView:onTouchUp(event)
  self:deliverTouchUpIfNeeded(event)
end

function UIView:deliverTouchDownIfNeeded(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos) and self.enableDeliverNextResponder) then
    for i = 1, #self.subViews do
      local subView = self.subViews[i]

      if (subView ~= nil) then
        subView:onTouchDown(event)
      end
    end
  end
end

function UIView:deliverTouchMoveIfNeeded(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos) and self.enableDeliverNextResponder) then
    for i = 1, #self.subViews do
      local subView = self.subViews[i]

      if (subView ~= nil) then
        subView:onTouchMove(event)
      end
    end
  end
end

function UIView:deliverTouchUpIfNeeded(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos) and self.enableDeliverNextResponder) then
    for i = 1, #self.subViews do
      local subView = self.subViews[i]

      if (subView ~= nil) then
        subView:onTouchUp(event)
      end
    end
  end
end

function UIView:isTouched(touchPoint)
  return self:isTouchedByCustomRect(touchPoint, self.rect)
end

function UIView:isTouchedByCustomRect(touchPoint, rect)
  if (not self.enabled) then
    return false
  end

  -- local touchPosX = self:convertedXTouchByDeviceRatio(touchPoint.x)
  -- local touchPosY = self:convertedYTouchByDeviceRatio(touchPoint.y)
  local touchPosX = touchPoint.x
  local touchPosY = touchPoint.y
  local leftX = rect.x / self.baseWidth
  local bottomY = rect.y / self.baseHeight
  local width = rect.width / self.baseWidth
  local height = rect.height / self.baseHeight
  local rightX = leftX + width
  local topY = bottomY + height
  local touchPointY = 1.0 - touchPosY

  return (touchPosX >= leftX and touchPosX <= rightX and touchPointY >= bottomY and touchPointY <= topY)
end

function UIView:convertedXTouchByDeviceRatio(touchPosition)
  local deviceRatio = DeviceConfig.instance():getResolution().x / DeviceConfig.instance():getResolution().y

  local scale = 0.5625 / deviceRatio

  if (scale > 1.0) then
    -- if (not isOverOrSameVersion(7, 10, 0) and DeviceConfig.instance().platformType == DeviceConfigPlatformType.P_IOS) then
    --   return touchPosition
    -- else
    scale = deviceRatio / 0.5625
    -- end
  end

  touchPosition = touchPosition - 0.5
  touchPosition = touchPosition / scale
  touchPosition = touchPosition + 0.5

  return touchPosition
end

function UIView:convertedYTouchByDeviceRatio(touchPosition)
  -- if (not isOverOrSameVersion(7, 10, 0) and DeviceConfig.instance().platformType == DeviceConfigPlatformType.P_IOS) then
  --   return touchPosition
  -- end

  local deviceRatio = DeviceConfig.instance():getResolution().x / DeviceConfig.instance():getResolution().y
  local scale = 0.5625 / deviceRatio

  touchPosition = touchPosition - 0.5

  if (scale > 1.0) then
    touchPosition = touchPosition * scale
  else
    touchPosition = touchPosition / scale
  end

  touchPosition = touchPosition + 0.5

  return touchPosition
end

function UIView:addNodeAndRelease(node)
  self.scene:addNode(node)
  node:release()

  return node
end

function UIView:print()
  print("-- UIView print --")
  print("x : " .. self.rect.x)
  print("y : " .. self.rect.y)
  print("width : " .. self.rect.width)
  print("height : " .. self.rect.height)
  print("baseWidth : " .. self.baseWidth)
  print("baseHeight : " .. self.baseHeight)
  print("------------------")
end

function UIView:release()
  if (self.texture ~= nil) then
    self.texture:release()
    self.texture = nil
  end
end
