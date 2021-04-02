require "CECollage/CECollage.lua"

COMPOSITION = {
  BG_SIZE = {
    WIDTH = 720.0,
    HEIGHT = 1280.0
  },

  BASE_RULE = {
    size = {
      width = 240,
      height = 426.7
    },
    scale = 0.33333,
    anchor = {
      x = 0,
      y = 0
    }
  },

  BG_COLOR = Vector4.create(0.0, 0.0, 0.0, 1.0)
}

function initialize(scene)
  cameraSnapshot = KuruSnapshotNode.create()
  scene:addNodeAndRelease(cameraSnapshot)

  detailNode = KuruImageDetailNode.create()
  scene:addNodeAndRelease(detailNode)
  detailNode:getParam().contrast = 1.0
  -- detailNode:getParam().brightness = 1.0

  cameraSnapshot2 = KuruSnapshotNode.create()
  scene:addNodeAndRelease(cameraSnapshot2)

  detailNode = KuruImageDetailNode.create()
  scene:addNodeAndRelease(detailNode)
  detailNode:getParam().saturation = -1.0

  cameraSnapshot3 = KuruSnapshotNode.create()
  scene:addNodeAndRelease(cameraSnapshot3)

  local collage = CECollage:new(scene, cameraSnapshot:getSnapshot(), COMPOSITION)
  :setCollageLayer({position = {x = 120.0, y = 1066.7}})
  :setCollageLayerWithSampler(cameraSnapshot2:getSampler(), {position = {x = 360.0, y = 1066.7}})
  :setCollageLayer({position = {x = 600.0, y = 1066.7}})
  :setCollageLayer({position = {x = 120.0, y = 640}})
  :setCollageLayer({position = {x = 360.0, y = 640}})
  :setCollageLayerWithSampler(cameraSnapshot2:getSampler(), {position = {x = 600.0, y = 640}})
  :setCollageLayerWithSampler(cameraSnapshot3:getSampler(), {position = {x = 120.0, y = 213.3}})
  :setCollageLayer({position = {x = 360.0, y = 213.3}})
  :setCollageLayerWithSampler(cameraSnapshot3:getSampler(), {position = {x = 600.0, y = 213.3}})
  :build()

  scene:addNodeAndRelease(KuruBackgroundImageNode.createFromSampler(collage:getSampler(), BlendMode.None))
end

function reset(scene)
end

function onAspectRatioChanged(scene)
end

function frameReady(scene, elapsedTime)
end

function finalize(scene)
end
