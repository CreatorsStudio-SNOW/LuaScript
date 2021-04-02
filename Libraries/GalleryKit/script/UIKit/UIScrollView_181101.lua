require "UIKit/Queue.lua"

------- class const ---------
-- SLIP_TIME
---------------------------------

------- member variables --------
-- super
-- contentSize
-- enableHorizonScroll
-- enableVerticalScroll
-- touchPositionList
-- isTouchUp
-- isTouchMove
-- slipElapsedTime
-- prevSlipTrans
-- slipSize
-- contentOffset
-- clipShaderNode
-- sumMoveDistance
---------------------------------

UIScrollView = UIView:new()
UIScrollView.SLIP_TIME = 1500.0

function UIScrollView:new(rect, texturePath, enableOnlyPreview, contentWdith, contentHeight)
  local newView = {}

  setmetatable(newView, self)
  self.__index = self

  newView.super = getmetatable(UIScrollView)
  newView.rect = rect or nil

  if (texturePath == nil) then
    newView.texture = nil
  else
    newView.texture = Texture.create(BASE_DIRECTORY .. texturePath)
  end

  newView.enableOnlyPreview = enableOnlyPreview or true
  newView.contentSize = { width = contentWdith or rect.width, height = contentHeight or rect.height }
  newView.enableHorizonScroll = true
  newView.enableVerticalScroll = true
  newView.touchPositionList = Queue:new(2)
  newView.isTouchUp = false
  newView.isTouchMove = false
  newView.slipElapsedTime = self.SLIP_TIME
  newView.prevSlipTrans = { x = 0.0, y = 0.0 }
  newView.slipSize = { x = 0.0, y = 0.0 }
  newView.contentOffset = { x = 0.0, y = 0.0 }
  newView.clipShaderNode = nil
  newView.sumMoveDistance = 0.0
  newView.subViews = {}

  return newView
end

function UIScrollView:frameReady(elapsedTime)
  if (self.isTouchUp and self.touchPositionList:count() == 2) then
    local gapTouches = self:gapBetweenTouches()
    local slipX = gapTouches.x * 8.0
    local slipY = gapTouches.y * 8.0

    self.slipSize = { x = slipX * self.baseWidth, y = slipY * self.baseHeight }
    self.slipElapsedTime = 0.0
    self.prevSlipTrans = { x = 0.0, y = 0.0 }
    self.isTouchUp = false
  end

  self.slipElapsedTime = self.slipElapsedTime + elapsedTime

  if (self.slipElapsedTime < self.SLIP_TIME) then
    self:slipContents()
  end

  local normalizeX = self.rect.x / self.baseWidth
  local normalizeY = self.rect.y / self.baseHeight
  local normalizeWidth = self.rect.width / self.baseWidth
  local normalizeHeight = self.rect.height / self.baseHeight

  self.clipShaderNode:getMaterial():getParameter("viewPosition"):setVector2(Vector2.create(normalizeX, normalizeY))
  self.clipShaderNode:getMaterial():getParameter("viewSize"):setVector2(Vector2.create(normalizeWidth, normalizeHeight))
end

function UIScrollView:slipContents()
  local transX = self:outCubic(self.slipElapsedTime, 0.0, self.slipSize.x, self.SLIP_TIME)
  local transY = self:outCubic(self.slipElapsedTime, 0.0, self.slipSize.y, self.SLIP_TIME)
  local gapTransX = transX - self.prevSlipTrans.x
  local gapTransY = transY - self.prevSlipTrans.y

  self.prevSlipTrans = { x = transX, y = transY }
  self:setTranslationToSubViews({ x = gapTransX, y = gapTransY })
end

function UIScrollView:onTouchDown(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  self.sumMoveDistance = { x = 0.0, y = 0.0 }

  if not (self:isTouched(pos)) then
    return
  end

  self.slipElapsedTime = self.SLIP_TIME
  self.isTouchUp = false
  self.isTouchMove = false
  self.touchPositionList:flush()
  self.touchPositionList:push({ x = pos.x, y = pos.y })

  self:deliverTouchDownIfNeeded(event)
end

function UIScrollView:onTouchMove(event)
  local pos = KuruTouchExtensionTouchEventArgs.cast(event):getPosition()

  if not (self:isTouched(pos)) then
    return
  end

  self.isTouchMove = true
  self.touchPositionList:push({ x = pos.x, y = pos.y })
  self:moveContents()
  self:deliverTouchMoveIfNeeded(event)
end

function UIScrollView:onTouchUp(event)
  if (self.isTouchMove) then
    self.isTouchUp = true
  end

  self.isTouchMove = false

  if (self:getTotalMoveDistance() < 0.02) then
    self:deliverTouchUpIfNeeded(event)
  end
end

function UIScrollView:addToScene(parentX, parentY)
  local prevSnapshot = self:getSnapshot()

  if (self.texture) then
    self.node = self:getFloatingImageNode(parentX, parentY)
    self:addNodeAndRelease(self.node)
  end

  self:addSubViewsToScene()
  self.clipShaderNode = self:getFragmentShader("UIKit/clip.frag")
  self.clipShaderNode:setChannel1(prevSnapshot:getSampler())
  self.clipShaderNode:getMaterial():getParameter("viewPosition"):setVector2(Vector2.create(0.0, 0.0))
  self.clipShaderNode:getMaterial():getParameter("viewSize"):setVector2(Vector2.create(0.0, 0.0))
end

function UIScrollView:getFragmentShader(filePath)
  local node = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. filePath, true)

  self:addNodeAndRelease(node)

  return node
end

function UIScrollView:getSnapshot()
  local node = KuruSnapshotNode.create()

  self.scene:addNode(node)
  node:release()

  return node
end

function UIScrollView:moveContents()
  local gap = self:gapBetweenTouches()

  self.sumMoveDistance.x = self.sumMoveDistance.x + math.abs(gap.x)
  self.sumMoveDistance.y = self.sumMoveDistance.y + math.abs(gap.y)

  self:setTranslationToSubViews({ x = gap.x * self.baseWidth, y = gap.y * self.baseHeight })
end

function UIScrollView:moveHorizonToSubviewIndex(index)
  local subView = self.subViews[index]

  if (subView == nil) then
    return
  end

  local subViewRightX = subView.rect.x + subView.rect.width
  if (subViewRightX <= self.rect.width) then
    return
  end

  local transX = subViewRightX - ((self.rect.width + subView.rect.width) / 2.0)

  self:setTranslationToSubViews({ x = -transX, y = 0.0 })
end

function UIScrollView:moveToInit()
  for i = 1, #self.subViews do
    local subView = self.subViews[i]
    local node = subView.node

    if (node ~= nil) then
      node:setTranslation(0.0, 0.0, 0.0)
    end
  end
end

function UIScrollView:getTotalMoveDistance()
  return math.sqrt(self.sumMoveDistance.x * self.sumMoveDistance.x + self.sumMoveDistance.y * self.sumMoveDistance.y)
end

function UIScrollView:setTranslationToSubViews(translation)
  if (translation.x == 0.0 and translation.y == 0.0) then
    return
  end

  for i = 1, #self.subViews do
    local subView = self.subViews[i]
    local node = subView.node

    if (node ~= nil) then
      local trans = node:getTranslation()
      local transX = self.enableHorizonScroll and (trans.x / 2.0) * self.baseWidth + translation.x or 0.0
      local transY = self.enableVerticalScroll and (trans.y / 2.0) * self.baseHeight + translation.y or 0.0
      local enableScrollX = math.max(0.0, self.contentSize.width - self.rect.width)
      local enableScrollY = math.max(0.0, self.contentSize.height - self.rect.height)

      self.contentOffset.x = math.min(-transX, enableScrollX)
      self.contentOffset.y = math.min(-transY, enableScrollY)

      local resultTransX = math.min((-self.contentOffset.x / self.baseWidth) * 2.0, 0.0)
      local resultTransY = math.min((-self.contentOffset.y / self.baseHeight) * 2.0, 0.0)

      node:setTranslation(resultTransX, resultTransY, 0.0)
    end
  end
end

function UIScrollView:gapBetweenTouches()
  local recentPosition = self.touchPositionList:retrieveFirst()
  local prevPosition = self.touchPositionList:retrieveLast()
  local gapX = (recentPosition.x - prevPosition.x)
  local gapY = (prevPosition.y - recentPosition.y)

  return { x = gapX, y = gapY }
end

function UIScrollView:release()
  if (self.texture ~= nil) then
    self.texture:release()
    self.texture = nil
  end

  self.super:release()
end

function UIScrollView:outCubic(t, b, c, d)
  t = t / d - 1
  return c * (self:pow(t, 3) + 1) + b
end

function UIScrollView:pow(num, pow)
  return num^pow
end
