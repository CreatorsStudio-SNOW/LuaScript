require "setting.lua"
require "photo_template.lua"

g_photoTemplate = nil

function initialize(scene)
  local snapshot = getSnapshot(scene, 1.0)
  local items = {
    {frameIndex = 0, effect = EffectType.TWIST, duration = 1, easing = EasingType.LINEAR, config = { ["startStrength"] = 0.0, ["endStrength"] = 0.85 }},
    {frameIndex = 1, effect = EffectType.TWIST, duration = 1, easing = EasingType.LINEAR, config = { ["startStrength"] = 0.85, ["endStrength"] = 1.0 }},
    {frameIndex = 2, effect = EffectType.TWIST, duration = 8, easing = EasingType.LINEAR, config = { ["startStrength"] = 1.0, ["endStrength"] = 1.0 }},
    {frameIndex = 5, effect = EffectType.ROLLING, duration = 4, easing = EasingType.IN_QUAD, config = { ["startRolling"] = 994, ["endRolling"] = 510 }},
    {frameIndex = 10, effect = EffectType.TWIST, duration = 1, easing = EasingType.LINEAR, config = { ["startStrength"] = 1.0, ["endStrength"] = 0.0 }},
  }

  g_photoTemplate = PhotoTemplate:new(scene, nil, items)
end

function reset(scene)
  g_photoTemplate:reset()
end

function frameReady(scene, elapsedTime)
  g_photoTemplate:checkFrame()
end

function finalize(scene)
  g_photoTemplate:release()
end

function getSnapshot(scene, bufferScale)
  local node = KuruSnapshotNode.create()

  scene:addNode(node)
  node:release()
  node:setFrameBufferScale(bufferScale, bufferScale)

  return node
end
