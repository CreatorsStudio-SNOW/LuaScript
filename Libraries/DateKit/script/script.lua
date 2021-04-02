--[[
   create at 2020-7-14 16:37:02
   author: Hong Sung Gon
   @brief:
--]]

require "DateKit/DateKit.lua"

AlignType = {
  Horizontal = 1,
  Vertical = 2
}


PropertyType = {
  Format = 1,
  Scale = 2,
  TransX = 3,
  TransY = 4,
  Rotate = 5,
  Anchor = 6,
  Variant = 7,
  Fill = 8,
  Ratio = 9,
  Align = 10,
  Blend = 11
}

g_dateKit = nil
g_dateNodes = {}
g_frameBufferNodes = {}
g_configs = {}
g_scene = nil

function initialize(scene)
  DateUtil.init()
  g_scene = scene
  g_dateKit = DateKit.create(scene)
  g_configs = {
    {"yyyy", 1.0, 0.0, 0.0, 0.0, KuruBackgroundImageNodeAnchorType.CENTER, StickerItemRotationMode.INVARIANT, KuruBackgroundImageNodeStretch.FILL_HORIZONTAL, CameraConfigAspectRatio.ANY, AlignType.Horizontal, BlendMode.None }
 }

 for i = 1, #g_configs do
   addBGNode(scene, i)
 end
end

function frameReady(scene, elapsedTime)
  local config = KuruEngine.getInstance():getCameraConfig()

  if config["isImageMode"] == nil or config:isImageMode() == false then
    g_dateKit:frameReady(scene)
    updateDateNodes()
  end
end

function finalize(scene)
  if (g_dateKit ~= nil) then
    g_dateKit:release()
  end
end

function updateDateNodes()
  for i = 1, #g_frameBufferNodes do
    if (g_frameBufferNodes[i] ~= nil) then
      g_scene:removeNode(g_frameBufferNodes[i])
    end
  end

  for i = 1, #g_dateNodes do
    if (g_dateNodes[i] ~= nil) then
      g_scene:removeNode(g_dateNodes[i])
    end

    addBGNode(g_scene, i)
  end
end

function addBGNode(scene, index)
  local config = g_configs[index]
  local format = config[PropertyType.Format]
  local scaleValue = config[PropertyType.Scale]
  local transX = config[PropertyType.TransX]
  local transY = config[PropertyType.TransY]
  local rotateZ = config[PropertyType.Rotate]
  local anchor = config[PropertyType.Anchor]
  local variant = config[PropertyType.Variant]
  local fillMode = config[PropertyType.Fill]
  local ratioType = config[PropertyType.Ratio]
  local isHorizontal = (config[PropertyType.Align] == AlignType.Horizontal)
  local blendModeType = config[PropertyType.Blend]

  g_frameBufferNodes[index] = g_dateKit:getFrameBuffer(format, isHorizontal)
  g_dateNodes[index] = KuruBackgroundImageNode.createFromSampler(g_frameBufferNodes[index]:getSampler())
  g_dateNodes[index]:setStretch(fillMode)
  g_dateNodes[index]:setAnchorType(anchor)
  g_dateNodes[index]:setRotationMode(variant)
  g_dateNodes[index]:rotateZ(rotateZ)
  g_dateNodes[index]:setScale(scaleValue, scaleValue, 1.0)
  g_dateNodes[index]:setTranslation(transX, transY, 0.0)
  g_dateNodes[index]:getStickerItem().aspectRatio = ratioType
  scene:addNodeAndRelease(g_dateNodes[index])
end
