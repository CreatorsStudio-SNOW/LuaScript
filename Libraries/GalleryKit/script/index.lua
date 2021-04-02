require "UIKit/UIKit_181109.lua"
require "ShaderSticker_181112.lua"
require "GalleryKit/GalleryKit.lua"

-- Multi gallery Sample
-- Minhwan.Ho
-- 2019. 03. 13

UIView.baseWidth = 720.0
UIView.baseHeight = 1280.0


ALL_MULTI_CONTENTS = false

buttonViews = {}
ImageSamplers = {}
SELECT_FRAME_NUM = 0
g_scene = nil

samplerJson = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : [{\"index\" : 1, \"photoId\" : \"97F34D03...\", \"textureId\" : 44, \"imageWidth\" : 750, \"imageHeight\" : 960}]}"
samplerJson2 = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : [{\"index\" : 2, \"photoId\" : \"97F34D24...\", \"textureId\" : 27, \"imageWidth\" : 750, \"imageHeight\" : 960}]}"
samplerJson3 = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : [{\"index\" : 1, \"photoId\" : \"97F34D03...\", \"textureId\" : 43, \"imageWidth\" : 400, \"imageHeight\" : 960}, {\"index\" : 3, \"photoId\" : \"97F34D43...\", \"textureId\" : 48, \"imageWidth\" : 750, \"imageHeight\" : 960}]}"
samplerJson4 = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : [{\"index\" : 2, \"photoId\" : \"97F34D03...\", \"textureId\" : 12, \"imageWidth\" : 750, \"imageHeight\" : 500}, {\"index\" : 3, \"photoId\" : \"97F34D42...\", \"textureId\" : 121, \"imageWidth\" : 300, \"imageHeight\" : 800}]}"
samplerJson5 = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : [{\"index\" : 5, \"photoId\" : \"77F34D03...\", \"textureId\" : 19, \"imageWidth\" : 750, \"imageHeight\" : 500}]}"
samplerJson6 = "{ \"methodType\" : \"setPhotos\" , \"methodId\" : \"collageImageSelect\" , \"photos\" : []}"

function initialize(scene)
  UIView.scene = scene
  touchExtension = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  touchExtension:getTouchDownEvent():addEventHandler(onTouchDown)
  touchExtension:getTouchMoveEvent():addEventHandler(onTouchMove)
  touchExtension:getTouchUpEvent():addEventHandler(onTouchUp)

  local botBgNode = getBackgroundNode("images/A_bg.png", BlendMode.None)
  scene:addNodeAndRelease(botBgNode)
  addImageShaders(scene)
  addButtons(scene)
  local topBgNode = getBackgroundNode("images/A_720.png", BlendMode.None)
  scene:addNodeAndRelease(topBgNode)

  GalleryKit.init(5, 1280, addImageCallback, replaceImageCallback, removeImageCallback)
  -- GalleryKit.updateImageStates(samplerJson)
  -- GalleryKit.updateImageStates(samplerJson2)
  -- local args = GalleryKit.encodeImageStates(Answer.GET_MULTI)
  -- print("@@@@@@@@@@@@@ send to app args1 : "..args)
  -- GalleryKit.updateImageStates(samplerJson3)
  -- GalleryKit.updateImageStates(samplerJson4)
  -- -- local args2 = GalleryKit.encodeImageStates(Answer.GET_SINGLE, 5)
  -- local args2 = GalleryKit.encodeImageStates(Answer.GET_MULTI)
  -- print("@@@@@@@@@@@@@ send to app args2 : "..args2)
  -- GalleryKit.updateImageStates(samplerJson5)
  -- -- local args3 = GalleryKit.encodeImageStates(Answer.GET_SINGLE, 3)
  -- local args3 = GalleryKit.encodeImageStates(Answer.GET_MULTI)
  -- print("@@@@@@@@@@@@@ send to app args3 : "..args3)
  -- GalleryKit.updateImageStates(samplerJson6)
end

function addImageCallback(idx, tId, width, height)
  print("addImageCallback !!! "..tostring(idx))
  local texture = Texture.createWithHandle(tonumber(tId), tonumber(width), tonumber(height), TextureFormat.RGBA)
  ImageSamplers[tonumber(idx)]:updateSampler(texture, g_scene)
  texture:release()
end


function replaceImageCallback(idx, tId, width, height)
  print("replaceImageCallback !!! "..tostring(idx))
  local texture = Texture.createWithHandle(tonumber(tId), tonumber(width), tonumber(height), TextureFormat.RGBA)
  ImageSamplers[tonumber(idx)]:updateSampler(texture, g_scene)
  texture:release()
end


function removeImageCallback(idx)
  print("removeImageCallback !!! "..tostring(idx))
  local i = tonumber(idx)
  ImageSamplers[i]:updateSampler("images/A_0"..i..".png")
end

function addButtons(scene)
  btLayer = UIView:new(UIRect:new(0, 0, 720, 1280), nil, false)
  buttonViews[1] = UIButton:new(UIRect:new(140, 790, 130, 130), "num/one.png", "num/one.png", onGalleryBtClicked, 1)
  buttonViews[2] = UIButton:new(UIRect:new(405, 890, 130, 130), "num/two.png", "num/two.png", onGalleryBtClicked, 2)
  buttonViews[3] = UIButton:new(UIRect:new(468, 575, 130, 130), "num/three.png", "num/three.png", onGalleryBtClicked, 3)
  buttonViews[4] = UIButton:new(UIRect:new(120, 432, 130, 130), "num/four.png", "num/four.png", onGalleryBtClicked, 4)
  buttonViews[5] = UIButton:new(UIRect:new(345, 290, 130, 130), "num/five.png", "num/five.png", onGalleryBtClicked, 5)



  for i=1, #buttonViews do
    btLayer:addSubView(buttonViews[i])
  end
  btLayer:addToScene(0, 0)
end

function addImageShaders(scene)

  ImageSamplers[1] = ShaderSticker:new("images/A_01.png", nil, nil, {blendSrc=RenderStateBlend.BLEND_SRC_ALPHA, enabled = true , width = 180, scaleH16 = 1.3, scaleH34 = 1.13, tx = -0.87, ty = 1.20, rotateZ = 0, aspectRatio = 1})
  ImageSamplers[2] = ShaderSticker:new("images/A_02.png", nil, nil, {blendSrc=RenderStateBlend.BLEND_SRC_ALPHA, enabled = true , width = 180, scaleH16 = 1.3, scaleH34 = 1.13, tx = 0.6, ty = 1.75, rotateZ = 0, aspectRatio = 1})
  ImageSamplers[3] = ShaderSticker:new("images/A_03.png", nil, nil, {blendSrc=RenderStateBlend.BLEND_SRC_ALPHA, enabled = true , width = 180, scaleH16 = 1.3, scaleH34 = 1.13, tx = 0.95, ty = -0.01, rotateZ = 0, aspectRatio = 1})

  ImageSamplers[4] = ShaderSticker:new( "images/A_04.png", nil, nil, {blendSrc=RenderStateBlend.BLEND_SRC_ALPHA, enabled = true , width = 180, scaleH16 = 1.3, scaleH34 = 1.13, tx = -0.98, ty = -0.8, rotateZ = 0, aspectRatio = 1})
  ImageSamplers[5] = ShaderSticker:new("images/A_05.png", nil, nil, {blendSrc=RenderStateBlend.BLEND_SRC_ALPHA, enabled = true ,  width = 180, scaleH16 = 1.3, scaleH34 = 1.13, tx = 0.28, ty = -1.58, rotateZ = 0, aspectRatio = 1})

  scene:addNodeAndRelease(ImageSamplers[1].node)
  scene:addNodeAndRelease(ImageSamplers[2].node)
  scene:addNodeAndRelease(ImageSamplers[3].node)
  scene:addNodeAndRelease(ImageSamplers[4].node)
  scene:addNodeAndRelease(ImageSamplers[5].node)

  for i=1, #ImageSamplers do
    ImageSamplers[i]:updateSampler("images/A_0"..i..".png")
  end
end


function frameReady(scene, elapsedTime)
  if SceneRenderConfig.instance():isRenderModeSnapshot() then
    for i=1, #buttonViews do
      buttonViews[i]:setEnabled(false)
    end
  end
end

function reset(scene)
  print("reset frames")
  for i=1, #buttonViews do
    buttonViews[i]:setEnabled(true)
  end
end

function onGalleryBtClicked(button)
  print("gallery button clicked : "..tostring(button:getId()))
  local id = button:getId()
  local args
  if ALL_MULTI_CONTENTS == false and GalleryKit.getImageCount() > 0 then
    GalleryKit.requestToApp(Answer.GET_SINGLE, id)
  else
    GalleryKit.requestToApp(Answer.GET_MULTI)
  end

end

function onTouchDown(event)
  btLayer:onTouchDown(event)
end

function onTouchMove(event)
  btLayer:onTouchMove(event)
end

function onTouchUp(event)
  btLayer:onTouchUp(event)
end

function finalize(scene)
  touchExtension:getTouchDownEvent():removeEventHandler(onTouchDown)
  touchExtension:getTouchMoveEvent():removeEventHandler(onTouchMove)
  touchExtension:getTouchUpEvent():removeEventHandler(onTouchUp)
  GalleryKit.finalize()

  btLayer:release()
  for i=1, #buttonViews do
    if (buttonViews[i] ~= nil) then
      buttonViews[i]:release()
    end
  end
end

function getBackgroundNode(filePath, blendMode)
  local bgNode = KuruBackgroundImageNode.create(BASE_DIRECTORY .. filePath, blendMode)
  bgNode:setStretch(KuruBackgroundImageNodeStretch.FILL_HORIZONTAL)
  bgNode:setAnchorType(KuruBackgroundImageNodeAnchorType.CENTER)
  return bgNode
end
