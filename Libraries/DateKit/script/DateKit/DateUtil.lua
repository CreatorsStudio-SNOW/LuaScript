------- class variables ---------
-- numTextures
---------------------------------

DateUtil = {}

D_PATH = {
  ["MONTH"] = "month_",
  ["WEEKDAY"] = "weekday_"
}

function DateUtil.init()
  DateUtil.rootPath = BASE_DIRECTORY .. 'images/'

  local dateTable = nil
  local config = KuruEngine.getInstance():getCameraConfig()

  if config:isGalleryMode() == true or config:isVideoMode() then
    local requestString = "{\"methodType\":\"getMediaCreateTime\",\"methodId\":\"mediaTime\"}"
    local mediaTime = KuruStatusExtension.cast(KuruEngine.getInstance():getExtension("KuruStatus")):apply("EditEventToApp", requestString)

    if mediaTime ~= nil and mediaTime:len() == 14 then
      dateTable = {}
      dateTable.year = string.sub(mediaTime, 0, 4)
      dateTable.month = string.sub(mediaTime, 5, 6)
      dateTable.day = string.sub(mediaTime, 7, 8)
      dateTable.hour = string.sub(mediaTime, 9, 10)
      dateTable.min = string.sub(mediaTime, 11, 12)
      dateTable.sec = string.sub(mediaTime, 13, 14)
    end
  end

  DateUtil.setDate(dateTable)
  DateUtil.textureTable = {}
  DateUtil.textureTable["num_"] = {}

  for i = 0, 9 do
    local texturePath = DateUtil.rootPath .. "num_" .. i .. ".png"
    local texture = Texture.create(texturePath)

    DateUtil.textureTable["num_"][i] = texture
  end

  -- return newObject
end

function DateUtil.updateElapsedtime(scene)
  DateUtil.elapsedTime = scene:getTotalElapsedTime()
  DateUtil.date = DateUtil.originalDate:copy():addticks(DateUtil.elapsedTime * 1000)
end

function DateUtil.setDate(dateTable)
  dateTable = dateTable or false

  DateUtil.elapsedTime = 0
  DateUtil.originalDate = date:new(dateTable)
  DateUtil.date = date:new(dateTable)
end

function DateUtil.getNumTable(num)
  local result = {
    math.floor(num / 10),
    math.floor(num % 10),
  }

  return result
end

function DateUtil.getYearNumTable(year)
  local result = {
    math.floor(year / 1000 % 10),
    math.floor(year / 100 % 10),
    math.floor(year / 10 % 10),
    math.floor(year % 10),
  }

  return result
end

function DateUtil.getTexturesFromTable(table)
  local result = {}

  for i = 1, #table do
    result[i] = DateUtil.getSingleTexture("num_", table[i])
  end

  return result
end

function DateUtil.getSingleTexture(prefix, subKey)
  local prefixKey = prefix or "num_"
  if DateUtil.textureTable[prefixKey] == nil then
     DateUtil.textureTable[prefixKey] = {}
  end

  if DateUtil.textureTable[prefixKey][subKey] == nil then
    local texturePath = DateUtil.rootPath .. prefixKey .. subKey .. ".png"
    local texture = Texture.create(texturePath)

    DateUtil.textureTable[prefixKey][subKey] = texture
  end

  return DateUtil.textureTable[prefixKey][subKey]
end

function DateUtil.getNumTextures(dDigit, length)
  local numTable = nil
  if length == 4 then
    numTable = DateUtil.getYearNumTable(dDigit)
  else
    numTable = DateUtil.getNumTable(dDigit)
  end

  return DateUtil.getTexturesFromTable(numTable)
end

function DateUtil.getTextures(format)
  if (format == "yyyy") then
    return DateUtil.getNumTextures(DateUtil.date:getyear(), 4)
  elseif (format == "yy") then
    return DateUtil.getNumTextures(DateUtil.date:fmt('%g'), 2)
  elseif (format == "mm") then
    return DateUtil.getNumTextures(DateUtil.date:getmonth(), 2)
  elseif (format == "dd") then
    return DateUtil.getNumTextures(DateUtil.date:getday(), 2)
  elseif (format == "ampm") then
    return { DateUtil.getSingleTexture("", DateUtil.date:fmt("%p")) }
  elseif (format == "hh") then
    return DateUtil.getNumTextures(DateUtil.date:gethours(), 2)
  elseif (format == "minmin") then
    return DateUtil.getNumTextures(DateUtil.date:getminutes(), 2)
  elseif (format == "ss") then
    return DateUtil.getNumTextures(DateUtil.date:getseconds(), 2)
  elseif (format == "msms") then
    return DateUtil.getNumTextures(DateUtil.date:getticks() % 100, 2)
  elseif (format == "month") then
    return { DateUtil.getSingleTexture(D_PATH.MONTH, DateUtil.date:getmonth()) }
  elseif (format == "weekday") then
    return { DateUtil.getSingleTexture(D_PATH.WEEKDAY, DateUtil.date:getweekday()) }
  elseif (format == "colon") then
    return { DateUtil.getSingleTexture("", "colon") }
  elseif (format == ".") then
    return { DateUtil.getSingleTexture("", "dot") }
  elseif (format == "/") then
    return { DateUtil.getSingleTexture("", "slash") }
  else
    return { DateUtil.getSingleTexture("", format) }
  end
end

function DateUtil.release()
  for k,v in pairs(DateUtil.textureTable) do
    for subKey, texture in pairs(v) do
      texture:release()
      v[subKey] = nil
    end
    for i, texture in ipairs(v) do
      texture:release()
      v[i] = nil
    end
    DateUtil.textureTable[k] = nil
  end
end

function DateUtil.getMaxHeightFromTextures(textures)
  local maxHeight = 0.0

  for i = 1, #textures do
    local textureHeight = textures[i]:getHeight()

    if (textureHeight > maxHeight) then
      maxHeight = textureHeight
    end
  end

  return maxHeight
end

function DateUtil.getMaxWidthFromTextures(textures)
  local maxWidth = 0.0

  for i = 1, #textures do
    local textureWidth = textures[i]:getWidth()

    if (textureWidth > maxWidth) then
      maxWidth = textureWidth
    end
  end

  return maxWidth
end

function DateUtil.getTotalWidthFromTextures(textures)
  local maxWidth = DateUtil.getMaxWidthNumTextures()
  local texturesCount = #textures

  return maxWidth * texturesCount
end

function DateUtil.getSumWidthFromTextures(textures)
  local texturesCount = #textures
  local sumWidth = 0.0

  for i = 1, texturesCount do
    local textureWidth = textures[i]:getWidth()

    sumWidth = sumWidth + textureWidth
  end

  return sumWidth
end

function DateUtil.getSumHeightFromTextures(textures)
  local texturesCount = #textures
  local sumHeight = 0.0

  for i = 1, texturesCount do
    local textureHeight = textures[i]:getHeight()

    sumHeight = sumHeight + textureHeight
  end

  return sumHeight
end

function DateUtil.getTotalHeightFromTextures(textures)
  local texturesCount = #textures
  local maxHeight = DateUtil.getMaxHeightNumTextures()

  return maxHeight * texturesCount
end

function DateUtil.getMaxWidthNumTextures()
  local maxWidth = 0.0

  for i = 0, 9 do
    local numWidth = DateUtil.textureTable["num_"][i]:getWidth()

    if (maxWidth < numWidth) then
      maxWidth = numWidth
    end
  end

  return maxWidth
end

function DateUtil.getMaxHeightNumTextures()
  local maxHeight = 0.0

  for i = 0, 9 do
    local numHeight = DateUtil.textureTable["num_"][i]:getHeight()

    if (maxHeight < numHeight) then
      maxHeight = numHeight
    end
  end

  return maxHeight
end

function DateUtil.isNumFormat(format)
  if (format == "yyyy" or format == "yy" or format == "mm" or format == "dd" or format == "hh" or format == "minmin" or format == "ss" or format == "msms") then
    return true
  else
    return false
  end
end
