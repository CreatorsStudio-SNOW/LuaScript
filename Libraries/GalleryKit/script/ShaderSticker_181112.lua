
ShaderSticker = {}
ShaderSticker.g_aspectRatio = 0.5625

function ShaderSticker:new(filePath, samplerWidth, samplerHeight, stickerInfo)
  local newObject = {}
  setmetatable(newObject, self)
  self.__index = self
  stickerInfo = stickerInfo or {}

  if type(filePath) == "string" then
    newObject.sampler = TextureSampler.create(BASE_DIRECTORY .. filePath, false, false)
  else
    newObject.sampler = TextureSampler.createWithTexture(filePath)
  end

  local width = samplerWidth or newObject.sampler:getTexture():getWidth()
  local height = samplerHeight or newObject.sampler:getTexture():getHeight()
  newObject.stickerRatio = width / height

  newObject.baseMatrix = Matrix.createFromMatrix(Matrix.identity())
  if stickerInfo.aspectRatio == Nil then

  elseif stickerInfo.aspectRatio ~= 1 then
    ShaderSticker.g_aspectRatio = 0.75
  end
  newObject.baseMatrix:postScale(1.0, ShaderSticker.g_aspectRatio / newObject.stickerRatio, 1.0)

  local quadFullMesh = Mesh.createQuadFullscreen()
  local model = Model.create(quadFullMesh)
  quadFullMesh:release()

  newObject.material = Material.createWithShaderFile("res/shaders/passthrough.vert", BASE_DIRECTORY .. "ShaderSticker.frag", Nil)
  newObject.material:getParameter("u_worldViewProjectionMatrix"):setMatrix(newObject.baseMatrix)
  newObject.material:getParameter("u_fragMat"):setMatrix(Matrix.identity())

  local blendSrc = stickerInfo.blendSrc or RenderStateBlend.BLEND_SRC_ALPHA
  local stateBlock = newObject.material:getStateBlock()
  stateBlock:setBlend(true)
  stateBlock:setBlendSrc(blendSrc)
  stateBlock:setBlendDst(RenderStateBlend.BLEND_ONE_MINUS_SRC_ALPHA)
  newObject.material:getParameter("u_texture"):setSampler(newObject.sampler)
  model:setMaterial(newObject.material, -1)
  newObject.material:release()
  newObject.sampler:release()
  newObject.node = KuruModelNode.createFromModel(model)
  model:release()
  stickerInfo.scaleX = stickerInfo.width /720 * 2
  stickerInfo.scaleY = stickerInfo.width /720 * 2

  newObject.scaleX_v = stickerInfo.scaleX
  newObject.scaleY_v = stickerInfo.scaleY
  newObject.scaleX_h = stickerInfo.scaleX * stickerInfo.scaleH34    -- 3/4
  newObject.scaleY_h = stickerInfo.scaleY * stickerInfo.scaleH34
  newObject.scaleX_h2 = stickerInfo.scaleX * stickerInfo.scaleH16     -- 9/16
  newObject.scaleY_h2 = stickerInfo.scaleY * stickerInfo.scaleH16
  newObject.translateX_v = stickerInfo.tx
  newObject.translateY_v = stickerInfo.ty
  newObject.translateX_h = stickerInfo.tx / stickerInfo.scaleH34
  newObject.translateY_h = stickerInfo.ty / stickerInfo.scaleH34
  newObject.translateX_h2 = stickerInfo.tx / stickerInfo.scaleH16
  newObject.translateY_h2 = stickerInfo.ty / stickerInfo.scaleH16
  newObject.rotateZ_1 = stickerInfo.rotateZ
  newObject.rotateZ_2 = 0
  newObject.enabled = stickerInfo.enabled

  print("init shadersticker")
  -- self.ALL_SHADERSTICKER[#self.ALL_SHADERSTICKER + 1] = newObject

  return newObject
end

function ShaderSticker:disableAllNodes()
  for i,v in ipairs(self.ALL_SHADERSTICKER) do
    v.node:setEnabled(false)
  end
end

function ShaderSticker:enableNode(id, enabled)
  print("try enable sticker ".. tostring(id) .. " "..tostring(enabled))
  self.ALL_SHADERSTICKER[id].enabled = enabled
end

function ShaderSticker:isEnabled(id)
  local enabled = self.ALL_SHADERSTICKER[id].enabled
  print("id "..tostring(id) .. " is enabled : " .. tostring(enabled))
  return enabled
end

function ShaderSticker:updateSampler(path)
  -- self:release()

  if type(path) == "string" then
    self.sampler = TextureSampler.create(BASE_DIRECTORY .. path, false, false)
  else
    self.sampler = TextureSampler.createWithTexture(path)
  end

  local width = self.sampler:getTexture():getWidth()
  local height = self.sampler:getTexture():getHeight()

  self.stickerRatio = width / height
  if self.stickerRatio > 1.1 and self.stickerRatio < 1.6 then
    self.isHorizontal = 1
  elseif self.stickerRatio >= 1.6 then
    self.isHorizontal = 2
  else
    self.isHorizontal = 0
  end
  print("sticker ratio : "..tostring(self.stickerRatio))

  self.material:getParameter("u_texture"):setSampler(self.sampler)
  self.baseMatrix = Matrix.createFromMatrix(Matrix.identity())
  self.baseMatrix:postScale(1.0, ShaderSticker.g_aspectRatio / self.stickerRatio, 1.0)
  self.material:getParameter("u_worldViewProjectionMatrix"):setMatrix(self.baseMatrix)
  self:setScreenAnchor()
  self.sampler:release()

end

function ShaderSticker:setBaseAnchorInfo(faceCenter, faceScaleX, faceScaleY, faceRoll)
  self.stickerCenter = faceCenter
  self.stickerScaleX = faceScaleX
  self.stickerScaleY = faceScaleY
  self.stickerRoll = faceRoll
end



function ShaderSticker:release()
  if self.sampler ~= nil then
    self.sampler:release()
  end
end

function ShaderSticker:setAspectFill()
  local fragMat = Matrix.createFromMatrix(Matrix.identity())
  fragMat:postTranslate(-0.5, -0.5, 0.0)
  -- if 1.0 < self.stickerScaleX / self.stickerScaleY then
  --   fragMat:postScale(1.0, 1.0 / self.stickerScaleY * self.stickerScaleX, 1.0)
  --   print(">>> " .. self.stickerScaleX .. " > " .. self.stickerScaleY)
  -- else
  --   fragMat:postScale(1.0 / self.stickerScaleX * self.stickerScaleY, 1.0, 1.0)
  -- end
  fragMat:postScale(1.0, 1.0 / self.stickerScaleY * self.stickerScaleX, 1.0)
  fragMat:postTranslate(0.5, 0.5, 0.0)
  fragMat:invert()
  self.material:getParameter("u_fragMat"):setMatrix(fragMat)
end

function ShaderSticker:setScreenAnchor()
  print("setScreenAnchors")
  if self.isHorizontal == 1 then
    self.scaleX = self.scaleX_h
    self.scaleY = self.scaleY_h
    self.translateX = self.translateX_h
    self.translateY = self.translateY_h
  elseif self.isHorizontal == 2 then
    self.scaleX = self.scaleX_h2
    self.scaleY = self.scaleY_h2
    self.translateX = self.translateX_h2
    self.translateY = self.translateY_h2
  else
    self.scaleX = self.scaleX_v
    self.scaleY = self.scaleY_v
    self.translateX = self.translateX_v
    self.translateY = self.translateY_v
  end
  self:setBaseAnchorInfo({x=0.5, y=0.5}, self.scaleX, self.scaleY, 0.0)
  -- self.translateX = transX * 2.0
  -- self.translateY = -transY * 2.0 / self.stickerRatio
  -- self.scaleX = scaleWidth
  -- self.scaleY = scaleHeight
  self:setAspectFill()
  self:applyMatrix()
end

function ShaderSticker:applyMatrix()

  local snapshotMatrix = Matrix.createFromMatrix(self.baseMatrix)
-- TODO 왜 두번? 제곱?
  snapshotMatrix:postScale(self.scaleX * self.stickerScaleX, self.scaleY * self.stickerScaleY, 1.0)
  snapshotMatrix:postScale(1.0, 1.0 / ShaderSticker.g_aspectRatio, 1.0)
  snapshotMatrix:postRotateZ(self.rotateZ_1)
  snapshotMatrix:postTranslate(self.translateX * self.stickerScaleX, self.translateY * self.stickerScaleY, 0.0)
  snapshotMatrix:postRotateZ(self.rotateZ_2)
  snapshotMatrix:postScale(1.0, ShaderSticker.g_aspectRatio, 1.0)

  snapshotMatrix:postScale(1.0, 1.0 / ShaderSticker.g_aspectRatio, 1.0)
  snapshotMatrix:postRotateZ(self.stickerRoll * math.pi / 180)
  snapshotMatrix:postScale(1.0, ShaderSticker.g_aspectRatio, 1.0)

  snapshotMatrix:postTranslate(self.stickerCenter.x * 2.0 - 1.0, self.stickerCenter.y * 2.0 - 1.0, 0.0)

  if self.isHorizontal == 2 then
    self.material:getParameter("cropL"):setFloat(0.218)
    self.material:getParameter("cropR"):setFloat(0.781)
  elseif self.isHorizontal == 1 then
    self.material:getParameter("cropL"):setFloat(0.125)
    self.material:getParameter("cropR"):setFloat(0.875)
  else
    self.material:getParameter("cropL"):setFloat(0.001)
    self.material:getParameter("cropR"):setFloat(0.999)
  end

  self.material:getParameter("u_worldViewProjectionMatrix"):setMatrix(snapshotMatrix)

end

function ShaderSticker:updateFaceData()
  ShaderSticker:disableAllNodes()

  local kuruFaceDetector = KuruFaceDetectorExtension.cast(KuruEngine.getInstance():getExtension("KuruFaceDetector"))

  if 0 < kuruFaceDetector:getFaceCount() then
    local faceFeature = KaleFaceFeature.cast(kuruFaceDetector:getFace(0))
    local faceData = faceFeature:getFaceData()

    for i,v in ipairs(ShaderSticker.ALL_SHADERSTICKER) do
      local faceCenterVec = Vector3.create((faceData:getUlseeVertexShape(v.anchorPoint).x + 1.0) / 2.0, (faceData:getUlseeVertexShape(v.anchorPoint).y + 1.0) / 2.0, 0.0);
      v:setBaseAnchorInfo(faceCenterVec, faceFeature:getNormalizedFaceScale() * 2.0 * 2.2, faceFeature:getNormalizedFaceScale() * 2.0 * 2.2, faceData.relativeRoll)
      v:applyMatrix()
      if v.enabled then
        print("enable ".. i .. "nodes")
        v.node:setEnabled(true)
      end
    end
  end
end
