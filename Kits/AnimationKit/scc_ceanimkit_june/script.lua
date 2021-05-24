require "KuruNodeKit/KuruNodeKit.lua"
require "AnimationKit/AnimationKit.lua"

function initialize(scene)
  local snap = KuruNodeKit.createSnapshotNode()
  scene:addNodeAndRelease(snap)

  scene:addNodeAndRelease(KuruNodeKit.createClearNode(Vector4.create(1, 0, 1, 0), true))

  local snapBg1 = KuruNodeKit.createBGNodeFromSampler(snap:getSampler(), {
    scale = 0.5
  })
  scene:addNodeAndRelease(snapBg1)

  local scaleItem = {
    {keyTime = 0, keyValue = 0.5},
    {keyTime = 1000, keyValue = 2.0, curveType = CurveInterpolationType.LINEAR},
    {keyTime = 2000, keyValue = 0.8, curveType = CurveInterpolationType.BOUNCE_OUT},
    {keyTime = 3000, keyValue = 0.5, curveType = CurveInterpolationType.QUARTIC_IN_OUT},
    {keyTime = 4000, keyValue = 0.7, curveType = CurveInterpolationType.CIRCULAR_IN}
  }

  --RoateItem의 인터페이스 개선 중
  local rotateItem = {
    {keyTime = 0, keyValue = 0},
    {keyTime = 500, keyValue = 180, curveType = CurveInterpolationType.BOUNCE_OUT},
    {keyTime = 1000, keyValue = 360, curveType = CurveInterpolationType.CIRCULAR_IN}
  }

  local translateItem = {
    {keyTime = 0, keyValue = Vector3.create(0.0, 0.0, 0.0)},
    {keyTime = 1000, keyValue = Vector3.create(0.5, 0.0, 0.0)},
    {keyTime = 2000, keyValue = Vector3.create(0.0, -0.5, 0.0)},
    {keyTime = 3000, keyValue = Vector3.create(-0.5, 0.0, 0.0)},
    {keyTime = 4000, keyValue = Vector3.create(0.0, 0.0, 0.0)}
  }

  local alphaItem = {
    {keyTime = 0, keyValue = 0.0},
    {keyTime = 1000, keyValue = 2.0},
    {keyTime = 2000, keyValue = 0.0},
    {keyTime = 3000, keyValue = 0.5},
    {keyTime = 4000, keyValue = 1.0}
  }

  local animObject = AnimateObject:create(snapBg1, true)
  :setAnimationItem(AnimationType.Scale, scaleItem)
  :setAnimationItem(AnimationType.Rotate, rotateItem)
  :setAnimationItem(AnimationType.Translate, translateItem)
  :setAnimationItem(AnimationType.Alpha, alphaItem) --alphaAnimation ver 10.1 above
  :build()

  --animObject:play()로 해도 되고 
  animObject:play()

  --아래처럼 animtionType별로 clip을 가져와서 개별 제어 가능
  -- local scaleClip = animObject:getClipByAnimationType(AnimationType.Scale):setSpeed(2.0)
  -- scaleClip:play()

  -- local rotateClip = animObject:getClipByAnimationType(AnimationType.Rotate):setSpeed(0.5)
  -- rotateClip:play()

  -- local translateClip = animObject:getClipByAnimationType(AnimationType.Translate):setSpeed(1.0)
  -- translateClip:play()

  -- local alphaClip = animObject:getClipByAnimationType(AnimationType.Alpha):setSpeed(1.0)
  -- alphaClip:play()
end