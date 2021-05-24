-- Update Date : 200317
-- Writer : Sunggon Hong

require "FileIOKit/JSON/json.lua"

FileIODataType = {
  Value = 1,
  Table = 2,
  Texture = 3,
}

FileIOKit = {
  filePath = nil,
  dataType = FileIODataType.Value
}

function FileIOKit.new(filePath, dataType)
  local newIO = {}

  setmetatable(newIO, FileIOKit)
  FileIOKit.__index = FileIOKit

  newIO.filePath = filePath
  newIO.dataType = dataType

  return newIO
end

function FileIOKit:write(data)
  local path = self:getFilePath()
  
  if (self.dataType == FileIODataType.Texture) then
    local targetPath = BASE_DIRECTORY .. path
    data:writeToFile(targetPath)
  else
    local file = io.open(BASE_DIRECTORY .. path, "w")
    local dataString = ""
    if (self.dataType == FileIODataType.Table) then
      dataString = json.encode(data)
    else
      dataString = tostring(data)
    end
    file:write(dataString)
    file:close()
  end
  
end

function FileIOKit:read()
  local path = self:getFilePath()
  local file = io.open(BASE_DIRECTORY .. path, "r")
  
  if (file == nil) then
    print("[FileIOKit] file is nil")
    return nil
  end
  
  local data = file:read()
  
  file:close()
  
  if (self.dataType == FileIODataType.Table) then
    return json.decode(data)
  else
    return data
  end
end


function FileIOKit:createTextureFromFile()
  local path = self:getFilePath()
  local file = io.open(BASE_DIRECTORY .. path, "r")

  if (file == nil) then
    print("[FileIOKit] file is nil")
    return nil
  end

  file:close()

  return Texture.create(BASE_DIRECTORY .. path, false, false)
end


function FileIOKit:getFilePath()
  if self.dataType == FileIODataType.Texture then
    return self.filePath .. ".tex"
  else
    return self.filePath .. ".db"
  end
end
