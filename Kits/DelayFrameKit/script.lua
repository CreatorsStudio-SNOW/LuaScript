require "DelayFrameKit/DelayFrameKit.lua"

TOTAL_TIME = 1500
BUFFER_SIZE = 0.5
FPS = 24

function initialize(scene)
  g_originSnapshot =  KuruSnapshotNode.create()
  scene:addNodeAndRelease(g_originSnapshot)

  g_delayFrameKit = DelayFrameKit:new(scene, g_originSnapshot, TOTAL_TIME, BUFFER_SIZE, FPS)
  g_divShaderNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "div.frag", true)
  scene:addNodeAndRelease(g_divShaderNode)

  g_divShaderNode:setChannel1(g_originSnapshot:getSampler())
  g_divShaderNode:setChannel2(g_originSnapshot:getSampler())
  g_divShaderNode:setChannel3(g_originSnapshot:getSampler())
end

function frameReady(scene, elapsedTime)
  g_delayFrameKit:frameReady(elapsedTime)
  if (scene:getTotalElapsedTime() <= 0.0) then --Skip the first frame
    return
  end

  local sampler1 = g_delayFrameKit:createSampler(400.0)
  g_divShaderNode:setChannel1(sampler1)
  sampler1:release()

  local sampler2 = g_delayFrameKit:createSampler(800.0)
  g_divShaderNode:setChannel2(sampler2)
  sampler2:release()

  local sampler3 = g_delayFrameKit:createSampler(1200.0)
  g_divShaderNode:setChannel3(sampler3)
  sampler3:release()
end

function reset(scene)
  g_delayFrameKit:reset()
  g_divShaderNode:setChannel1(g_originSnapshot:getSampler())
  g_divShaderNode:setChannel2(g_originSnapshot:getSampler())
  g_divShaderNode:setChannel3(g_originSnapshot:getSampler())
end

function finalize(scene)
  g_delayFrameKit:release()
end
