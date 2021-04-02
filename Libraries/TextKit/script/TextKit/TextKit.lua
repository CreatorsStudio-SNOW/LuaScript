-- 2019. 03. 27.
-- jeong.ji.hun

TextKit = {
  eventExtension = nil,
  TEXT_KIT_INSTANCE = {}
}

EVENT_NAME_TEXT_TO_APP = "TextEventToApp"
EVENT_NAME_TEXT_TO_SCRIPT = "TextEventToScript"

TextMethodType = {
  SHOW_TEXT_INPUT = "showTextInput",
  DISMISS_TEXT_INPUT = "dismissTextInput",
  ENABLE_TEXT_MODE = "enableTextMode",
  DISABLE_TEXT_MODE = "disableTextMode",
  GET_TEXT_IMAGE = "getTextImage",
  SET_TEXT = "setText",
}

TextRequestParams = {
  METHOD_TYPE = "methodType",
  METHOD_ID = "methodId",
  KEYBOARD_TYPE = "keyboardType",
  FONT_FAMILY = "fontFamily",
  IMAGE_WIDTH = "imageWidth",
  IMAGE_HEIGHT = "imageHeight",
  FONT_COLOR = "fontColor",
  MAX_LINE = "maxLine",
  MAX_LENGTH = "maxLength",
  TEXT_ONLY = "textOnly",
  PLACE_HOLDER = "placeholder",
  DEFAULT_TEXT = "defaultText"
}

TextResponseParams = {
  METHOD_TYPE = "methodType",
  METHOD_ID = "methodId",
  TEXT = "text",
  TEXTURE_IDS = "textureIds",
  IMAGE_SIZES = "imageSizes",
  TEXT_ONLY = "textOnly"
}

function TextKit:new(textOption, responseFunction)
  local newTextKit = {}

  setmetatable(newTextKit, self)
  self.__index = self

  newTextKit[TextRequestParams.METHOD_TYPE] = TextMethodType.GET_TEXT_IMAGE
  newTextKit[TextRequestParams.METHOD_ID] = "default"
  newTextKit[TextRequestParams.FONT_FAMILY] = nil
  newTextKit[TextRequestParams.IMAGE_WIDTH] = 750
  newTextKit[TextRequestParams.IMAGE_HEIGHT] = 100
  newTextKit[TextRequestParams.FONT_COLOR] = "FFFFFFFF"
  newTextKit[TextRequestParams.MAX_LINE] = 1
  newTextKit[TextRequestParams.MAX_LENGTH] = 20
  newTextKit[TextRequestParams.TEXT_ONLY] = false
  newTextKit[TextRequestParams.PLACE_HOLDER] = nil

  TextKit.setTable(newTextKit, textOption)

  if TextKit.eventExtension == nil then
    local kuruEngineInstance = KuruEngine.getInstance()
    TextKit.eventExtension = KuruEventExtension.cast(kuruEngineInstance:getExtension("KuruEvent"))
    TextKit.eventExtension:getSimpleEvent():addEventHandler(TextKit_responseEventHandler)
  end
  TextKit.TEXT_KIT_INSTANCE[#TextKit.TEXT_KIT_INSTANCE + 1] = newTextKit

  newTextKit.instanceIdx = #TextKit.TEXT_KIT_INSTANCE
  newTextKit.responseFunction = responseFunction

  if newTextKit[TextRequestParams.METHOD_TYPE] == TextMethodType.ENABLE_TEXT_MODE then
    newTextKit:changeToEnableTextMode()
  end

  print("---- TextKit init")

  return newTextKit
end

function TextKit:showTextInput(textOption)
  local request = self:getRequestWithOption(textOption)
  request[TextRequestParams.METHOD_TYPE] = TextMethodType.SHOW_TEXT_INPUT
  self:postTextEventAsync(request)
end

function TextKit:changeToEnableTextMode(textOption)
  local request = self:getRequestWithOption(textOption)
  request[TextRequestParams.METHOD_TYPE] = TextMethodType.ENABLE_TEXT_MODE
  self:postTextEventAsync(request)
end

function TextKit:changeToDisableTextMode(textOption)
  local request = self:getRequestWithOption(textOption)
  request[TextRequestParams.METHOD_TYPE] = TextMethodType.DISABLE_TEXT_MODE
  self:postTextEventAsync(request)
end

function TextKit:createTexture(text, textOption)
  local request = self:getRequestWithOption(textOption)
  request[TextRequestParams.METHOD_TYPE] = TextMethodType.GET_TEXT_IMAGE
  request[TextRequestParams.PLACE_HOLDER] = text

  local responseObj = self:postTextEventSync(request)
  local textureInfos = self:getTextureInfoList(responseObj)

  if 0 < #textureInfos then
    return Texture.createWithHandle(textureInfos[1].textureId, textureInfos[1].width, textureInfos[1].height, TextureFormat.RGBA)
  end

  return nil
end

function TextKit.setTable(table, other)
  if other then
    for k, v in pairs(other) do
      table[k] = v
    end
  end
end

function TextKit:getRequestWithOption(textOption)
  local request = {}

  for k,v in pairs(TextRequestParams) do
    request[v] = self[v]
  end

  TextKit.setTable(request, textOption)

  return request
end

function TextKit:getTextureInfoList(jsonObject)
  local textureList = {}

  local textureIds = jsonObject[TextResponseParams.TEXTURE_IDS] or {}
  local imageSizes = jsonObject[TextResponseParams.IMAGE_SIZES] or {}

  for i,v in ipairs(textureIds) do
    textureList[#textureList + 1] = {textureId=textureIds[i], width=imageSizes[i][1], height=imageSizes[i][2]}
  end

  return textureList
end

function TextKit:notifyToScript(jsonObject)
  local textureInfoList = self:getTextureInfoList(jsonObject)
  local textureList = {}
  for i,v in ipairs(textureInfoList) do
    textureList[#textureList + 1] = Texture.createWithHandle(v["textureId"], v["width"], v["height"], TextureFormat.RGBA)      
  end

  if self.responseFunction then
    self.responseFunction(jsonObject, textureList)
  end

  for i,v in ipairs(textureList) do
    v:release()
  end
end

function TextKit:postTextEventSync(request)
  local requestString = json.encode(request)
  print(">>> TextKit Posting Sync Event: " .. requestString .. "")
  local kuruEngineInstance = KuruEngine.getInstance()
  local response = KuruStatusExtension.cast(kuruEngineInstance:getExtension("KuruStatus")):apply(EVENT_NAME_TEXT_TO_APP, requestString)
  print("<<< TextKit Recevie Sync Event Response: " .. response .. "")
  return json.decode(response)
end

function TextKit:postTextEventAsync(request)
  local requestId = "TextKit_" .. self.instanceIdx .. "_" .. request[TextRequestParams.METHOD_ID]
  request[TextRequestParams.METHOD_ID] = requestId
  local requestString = json.encode(request)
  print(">>> TextKit Posting Async Event: " .. requestString .. "")
  TextKit.eventExtension:postSimpleEventToApp(EVENT_NAME_TEXT_TO_APP, requestString)
end

function TextKit.finalize(scene)
  TextKit.eventExtension:getSimpleEvent():removeEventHandler(TextKit_responseEventHandler)
  TextKit.eventExtension = nil
  print("---- TextKit finalize")
end

function TextKit.split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function TextKit_responseEventHandler(event)
  local eventObj = KuruEventExtensionSimpleEventArgs.cast(event)
  local eventName = eventObj:getName()

  if (eventName == EVENT_NAME_TEXT_TO_SCRIPT) then
    local response = eventObj:getArg()
    local responseObj = json.decode(response)

    local instanceIdx = tonumber(TextKit.split(responseObj[TextResponseParams.METHOD_ID], "_")[2])

    TextKit.TEXT_KIT_INSTANCE[instanceIdx]:notifyToScript(responseObj)
  end
end



