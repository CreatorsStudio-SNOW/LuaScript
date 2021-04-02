------- class variables ---------
-- numTextures
---------------------------------

require "DateKit/Date.lua"
require "DateKit/DateUtil.lua"

DateKit = {
  scene = nil,
  -- dateUtil = nil
}

function DateKit.create(scene)
  local newObject = {}

  setmetatable(newObject, DateKit)
  DateKit.__index = DateKit
  newObject.scene = scene
  -- newObject.dateUtil = DateUtil.new()

  return newObject
end

function DateKit:getFrameBuffer(format, isHorizontal)
  local isHorizontalMode = isHorizontal or true
  local isNumFormat = DateUtil.isNumFormat(format)
  local textures = DateUtil.getTextures(format)

  if (isHorizontal) then
    local texturesTotalWidth = 0.0
    local xPosition = -1.0

    if (isNumFormat) then
      local texturesSumWidth = DateUtil.getSumWidthFromTextures(textures)

      texturesTotalWidth = DateUtil.getTotalWidthFromTextures(textures)
      xPosition = -1.0 + ((texturesTotalWidth - texturesSumWidth) / texturesTotalWidth)
    else
      texturesTotalWidth = DateUtil.getSumWidthFromTextures(textures)
    end

    local texturesTotalHeight = DateUtil.getMaxHeightFromTextures(textures)
    local frameBufferNode = KuruFrameBufferNode.createWithSize(math.floor(texturesTotalWidth), math.floor(texturesTotalHeight))

    self.scene:addNodeAndRelease(frameBufferNode)

    for i = 1, #textures do
      local texture = textures[i]
      local textureSize = texture:getSize()
      local textureWidth = textureSize.x
      local textureHeight = textureSize.y

      textureHeight = (textureHeight / texturesTotalHeight) * 2.0

      local yPosition = -1.0 + ((2.0 - textureHeight) / 2.0)

      textureWidth = (textureWidth / texturesTotalWidth) * 2.0

      local floatingImageNode = KuruFloatingImageNode.createFromTexture(texture, xPosition, yPosition, textureWidth, textureHeight, BlendMode.None)

      frameBufferNode:addChildAndRelease(floatingImageNode)
      xPosition = xPosition + textureWidth
    end

    return frameBufferNode
  else
    local texturesTotalHeight = 0.0
    local yPosition = 1.0

    if (isNumFormat) then
      local texturesSumHeight = DateUtil.getSumHeightFromTextures(textures)

      texturesTotalHeight = DateUtil.getTotalHeightFromTextures(textures)
      yPosition = 1.0 - ((texturesTotalHeight - texturesSumHeight) / texturesTotalHeight)
    else
      texturesTotalHeight = DateUtil.getSumHeightFromTextures(textures)
    end

    local texturesTotalWidth = DateUtil.getMaxWidthFromTextures(textures)
    local frameBufferNode = KuruFrameBufferNode.createWithSize(math.floor(texturesTotalWidth), math.floor(texturesTotalHeight))

    self.scene:addNodeAndRelease(frameBufferNode)

    local yPosition = 1.0

    for i = 1, #textures do
      local texture = textures[i]
      local textureSize = texture:getSize()
      local textureWidth = textureSize.x
      local textureHeight = textureSize.y

      textureWidth = (textureWidth / texturesTotalWidth) * 2.0

      local xPosition = -1.0 + ((2.0 - textureWidth) / 2.0)

      textureHeight = (textureHeight / texturesTotalHeight) * 2.0
      yPosition = yPosition - textureHeight

      local floatingImageNode = KuruFloatingImageNode.createFromTexture(texture, xPosition, yPosition, textureWidth, textureHeight, BlendMode.None)

      frameBufferNode:addChildAndRelease(floatingImageNode)
    end

    return frameBufferNode
  end
end

function DateKit:frameReady(scene)
  DateUtil.updateElapsedtime(scene)
end

function DateKit:release()
  DateUtil.release()
end
