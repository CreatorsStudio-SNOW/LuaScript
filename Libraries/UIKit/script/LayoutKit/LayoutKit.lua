-- Update Date : 20200414
-- Writer : Sangcheol Jeon

require "LayoutKit/LView.lua"
require "LayoutKit/LayoutBox.lua"
require "LayoutKit/TextureUtil.lua"

LayoutKit = {
}

function LayoutKit.init(scene)
  LayoutBox.scene = scene
  LayoutBox.init()

  local textureUtil = TextureUtil:new(BASE_DIRECTORY)
  LayoutBox.textureUtil = textureUtil
end

function LayoutKit.finalize()
	LayoutBox.textureUtil:release()
end
