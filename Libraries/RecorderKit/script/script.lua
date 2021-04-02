--[[
   create at 2018-10-18 16:37:02
   author: Hong Sung Gon
   @brief:
--]]

require "RecorderKit/RecorderKit.lua"

g_recorderKit = nil

function initialize(scene)
  g_cameraSnapshot =  addNodeAndRelease(scene, KuruSnapshotNode.create())
  g_recorderKit = RecorderKit:new(scene, g_cameraSnapshot, 1500.0, 0.5, 30.0)
  g_displayNode = getFragmentShader("display.frag")
  scene:addNodeAndRelease(g_displayNode)
  g_displayNode:setChannel1(g_cameraSnapshot:getSampler())
  g_displayNode:setChannel2(g_cameraSnapshot:getSampler())
  g_displayNode:setChannel3(g_cameraSnapshot:getSampler())
end

function finalize(scene)
  g_recorderKit:release()
end

function frameReady(scene, elapsedTime)
  g_recorderKit:frameReady(elapsedTime)

  local totalElapsedTime = scene:getTotalElapsedTime()

  if (totalElapsedTime > 2000.0) then
    local sampler = g_recorderKit:createSampler(400.0)

    g_displayNode:setChannel1(sampler)
    sampler:release()
    sampler = g_recorderKit:createSampler(800.0)
    g_displayNode:setChannel2(sampler)
    sampler:release()
    sampler = g_recorderKit:createSampler(1200.0)
    g_displayNode:setChannel3(sampler)
    sampler:release()
  end
end

function reset(scene)
  g_recorderKit:reset()
  g_displayNode:setChannel1(g_cameraSnapshot:getSampler())
  g_displayNode:setChannel2(g_cameraSnapshot:getSampler())
  g_displayNode:setChannel3(g_cameraSnapshot:getSampler())
end

function addNodeAndRelease(scene, node)
  scene:addNodeAndRelease(node)

  return node
end

function getFragmentShader(filePath)
  return KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. filePath, true)
end
