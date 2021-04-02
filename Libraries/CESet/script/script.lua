-- Update Date : 200101
-- Writer : Sunggon Hong

require "CESet.lua"

function initialize(scene)
  local setA = CESet.new{ 1, 2, 3 }
  local setB = CESet.new{ 2, 3, 4 }
  local unionSet = setA+setB
  local subtractSet = setA-setB
  local interSectionSet = setA*setB
  local str = ""

  for key, val in pairs(unionSet:getTable()) do
    str = str .. ", " .. val
  end

  print("[script] union set : " .. str)

  str = ""

  for key, val in pairs(subtractSet:getTable()) do
    str = str .. ", " .. val
  end

  print("[script] subtract set : " .. str)

  str = ""

  for key, val in pairs(interSectionSet:getTable()) do
    str = str .. ", " .. val
  end

  print("[script] interSection set : " .. str)
end
