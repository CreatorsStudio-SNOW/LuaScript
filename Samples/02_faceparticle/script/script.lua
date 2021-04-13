function initialize(scene)
  --다른 callback에서 접근하기 위해 global로 선언
  g_particleNodes = {}

  --red 파티클, 얼굴을 Tracking하는 파티클은 KaleFaceParticleNode
  g_particleNodes[1] = KaleFaceParticleNode.create(BASE_DIRECTORY .. "red.particle")

  --LocationType 속성은 일반적인 FaceSticker와 유사함
  g_particleNodes[1]:setLocationType(StickerItemLocationType.FACE)
  g_particleNodes[1]:getStickerItem().translateY = -0.8

  --파티클은 명시적으로 start()를 호출해줘야 시작
  g_particleNodes[1]:start()
  scene:addNodeAndRelease(g_particleNodes[1])

  --blue
  g_particleNodes[2] = KaleFaceParticleNode.create(BASE_DIRECTORY .. "blue.particle")
  g_particleNodes[2]:setLocationType(StickerItemLocationType.FACE)
  g_particleNodes[2]:getStickerItem().scale = 1.5
  g_particleNodes[2]:getStickerItem().translateY = -0.8
  g_particleNodes[2]:start()
  scene:addNodeAndRelease(g_particleNodes[2])
end

--여러명이 촬영할 경우에, 사람별로 face,body등을 제어할 수 있는 Callback(인원수만큼 호출된다.)
--ex)룰렛게임이나 WhichWhat같이 게임에서 사람별로 돌아가는 시퀀스가 랜덤하게 보이려면 이 Callback에서 제어해줘야한다.
function onPreRender(param)
  if param:getType() ~= RenderArgsType.FACE then
    return
  end

  local faceParam = FacePreRenderArgs.cast(param)

  --1번얼굴(첫번째 잡힌 사람)은 1번파티클(red)만, 2번얼굴은 2번파티클(blue)만 나오도록 설정
  --주의할 점은 setEnbaled로 꺼버릴 경우, 아예 렌더링 되지 않음. 해당 얼굴에서만 제어하려면 반드시 faceParam:setResult()로 제어해야한다.
  for i, node in pairs(g_particleNodes) do
    if node:equals(faceParam:getNode()) then
      --lua 테이블은 1부터시작하고 faceID는 0부터 시작하기때문에 i-1을 해준다.
      faceParam:setResult(faceParam:getFaceData():getId() == (i-1))

      --위 코드를 주석처리하고 아래 코드를 주석해제 하면 반대로된다(1번얼굴에 파란파티클, 2번얼굴에 빨간파티클)
      --faceParam:setResult(faceParam:getFaceData():getId() ~= (i-1))
    end
  end
end