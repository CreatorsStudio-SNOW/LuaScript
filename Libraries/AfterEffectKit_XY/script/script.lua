require "easing.lua"
require "AE_Template.lua"

COMPOSITION = {
  FPS = 30,
  TOTAL_FRAME = 90,
  SIZE = {
    WIDTH = 1080.0,
    HEIGHT = 1920.0
  },
  RepeatFrame = true,
  MotionBlur = true,
  MotionBlurSize = 1.5,
  repeTile = false,
  BG_COLOR = Vector4.create(0.0, 0.0, 0.0, 1.0)
}

TIME_PER_FRAME = 1000 / COMPOSITION.FPS

function initialize(scene)
  local snapshotNode = KuruSnapshotNode.create()
  scene:addNodeAndRelease(snapshotNode)

  bgColorNode = KuruClearNode.create(COMPOSITION.BG_COLOR)
  scene:addNodeAndRelease(bgColorNode)

  Rotation1 = {
    {frame = 0, value = -75},

    {frame = 44, easingType = EasingType.OUT_QUART, value = 0},

    {frame = 89, easingType = EasingType.IN_CUBIC, value = -70},
  }

  AnchorPoint2 = {
    {frame = 0, value = {['x'] = 540.0, ['y'] = 960.0}},
    {frame = 89, easingType = EasingType.LINEAR, value = {['x'] = 540.0, ['y'] = 960.0}},
  }

  Position_X = {
    {frame = 0, value = 940},

    {frame = 30, easingType = EasingType.OUT_QUART, value = 540},

    {frame = 60, easingType = EasingType.LINEAR, value = 540},

    {frame = 89, easingType = EasingType.IN_CUBIC, value = 160},
  }

  Position_Y = {
    {frame = 0, value = 1480},

    {frame = 44, easingType = EasingType.OUT_QUART, value = 960},

    {frame = 89, easingType = EasingType.IN_CUBIC, value = 310},
  }

  -- Position3 = {
  --   {frame = 0, value = {['x'] = 360.0, ['y'] = 640.0}},
  --
  --   {frame = 89, easingType = EasingType.LINEAR, value = {['x'] = 720.0, ['y'] = 640.0}},
  -- }


  solidObject = SolidObject:create(scene, snapshotNode:getSnapshot(), COMPOSITION.SIZE.WIDTH, COMPOSITION.SIZE.HEIGHT, COMPOSITION)

  :setTransformLayerKeyframes(TRANSFORM.Rotation, Rotation1)
  :setTransformLayerKeyframes(TRANSFORM.Position_X, Position_X)
  :setTransformLayerKeyframes(TRANSFORM.Position_Y, Position_Y)
  :build()

  scene:addNodeAndRelease(KuruBackgroundImageNode.createFromSampler(solidObject:getSampler(), BlendMode.Normal))

end
function frameReady(scene, elapsedTime)

  local currentFrameIndex = getCurrentFrameIndex(scene)
  solidObject:frameReady(currentFrameIndex)

end
function finalize(scene)


end
function getCurrentFrameIndex(scene)


  local currentFrameIndex = math.floor(scene:getTotalElapsedTime() / TIME_PER_FRAME)
  if COMPOSITION.RepeatFrame == true then
    return currentFrameIndex % COMPOSITION.TOTAL_FRAME
  end

  return currentFrameIndex

end
