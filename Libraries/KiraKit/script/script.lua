require "kiraItemList.lua"
require "KiraKit.lua"

g_kiraKit = nil

function sceneCreated(scene)
  g_kiraKit = KiraKit.new(scene)
end

function frameReady(scene, elapsedTime)
  g_kiraKit:frameReady()
end

function finalize(scene)
  g_kiraKit:finalize()
end