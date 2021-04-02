require "MotionKit.lua"

function initialize(scene)
  local motionItems = {
      MotionItem:new(40, 65, 80, 0.5, 2.0),
      MotionItem:new(100, 120, 140, 0.3, 3.0),
      MotionItem:new(150, 165, 180, 0.7, 1.5)
  }

  local cameraSnapshot = getSnapshot(scene, 0.5)

  g_motionKit = MotionKit:new(scene, cameraSnapshot, motionItems, 0.5)
end

function frameReady(scene, elapsedTime)
  g_motionKit:frameReady(elapsedTime)
end

function reset(scene)
  g_motionKit:reset()
end

function finalize(scene)
  g_motionKit:release()
end

function getSnapshot(scene, bufferScale)
  local node = KuruSnapshotNode.create()

  node:setFrameBufferScale(bufferScale, bufferScale)
  scene:addNodeAndRelease(node)

  return node
end
