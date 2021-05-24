require "CELayout/CELayout.lua"

COMPOSITION = {
  BG_SIZE = {WIDTH = 720.0, HEIGHT = 1280.0},

  BASE_RULE = {
    size = {width = 240, height = 426.7},
    scale = 0.33333,
    anchor = {x = 0, y = 0}
  },

  BG_COLOR = Vector4.create(0.0, 0.0, 0.0, 1.0)
}

function initialize(scene)
  local originSnapshot = KuruSnapshotNode.create()
  scene:addNodeAndRelease(originSnapshot)

  local detailNode1 = KuruImageDetailNode.create()
  scene:addNodeAndRelease(detailNode1)
  detailNode1:getParam().contrast = 1.0

  local detailSnap1 = KuruSnapshotNode.create()
  scene:addNodeAndRelease(detailSnap1)

  local detailNode2 = KuruImageDetailNode.create()
  scene:addNodeAndRelease(detailNode2)
  detailNode2:getParam().saturation = -1.0

  local detailSnap2 = KuruSnapshotNode.create()
  scene:addNodeAndRelease(detailSnap2)

  local layout = CELayout:new(scene, originSnapshot:getSnapshot(), COMPOSITION)
  :setCollageLayer({position = {x = 120.0, y = 1066.7}})
  :setCollageLayerWithSampler(detailSnap1:getSampler(), {position = {x = 360.0, y = 1066.7}})
  :setCollageLayer({position = {x = 600.0, y = 1066.7}})
  :setCollageLayer({position = {x = 120.0, y = 640}})
  :setCollageLayer({position = {x = 360.0, y = 640}})
  :setCollageLayerWithSampler(detailSnap1:getSampler(),{position = {x = 600.0, y = 640}})
  :setCollageLayerWithSampler(detailSnap2:getSampler(),{position = {x = 120.0, y = 213.3}})
  :setCollageLayer({position = {x = 360.0, y = 213.3}})
  :setCollageLayerWithSampler(detailSnap2:getSampler(), {position = {x = 600.0, y = 213.3}})
  :build()

  scene:addNodeAndRelease(KuruBackgroundImageNode.createFromSampler(layout:getSampler(), BlendMode.None))
end