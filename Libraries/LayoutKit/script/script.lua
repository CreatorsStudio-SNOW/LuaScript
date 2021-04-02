
require "LayoutKit/LayoutKit.lua"

function initialize(scene)
  LayoutKit.init(scene)
  -- 상, 하, 좌, 우 margin값을 넣고 DateBox 생성
  g_layoutBox = LayoutBox:new(0.0, 0.0, 0.0, 0.0)

  -- addComponentToFree, addComponentToRight, addComponentToBottom 메서드로 DateView를 생성해서 DateBox에 더한다.
  ---- addComponentToFree : DateBox의 BG 이미지를 더한다고 보면된다.
  ---- addComponentToRight : DateBox의 더해진 마지막 뷰(addComponentToFree로 더한 뷰 제외)의 오른쪽에 더해짐.
  ---- addComponentToBottom : DateBox의 더해진 뷰들중(addComponentToFree로 더한 뷰 제외) 맨 왼쪽 맨 아래 뷰의 밑에 더해짐.
  ---- 위 메서드 모두 파라미터가 같다.
  ------ 1번째 파라미터(prefix)
  -------- 기존 이미지 이름 찾는 문법에 prefix를 붙이기 위함이다.
  -------- 예를 들어 "ampm" format에 prefix로 "pre"를 넘기면, "preAM.png" or "preBM.png" 이미지를 찾는다.(2번째 파라미터 설명 참고)
  -------- "yyyy" format에 prefix로 "pre"를 넘기면 숫자 이미지를 가져올때, prenum_0.png ~ prenum_9.png를 찾는다.

  ------ 2번째파라미터(format)
  -------- 원하는 이미지 타입을 format으로 지정한다.
  -------- 날짜 format
  ---------- yyyy, yy, mm, dd, hh, minmin, ss, msms(년도 전체, 년도 뒤 두글자, 월, 일, 시간, 분, 초, 밀리초)
  ---------- num_0.png ~ num_9.png 이름으로 대응된 이미지들을 가져와서 날짜를 만듦
  -------- 기타 format
  ---------- ampm : AM.png, PM.png
  ---------- month : month_1.png ~ month_12.png
  ---------- weekday : weekday_0.png ~ weekday_6.png(일요일 ~ 토요일)
  ---------- . : dot.png
  ---------- / : slash.png
  -------- Custom format
  ---------- 위에 정의된 format 이외에 다른 문자열을 입력할 경우. 문자열.png 이미지를 참조한다.(밑 "bg" 같은경우 bg.png를 찾는다.)

  ------ 3번째파라미터(betweenMargin)
  -------- 숫자 사이 간격이다.
  -------- 예를들어, "yyyy" format이면 4개 숫자 사이의 margin을 지정하는 것이다.

  ------ 4번째, 5번째파라미터(leftMargin, topMargin)
  -------- addComponentToFree같은 경우는 DateBox와의 left, top margin을 지정한다.
  -------- addComponentToRight같은 경우는 DateBox의 더해진 마지막 뷰(addComponentToFree로 더한 뷰 제외)의 오른쪽에 더해짐.
  ---------- leftMargin은 오른쪽뷰와의 margin, topMargin은 위의 줄 첫번째 이미지와의 topMargin 이다.(첫번째 줄이면 DateBox와의 topMargin)
  -------- addComponentToBottom 경우는 leftMargin은 DateBox와의 왼쪽 margin 이고, topMargin addComponentToRight 경우와 같다.

  ------ 6번째파라미터(blendMode)
  -------- 블렌드 모드이다.

  ------ 7번째파라미터(isHorizonOrientation)
  -------- 이미지들의 가로 정렬이다.
  -------- 예를들어, "yyyy" format을 isHorizonOrientation = false로 그릴경우,
  -------- 2
  -------- 0
  -------- 2
  -------- 0
  -------- 이런식으로 그려진다.

  ---- 렌더링 되는 크기는 가로 전체 720 기준대비 이미지 크기로 그려진다.
  ------ 예를들어, 가로 720, 세로 640 크기의 이미지를 9:16 비율에서 그리면 가로는 꽉차고 세로는 반이 찬다.

  ---- 밑 코드에 의해 더해진 모습을 그려보면 DateBox 배경에 bg.png가 깔리고,
  ---- "yyyy" "mm" "dd" "hh" "minmin"
  ---- "ss" "msms" "month" "." "ampm" "/"
  ---- 대충 이런 모양으로 그려진다.

  local prefix = "images/"
  g_layoutBox:addComponentToFree(prefix, "bg", 0.0, 0.0, 0.0, BlendMode.None, true)
  g_layoutBox:addComponentToRight(prefix, "AM", 0.0, 0.0, 0.0, BlendMode.None, true)
  g_layoutBox:addComponentToRight(nil, "dot", 0.0, 0.0, 0.0, BlendMode.None, true)
  g_layoutBox:addComponentToRight(nil, "month_1", 0.0, 0.0, 0.0, BlendMode.None, true)
  g_layoutBox:addToSceneWithBackground(KuruBackgroundImageNodeAnchorType.CENTER, StickerItemRotationMode.VARIANT, BlendMode.None)
end

function frameReady(scene, elapsedTime)
  g_layoutBox:frameReady()

  -- align 메서드를 쓰거나, 뭔가 layout이 변경되었을 때 이 메서드를 호출해야 한다.
  -- g_layoutBox:setNeedsLayout()
end

function finalize(scene)
  LayoutKit.finalize()
end
