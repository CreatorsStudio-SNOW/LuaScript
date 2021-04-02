
------- member variables --------
-- super
-- sampler
---------------------------------

UISamplerView = UIView:new()

function UISamplerView:new(rect, sampler)
  local newView = {}

  setmetatable(newView, self)
  self.__index = self

  newView.super = getmetatable(UISamplerView)
  newView.sampler = sampler
  newView.rect = rect or nil
  newView.touchEnabled = false

  return newView
end

function UISamplerView:addToScene(parentX, parentY)
  if (self.sampler) then
    self.node = self:getFloatingImageNode(parentX, parentY)
    self:addNodeAndRelease(self.node)
  end

  self:addSubViewsToScene()
end

function UISamplerView:getFloatingImageNode(parentX, parentY)
  local rect = self.rect
  local rectOnScene = UIRect:new(rect.x + parentX, rect.y + parentY, rect.width, rect.height)

  rectOnScene:normalizeToVertex(self.baseWidth, self.baseHeight)

  local node = KuruFloatingImageNode.createFromSampler(self.sampler,
    rectOnScene.x, rectOnScene.y, rectOnScene.width, rectOnScene.height, BlendMode.None
  )

  node:getSampler():setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  return node
end

function UISamplerView:updateSampler(sampler)
  self.sampler = sampler
  self.node:getSampler():setTexture(self.sampler:getTexture())
end
