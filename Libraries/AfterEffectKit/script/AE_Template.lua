require "AE_Layer.lua"
require "TransformLayer/AE_Position.lua"
require "TransformLayer/AE_AnchorPoint.lua"
require "TransformLayer/AE_Scale.lua"
require "TransformLayer/AE_Rotation.lua"
require "TransformLayer/AE_Opacity.lua"


TRANSFORM = {
  AnchorPoint = 1,
  Position = 2,
  Scale = 3,
  Rotation = 4,
  Opacity = 5
}

SolidObject = {
  COMPOSITION = nil,
  sampler = nil,
  width = nil,
  height = nil,
  bufferNode = nil,
  transformNode = nil,
  effectNodes = {},
  motionBlur = nil,
  TransformLayers = {
    [TRANSFORM.AnchorPoint] = nil,
    [TRANSFORM.Position] = nil,
    [TRANSFORM.Scale] = nil,
    [TRANSFORM.Rotation] = nil,
    [TRANSFORM.Opacity] = nil,
  },
  EffectLayers = {
  },
}

function SolidObject:create(scene, sampler, width, height, compositionSetting)
  local newObject = {}

  setmetatable(newObject, self)
  self.__index = self

  newObject.sampler = sampler
  newObject.width = width
  newObject.height = height
  newObject.COMPOSITION = compositionSetting
  newObject.transformNode = nil
  newObject.TransformLayers = {
    [TRANSFORM.AnchorPoint] = nil,
    [TRANSFORM.Position] = nil,
    [TRANSFORM.Scale] = nil,
    [TRANSFORM.Rotation] = nil,
    [TRANSFORM.Opacity] = nil,
  }
  newObject.motionBlur = nil
  newObject.effectNodes = {}
  newObject.EffectLayers = {}

  newObject:init(scene)

  return newObject
end

function SolidObject:init(scene)
  self.bufferNode = KuruFrameBufferNode.createWithSize(self.width, self.height)
  scene:addNodeAndRelease(self.bufferNode)

  self.transformNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "TransformLayer/transform.vert", BASE_DIRECTORY .. "TransformLayer/effect.frag", true)

  positionLayer = AE_Position:create({})
  positionLayer.nodes = {self.transformNode}
  positionLayer.COMPOSITION = self.COMPOSITION
  self.TransformLayers[TRANSFORM.Position] = positionLayer

  anchorPointLayer = AE_AnchorPoint:create({})
  anchorPointLayer.nodes = {self.transformNode}
  anchorPointLayer.COMPOSITION = self.COMPOSITION
  self.TransformLayers[TRANSFORM.AnchorPoint] = anchorPointLayer

  scaleLayer = AE_Scale:create({})
  scaleLayer.nodes = {self.transformNode}
  scaleLayer.COMPOSITION = self.COMPOSITION
  self.TransformLayers[TRANSFORM.Scale] = scaleLayer

  rotationLayer = AE_Rotation:create({})
  rotationLayer.nodes = {self.transformNode}
  rotationLayer.COMPOSITION = self.COMPOSITION
  self.TransformLayers[TRANSFORM.Rotation] = rotationLayer

  opacityLayer = AE_Opacity:create({})
  opacityLayer.nodes = {self.transformNode}
  self.TransformLayers[TRANSFORM.Opacity] = opacityLayer

--  self.motionBlur = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "motionBlur.vert", BASE_DIRECTORY .. "motionBlur.frag", true)
--  self.bufferNode:addChildAndRelease(self.motionBlur)
end

function SolidObject:setTransformLayerKeyframes(transformType, keyFrames)
  self.TransformLayers[transformType].keyframes = keyFrames
  return self
end

function SolidObject:appendEffectLayer(effectLayer)
  local key = effectLayer.key
  if key ~= nil then
    table.insert(self.EffectLayers, effectLayer)
    for _,node in ipairs(effectLayer.nodes) do
      table.insert(self.effectNodes, node)
    end
  end

  return self
end

function SolidObject:build()
  for _, node in ipairs(self.effectNodes) do
    self.bufferNode:addChildAndRelease(node)
  end
  self.bufferNode:addChildAndRelease(self.transformNode)

  KuruShaderFilterNode.cast(self.bufferNode:getFirstChild()):setChannel0(self.sampler)

  return self
end

function SolidObject:frameReady(index)
  local ratio = KuruEngine.getInstance():getResolution().x / KuruEngine.getInstance():getResolution().y
  self.transformNode:getMaterial():getParameter("u_ratio"):setFloat(ratio)
  self.transformNode:getMaterial():getParameter("u_repeTile"):setBool(self.COMPOSITION.repeTile)
  self.transformNode:getMaterial():getParameter("u_motionBlur"):setBool(self.COMPOSITION.MotionBlur)
  self.transformNode:getMaterial():getParameter("u_motionBlurSize"):setFloat(self.COMPOSITION.MotionBlurSize)
  
  for type, transformLayer in ipairs(self.TransformLayers) do
    transformLayer:frameReady(index)
  end
  for _,effectLayer in ipairs(self.EffectLayers) do
    effectLayer:frameReady(index)
  end

  KuruShaderFilterNode.cast(self.bufferNode:getFirstChild()):setChannel0(self.sampler)
end

function SolidObject:getEffectLayer(effectLayerKey)
  return self.effectLayer[effectLayerKey]
end

function SolidObject:getTransformLayer(transformLayerKey)
  return self.TransformLayers[transformLayerKey]
end

function SolidObject:getSampler()
  return self.bufferNode:getSampler()
end
