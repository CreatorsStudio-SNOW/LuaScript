


CEModelComponent = {}

function CEModelComponent:new()
  local instance = {}
  instance.model = nil
  instance.materials = {}
  instance.joints = {}
  instance.jointMap = {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CEModelComponent:setModel(model)
  self.model = model
  local renderNodeSize = model:getRenderNodeSize()
  print("setModel!!!!! "..tostring(renderNodeSize))
  for j = 0, renderNodeSize -1 do
    local partNode = model:getRenderNode(j)
    -- 2d animation setting,.
    if partNode:getDrawable() ~= nil then
      local _model = Model.cast(partNode:getDrawable())
      local partCount = _model:getMeshPartCount()
      for i= 0, partCount -1 do
        local material = _model:getMaterial(i)

        if material ~= nil then
          local materialName = material:getId()
          if materialName ~= nil then
            self.materials[materialName] = material
          end
        end
      end
    end
  end
end

function CEModelComponent:getMaterial(name)
  return self.materials[name]
end

function CEModelComponent:getJointArray(materialName)
  if self.materials[materialName] == nil then
    return nil
  end

  if #(self.joints) == 0 then
    self:arrayJoint(materialName)
    return self.joints[materialName]
  end

  if self.joints[materialName] == nil then
    self:arrayJoint(materialName)
    return self.joints[materialName]
  end

  return self.joints[materialName]
end

function CEModelComponent:getJointMap(materialName)
  if self.materials[materialName] == nil then
    return nil
  end

  if #(self.joints) == 0 then
    self:arrayJoint(materialName)
  end

  if self.joints[materialName] == nil then
    self:arrayJoint(materialName)
  end

  if #(self.jointMap) == 0 then
    self:mappingJoint(materialName)
  end

  if self.jointMap[materialName] == nil then
    self:mappingJoint(materialName)
  end

  return self.jointMap[materialName]
end

function CEModelComponent:getJoint(materialName, index)
  if self.materials[materialName] == nil then
    return nil
  end

  if #(self.joints) == 0 then
    self:arrayJoint(materialName)
    return self.joints[materialName][index]
  end

  if self.joints[materialName] == nil then
    self:arrayJoint(materialName)
    return self.joints[materialName][index]
  end

  return self.joints[materialName][index]
end

function CEModelComponent:mappingJoint(materialName)
  self.jointMap[materialName] = {}
  for i=1, #(self.joints[materialName]) do
    local joint = self.joints[materialName][i]
    self.jointMap[materialName][tostring(joint:getId())] = joint
  end
end

function CEModelComponent:arrayJoint(materialName)
  local renderNodeSize = self.model:getRenderNodeSize()
  for i=0, renderNodeSize -1 do
    local partNode = self.model:getRenderNode(i)
    if partNode:getDrawable() ~= nil then
      local model = Model.cast(partNode:getDrawable())

      for j= 0, model:getMeshPartCount() -1 do
        local material = model:getMaterial(j)
        if material ~= nil then
          local name = material:getId()
          if name == materialName then
            local meshSkin = MeshSkin.cast(model:getSkin())

            if meshSkin:getJointCount() > 0 then
              self.joints[materialName] = {}
              for k = 0, meshSkin:getJointCount() -1 do
                self.joints[materialName][k + 1] = meshSkin:getJoint(k)
              end
            end
          end
        end
      end
    end
  end
end
