require "CEModelKit/CEModelKit.lua"

g_count = 0
function initialize(scene)
  g_touchExtension = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  g_touchExtension:getTouchDownEvent():addEventHandler(onTouchDown)


  g_hoodieModel = CEFaceModel.createFaceModel("hoodie/hoodie.gpb", {useFaceRecalculateExcludeChin = true, faceRotationMultiplyFactor = Vector3.create(0, 0.05, 0.0), faceOffset = Vector3.create(0, -0.38, 0.03)})
  scene:addNodeAndRelease(g_hoodieModel:getNode())

  g_joints = g_hoodieModel:getJointMap("cap")


  joint1_yaw = PropertyConfig.instance():getNumber("num1", 0.07) * 0.5 + 0.5
  joint1_roll = PropertyConfig.instance():getNumber("num2", 0.7) * 0.5 + 0.5
  joint1_pitch = PropertyConfig.instance():getNumber("num3", 0.84) * 0.5 + 0.5
  g_offsetY = PropertyConfig.instance():getNumber("num4", -0.38)
  g_offsetZ = PropertyConfig.instance():getNumber("num5", 0) * 2

end


function onPreRender(param)
  local faceParam = FacePreRenderArgs.cast(param)
  local faceData = faceParam:getFaceData()

  local yaw = faceData.relativeYaw  -- x
  local roll = faceData.relativeRoll * -1 -- y
  local pitch = faceData.relativePitch * -1 -- z

  local deviceRadian = CameraConfig.instance():getDeviceRoll()
  local deviceDegree = math.deg(deviceRadian)
  if deviceDegree > 180 then
    deviceDegree = deviceDegree - 360
  end
  local faceRoll = (roll * -1) - deviceDegree
  local jointRoll = faceRoll * -1
  local faceRoll = clamp(-40, 40, faceRoll)
  local faceYaw = clamp(-40, 40, yaw)
  local facePitch = clamp(-40, 40, (pitch * -1))

  local transx = faceYaw/50
  local transy = facePitch/30
  local deltax = (faceRoll)/30
  local deltay = math.abs(faceRoll)/50
  local transz = facePitch/40
  if transz < 0 then
    transz = 0
  end

  g_joints["Bone004"]:setRotationByDegree(Vector3.create(yaw * joint1_yaw, jointRoll * joint1_roll, pitch * joint1_pitch))
end

function onTouchDown(event)
  g_count = g_count + 1
  if g_count > 1 then
    g_count = 0
  end

  if g_count == 1 then
    g_hoodieModel:getMaterial("hoodie_top"):getParameter("u_modulateAlpha"):setFloat(0.3)
    g_hoodieModel:getMaterial("hoodie_bottom"):getParameter("u_modulateAlpha"):setFloat(0.3)
    g_hoodieModel:getMaterial("cap"):getParameter("u_modulateAlpha"):setFloat(0.3)
  else
    g_hoodieModel:getMaterial("hoodie_top"):getParameter("u_modulateAlpha"):setFloat(1.0)
    g_hoodieModel:getMaterial("hoodie_bottom"):getParameter("u_modulateAlpha"):setFloat(1.0)
    g_hoodieModel:getMaterial("cap"):getParameter("u_modulateAlpha"):setFloat(1.0)
  end
end

function clamp(min, max, val)
  return math.min(max, math.max(min, val))
end


function finalize(scene)
  g_touchExtension:getTouchDownEvent():removeEventHandler(onTouchDown)
end
