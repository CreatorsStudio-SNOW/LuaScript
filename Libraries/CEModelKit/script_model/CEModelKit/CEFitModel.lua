CEFaceFitModel = CEModelComponent:new()

function CEFaceFitModel.createFaceFitModel(modelPath, stickerInfo)
  local instance = {}
  if stickerInfo == nil then
    stickerInfo = {}
  end

  local faceOffset = stickerInfo.faceOffset or Vector3.create(0, 0, 0)
  local scale = stickerInfo.scale or 1.0
  local useNormal = stickerInfo.userNormal or true
  local fillEye = stickerInfo.fillEye or false
  local fillMouth = stickerInfo.fillEye or false

  setmetatable(instance, CEFaceModel)
  CEFaceModel.__index = CEFaceModel

  instance.node = KaleFaceFittingNode.create(KaleFaceFittingNodeBuilder.create():useNormal(useNormal):fillEye(fillEye):fillMouth(fillMouth):path(BASE_DIRECTORY .. modelPath):build())
  instance.node:setScale(scale, scale, scale)
  local item = StickerItem.create()
  item:getConfig().faceOffset = faceOffset
  instance.node:setStickerItem(item)
  instance:setModel(instance.node)

  return instance
end

function CEFaceFitModel:getNode()
  return self.node
end
