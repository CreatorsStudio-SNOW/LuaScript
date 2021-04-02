CEModel = CEModelComponent:new()

function CEModel.createModel(modelPath, stickerInfo)
  local instance = {}
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local faceOffset = stickerInfo.faceOffset or Vector3.create(0, 0, 0)

  local scaleX = stickerInfo.scaleX or 1.0
  local scaleY = stickerInfo.scaleY or 1.0
  local scaleZ = stickerInfo.scaleZ or 1.0
  local rotateXYZ = stickerInfo.rotateXYZ or Vector3.create(0, 0, 0)
  local translateX = stickerInfo.translateX or 0
  local translateY = stickerInfo.translateY or 0
  local translateZ = stickerInfo.translateZ or 0

  setmetatable(instance, CEModel)
  CEModel.__index = CEModel

  instance.node = KuruModelNode.createFromModelPath(BASE_DIRECTORY .. modelPath)
  instance.node:setScale(scaleX, scaleY, scaleZ)
  instance.node:setTranslation(translateX, translateY, translateZ)

  local item = StickerItem.create()
  item.rotateXYZ = rotateXYZ
  instance.node:setStickerItem(item)
  instance:setModel(instance.node)

  return instance
end

function CEModel:getNode()
  return self.node
end
