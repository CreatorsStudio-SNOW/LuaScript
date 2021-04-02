
CESet = {}

function CESet.new(table)
  local newSet = {}

  setmetatable(newSet, CESet)
  CESet.__index = CESet

  if (table ~= nil) then
    for _, val in ipairs(table) do
      newSet[val] = true
    end
  end

  return newSet
end

function CESet.__sub(set1, set2)
  local newSet = CESet.new()

  for key, _ in pairs(set1) do
    newSet[key] = set1[key]
  end

  for key, _ in pairs(set2) do
    if (set2[key]) then
      newSet[key] = false
    end
  end

  return newSet
end

function CESet.__add(set1, set2)
  local newSet = CESet.new()

  for key, _ in pairs(set1) do
    newSet[key] = set1[key]
  end

  for key, _ in pairs(set2) do
    newSet[key] = set2[key]
  end

  return newSet
end

function CESet.__mul(set1, set2)
  local newSet = CESet.new()

  for key1, _ in pairs(set1) do
    if (set1[key1]) then
      for key2, _ in pairs(set2) do
        if (key1 == key2 and set2[key2]) then
          newSet[key1] = true
        end
      end
    end
  end

  return newSet
end

function CESet:getTable()
  local table = {}

  for key, value in pairs(self) do
    if (value) then
      table[#table + 1] = key
    end
  end

  return table
end
