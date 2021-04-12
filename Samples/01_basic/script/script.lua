--스크립트가 처음 실행 될 때 호출
function initialize(scene)
  print("initialize!")

  --엔진과 상호작용하는 각종 기능은 Extension으로 받아온다(터치, 얼굴인식 등)
  g_kuruTouchExtension = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  
  --터치 이벤트 callback을 등록해준다. finalize에서 반드시 해제해주지 않으면 크래시가 발생한다.
  g_kuruTouchExtension:getTouchDownEvent():addEventHandler(onTouchDown)
  
  --배경타입의 노드. 스크립트에서 사용할 리소스들은 script.lua와 동일한 계층디렉토리에 있어야 한다.
  --touch이벤트에서 제어할 것이므로 전역변수로 선언했다.
  g_bgNode = KuruBackgroundImageNode.create(BASE_DIRECTORY .. "bg/frame_916.png", BlendMode.None)
  --[[모든 노드는 scene에 add되고, release되어야 사용할 수 있다. 
  각 함수를 따로 호출 할 수도 있지만, 특별한 이유가 없는 한 하나의 함수로 아래와 같이 사용한다.]]
  scene:addNodeAndRelease(g_bgNode)

  --[[
    * 노드(node), 씬(scene), 씬그래프(scene graph)의 관계?
    1. 노드(node)란? 게임(이펙트)를 사용하는 유저와 함께 상호작용하며 씬을 구성하는 객체입니다.
    2. 씬(scene)이란? 노드들이 배치된 공간으로, 씬의 내용물은 디스플레이로 보여지고 가상의 카메라를 이용하여 보여지는 영역이 조절됩니다. 
    3. 씬그래프(scene graph)란 씬을 렌더하기 위해 필요한 정보를 정리하는 특수한 데이터 구조입니다.
    -> 알맞게 최적화된 노드들로 정리된 씬은 효율적이고 안정적으로 시스템의 계산 부담을 최소화합니다.
  ]]

  --Stretch방식. NONE으로 하면 촬영시에 이미지가 줄어드니 특별한 경우가 아닌이상 NONE은 사용하지 않음
  g_bgNode:setStretch(KuruBackgroundImageNodeStretch.CENTER_CROP)

  --Anchor 타입. BOTTOM, CENTER, TOP에 따라 translation 좌표도 변경된다.
  g_bgNode:setAnchorType(KuruBackgroundImageNodeAnchorType.CENTER)

  --디바이스 회전에 대한 정의. VARIANT, INVARIANT, SHOW_ON_PORTRAIT_ONLY, SHOW_ON_LANDSCAPE_ONLY 가 있다.
  g_bgNode:setRotationMode(StickerItemRotationMode.INVARIANT)

  --각도. 인자로 radian값을 받기 때문에 degree->radian 변환을 해줘야 한다.
  g_bgNode:rotateZ(math.rad(0))

  --크기
  g_bgNode:setScale(1, 1, 0)

  --[[좌표계(anchor CENTER 기준, x:-0.5~0.5, y는 화면비율에 따라 달라지므로주의한다.
  예를들어 9:16 에서는 x:-0.5~0.5이고 y는 -0.88~0.88 이다.
  ]]
  g_bgNode:setTranslation(0, 0, 0)

  --[[
    node의 일부 속성은 getStickerItem()에서 접근해야한다.
    대표적으로 aspectRatio와 alpha가 자주쓰인다.
    aspectRatio는 해당 비율상태에서만 이 노드가 보이도록 설정하는 것.
  ]]
  g_bgNode:getStickerItem().aspectRatio = Vector2AspectRatioType.NINE_TO_SIXTEEN
  g_bgNode:getStickerItem().alpha = 1.0

  --[[기본적으로 이미지(단일,시퀀스)가 사용되는 노드들은 sampler를 받게돼있다.
  만약 위의 KuruBackgroundImageNode.create(BASE_DIRECTORY .. "bg/frame_916.png" .. 처럼 따로 샘플러를 생성하지 않고
  filePath를 인자로 받는경우에는 엔진에서 자동으로 샘플러를 생성한다.
  주로 애니메이션 시퀀스를 동적으로 제어하거나 커스텀한 설정을 하고 싶을경우 아래와같이 샘플러를 따로 생성하여 사용한다.
  주의사항은 sampler를 생성하면 reference count가 증가하니 반드시 샘플러 사용 후, sampler:release()를 명시적으로 해줘야 메모리 누수가 발생하지 않는다.
  ]]
  
  local stickerSampler = KuruAnimationSampler.createFromPath(BASE_DIRECTORY .. "face", false, false)
  stickerSampler:setRepeatCount(0)
  stickerSampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)
  stickerSampler:setFPS(20)
  stickerSampler:play()

  --인자로 sampler, blendmode, width, height를 받는다. width,height가 0이면 알아서 디폴트 크기로 설정된다.(대부분 0으로 설정하고, setScale로 스케일 조절)
  local faceStickerNode = KaleStickerNode.createFromSampler(stickerSampler, BlendMode.None, 0, 0)
  scene:addNodeAndRelease(faceStickerNode)

  --sampler:release()를 하지 않으면 memory leak이 발생한다.
  stickerSampler:release()

  --아래 60번째 코드와 48~57 코드는 똑같이 동작한다.
  -- local faceStickerNode = KaleStickerNode.create(BASE_DIRECTORY .. "face", BlendMode.None, 0, 0)

  faceStickerNode:setScale(1.5, 1.5, 0)
  faceStickerNode:setTranslation(0.0, -1.3, 0.0)
  faceStickerNode:rotateZ(math.rad(0))
  faceStickerNode:setLocationType(StickerItemLocationType.EYES_CENTER)
  faceStickerNode:setAnchorType(StickerItemAnchorType.CENTER)
  
  --z를 조절하고 싶을 경우 faceOffset으로 조절한다.
  faceStickerNode:getStickerItem():getConfig().faceOffset = Vector3.create(0.0, 0.0, -0.5)
  
  --빌보딩 설정
  faceStickerNode:getStickerItem():getConfig().billboard = false
  faceStickerNode:getStickerItem().alpha = 1.0
end

--화면을 출력하기 전 호출
function frameReady(scene, elapsedTime)
  print("frameReady!")
end

--컨펌화면에서 다시 되돌아올 때 호출
function reset(scene)
  print("reset!")
end

--스크립트가 종료 될 때 호출
function finalize(scene)
  print("finalize!")  
  g_kuruTouchExtension:getTouchDownEvent():removeEventHandler(onTouchDown)
end

function onTouchDown(event)
  --g_bgNode를 껐다켰다 한다.
  g_bgNode:setEnabled(not g_bgNode:isEnabled())
end