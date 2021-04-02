--[[
   create at 2019-8-22 16:37:02
   author: Hong Sung Gon
   @brief:
--]]

require "UIScrollBar.lua"

g_scrollBar = nil

function initialize(scene)
  g_scrollBar = UIScrollBar:init(scene, 0.5)
  g_colorShaderNode = getFragmentShader("display.frag")
  scene:addNodeAndRelease(g_colorShaderNode)
  g_colorShaderNode:setChannel1(g_scrollBar:getPickerColorSampler())
end

function frameReady(scene, elapsedTime)
  g_scrollBar:frameReady()
end

function finalize(scene)
  g_scrollBar:finalize()
end

function getFragmentShader(filePath)
  return KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. filePath, true)
end
