
------- member variables --------
-- textureUtil
-- format
-- prefix
-- textures
-- betweenMargin
-- rect = { x, y, width, height }
-- margins = { left, top }
-- nodes
-- isHorizonOrientation
-- blendMode
---------------------------------

LView = {}

function LView:new(textureUtil, format, betweenMargin, isHorizonOrientation, prefix, blendMode)
  local newView = {}

  setmetatable(newView, self)
  self.__index = self

  newView.format = format
  newView.prefix = prefix or nil
  newView.textures = textureUtil:getTextures(prefix, format)
  newView.betweenMargin = betweenMargin or 0.0
  newView.isHorizonOrientation = (isHorizonOrientation == nil) and true or isHorizonOrientation
  newView.rect = {}
  newView.margins = {}
  newView.nodes = {}
  newView.blendMode = blendMode or BlendMode.None

  return newView
end

function LView:getFloatingNodes(baseWidth, baseHeight, sceneHeight)
  if (self.textures == nil) then
    return nil
  end

  local textures = self.textures

  if (self.isHorizonOrientation) then
    local prevRightX = self.rect.x
    local textureY = baseHeight - (sceneHeight - self.rect.y)

    for i = 1, #textures do
      local width = textures[i]:getWidth()
      local height = textures[i]:getHeight()
      local x = (i == 1) and prevRightX or prevRightX + self.betweenMargin

      prevRightX = x + width

      local textureRect = { x = x, y = textureY, width = width, height = height }
      local vertexRect = self:getVertexRect(textureRect, baseWidth, baseHeight)

      self.nodes[i] = self:getFloatingImageWithTexture(textures[i], vertexRect)
    end
  else
    local prevBottomY = baseHeight - (sceneHeight - self.rect.y)
    local textureX = self.rect.x

    for i = #textures, 1, -1 do
      local width = textures[i]:getWidth()
      local height = textures[i]:getHeight()
      local y = (i == 1) and prevBottomY or prevBottomY + self.betweenMargin

      prevBottomY = y + height

      local textureRect = { x = textureX, y = y, width = width, height = height }
      local vertexRect = self:getVertexRect(textureRect, baseWidth, baseHeight)

      self.nodes[i] = self:getFloatingImageWithTexture(textures[i], vertexRect)
    end
  end

  return self.nodes
end

function LView:getFloatingImageWithTexture(texture, rect)
  return KuruFloatingImageNode.createFromTexture(texture, rect.x, rect.y, rect.width, rect.height, self.blendMode)
end

function LView:getVertexRect(rect, baseWidth, baseHeight)
  local halfWidth = baseWidth / 2.0
  local imageX = (rect.x - halfWidth) / halfWidth
  local halfHeight = baseHeight / 2.0
  local imageY = (rect.y - halfHeight) / halfHeight
  local imageWidth = rect.width * 2 / baseWidth
  local imageHeight = rect.height * 2 / baseHeight

  return {
    x = imageX,
    y = imageY,
    width = imageWidth,
    height = imageHeight
  }
end

function LView:updateRect()
  if (self.isHorizonOrientation) then
    self.rect.height = TextureUtil.getMaxHeightFromTextures(self.textures)
    self.rect.width = TextureUtil.getTotalWidthFromTextures(self.textures, self.betweenMargin)
  else
    self.rect.height = TextureUtil.getTotalHeightFromTextures(self.textures, self.betweenMargin)
    self.rect.width = TextureUtil.getMaxWidthFromTextures(self.textures)
  end
end

function LView:printRect()
  print("-----------------")
  print("vertex X : " .. self.rect.x)
  print("vertex Y : " .. self.rect.y)
  print("vertex width : " .. self.rect.width)
  print("vertex height : " .. self.rect.height)
  print("-----------------")
end
