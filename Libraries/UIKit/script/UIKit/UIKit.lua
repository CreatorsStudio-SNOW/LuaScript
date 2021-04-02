require "UIKit/UIView.lua"
require "UIKit/UIButton.lua"
require "UIKit/UIRect.lua"
require "UIKit/UIScrollView.lua"
require "UIKit/UISamplerView.lua"

UIKit = {
}

function UIKit.init(scene, baseWidth, baseHeight)
  UIView.scene = scene
  UIView.baseWidth = baseWidth
  UIView.baseHeight = baseHeight
end

function UIKit.update(baseWidth, baseHeight)
  UIView.baseWidth = baseWidth
  UIView.baseHeight = baseHeight
end
