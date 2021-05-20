Queue = {}

function Queue:new()
  local newQueue = {front = 0, rear = -1, list = {}}
  setmetatable(newQueue, self)
  self.__index = self

  return newQueue
end


function Queue:push(value, needAddRef)
  local front = self.front - 1

  self.front = front
  self.list[front] = value

  if (needAddRef) then
    self.list[front]:addRef()
  end
end

function Queue:pop(needRelease)
  local rear = self.rear

  if (self.front > rear) then
    return nil
  end

  local value = self.list[rear]

  if (needRelease) then
    value:release()
  end

  self.list[rear] = nil
  self.rear = rear - 1

  return value
end

function Queue:retrieve(index)
  return self.list[index]
end

function Queue:retrieveLast()
  local rear = self.rear

  if (self.front > rear) then
    return nil
  end

  return self.list[rear]
end

function Queue:updateLast(element)
  local rear = self.rear

  self.list[rear] = element
end

function Queue:clear(needRelease)
  for i = self.front, self.rear do
    local element = self.list[i]

    if (needRelease) then
      element:release()
    end

    self.list[i] = nil
  end

  self.front = 0
  self.rear = -1
end

function Queue:retrieveAll(callBack)
  for i = self.front, self.rear do
    local element = self.list[i]

    callBack(element)
  end
end

function Queue:print()
  for i = self.front, self.rear do
    local element = self.list[i]
    print("element : " .. element)
  end

  print("[Queue] Count : " .. (self.rear - self.front) + 1)
end
