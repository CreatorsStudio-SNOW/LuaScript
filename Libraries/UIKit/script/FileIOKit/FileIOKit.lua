-- Update Date : 200317
-- Writer : Sunggon Hong

require "FileIOKit/JSON/json.lua"

FileIODataType = {
  Value = 1,
  Table = 2
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
  local file = io.open(BASE_DIRECTORY .. self.filePath, "w")
  local dataString = ""

  if (self.dataType == FileIODataType.Table) then
    dataString = json.encode(data)
  else
    dataString = tostring(data)
  end

  file:write(dataString)
  file:close()
end

function FileIOKit:read()
  local file = io.open(BASE_DIRECTORY .. self.filePath, "r")

  if (file == nil) then
    print("[script file is nil")
    return nil
  end

  local data = file:read()

  file:close()

  if (self.dataType == FileIODataType.Table) then
    return json.decode(data)
  else
    return data
  end

  return data
end
