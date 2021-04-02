require "KuruNodeKit/KuruNodeKit.lua"
require "KiraKit/itemList.lua"
require "KiraKit/KiraKit.lua"
require "CEModelKit/CEModelKit.lua"

GradientType = {
  Horizontal = 0.0,
  Vertical = 1.0,
  Circular = 2.0
}

g_gradientType = GradientType.Horizontal
g_edgeL = 0.5
g_edgeM = 0.6
g_colorEdgeL = 0.4
g_colorEdgeM = 0.6
g_lightness = 0.5
g_contrast = 1.0
g_isInitVolume = false

function initialize(scene)
  local distNode = KuruNodeKit.createBuiltInDistortionNode()
  scene:addNodeAndRelease(distNode)
  g_previewSnap = KuruNodeKit.createSnapshotNode()
  scene:addNodeAndRelease(g_previewSnap)
  g_kiraKit = KiraKit.new(scene)

end

function initVolumatricModel(scene)
  g_flipBuffer = KuruFrameBufferNode.create()
  scene:addNodeAndRelease(g_flipBuffer)
  flipShader = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "flip.frag", true)
  flipShader:setChannel0(g_previewSnap:getSampler())
  flipShader:setChannel1(g_kiraKit:getSampler())
  flipShader:getMaterial():getParameter("dir"):setFloat(g_gradientType)
  flipShader:getMaterial():getParameter("colorEdgeL"):setFloat(g_colorEdgeL)
  flipShader:getMaterial():getParameter("colorEdgeM"):setFloat(g_colorEdgeM)
  flipShader:getMaterial():getParameter("lightness"):setFloat(g_lightness)
  flipShader:getMaterial():getParameter("contrast"):setFloat(g_contrast)
  g_flipBuffer:addChildAndRelease(flipShader)

  previewNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "camera.frag", true)
  previewNode:setChannel0(g_previewSnap:getSampler())
  scene:addNodeAndRelease(previewNode)


  cubeModel = CEModel.createModel("volumatric2.gpb", {translateZ = -70.25, scaleZ = 0.475})
  scene:addNodeAndRelease(cubeModel:getNode())
  cubeModel:getMaterial("previewMat"):getParameter("u_diffuseTexture"):setSampler(g_flipBuffer:getSampler())


  g_segNode = KuruNodeKit.createSegmentationNode(g_previewSnap:getSampler(), distNode, {})
  scene:addNodeAndRelease(g_segNode)
end



function frameReady(scene, elapsedTime)
  g_kiraKit:frameReady()

  if scene:getResolution().x <= 0 then
      return
  end

  if not g_isInitVolume then
    g_isInitVolume = true
    initVolumatricModel(scene)
  end

  if CameraConfig.instance().isFaceFront then
    if not g_segNode:isEnabled() then
      g_segNode:setEnabled(true)
    end
    g_strength = 1.0
  else
    if g_segNode:isEnabled() then
      g_segNode:setEnabled(false)
    end
    g_strength = 0.7
  end

  local s = PropertyConfig.instance():getNumber("num1", -0.05) * 0.5 + 0.5
  local a = PropertyConfig.instance():getNumber("num2", -0.3) * 0.5 + 0.5
  local c = PropertyConfig.instance():getNumber("num3", -0.415) * 0.5 + 0.5
  local cl = PropertyConfig.instance():getNumber("num4", -0.32) * 0.5 + 0.5
  local cm = PropertyConfig.instance():getNumber("num5", 0.32) * 0.5 + 0.5
  local light = PropertyConfig.instance():getNumber("num6", 0.0) * 0.5 + 0.5
  c = c + 1.0
  a = a * 0.1


  cubeModel:getNode():setScale(1, 1, s)
  flipShader:getMaterial():getParameter("contrast"):setFloat(c)
  flipShader:getMaterial():getParameter("colorEdgeL"):setFloat(cl)
  flipShader:getMaterial():getParameter("colorEdgeM"):setFloat(cm)
  flipShader:getMaterial():getParameter("lightness"):setFloat(light)
  cubeModel:getMaterial("previewMat"):getParameter("u_modulateAlpha"):setFloat(a)
end


function finalize(scene)
  g_kiraKit:finalize()
end
