require "CEAnimationSampler.lua"

g_ceSampler = nil
g_didSetFrameIndex = false

function initialize(scene)
  -- 샘플러를 시나리오(트리거)에 따라서 지유롭게 play, stop, pause, resume 하고 싶을때 사용.
  ---- 4번째 파라미터 repeatCount <= 0 이면 무한반복
  ---- g_ceSampler = CEAnimationSampler.create(scene, "b_ball_t", 20, 0)
  ---- scene:addNodeAndRelease(getStickerNode(g_ceSampler:getSampler(), 0.32, StickerItemLocationType.FACE, KaleStickerNodeAnchorType.CENTER, -0.18, -0.34, 0.0))
  ---- g_ceSampler:release()
  ---- g_ceSampler:play()

  -- 샘플러의 시나리오를 생성할 때 미리 정해놓고 사용하기 위함.
  ---- 4번째 파라미터 : startOffSet
  ------ 샘플러 재생을 시작할 시작 frameIndex
  ---- 5번째 파라미터 : endOffSet
  ------ 샘플러 재생이 끝나는 마지막 frameIndex
  ---- 6번째 파라미터 : repeatStartOffSet
  ------ 반복구간을 지정할 때, 반복구간 시작 frameIndex
  ---- 7번째 파라미터 : repeatEndOffSet
  ------ 반복구간을 지정할 때, 반복구간 끝 frameIndex
  ---- 8번째 파라미터 : repeatCount
  ------ repeatStartOffSet, repeatEndOffSet으로 지정된 구간을 몇번 반복할지 지정
  ---- 9번째 파라미터 : startDelayFrame
  ------ 샘플러를 재생하기전 앞에 delayFrameCount
  ---- 10번째 파라미터 : endDelayFrame
  ------ 샘플러를 재생이 모두 끝난 이후 뒤에 delayFrameCount

  -- ex) 60장 짜리 sampler를 밑에 설정으로 재생하면
  -- 0 ~ 9 frame : 투명처리
  -- 10 ~ 25 : sampler 0번 ~ 15번 1회 재생
  -- 26 ~ 55 : sampler 16번 ~ 30번 2회 재생
  -- 56 ~ 84 : sampler 31번 ~ 59번(끝까지) 1회 재생
  -- 85 ~ 104 : sampler 투명처리
  g_ceSampler = CEAnimationSampler.createFromFrames(scene, "b_ball_t", 5, 0, 59, 16, 30, 2, 10, 20)
  scene:addNodeAndRelease(getStickerNode(g_ceSampler:getSampler(), 0.32, StickerItemLocationType.FACE, KaleStickerNodeAnchorType.CENTER, -0.18, -0.34, 0.0))
  g_ceSampler:release()
end

function frameReady(scene, elapsedTime)
  g_ceSampler:frameReady()

  -- 아래 주석문은 CEAnimationSampler.create(scene, "b_ball_t", 20, 0)로 생성했을 때 사용가능.
  -- local totalElapsedTime = scene:getTotalElapsedTime()

  -- if (totalElapsedTime > 7000.0) then
  --   g_ceSampler:stop()
  -- elseif (totalElapsedTime > 5000.0) then
  --   if (not g_didSetFrameIndex) then
  --     g_ceSampler:setFrameIndex(5)
  --     g_didSetFrameIndex = true
  --   end
  --
  --   g_ceSampler:resume()
  -- elseif (totalElapsedTime > 2000.0) then
  --   g_ceSampler:pause()
  -- end
end

function reset(scene)
  g_didSetFrameIndex = false
  g_ceSampler:reset()
end

function getStickerNode(sampler, scale, loactionType, anchorType, translateX, translateY, translateZ)
  local node = KaleStickerNode.createFromSampler(sampler, BlendMode.None, 0, 0)

  node:setId("sticker")
  node:setLocationType(loactionType)
  node:setAnchorType(anchorType)
  node:setScale(scale, scale, 0)
  node:setTranslation(translateX, translateY, translateZ)

  return node
end

function getBGNode(sampler, blendMode)
  local bgNode = KuruBackgroundImageNode.createFromSampler(sampler, blendMode)

  bgNode:setStretch(KuruBackgroundImageNodeStretch.FILL_HORIZONTAL)
  bgNode:setAnchorType(KuruBackgroundImageNodeAnchorType.CENTER)

  return bgNode
end

function addNodeAndRelease(scene, node)
  scene:addNodeAndRelease(node)

  return node
end
