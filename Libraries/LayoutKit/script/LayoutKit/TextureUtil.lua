TextureUtil = {}

function TextureUtil:new(rootPath)
  local newObject = {}

  setmetatable(newObject, self)
  self.__index = self


  newObject.rootPath = rootPath or (BASE_DIRECTORY .. 'images/')
  newObject.textureTable = {}

  return newObject
end

function TextureUtil:getTexturesFromTable(prefix, table)
  local result = {}
  for i = 1, #table do
    result[i] = self:getSingleTexture(prefix, table[i])
  end

  return result
end

function TextureUtil:getSingleTexture(prefix, subKey)
  local prefixKey = prefix or "images/"
  if self.textureTable[prefixKey] == nil then
    self.textureTable[prefixKey] = {}
  end

  if self.textureTable[prefixKey][subKey] == nil then
    local texturePath = self.rootPath .. prefixKey .. subKey .. ".png"
    local texture = Texture.create(texturePath)

    self.textureTable[prefixKey][subKey] = texture
  end

  return self.textureTable[prefixKey][subKey]
end

function TextureUtil:getTextures(prefix, format)
  return { self:getSingleTexture(prefix, format) }
end

function TextureUtil:release()
  for k, v in pairs(self.textureTable) do
    for subKey, texture in pairs(v) do
      texture:release()
      v[subKey] = nil
    end
    for i, texture in ipairs(v) do
      texture:release()
      v[i] = nil
    end
    self.textureTable[k] = nil
  end
end

function TextureUtil.getMaxHeightFromTextures(textures)
  local maxHeight = 0.0

  for i = 1, #textures do
    local textureHeight = textures[i]:getHeight()

    if (textureHeight > maxHeight) then
      maxHeight = textureHeight
    end
  end

  return maxHeight
end

function TextureUtil.getMaxWidthFromTextures(textures)
  local maxWidth = 0.0

  for i = 1, #textures do
    local textureWidth = textures[i]:getWidth()

    if (textureWidth > maxWidth) then
      maxWidth = textureWidth
    end
  end

  return maxWidth
end

function TextureUtil.getTotalWidthFromTextures(textures, betweenMargin)
  local texturesCount = #textures
  local totalBetweenMargin = betweenMargin * (texturesCount - 1)
  local totalWidth = 0.0

  for i = 1, texturesCount do
    local textureWidth = textures[i]:getWidth()

    totalWidth = totalWidth + textureWidth
  end

  totalWidth = totalWidth + totalBetweenMargin

  return totalWidth
end

function TextureUtil.getTotalHeightFromTextures(textures, betweenMargin)
  local texturesCount = #textures
  local totalBetweenMargin = betweenMargin * (texturesCount - 1)
  local totalHeight = 0.0

  for i = 1, texturesCount do
    local textureHeight = textures[i]:getHeight()

    totalHeight = totalHeight + textureHeight
  end

  totalHeight = totalHeight + totalBetweenMargin

  return totalHeight
end
