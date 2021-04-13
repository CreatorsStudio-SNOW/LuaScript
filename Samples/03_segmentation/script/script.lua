function initialize(scene)
  --원본 저장
  local originSnap = KuruSnapshotNode.create()
  scene:addNodeAndRelease(originSnap)

  --frameReady에서 접근할 것이므로 global로 선언, 세그의 배경영역을 그리는 쉐이더
  g_colorShader = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "color.frag", true)
  g_colorShader:getMaterial():getParameter("u_speed"):setFloat(1.0)
  scene:addNodeAndRelease(g_colorShader)

  --쉐이더가 화면에 덮인 상태 저장
  local colorSnap = KuruSnapshotNode.create() 
  scene:addNodeAndRelease(colorSnap)
  
  --세그멘테이션노드 생성, setSourceSampler로 세그멘테이션 대상이미지를 가져옴
  local segNode = KuruSegmentationNode.create()
  segNode:setSourceSampler(originSnap:getSampler())

  --세그멘테이션의 다양한옵션을 item속성으로 설정 가능
  --여기선 세그멘테이션을 단순히 컬러그라데이션배경과 원본의 마스킹역할로 사용
  local item = segNode:getSegmetationItem()
  local edgeColor = Vector4.create(1, 1, 1, 1) 
  item.enableEdge = true
  item.textureType = SegmentationItemTextureType.BACKGROUND
  item.edgeColor = edgeColor
  item.edgeRatio = 20.0

  --버퍼노드를 생성. 버퍼노드는 빈 스케치북과 같다고 생각하면 된다.
  local segBuffer = KuruFrameBufferNode.create()
  scene:addNodeAndRelease(segBuffer)

  --이 버퍼노드는 세그멘테이션"만" 갖고있는 버퍼노드이다.
  segBuffer:addChildAndRelease(segNode)

  --최종적으로 화면에 그려질 쉐이더
  local mixShader = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "mix.frag", true)

  --마스킹으로 사용할 색
  mixShader:getMaterial():getParameter("u_edgeColor"):setVector4(edgeColor)

  --배경(colorSnap), 마스킹(segBuffer), 원본이미지(originSnap)를 쉐이더에 넘겨준다.
  mixShader:setChannel0(colorSnap:getSampler())
  mixShader:setChannel1(segBuffer:getSampler())
  mixShader:setChannel2(originSnap:getSampler())

  scene:addNodeAndRelease(mixShader)
end

function frameReady(scene, elapsedTime)
  --쉐이더에서 색깔이 돌아가는 스피드를 uniform변수로 선언해놓고, frameReady에서 실시간으로 변경해볼 수 있다.
  --이때 실시간으로 넣어주는 값으로 자주사용되는것은 PropertyConfig Number이다.
  local s = PropertyConfig.instance():getNumber("num1", 0.5) * 5.0
  g_colorShader:getMaterial():getParameter("u_speed"):setFloat(s)
end