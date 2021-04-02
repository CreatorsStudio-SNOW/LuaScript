

TriggerUtil = {}

function TriggerUtil.getDictCount(dict)
  local count = 0

  for key in pairs(dict) do
    if dict[key] ~= nil then
      count = count + 1
    end
  end

  return count
end

function TriggerUtil.getAllValues(originDict)
  local values = {}

  for key in pairs(originDict) do
      if originDict[key] ~= nil then
        values[#values + 1] = originDict[key]
      end
  end

  return values
end

function TriggerUtil.getDictFromDeepCopy(fromDict)
  local resultDict = {}

  for key in pairs(fromDict) do
      if fromDict[key] ~= nil then
        resultDict[key] = fromDict[key]
      end
  end

  return resultDict
end

function TriggerUtil.getDataDictByUpdated(currentActivatedDataDict, prevActivatedDict)
  local activatedDict = {}
  local activatingDict = {}
  local deActivatedDict = {}

  if (TriggerUtil.getDictCount(currentActivatedDataDict) <= 0) then
    deActivatedDict = TriggerUtil.getDictFromDeepCopy(prevActivatedDict)

    return activatedDict, activatingDict, deActivatedDict
  end

  if (TriggerUtil.getDictCount(prevActivatedDict) <= 0) then
    activatedDict = TriggerUtil.getDictFromDeepCopy(currentActivatedDataDict)

    return activatedDict, activatingDict, deActivatedDict
  end

  activatedDict = TriggerUtil.getDictFromDeepCopy(currentActivatedDataDict)
  deActivatedDict = TriggerUtil.getDictFromDeepCopy(prevActivatedDict)

  for key in pairs(currentActivatedDataDict) do
    for prevDictKey in pairs(prevActivatedDict) do
      if (key == prevDictKey) then
        activatingDict[key] = currentActivatedDataDict[key]
        activatedDict[key] = nil
        deActivatedDict[key] = nil
      end
    end
  end

  return activatedDict, activatingDict, deActivatedDict
end

function TriggerUtil.printDictKey(prefix, dict)
  local resultString = ""

  for key in pairs(dict) do
      if dict[key] ~= nil then
        resultString = resultString .. ", " .. key
      end
  end

  print("[script] dict Key " .. prefix .. " : " .. resultString)
end
