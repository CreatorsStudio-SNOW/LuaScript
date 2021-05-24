-- Update Date : 200731
-- Author : Charlie

CELayout = {
  COMPOSITION = nil,
  baseSampler = nil,
  bufferNode = nil,
  layoutList = {},
  samplerList = {},
  materialList = {}
}
CELayout.__index = CELayout

function CELayout:new(scene, baseSampler, compositionSetting)
  local newObject = {}
  setmetatable(newObject, CELayout)

  newObject.baseSampler = baseSampler
  newObject.COMPOSITION = compositionSetting

  newObject.bufferNode = KuruFrameBufferNode.create()
  scene:addNodeAndRelease(newObject.bufferNode)

  newObject.samplerList = {}
  newObject.layoutList = {}
  newObject.materialList = {}

  return newObject
end

function CELayout:setLayer(layerInfo)
  return self:setLayerWithSampler(self.baseSampler, layerInfo)
end

function CELayout:setLayerWithSampler(sampler, layerInfo)
  local layout = {}

  layout["position"] = layerInfo.position
  layout["size"] = layerInfo.size or self.COMPOSITION.BASE_RULE.size
  layout["scale"] = layerInfo.scale or self.COMPOSITION.BASE_RULE.scale
  layout["anchor"] = layerInfo.anchor or self.COMPOSITION.BASE_RULE.anchor

  self.layoutList[#self.layoutList + 1] = layout
  self.samplerList[#self.samplerList + 1] = sampler

  return self
end

function CELayout.shallowCopy(list, startOffset, endOffset)
  local newList = {}

  for i = startOffset, endOffset do newList[#newList + 1] = list[i] end

  return newList
end

function CELayout:build()
  local shaderNodeCount = math.ceil(#self.layoutList / 8)

  for i = 1, shaderNodeCount do
    local startOffset = (i - 1) * 8 + 1
    local endOffset = #self.layoutList % 8 + math.floor(#self.layoutList / 8) *
                          8

    local lList = CELayout.shallowCopy(self.layoutList, startOffset, endOffset)
    local lSamplers = CELayout.shallowCopy(self.samplerList, startOffset,
                                           endOffset)

    local quadFullMesh = Mesh.createQuadFullscreen()
    local model = Model.create(quadFullMesh)
    quadFullMesh:release()

    local material = Material.createWithShaderFile(
                         "res/shaders/passthrough.vert",
                         BASE_DIRECTORY .. "CELayout/div.frag", Nil)
    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(
        Matrix.createFromMatrix(Matrix.identity()))

    local blendSrc = RenderStateBlend.BLEND_SRC_ALPHA
    local stateBlock = material:getStateBlock()
    stateBlock:setBlend(true)
    stateBlock:setBlendSrc(blendSrc)
    stateBlock:setBlendDst(RenderStateBlend.BLEND_ONE_MINUS_SRC_ALPHA)
    model:setMaterial(material, -1)
    material:release()
    local node = KuruModelNode.createFromModel(model)
    model:release()

    self.bufferNode:addChildAndRelease(node)

    if i == 1 then
      material:getParameter("u_bgColor"):setVector4(self.COMPOSITION.BG_COLOR)
    else
      material:getParameter("u_bgColor"):setVector4(Vector4.create(0, 0, 0, 0))
    end

    self:setLayoutInfo(material, lList, lSamplers)
    self.materialList[#self.materialList + 1] = material
  end

  return self
end

function CELayout:setAllSamplers(sampler)
  self.baseSampler = sampler
  for i, v in ipairs(self.samplerList) do self.samplerList[i] = sampler end

  local shaderNodeCount = math.ceil(#self.layoutList / 8)

  for i = 1, shaderNodeCount do
    local startOffset = (i - 1) * 8 + 1
    local endOffset = i * 8
    local lSamplers = CELayout.shallowCopy(self.samplerList, startOffset,
                                           endOffset)

    self.materialList[i]:getParameter("u_samplers"):setSamplerArray(lSamplers)
  end
end

function CELayout:setLayoutInfo(material, layoutList, samplers)
  material:getParameter("u_count"):setInt(#layoutList)

  local positions = {}
  local sizes = {}
  local anchors = {}
  local scales = {}

  local scaleOneToOne = 1.0
  local offsetOneToOne = 0.0
  local config = KuruEngine.getInstance():getCameraConfig()

  if not config:isGalleryMode() and config:isOneToOne() == true then
    scaleOneToOne = 3.0 / 4.0
    offsetOneToOne = 0.125
  end

  for i = 1, #layoutList do
    local offsetX = (layoutList[i].size.width) / 2
    local offsetY = (layoutList[i].size.height) / 2
    positions[i] = Vector2.create((layoutList[i].position.x - offsetX) /
                                      self.COMPOSITION.BG_SIZE.WIDTH,
                                  (layoutList[i].position.y - offsetY) /
                                      self.COMPOSITION.BG_SIZE.HEIGHT *
                                      scaleOneToOne + offsetOneToOne)
    sizes[i] = Vector2.create(layoutList[i].size.width /
                                  self.COMPOSITION.BG_SIZE.WIDTH, layoutList[i]
                                  .size.height / self.COMPOSITION.BG_SIZE.HEIGHT *
                                  scaleOneToOne)
    anchors[i] = Vector2.create(-layoutList[i].anchor.x /
                                    self.COMPOSITION.BG_SIZE.WIDTH,
                                -layoutList[i].anchor.y /
                                    self.COMPOSITION.BG_SIZE.HEIGHT *
                                    scaleOneToOne)
    scales[i] = Vector2.create(layoutList[i].scale, layoutList[i].scale)
  end

  material:getParameter("u_positions"):setVector2Array(positions)
  material:getParameter("u_sizes"):setVector2Array(sizes)
  material:getParameter("u_anchors"):setVector2Array(anchors)
  material:getParameter("u_scales"):setVector2Array(scales)
  material:getParameter("u_samplers"):setSamplerArray(samplers)
end

function CELayout:getSampler()
  return self.bufferNode:getSampler()
end
