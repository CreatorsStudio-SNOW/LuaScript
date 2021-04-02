CEARModel = CEModelComponent:new()

function CEARModel.createModel(modelPath, stickerInfo)
  local instance = {}
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local scaleX = stickerInfo.scaleX or 1.0
  local scaleY = stickerInfo.scaleY or 1.0
  local scaleZ = stickerInfo.scaleZ or 1.0
  local translateX = stickerInfo.translateX or 0.0
  local translateY = stickerInfo.translateY or 0.0
  local translateZ = stickerInfo.translateZ or 0.0
  local minScale = stickerInfo.minScale or 0.001
  local maxScale = stickerInfo.maxScale or 0.1
  local rotateXYZ = stickerInfo.rotateXYZ or Vector3.create(1, 1, 1)
  local isBillboard = stickerInfo.billboard or false
  local nodeTouch = stickerInfo.nodeTouch or false

  setmetatable(instance, CEARModel)
  CEARModel.__index = CEARModel

  instance.builder = KuruAR3DNodeBuilder.create():path(BASE_DIRECTORY .. modelPath):billboard(isBillboard):nodeTouch(nodeTouch):build()
  instance.node = KuruAR3DNode.create(instance.builder)
  instance.node:setScale(scaleX, scaleY, scaleZ)
  instance.node:setTranslation(translateX, translateY, translateZ)
  local item = StickerItem.create()
  item.rotateXYZ = rotateXYZ
  item.minScale = minScale
  item.maxScale = maxScale
  instance.node:setStickerItem(item)
  instance:setModel(instance.node)

  return instance
end

function CEARModel:getNode()
  return self.node
end
