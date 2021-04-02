require "easing.lua"
require "AE_Template.lua"

COMPOSITION = {
  FPS = 30,
  TOTAL_FRAME = 60,
  SIZE = {
    WIDTH = 720.0,
    HEIGHT = 1280.0
  },
  RepeatFrame = true,
  MotionBlur = true,
  MotionBlurSize = 3.9,
  repeTile = true,
  BG_COLOR = Vector4.create(0.0, 0.0, 0.0, 1.0)
}

TIME_PER_FRAME = 1000 / COMPOSITION.FPS

function initialize(scene)
  local snapshotNode = KuruSnapshotNode.create()
  scene:addNodeAndRelease(snapshotNode)

  bgColorNode = KuruClearNode.create(COMPOSITION.BG_COLOR)
  scene:addNodeAndRelease(bgColorNode)

  Scale1 = {
    {frame = 0, value = 100},
    {frame = 5, easingType = EasingType.LINEAR, value = 100},
    {frame = 10, easingType = EasingType.LINEAR, value = 130},
  }

  AnchorPoint2 = {
    {frame = 0, value = {['x'] = 360.0, ['y'] = 640.0}},
    {frame = 50, easingType = EasingType.LINEAR, value = {['x'] = 720.0, ['y'] = 640.0}},
  }

  Position3 = {
    {frame = 0, value = {['x'] = 360.0, ['y'] = 640.0}},
    {frame = 50, easingType = EasingType.LINEAR, value = {['x'] = 720.0, ['y'] = 640.0}},
  }

  Rotation4 = {
    {frame = 0, value = 0},
    {frame = 50, easingType = EasingType.LINEAR, value = 90},
  }

  solidObject = SolidObject:create(scene, snapshotNode:getSnapshot(), COMPOSITION.SIZE.WIDTH, COMPOSITION.SIZE.HEIGHT, COMPOSITION)
  :setTransformLayerKeyframes(TRANSFORM.Scale, Scale1)
  :setTransformLayerKeyframes(TRANSFORM.AnchorPoint, AnchorPoint2)
  :setTransformLayerKeyframes(TRANSFORM.Position, Position3)
  :setTransformLayerKeyframes(TRANSFORM.Rotation, Rotation4)
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
