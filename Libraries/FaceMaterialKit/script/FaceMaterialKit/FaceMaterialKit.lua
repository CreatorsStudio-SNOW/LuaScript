-- Update Date : 2020. 04. 23.
-- Test contents : 321553
-- Developer : Minhwan. Ho

FaceMaterialKit = {
  scene = nil,
  TAG = "FaceMaterialKit",

  M_PI = 3.141592,
  PLANE_MAT = "face",
  PARTICLE_MAT = "PARTICLE!!",
  STICKER_MAT = "STICKER!!",
  nodes = {}
  -- F_Samplers = {nil, nil}
}

function FaceMaterialKit.init(scene)
  FaceMaterialKit.kuruFace = KuruFaceDetectorExtension.cast(KuruEngine.getInstance():getExtension("KuruFaceDetector"))
  FaceMaterialKit.scene = scene
  FaceMaterialKit.isRecoverPreview = false
  FaceMaterialKit.count = 0
end

function FaceMaterialKit:new(mat_list, f_sampler, f_scale, max_face_count, bufferScale)
  local instance = {}
  instance.materials = mat_list
  instance.f_sampler = f_sampler
  instance.f_scale = f_scale
  instance.f_max = max_face_count
  instance.faceShaders = {}
  instance.fitSnaps = {}
  instance.offsetX = 0
  instance.offsetY = 0
  instance.nofaceSampler = nil
  instance.isFaceChange = false
  instance.node3d = nil
  instance.indice = -1
  FaceMaterialKit.count = FaceMaterialKit.count + 1

  for i=1, instance.f_max do
    instance.fitSnaps[i] = KuruFrameBufferNode.create()
    instance.fitSnaps[i]:setFrameBufferScale(bufferScale, bufferScale)
    FaceMaterialKit.scene:addNodeAndRelease(instance.fitSnaps[i])
    instance.faceShaders[i] = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "FaceMaterialKit/small_face.vert", BASE_DIRECTORY .. "FaceMaterialKit/pass.frag", false)
    instance.fitSnaps[i]:addChildAndRelease(instance.faceShaders[i])
    instance.faceShaders[i]:getMaterial():getParameter("faceMat"):setMatrix(Matrix.identity())
    instance.faceShaders[i]:getMaterial():getParameter("u_texture"):setSampler(instance.f_sampler)
  end
  setmetatable(instance, self)
  self.__index = self

  return instance
end

function FaceMaterialKit:setIndice(num)
  self.indice = num
  return self
end

function FaceMaterialKit:setOffset(offsetX, offsetY)
  self.offsetX = offsetX
  self.offsetY = offsetY
  return self
end

function FaceMaterialKit:setFaceChangeMode(isFaceChange)
  self.isFaceChange = isFaceChange
  return self
end


function FaceMaterialKit:bindNode(node3d)
  self.node3d = node3d
  if FaceMaterialKit.hasNodes(self.node3d) then
     node3d:addRef()
     self:removeNode(self.node3d)
    -- self:addNodeAndRelease(self.node3d)
    print("bindNode and add Node")
  end

  self:addNodeAndRelease(node3d)

  if self.materials[1] == FaceMaterialKit.PARTICLE_MAT then
    self.emitter = ParticleEmitter.cast(self.node3d:getParticleEmitter())
    self.t_ratio = self.emitter:getSpriteWidth()/self.emitter:getSpriteHeight()
  elseif self.materials[1] == FaceMaterialKit.STICKER_MAT then
    local tex = self.node3d:getSampler():getTexture()
    self.t_ratio = tex:getWidth()/tex:getHeight()
    print("t_ratio "..tostring(self.t_ratio))
  end
  return self
end

function FaceMaterialKit.getMinMax(val, min, max)
    return math.max(max, math.min(min, val))
end

function FaceMaterialKit.hasNodes(node)
  for i=1, #FaceMaterialKit.nodes do
    if FaceMaterialKit.nodes[i] ~= nil then
      if FaceMaterialKit.nodes[i]:equals(node) then
        return true
      end
    end
  end
  return false
end

function FaceMaterialKit:addNodeAndRelease(node)
  FaceMaterialKit.scene:addNodeAndRelease(node)
  FaceMaterialKit.nodes[#FaceMaterialKit.nodes + 1] = node
end

function FaceMaterialKit:removeNode(node)
  FaceMaterialKit.scene:removeNode(node)
  for i=1, #FaceMaterialKit.nodes do
    if FaceMaterialKit.nodes[i] ~= nil then
      if FaceMaterialKit.nodes[i]:equals(node) then
        table.remove(FaceMaterialKit.nodes, i)
      end
    end
  end
end

function FaceMaterialKit:updateSampler(param)
  if self.node3d == nil then
    return
  end



  -- if SceneRenderConfig.instance():isRenderModeSnapshot() then
  --   return
  -- end

  local faceParam = FacePreRenderArgs.cast(param)
  local faceData = faceParam:getFaceData()
  local id = faceData.id
  if id > (self.f_max - 1) then
    return
  end
  local faceFeature = KaleFaceFeature.cast(FaceMaterialKit.kuruFace:getFace(id))
  local faceScale = faceFeature:getNormalizedFaceScale() * 10
  local resolution = FaceMaterialKit.scene:getResolution()
  local res = resolution.x / resolution.y
  local centerX = ((faceData:getVertexCenter().x + 1.0) / 2.0)
  local centerY = ((faceData:getVertexCenter().y + 1.0) / 2.0)
  if self.indice ~= -1 then
    centerX = ((faceData:getUlseeVertexShape(self.indice).x + 1.0) / 2.0)
    centerY = ((faceData:getUlseeVertexShape(self.indice).y + 1.0) / 2.0)
  end
  local faceRect = faceData.vertexFaceRect
  local offsetX = (faceRect.width + 1.0)/2.0 * 0.2
  local offsetY = (faceRect.height + 1.0)/2.0 * 0.15
  local matrix = Matrix.createFromMatrix(Matrix.identity())
  -- print("face scale is "..tostring(faceScale))
  local yaw = faceData.ulseeYaw
  local s = self.f_scale * 10

  local moveX = 0.5 + (yaw * -0.2)

  local flip = 1
  if self.materials[1] == FaceMaterialKit.PARTICLE_MAT then
    flip = -1 * res
  elseif self.materials[1] == FaceMaterialKit.STICKER_MAT then
    flip = self.t_ratio
  end

  matrix:translate(-centerX, -centerY, 0.0)
  matrix:postScale(1.0, 1/res, 1.0)
  matrix:postRotateZ(-faceData.relativeRoll / 180.0 * FaceMaterialKit.M_PI)
  matrix:postScale(1 * s/faceScale, flip * s/faceScale, 1.0)
  matrix:postTranslate(moveX + self.offsetX , 0.5 + self.offsetY, 0.0)
  matrix:invert()
  -- edit for face change

  self.faceShaders[id + 1]:getMaterial():getParameter("faceMat"):setMatrix(matrix)
  -- FaceMaterialKit.F_Samplers[id + 1] = self.fitSnaps[id + 1]:getSampler()
  local change_id = 1
  if id + 1 == 1 then
    change_id = 2
  end

  if self.fitSnaps[change_id] ~= nil and FaceMaterialKit.kuruFace:getFaceCount() > 1 and self.isFaceChange then
    self:updateTexture(param:getNode(), self.fitSnaps[change_id]:getSampler())
  else
    -- print("alone")
    self:updateTexture(param:getNode(), self.fitSnaps[id + 1]:getSampler())
  end
end


function FaceMaterialKit:updateFaceScale(f_scale)
  self.f_scale = f_scale
end



function FaceMaterialKit:updateTexture(modelNode, sampler)
  if self.materials[1] == FaceMaterialKit.PARTICLE_MAT then
    if not modelNode:equals(self.node3d) then
      return
    end
    if sampler:getTexture() ~= nil then
      self.emitter:setTexture(sampler:getTexture(), self.emitter:getBlendMode())
    end
    return
  end

  if self.materials[1] == FaceMaterialKit.STICKER_MAT then
    if not modelNode:equals(self.node3d) then
      return
    end
    if sampler:getTexture() ~= nil then
      KaleStickerNode.cast(self.node3d):updateSampler(sampler)
    end
    return
  end

  local renderNodeSize = KaleFaceModelNode.cast(self.node3d):getRenderNodeSize()

  for j = 0, renderNodeSize -1, 1 do
    local partNode = KaleFaceModelNode.cast(self.node3d):getRenderNode(j)
    -- 2d animation setting,.
    if partNode:getDrawable() ~= nil then
      local model = Model.cast(partNode:getDrawable())
      local partCount = model:getMeshPartCount()
      for i= 0, partCount -1, 1 do
        local material = model:getMaterial(i)

        if material ~= nil then
          local materialName = material:getId()

          for i=1, #self.materials do
            print("material names : "..tostring(materialName))
            if materialName == self.materials[i] then
              if sampler:getTexture() ~= nil then
                material:getParameter("u_diffuseTexture"):setSampler(sampler)
              end
            end
          end
        end
      end
    end
  end
end


function FaceMaterialKit.createPlaneNode()
  local node = KaleFaceModelNode.create(BASE_DIRECTORY .. "FaceMaterialKit/plane/face_plane.gpb")
  node:setFlipHorizontally(false)
  return node
end

function FaceMaterialKit:finalize()
end
