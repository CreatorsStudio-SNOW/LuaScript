
------- member variables --------
-- fist
-- last
-- maxSize
---------------------------------

Queue = {}

function Queue:new(maxSize)
  local newQueue = { first = 0, last = -1 }

  setmetatable(newQueue, self)
  self.__index = self

  newQueue.maxSize = maxSize or 65535

  return newQueue
end

function Queue:push(value)
  local first = self.first - 1
  self.first = first
  self[first] = value

  if (self.last - self.first >= self.maxSize) then
    self:pop()
  end
end

function Queue:pop()
  local last = self.last

  if (self.first > last) then
    return nil
  end

  local value = self[last]

  self[last] = nil
  self.last = last - 1

  return value
end

function Queue:retrieveLast()
  if (self.first > self.last) then
    return nil
  end

  return self[self.last]
end

function Queue:retrieveFirst()
  if (self.first > self.last) then
    return nil
  end

  return self[self.first]
end

function Queue:count()
  return self.last - self.first + 1
end

function Queue:flush()
  for i = 1, self:count() do
    self:pop()
  end

  self.first = 0
  self.last = -1
end
