UIRect = {
  x = 0.0,
  y = 0.0,
  width = 0.0,
  height = 0.0
}


function UIRect:new(x, y, width, height)
  local newRect = {}

  setmetatable(newRect, self)
  self.__index = self

  newRect.x = x or 0.0
  newRect.y = y or 0.0
  newRect.width = width or 0.0
  newRect.height = height or 0.0

  return newRect
end

function UIRect:normalizeToVertex(baseWidth, baseHeight)
  if (baseWidth == 0.0 or baseHeight == 0.0) then
    return
  end

  self.x = ((self.x / baseWidth) * 2.0) - 1.0
  self.y = ((self.y / baseHeight) * 2.0) - 1.0
  self.width = ((self.width / baseWidth) * 2.0)
  self.height = ((self.height / baseHeight) * 2.0)
end
