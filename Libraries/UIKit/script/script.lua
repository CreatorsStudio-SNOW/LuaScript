require "FileIOKit/FileIOKit.lua"
require "UIKit/UIKit.lua"
require "LayoutKit/LayoutKit.lua"
require "UIScrollBar.lua"

buttonPrefixPath = "res/"

BUTTON_ID = {
  contrast = "contrast",
  saturation = "saturation",
  temperature = "temperature",
  tint = "tint",
}

BUTTON_WIDTH = 121
BUTTON_HEIGHT = 121

BUTTON_X = 60
BUTTON_Y = 350

g_buttonInfo = {
  {
    tag = BUTTON_ID.contrast,
    offsetX = BUTTON_X,
    offsetY = BUTTON_Y,
    normalImagePath = buttonPrefixPath .. "contrast_off.png",
    selectedImagePath = buttonPrefixPath .. "contrast_on.png",
  },
  {
    tag = BUTTON_ID.saturation,
    offsetX = BUTTON_X,
    offsetY = BUTTON_Y + 150,
    normalImagePath = buttonPrefixPath .. "saturation_off.png",
    selectedImagePath = buttonPrefixPath .. "saturation_on.png",
  },
  {
    tag = BUTTON_ID.temperature,
    offsetX = BUTTON_X,
    offsetY = BUTTON_Y + 300,
    normalImagePath = buttonPrefixPath .. "temperature_off.png",
    selectedImagePath = buttonPrefixPath .. "temperature_on.png",
  },
  {
    tag = BUTTON_ID.tint,
    offsetX = BUTTON_X,
    offsetY = BUTTON_Y + 450,
    normalImagePath = buttonPrefixPath .. "tint_off.png",
    selectedImagePath = buttonPrefixPath .. "tint_on.png",
  }
}

g_buttons = {}
g_currentButton = BUTTON_ID.contrast

g_detail_data = {
  contrast = 0.5,
  saturation = 0.5,
  tint = 0.5,
  temperature = 0.5,
  selectedButton = BUTTON_ID.contrast
}

g_scrollbar = nil
g_fileIOKit = nil

function initialize(scene)
  UIKit.init(scene, 720, 1280)
  LayoutKit.init(scene)

  detailNode = KuruImageDetailNode.create()
  -- detailNode:getParam().contrast = -0.4
  -- detailNode:getParam().saturation = 1
  -- detailNode:getParam().tint = 0.6
  -- detailNode:getParam().temperature = -0.25
  scene:addNodeAndRelease(detailNode)

  g_scrollbar = UIScrollBar:init(scene, 0.3)

  local kuruEngineInstance = KuruEngine.getInstance()
  kuruTouch = KuruTouchExtension.cast(kuruEngineInstance:getExtension("KuruTouch"))

  kuruTouch:getTouchDownEvent():addEventHandler(onTouchDown)
  kuruTouch:getTouchMoveEvent():addEventHandler(onTouchMove)
  kuruTouch:getTouchUpEvent():addEventHandler(onTouchUp)

  setupButtons()

  g_fileIOKit = FileIOKit.new("detail.txt", FileIODataType.Table)

  local table = g_fileIOKit:read()
  if table ~= nil then
    g_detail_data = table
  end

  for k, v in pairs(g_detail_data) do
    if tostring(k) ~= "selectedButton" then
      updateStrength(tostring(k), v)
    end
  end

  onButtonPressed(g_buttons[g_detail_data.selectedButton])


end

g_prev_strength = -1

function frameReady(scene, elapsedTime)
  -- local strength = PropertyConfig.instance():getNumber("stickerSliderValue", 1.0)
  g_scrollbar:frameReady(elapsedTime)
  -- local sliderWeight = (PropertyConfig.instance():getNumber("stickerSliderValue", 1.0) * 0.7) + 0.35
  local strength = g_scrollbar:getStrength()
  if g_prev_strength ~= strength then
    updateStrength(g_currentButton, strength)
    g_prev_strength = strength
  end
end

function setupButtons()
  for k, v in ipairs(g_buttonInfo) do
    g_buttons[v.tag] = UIButton:new(
      UIRect:new(v.offsetX, v.offsetY, BUTTON_WIDTH, BUTTON_HEIGHT),
      v.normalImagePath,
      v.selectedImagePath,
      onButtonPressed,
      false,
      true,
      v.tag
    )
    g_buttons[v.tag]:addToScene(0.0, 0.0)
    -- g_buttons[v.tag]:print()
  end
end

function onTouchDown(event)
  for k, v in pairs(g_buttons) do
    v:onTouchDown(event)
  end

  g_scrollbar:onTouchDown(event)
end

function onTouchMove(event)
  for k, v in pairs(g_buttons) do
    v:onTouchMove(event)
  end

  g_scrollbar:onTouchMove(event)
end

function onTouchUp(event)
  for k, v in pairs(g_buttons) do
    v:onTouchUp(event)
  end

  g_scrollbar:onTouchUp(event)

  g_fileIOKit:write(g_detail_data)
end

function onButtonPressed(button)
  deselectAllButton()
  button:setSelected(true)
  g_currentButton = button.tag
  g_scrollbar:setStrength(g_detail_data[g_currentButton])
  g_detail_data.selectedButton = g_currentButton
end

function updateStrength(buttonId, strength)

  strength = math.floor(strength * 1000) / 1000

  local value = strength * 2.0 - 1.0

  if buttonId == BUTTON_ID.contrast then
    detailNode:getParam().contrast = value
    g_detail_data.contrast = strength
  elseif buttonId == BUTTON_ID.saturation then
    detailNode:getParam().saturation = value
    g_detail_data.saturation = strength
  elseif buttonId == BUTTON_ID.temperature then
    detailNode:getParam().temperature = value
    g_detail_data.temperature = strength
  else
    detailNode:getParam().tint = value
    g_detail_data.tint = strength
  end

  addOrUpdateData(buttonId, strength)
end

function deselectAllButton()
  for k, v in pairs(g_buttons) do
    v:setSelected(false)
  end
end

function finalize(scene)
  g_scrollbar:finalize()
  LayoutKit.finalize()
  kuruTouch:getTouchDownEvent():removeEventHandler(onTouchDown)
  kuruTouch:getTouchMoveEvent():removeEventHandler(onTouchMove)
  kuruTouch:getTouchUpEvent():removeEventHandler(onTouchUp)
end
