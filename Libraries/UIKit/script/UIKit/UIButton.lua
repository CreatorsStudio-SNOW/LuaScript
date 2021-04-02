
------- member variables --------
-- super
-- touchCallback
-- isSelected
-- textureSelected
-- texturePressed
-- textureSelectPressed
-- didTouchDown
-- isOverlapSelectedImage
-- overlapNode
-- touchDownPos
---------------------------------

UIButton = UIView:new()

function UIButton:new(rect, normalImagePath, selectedImagePath, touchCallback, isOverlapSelectedImage, enabled, tag)
  local newButton = {}

  setmetatable(newButton, self)
  self.__index = self

  newButton.super = getmetatable(UIButton)
  newButton.rect = rect or nil
  newButton.isSelected = false
  newButton.texture = nil

  if (normalImagePath ~= nil) then
    newButton.texture = Texture.create(BASE_DIRECTORY .. normalImagePath)
  end

  newButton.textureSelected = nil

  if (selectedImagePath ~= nil) then
    newButton.textureSelected = Texture.create(BASE_DIRECTORY .. selectedImagePath)
  end

  newButton.texturePressed = nil
  newButton.textureSelectPressed = nil

  newButton.touchCallback = touchCallback or nil
  newButton.enabled = (enabled == nil) and true or enabled
  newButton.isOverlapSelectedImage = (isOverlapSelectedImage == nil) and false or isOverlapSelectedImage
  newButton.didTouchDown = false
  newButton.overlapNode = nil
  newButton.touchDownPos = { x = 0.0, y = 0.0}
  newButton.tag = tag

  return newButton
end

function UIButton:onTouchDown(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos)) then
    self.didTouchDown = true
    self.touchDownPos.x = pos.x
    self.touchDownPos.y = pos.y
    self:setPressedTextureIfNeeded()
  end

  self:deliverTouchMoveIfNeeded(event)
end

function UIButton:onTouchMove(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (not self:isTouched(pos)) then
    self.didTouchDown = false

    self:setOriginPathIfNeeded()
  end

  self:deliverTouchMoveIfNeeded(event)
end

function UIButton:onTouchUp(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos) and self.didTouchDown) then
    local isValidTouch = (self:getDistance(self.touchDownPos, pos)) < 0.001 and true or false

    if (isValidTouch) then
      self.touchCallback(self)
    end
  else
    self.didTouchDown = false
  end

  self:deliverTouchUpIfNeeded(event)

  self:setOriginPathIfNeeded()
end

function UIButton:getDistance(pos1, pos2)
  local distance = (pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.y - pos2.y) * (pos1.y - pos2.y)

  return distance
end

function UIButton:addToScene(parentX, parentY)
  if (self.texture) then
    self.node = self:getFloatingImageNode(self.texture, parentX, parentY)
    self:addNodeAndRelease(self.node)
  end

  if (self.isOverlapSelectedImage and self.textureSelected ~= nil) then
    self.overlapNode = self:getFloatingImageNode(self.textureSelected, parentX, parentY)
    self:addNodeAndRelease(self.overlapNode)
    self.overlapNode:setEnabled(false)
  end

  self:addSubViewsToScene()
end

function UIButton:getFloatingImageNode(texture, parentX, parentY)
  local rect = self.rect
  local rectOnScene = UIRect:new(rect.x + parentX, rect.y + parentY, rect.width, rect.height)

  rectOnScene:normalizeToVertex(self.baseWidth, self.baseHeight)

  local node = KuruFloatingImageNode.createFromTexture(texture,
    rectOnScene.x, rectOnScene.y, rectOnScene.width, rectOnScene.height, BlendMode.None
  )

  node:getSampler():setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  return node
end

function UIButton:isTouched(touchPoint)
  if (not self.enabled) then
    return false
  end

  if (self.texture == nil) then
    return self:isTouchedByCustomRect(touchPoint, self.rect)
  end

  -- local touchPosX = self:convertedXTouchByDeviceRatio(touchPoint.x)
  -- local touchPosY = self:convertedYTouchByDeviceRatio(touchPoint.y)

  return (self.node:hitTest(touchPoint.x, touchPoint.y, nil))
end

function UIButton:setPressedPath(pressedImagePath)
  self.texturePressed = Texture.create(BASE_DIRECTORY .. pressedImagePath)
end

function UIButton:setSelectPressedPath(selectPressedImagePath)
  self.textureSelectPressed = Texture.create(BASE_DIRECTORY .. selectPressedImagePath)
end

function UIButton:setSelected(selected)
  self.isSelected = selected

  if (self.node == nil) then
    return
  end
  if (self.isOverlapSelectedImage and self.overlapNode ~= nil) then
    local enabled = self.isSelected and true or false

    self.overlapNode:setEnabled(enabled)
  else
    local texture = self.isSelected and self.textureSelected or self.texture
    self.node:getSampler():setTexture(texture)
  end
end

function UIButton:setPressedTextureIfNeeded()
  if (self.isSelected) then
    if (self.textureSelectPressed ~= nil) then
      self.node:getSampler():setTexture(self.textureSelectPressed)
    end
  else
    if (self.texturePressed ~= nil) then
      self.node:getSampler():setTexture(self.texturePressed)
    end
  end

  if (self.isOverlapSelectedImage and self.overlapNode ~= nil) then
    self.overlapNode:setEnabled(false)
  end
end


function UIButton:setEnabled(enabled)
  self.enabled = enabled

  if (self.isOverlapSelectedImage and self.overlapNode ~= nil) then
    local selected = self.isSelected and true or false

    self.overlapNode:setEnabled(enabled and selected)
  end

  if (self.node ~= nil) then
    self.node:setEnabled(self.enabled)
  end
end

function UIButton:setOriginPathIfNeeded()
  if (self.texturePressed == nil) then
    return
  end

  if (self.isOverlapSelectedImage and self.overlapNode ~= nil) then
    local enabled = self.isSelected and true or false

    self.node:getSampler():setTexture(self.texture)
    self.overlapNode:setEnabled(enabled)
  else
    local texture = self.isSelected and self.textureSelected or self.texture
    self.node:getSampler():setTexture(texture)
  end
end

function UIButton:release()
  if (self.textureSelected ~= nil) then
    self.textureSelected:release()
    self.textureSelected = nil
  end

  if (self.texturePressed ~= nil) then
    self.texturePressed:release()
    self.texturePressed = nil
  end

  if (self.textureSelectPressed ~= nil) then
    self.textureSelectPressed:release()
    self.textureSelectPressed = nil
  end

  if (self.texture ~= nil) then
    self.texture:release()
    self.texture = nil
  end

  self.super:release()
end
