-- https://wiki.navercorp.com/display/LFS/AnimationKit
-- Update Date : 210401
-- Writer : June Kim
--[[
  Reference
  - https://wiki.navercorp.com/display/LFS/Property+Animation
  - https://wiki.navercorp.com/display/LFS/Kuru+Features#KuruFeatures-KuruScene.getSnapshotNodeOfScene,StickerConfig::getFirstScene(),MultilineValue
]]

AnimationType = {
  Scale = "Scale",
  Rotate = "Rotate",
  Translate = "Translate",
  Alpha = "Alpha"
}

AnimateObject = {}

function AnimateObject:create(paramNode)
  local newObject = {}

  setmetatable(newObject, self)
  self.__index = self

  newObject.AnimationItems = {}
  newObject.Clips = {}
  newObject.TargetNode = paramNode
  return newObject
end

function AnimateObject:setAnimationItem(animationType, item)
  self.AnimationItems[animationType] = item
  return self
end

function AnimateObject:build()
  local animTypes = {
    [AnimationType.Scale] = TransformAnimationType.ANIMATE_SCALE_UNIT,
    [AnimationType.Rotate] = TransformAnimationType.ANIMATE_ROTATE,
    [AnimationType.Translate] = TransformAnimationType.ANIMATE_TRANSLATE,
    [AnimationType.Alpha] = MaterialParameterAnimationType.ANIMATE_UNIFORM
  }

  for type, item in pairs(self.AnimationItems) do
    local keyTimes = {}
    local keyValues = {}
    for i, v in ipairs(item) do
      keyTimes[i] = v.keyTime
      keyValues[i] = v.keyValue
    end

    local curves = {}
    for i=2, #item do --curve는 item의 index 2부터 적용
      if item[i].curveType ~= nil then
        curves[i-1] = item[i].curveType
      else
        curves[i-1] = CurveInterpolationType.LINEAR
      end
    end

    keyTimes = IntArray.create():setFromLuaArray(keyTimes)
    keyValues = self:convertKeyValues(type, keyValues) --AnimationType별로 KeyValue 전처리가 필요함
    curves = IntArray.create():setFromLuaArray(curves)

    local animation = nil
    local animationTarget = nil
    if type == AnimationType.Alpha then
      self.TargetNode:getQuadMeshModel():getDefaultMaterial():getParameter("u_modulateAlpha"):setFloat(1.0)
      self.TargetNode:getQuadMeshModel():getDefaultMaterial():getParameter("u_modulateAlpha").isUpdatableByOnlyAnimation = true
      animationTarget = self.TargetNode:getQuadMeshModel():getDefaultMaterial():getParameter("u_modulateAlpha")
    else
      animationTarget = self.TargetNode
    end

    --MultiCurve를 사용할 수 도 있기때문에, Curve 유무에 따라 분기
    if curves:size() > 0 then
      animation = animationTarget:createAnimationWithCurves(
      type,
      animTypes[type],
      keyTimes:size(),
      keyTimes:getAsUnsigned(),
      keyValues:get(),
      curves:getAsUnsigned()
    )
    else
      animation = animationTarget:createAnimation(
      type,
      animTypes[type],
      keyTimes:size(),
      keyTimes:getAsUnsigned(),
      keyValues:get(),
      CurveInterpolationType.LINEAR
    )
    end
    self.Clips[type] = animation:getDefaultClip()
  end

  return self
end

function AnimateObject:convertKeyValues(type, keyValues)
  local resultsKeyValues = nil
  if type == AnimationType.Rotate then
    local axis = Vector3.create(0, 0, 1)
    local quaternions = {}
    resultsKeyValues = {}
    for i=1, #self.AnimationItems[AnimationType.Rotate] do
      quaternions[i] = Quaternion.createFromAxisAngle(axis, math.rad(keyValues[i]))
      table.insert(resultsKeyValues, quaternions[i].x)
      table.insert(resultsKeyValues, quaternions[i].y)
      table.insert(resultsKeyValues, quaternions[i].z)
      table.insert(resultsKeyValues, quaternions[i].w)
    end
  elseif type == AnimationType.Translate then
    resultsKeyValues = {}
    for i=1, #self.AnimationItems[type] do
      table.insert(resultsKeyValues, keyValues[i].x)
      table.insert(resultsKeyValues, keyValues[i].y)
      table.insert(resultsKeyValues, keyValues[i].z)
    end
  else --if type == AnimationType.Scale or type == AnimationType.Alpha then
    resultsKeyValues = keyValues
  end
  
  return FloatArray.create():setFromLuaArray(resultsKeyValues)
end

function AnimateObject:getClipByAnimationType(type)
  return self.Clips[type]
end

function AnimateObject:setRepeatCount(repeatCount)
  for _, clip in pairs(self.Clips) do
    clip:setRepeatCount(repeatCount)
  end
end

function AnimateObject:setSpeed(speed)
  for _, clip in pairs(self.Clips) do
    clip:setSpeed(speed)
  end
end

function AnimateObject:pause()
  for _, clip in pairs(self.Clips) do
    clip:pause()
  end
end

function AnimateObject:stop()
  for _, clip in pairs(self.Clips) do
    clip:stop()
  end
end

function AnimateObject:play()
  for _, clip in pairs(self.Clips) do
    clip:play()
  end
end


function AnimateObject:isPlaying()
  for _, clip in pairs(self.Clips) do
    if clip:isPlaying() then
      return true
    end
  end
  
  return false
end