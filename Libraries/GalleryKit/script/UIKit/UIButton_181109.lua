
------- member variables --------
-- super
-- touchCallback
-- isSelected
-- textureSelected
-- texturePressed
-- didTouchDown
---------------------------------

UIButton = UIView:new()

function UIButton:new(rect, normalImagePath, selectedImagePath, touchCallback, id, enabled)
  local newButton = {}

  setmetatable(newButton, self)
  self.__index = self

  newButton.super = getmetatable(UIButton)
  newButton.rect = rect or nil
  newButton.isSelected = false
  newButton.texture = Texture.create(BASE_DIRECTORY .. normalImagePath)
  newButton.textureSelected = Texture.create(BASE_DIRECTORY .. selectedImagePath)
  newButton.texturePressed = nil
  newButton.touchCallback = touchCallback or nil
  newButton.enabled = (enabled == nil) and true or enabled
  newButton.didTouchDown = false
  newButton.id = id
  newButton.eventEnabled = true

  return newButton
end

function UIButton:onTouchDown(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if (self:isTouched(pos)) then
    self.didTouchDown = true
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
    self.touchCallback(self)
  else
    self.didTouchDown = false
  end

  self:deliverTouchUpIfNeeded(event)

  self:setOriginPathIfNeeded()
end

function UIButton:setEventEnabled(enable)
  self.eventEnabled = enable
end

function UIButton:isTouched(touchPoint)
  -- if (not self.enabled) then
  --   return false
  -- end

  if (not self.eventEnabled) then
    return false
  end

  local touchPosX = touchPoint.x
  local touchPosY = touchPoint.y

  return (self.node:hitTest(touchPosX, touchPosY, nil))
end

function UIButton:setPressedPath(pressedImagePath)
  self.texturePressed = Texture.create(BASE_DIRECTORY .. pressedImagePath)
end

function UIButton:setSelected(selected)
  self.isSelected = selected

  if (self.node == nil) then
    return
  end

  local texture = self.isSelected and self.textureSelected or self.texture
  self.node:getSampler():setTexture(texture)
end

function UIButton:setPressedTextureIfNeeded()
  if (self.texturePressed == nil) then
    return
  end

  self.node:getSampler():setTexture(self.texturePressed)
end

function UIButton:setOriginPathIfNeeded()
  if (self.texturePressed == nil) then
    return
  end

  local texture = self.isSelected and self.textureSelected or self.texture
  self.node:getSampler():setTexture(texture)
end

function UIButton:getId()
  if (self.id == nil) then
    return -1
  else
    return self.id
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

  if (self.texture ~= nil) then
    self.texture:release()
    self.texture = nil
  end

  self.super:release()
end
