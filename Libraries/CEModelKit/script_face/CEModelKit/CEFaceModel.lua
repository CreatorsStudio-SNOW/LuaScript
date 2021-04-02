CEFaceModel = CEModelComponent:new()

function CEFaceModel.createFaceModel(modelPath, stickerInfo)
  local instance = {}
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local faceOffset = stickerInfo.faceOffset or Vector3.create(0, 0, 0)

  local scale = stickerInfo.scale or 1.0
  local rotateXYZ = stickerInfo.rotateXYZ or Vector3.create(0, 0, 0)
  local faceRotationMultiplyFactor = stickerInfo.faceRotationMultiplyFactor or Vector3.create(1, 1, 1)
  local useFaceRecalculateExcludeChin = stickerInfo.useFaceRecalculateExcludeChin or false
  local useFaceRecalculate = stickerInfo.useFaceRecalculate or false

  setmetatable(instance, CEFaceModel)
  CEFaceModel.__index = CEFaceModel

  instance.node = KaleFaceModelNode.create(BASE_DIRECTORY .. modelPath)
  local item = StickerItem.create()
  item:getConfig().useFaceRecalculateExcludeChin = useFaceRecalculateExcludeChin
  item:getConfig().faceOffset = faceOffset
  item:getConfig().faceRotationMultiplyFactor = faceRotationMultiplyFactor
  item:getConfig().useFaceRecalculate = useFaceRecalculate
  item.rotateXYZ = rotateXYZ
  item.scale = scale
  instance.node:setStickerItem(item)
  instance.node:setFlipHorizontally(false)
  instance:setModel(instance.node)

  return instance
end

function CEFaceModel:getNode()
  return self.node
end
