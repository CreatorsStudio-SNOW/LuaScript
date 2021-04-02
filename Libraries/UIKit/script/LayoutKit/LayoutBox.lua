------- class variables ---------
-- scene
-- textureScale
-- sceneResolution
---------------------------------

------- member variables --------
-- frameBuffer
-- width
-- height
-- leftMargin
-- rightMargin
-- topMargin
-- bottomMargin
-- currentRow
-- childViewsTable
-- bgNode
-- debugClearNode
---------------------------------

LayoutBox = {
  scene = nil,
  textureScale = 1.0,
  sceneResolution = 0.0
}

LayoutBox_LocationType = {
  LeftEdge = 1,
  RightEdge = 2
}

LayoutBox_AlignType = {
  Left = 1,
  Center = 2,
  Right = 3
}

LayoutBox_FreeType_Key = "LayoutBox_FreeType_Key"

function LayoutBox.getBaseResolution()
  local result = {
    x = LayoutBox.sceneResolution.x / LayoutBox.textureScale,
    y = LayoutBox.sceneResolution.y / LayoutBox.textureScale
  }

  return result
end

function LayoutBox.init()
  LayoutBox.updateTextureScale()
end

function LayoutBox.updateTextureScale()
  LayoutBox.sceneResolution = LayoutBox.scene:getResolution()

  local realX = LayoutBox.sceneResolution.x
  local realY = LayoutBox.sceneResolution.y
  local ratio = realX / realY
  local baseX = 720.0
  local baseY = baseX / ratio

  if (realY < realX) then
    LayoutBox.textureScale = realY / ratio / baseY
  else
    LayoutBox.textureScale = realY / baseY
  end
end

function LayoutBox:new(leftMargin, rightMargin, topMargin, bottomMargin)
  local newBox = {}

  setmetatable(newBox, self)
  self.__index = self

  newBox.frameBuffer = self:addNodeAndRelease(KuruFrameBufferNode.create())
  newBox.width = 0.0
  newBox.height = 0.0
  newBox.leftMargin = leftMargin or 0.0
  newBox.rightMargin = rightMargin or 0.0
  newBox.topMargin = topMargin or 0.0
  newBox.bottomMargin = bottomMargin or 0.0
  newBox.align = LayoutBox_AlignType.Left
  newBox.currentRow = 1
  newBox.childViewsTable = {LayoutBox_FreeType_Key = {}}
  newBox.debugClearNode = newBox:addChildAndRelease(KuruClearNode.create(Vector4.create(0.0, 1.0, 0.0, 1.0)))
  newBox.bgNode = nil
  newBox.debugClearNode:setEnabled(false)

  return newBox
end

function LayoutBox:frameReady()
  LayoutBox.updateTextureScale()
  self:updateFrameBufferScale()
end

function LayoutBox:setDebugMode(isDebugMode)
  self.debugClearNode:setEnabled(isDebugMode)
end

function LayoutBox:updateFrameBufferScale()
  local baseResolution = LayoutBox.getBaseResolution()
  local bufferScaleWidth = self.width / baseResolution.x
  local bufferScaleHeight = self.height / baseResolution.y

  self.frameBuffer:setFrameBufferScale(bufferScaleWidth, bufferScaleHeight)
end

function LayoutBox:getSampler()
  return self.frameBuffer:getSampler()
end

function LayoutBox:addComponentToRight(prefix, format, betweenMargin, leftMargin, topMargin, blendMode, isHorizonOrientation)
  return self:addLViewToRight(LView:new(self.textureUtil, format, betweenMargin, isHorizonOrientation, prefix, blendMode), leftMargin, topMargin)
end

function LayoutBox:addComponentToBottom(prefix, format, betweenMargin, leftMargin, topMargin, blendMode, isHorizonOrientation)
  return self:addLViewToBottom(LView:new(self.textureUtil, format, betweenMargin, isHorizonOrientation, prefix, blendMode), leftMargin, topMargin)
end

function LayoutBox:addComponentToFree(prefix, format, betweenMargin, leftMargin, topMargin, blendMode, isHorizonOrientation)
  local LView = LView:new(self.textureUtil, format, betweenMargin, isHorizonOrientation, prefix, blendMode)
  LView.margins.left = leftMargin
  LView.margins.top = topMargin
  LView:updateRect()

  self.childViewsTable[LayoutBox_FreeType_Key][#self.childViewsTable[LayoutBox_FreeType_Key] + 1] = LView

  return LView
end

function LayoutBox:addLViewToRight(LView, leftMargin, topMargin)
  LView.margins.left = leftMargin
  LView.margins.top = topMargin

  LView:updateRect()

  self:addLViewToTable(LView)

  return LView
end

function LayoutBox:addLViewToBottom(LView, leftMargin, topMargin)
  self.currentRow = self.currentRow + 1

  LView:updateRect()

  LView.margins.left = leftMargin
  LView.margins.top = topMargin

  self:addLViewToTable(LView)

  return LView
end

function LayoutBox:addLViewToTable(LView)
  if (self.childViewsTable[self.currentRow] == nil) then
    self.childViewsTable[self.currentRow] = {}
  end

  self.childViewsTable[self.currentRow][#self.childViewsTable[self.currentRow] + 1] = LView
end

function LayoutBox:eachFreeView(func)
  for i, view in ipairs(self.childViewsTable[LayoutBox_FreeType_Key]) do
    func(i, view)
  end
end

function LayoutBox:eachView(func)
  self:eachFreeView(function (index, view)
    func(view)
  end)
  self:eachViewExceptFreeViews(func)
end

function LayoutBox:eachRow(func)
  for i, row in ipairs(self.childViewsTable) do
    func(i, row)
  end
end

function LayoutBox:eachColumn(row, func)
  for i, view in ipairs(row) do
    func(i, view)
  end
end

function LayoutBox:eachViewExceptFreeViews(func)
  for i, row in ipairs(self.childViewsTable) do
    for j, view in ipairs(row) do
      func(view)
    end
  end
end

function LayoutBox:eachFirstColumn(func)
  for i, row in ipairs(self.childViewsTable) do
    func(i, row[1])
  end
end

function LayoutBox:eachLastColumn(func)
  for i, row in ipairs(self.childViewsTable) do
    func(i, row[#row])
  end
end

function LayoutBox:getLastRow()
  return self.childViewsTable[#self.childViewsTable]
end

function LayoutBox:updateSubViewsPosition()
  local baseResolution = LayoutBox.getBaseResolution()
  local topViewY = baseResolution.y

  for i, row in ipairs(self.childViewsTable) do
    local prevViewRightX = 0.0

    for j, LView in ipairs(row) do
      LView.rect.x = prevViewRightX + LView.margins.left
      LView.rect.y = topViewY - LView.rect.height - LView.margins.top

      if (j == 1) then
        LView.rect.x = LView.rect.x + self.leftMargin
      end

      if (i == 1) then
        LView.rect.y = LView.rect.y - self.topMargin
      end

      prevViewRightX = LView.rect.x + LView.rect.width

      -- LView:printRect()
    end

    topViewY = row[1].rect.y
  end

  self:eachFreeView(function (index, view)
    view.rect.x = view.margins.left + self.leftMargin
    view.rect.y = baseResolution.y - view.rect.height - view.margins.top - self.topMargin

    -- view:printRect()
  end)

end


function LayoutBox:getMaxRightXForRow()
  local maxRightX = 0.0

  self:eachLastColumn(function (index, view)
    local rightEdgeViewRightX = view.rect.x + view.rect.width

    if (rightEdgeViewRightX > maxRightX) then
      maxRightX = rightEdgeViewRightX
    end
  end)
  self:eachFreeView(function (index, view)
    local rightEdgeViewRightX = view.rect.x + view.rect.width

    if (rightEdgeViewRightX > maxRightX) then
      maxRightX = rightEdgeViewRightX
    end
  end)

  return maxRightX
end

function LayoutBox:getMinYForLastRow()
  local baseResolution = LayoutBox.getBaseResolution()
  local minY = baseResolution.y

  local lastRowViews = self:getLastRow()

  if (lastRowViews ~= nil) then
    for i, view in ipairs(lastRowViews) do
      if (view.rect.y < minY) then
        minY = view.rect.y
      end
    end
  end

  self:eachFreeView(function (index, view)
    if (view.rect.y < minY) then
      minY = view.rect.y
    end
  end)

  return minY
end

function LayoutBox:addToScene()
  self:updateSubViewsPosition()

  local maxRightXForRow = self:getMaxRightXForRow()
  local minYForLastRow = self:getMinYForLastRow()
  local baseResolution = LayoutBox.getBaseResolution()

  self.width = maxRightXForRow + self.rightMargin
  self.height = baseResolution.y - minYForLastRow + self.bottomMargin
  self:updateFrameBufferScale()

  self:eachView(function (view)
    local imageNodes = view:getFloatingNodes(self.width, self.height, LayoutBox.getBaseResolution().y)
    self:addChildNodesAndRelease(imageNodes)
  end)

end

function LayoutBox:addToSceneWithBackground(anchorType, rotationMode, blendMode)
  self:addToScene()

  self.bgNode = self:getBGNodeWithSampler(self:getSampler(), anchorType, rotationMode, blendMode)

  self:addNodeAndRelease(self.bgNode)
end

function LayoutBox:setNeedsLayout()
  self:removeAllChildViews()
  self:addToScene()
end

function LayoutBox:addNodeAndRelease(node)
  LayoutBox.scene:addNode(node)
  node:release()

  return node
end

function LayoutBox:removeAllComponent()
  self:removeAllChildViews()
  self.childViewsTable = {LayoutBox_FreeType_Key = {}}
end

function LayoutBox:removeAllChildViews()
  self:eachView(function (view)
    self:removeChildNodes(view.nodes)
  end)
end

function LayoutBox:removeChildNodes(nodes)
  for i = 1, #nodes do
    if (nodes[i] ~= nil) then
      self.frameBuffer:removeChild(nodes[i])
      nodes[i] = nil
    end
  end
end

function LayoutBox:addChildNodesAndRelease(nodes)
  if (nodes == nil) then
    return
  end

  for i = 1, #nodes do
    self:addChildAndRelease(nodes[i])
  end
end

function LayoutBox:addChildAndRelease(node)
  self.frameBuffer:addChild(node)
  node:release()

  return node
end

function LayoutBox:updateAlign()
  if self.align == LayoutBox_AlignType.Left then
    self:alignLeft()
  elseif self.align == LayoutBox_AlignType.Center then
    self:alignCenter()
  elseif self.align == LayoutBox_AlignType.Right then
    self:alignRight()
  end
end

function LayoutBox:alignLeft()
  local baseResolution = LayoutBox.getBaseResolution()
  local minX = baseResolution.x
  local xPositionsForRow = {}
  local xPositionsForFreeView = {}

  self:eachFirstColumn(function (index, view)
    local firstViewX = view.rect.x

    xPositionsForRow[index] = firstViewX

    if (firstViewX < minX) then
      minX = firstViewX
    end
  end)
  self:eachFreeView(function (index, view)
    local x = view.rect.x

    xPositionsForFreeView[index] = x

    if (x < minX) then
      minX = x
    end
  end)

  self:moveViewsToX(LayoutBox.eachFirstColumn, minX, xPositionsForRow)
  self:moveViewsToX(LayoutBox.eachFreeView, minX, xPositionsForFreeView)
end

function LayoutBox:alignRight()
  local maxRightX, rightXPositionsForRow, rightXPositionsForFreeView = self:getMaxRightX_getRightXPositionsForRow_getXPositionsForFreeView()

  self:moveViewsToX(LayoutBox.eachFirstColumn, maxRightX, rightXPositionsForRow)
  self:moveViewsToX(LayoutBox.eachFreeView, maxRightX, rightXPositionsForFreeView)
end

function LayoutBox:alignCenter()
  local maxRightX, rightXPositionsForRow, rightXPositionsForFreeView = self:getMaxRightX_getRightXPositionsForRow_getXPositionsForFreeView()

  self:moveViewsToCenter(LayoutBox.eachFirstColumn, maxRightX, rightXPositionsForRow)
  self:moveViewsToCenter(LayoutBox.eachFreeView, maxRightX, rightXPositionsForFreeView)
end

function LayoutBox:getMaxRightX_getRightXPositionsForRow_getXPositionsForFreeView()
  local maxRightX = 0.0
  local rightXPositionsForRow = {}
  local rightXPositionsForFreeView = {}

  self:eachLastColumn(function (index, view)
    local rightEdgeViewRightX = view.rect.x + view.rect.width

    rightXPositionsForRow[index] = rightEdgeViewRightX

    if (rightEdgeViewRightX > maxRightX) then
      maxRightX = rightEdgeViewRightX
    end
  end)
  self:eachFreeView(function (index, view)
    local rightX = view.rect.x + view.rect.width

    rightXPositionsForFreeView[index] = rightX

    if (rightX > maxRightX) then
      maxRightX = rightX
    end
  end)

  return maxRightX, rightXPositionsForRow, rightXPositionsForFreeView
end

function LayoutBox:moveViewsToCenter(viewIterationFunc, maxRightX, rightXPositions)
  viewIterationFunc(self, function (index, view)
    local viewLeftMargin = view.margins.left
    local rowWidth = rightXPositions[index] - viewLeftMargin
    local leftMargin = (maxRightX - rowWidth) / 2.0

    view.margins.left = leftMargin
  end)
end

function LayoutBox:moveViewsToX(viewIterationFunc, targetX, sourceXPositions)
  viewIterationFunc(self, function (index, view)
    local sourceX = sourceXPositions[index]
    local gapX = targetX - sourceX

    view.margins.left = view.margins.left + gapX
  end)
end

function LayoutBox:getEdgeLView(row, locationType)
  local edgeIndex = self.bothEdgesColumnsTable[row][locationType]

  return self.childViewsTable[row][edgeIndex]
end

function LayoutBox:getBGNodeWithSampler(sampler, anchorType, variantMode, blendMode)
  local bgNode = KuruBackgroundImageNode.createFromSampler(sampler, blendMode)

  bgNode:setStretch(KuruBackgroundImageNodeStretch.NONE)
  bgNode:setAnchorType(anchorType)
  bgNode:setRotationMode(variantMode)

  return bgNode
end
