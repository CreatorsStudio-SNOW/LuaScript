function _getKeyframe(dataModels)
  local code = ""

  for idx,dataModel in pairs(dataModels) do
      code = code .. '^{dataModels[' .. tostring(idx) .. ']->initialize}^'
  end

  return code
end

function _getInitializeDataModels(dataModels)
  local code = ""

  for idx, dataModel in pairs(dataModels) do
    if dataModel.modelType ~= "Composition" then
      code = code .. '^{dataModels[' .. tostring(idx) .. ']->initialize}^'
    end
  end
  -- body
  return code
end

function _getSoldObjectSetting(dataModels)
  local code = ""

  for idx, dataModel in pairs(dataModels) do
    if dataModel.modelType ~= "Composition" then
      code = code .. '^{dataModels[' .. tostring(idx) .. ']->setKeyframes}^'
    end
  end
  -- body
  return code
end

function _getIndex(dataModels, name)
  local code = ""

  for idx, dataModel in pairs(dataModels) do
    if dataModel.name == name then
      return tostring(idx)
    end
  end
  -- body
  return "1"
end

---- NodeWrapper END ----