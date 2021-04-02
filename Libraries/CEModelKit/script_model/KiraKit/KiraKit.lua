-- Update Date : 191007
-- Writer : Sunggon Hong


KiraKit = {
  HIGHLIGHT_WIDTH = 240.0,
  scene = nil,
  inited = false,
  weight = 0.0,
  kiraNode = nil,
  highlightMaskFilter = nil,
  highlightMaskSmallFilter = nil,
  splitFrameBuffer = nil,
  splitFrameBufferSampler = nil,
  splitFrameDrawModel = nil,
  staticKiraNode = nil
}

function KiraKit.new(scene)
  Logger.setLogLevel(LogLevel.Debug)
  local newKiraKit = {}

  setmetatable(newKiraKit, KiraKit)
  KiraKit.__index = KiraKit
  newKiraKit.scene = scene

  return newKiraKit
end

function KiraKit:initThisScript()
  --useCustomHighlight
  -- 스티커 의 기준 가져옴.

  if self.inited then
        return
  end

  if self.scene:getResolution().x <= 0 then
      return
  end

  self.inited = true

  local width = math.floor(self.HIGHLIGHT_WIDTH)
  local height = math.floor(self.HIGHLIGHT_WIDTH * self.scene:getResolution().y / self.scene:getResolution().x)
  local cameraSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
  local faceMaskSnapshot = nil

  if (IS_FACE_MASKING) then
    self.scene:addNodeAndRelease(KuruClearNode.create(Vector4.create(1, 1, 1, 0.0)))
    self.scene:addNodeAndRelease(KaleFaceSkinNode.create( KaleFaceSkinNodeBuilder.create():path(BASE_DIRECTORY .. FACE_MASK_PATH):skinType(KaleFaceSkinType.FACE_EX):build()))
    faceMaskSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    faceMaskSnapshot:setFrameBufferScale(0.3, 0.3)
  end

  self.splitFrameBuffer = FrameBuffer.create("STORED_FB_1", width, height, TextureFormat.RGBA)
  self.splitFrameBufferSampler = TextureSampler.createWithTexture(self.splitFrameBuffer:getRenderTarget(0):getTexture())
  self.splitFrameBufferSampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  local splitFrameMesh = Mesh.createQuadFullscreen()

  self.splitFrameDrawModel = Model.create(splitFrameMesh)
  splitFrameMesh:release()

--downsample
  local downsampleBufferNode = self:addNodeAndRelease(self.scene, KuruFrameBufferNode.createWithSize(width, height))
  local downsampleFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/passthrough.frag", false)

  downsampleFilter:getMaterial():getParameter("u_texture"):setSampler(cameraSnapshot:getSnapshot())
  self:addChildNodeAndRelease(downsampleBufferNode, downsampleFilter)

--blur..
  local blurBufferNode = KuruFrameBufferNode.createWithSize(width, height)

  self:addNodeAndRelease(self.scene, blurBufferNode)

  local downsampleFilter2 = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/passthrough.frag", false)

  downsampleFilter2:getMaterial():getParameter("u_texture"):setSampler(cameraSnapshot:getSnapshot())
  self:addChildNodeAndRelease(blurBufferNode, downsampleFilter2)

  local blurFilter = KuruBlurNode.create(KuruBlurDrawableKernelSize.MEDIUM_KERNEL)

  self:addChildNodeAndRelease(blurBufferNode, blurFilter)

  local lightBufferNode = KuruFrameBufferNode.createWithSize(width, height)

  self:addNodeAndRelease(self.scene, lightBufferNode)

  if (g_kiraType == KiraType.SINGLE) then
    self.highlightMaskFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/highlight.frag", false)
    self.highlightMaskFilter:getMaterial():getParameter("u_texture"):setSampler(downsampleBufferNode:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBufferNode:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.highlightMaskFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskFilter:getMaterial():getParameter("u_threshold"):setFloat(0.2)
    self.highlightMaskFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.highlightMaskFilter:getMaterial():getParameter("u_maskAlpha"):setInt(-1)
    self:addChildNodeAndRelease(lightBufferNode, self.highlightMaskFilter)

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(false):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()

    self.staticKiraNode = KuruKirakiraNode.create(builder)

    for i = 1, #SINGLE_ITEMS do
        local item = SINGLE_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = item.scale
          item.maxScale = item.scale
        end

        self.staticKiraNode:addSamplerFromPath(BASE_DIRECTORY .. item.fileName, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.staticKiraNode)

    local item = StickerItem.create()

    self.staticKiraNode:setStickerItem(item)
    self.staticKiraNode:setHighlightSampler(lightBufferNode:getSampler())

    local disappearNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "KiraKit/disappear.frag", true))
    disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "KiraKit/singleMerge.frag", true))
    self.resultSnap = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    -- mergeNode:setChannel1(cameraSnapshot:getSampler())
  elseif (g_kiraType == KiraType.ANIMATION) then
    self.highlightMaskSmallFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/highlight.frag", false)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_texture"):setSampler(downsampleBufferNode:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBufferNode:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_threshold"):setFloat(0.1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskSmallFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.highlightMaskSmallFilter:getMaterial():getParameter("u_maskAlpha"):setInt(-1)
    self:addChildNodeAndRelease(lightBufferNode, self.highlightMaskSmallFilter)

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(true):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()

    self.kiraNode = KuruKirakiraNode.create(builder)

    for i=1, #ANIMATION_ITEMS do
        local item = ANIMATION_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = item.scale
          item.maxScale = item.scale
        end

        self.kiraNode:addSamplerFromPath(BASE_DIRECTORY .. item.fileName, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.kiraNode)

    local item = StickerItem.create()

    item.fps = ANIMATION_ITEMS[1].fps
    self.kiraNode:setStickerItem(item)
    self.kiraNode:setHighlightSampler(lightBufferNode:getSampler())

    local disappearNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "KiraKit/disappear.frag", true))

    disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "KiraKit/singleMerge.frag", true))
    self.resultSnap = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    -- mergeNode:setChannel1(cameraSnapshot:getSampler())
  else
    local maskSampler = TextureSampler.create(BASE_DIRECTORY .. MASK_PATH, false, false)

    self.highlightMaskFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/highlight.frag", false)
    self.highlightMaskFilter:getMaterial():getParameter("u_texture"):setSampler(downsampleBufferNode:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBufferNode:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.highlightMaskFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskFilter:getMaterial():getParameter("u_threshold"):setFloat(0.2)
    self.highlightMaskFilter:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
    self.highlightMaskFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.highlightMaskFilter:getMaterial():getParameter("u_maskAlpha"):setInt(1)
    self:addChildNodeAndRelease(lightBufferNode, self.highlightMaskFilter)

    local bigLightSnapshot = self:addChildNodeAndRelease(lightBufferNode, KuruSnapshotNode.create())

    self.highlightMaskSmallFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "passthrough_simple.vert", BASE_DIRECTORY .. "KiraKit/highlight.frag", false)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_texture"):setSampler(downsampleBufferNode:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBufferNode:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_threshold"):setFloat(0.1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskSmallFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.highlightMaskSmallFilter:getMaterial():getParameter("u_maskAlpha"):setInt(0)
    self:addChildNodeAndRelease(lightBufferNode, self.highlightMaskSmallFilter)
    maskSampler:release()

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(true):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()
    self.kiraNode = KuruKirakiraNode.create(builder)

    for i=1, #ANIMATION_ITEMS do
        local item = ANIMATION_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = item.scale
          item.maxScale = item.scale
        end

        self.kiraNode:addSamplerFromPath(BASE_DIRECTORY .. item.fileName, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.kiraNode)

    local aniKiraSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    local item = StickerItem.create()

    item.fps = ANIMATION_ITEMS[1].fps
    self.kiraNode:setStickerItem(item)
    self.kiraNode:setHighlightSampler(lightBufferNode:getSampler())

    builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(false):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()
    self.staticKiraNode = KuruKirakiraNode.create(builder)

    for i=1, #SINGLE_ITEMS do
        local item = SINGLE_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = item.scale
          item.maxScale = item.scale
        end

        self.staticKiraNode:addSamplerFromPath(BASE_DIRECTORY .. item.fileName, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.staticKiraNode)

    local item = StickerItem.create()

    self.staticKiraNode:setStickerItem(item)
    self.staticKiraNode:setHighlightSampler(bigLightSnapshot:getSampler())

    local disappearNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. " KiraKit/disappear.frag", true))
    disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = self:addNodeAndRelease(self.scene, KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "KiraKit/merge.frag", true))

    -- mergeNode:setChannel1(cameraSnapshot:getSampler())
    mergeNode:setChannel2(aniKiraSnapshot:getSampler())
    self.resultSnap = self:addNodeAndRelease(self.scene, KuruSnapshotNode.create())
  end
end

function KiraKit:frameReady()
  self:initThisScript()

  if self.inited == false then
    return
  end

  local sliderWeight = (PropertyConfig.instance():getNumber("stickerSliderValue", 1.0) * 0.7) + 0.35

  g_strength = (g_strength == 0.0) and 0.05 or g_strength

  self.weight = sliderWeight*2.5 +1.1 --0 ~ 클수록 빛이 많이 보임.
  self.weight = self.weight * g_strength

  if (g_kiraType == KiraType.SINGLE) then
    local item = self.staticKiraNode:getStickerItem()

    self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.staticKiraNode.elementSize = SINGLE_ITEMS[1].elementSize
    self.staticKiraNode.areaThreshold = SINGLE_ITEMS[1].areaThreshold
    self.staticKiraNode.strength = self.weight
    item.rotateZ = SINGLE_ITEMS[1].rotateZ
  elseif (g_kiraType == KiraType.ANIMATION) then
    local item = self.kiraNode:getStickerItem()

    self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.kiraNode.elementSize = ANIMATION_ITEMS[1].elementSize --0~ 키라키라 highlight 노이즈제거 필터용 커널 크기, 클수록 highlight가 없어지고 느려진다.
    self.kiraNode.areaThreshold = ANIMATION_ITEMS[1].areaThreshold
    self.kiraNode.strength = self.weight
    item.rotateZ = ANIMATION_ITEMS[1].rotateZ
  else
    local item = self.kiraNode:getStickerItem()

    self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.kiraNode.elementSize = ANIMATION_ITEMS[1].elementSize --0~ 키라키라 highlight 노이즈제거 필터용 커널 크기, 클수록 highlight가 없어지고 느려진다.
    self.kiraNode.areaThreshold = ANIMATION_ITEMS[1].areaThreshold
    self.kiraNode.strength = self.weight
    item.rotateZ = ANIMATION_ITEMS[1].rotateZ

    item = self.staticKiraNode:getStickerItem()
    self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    self.staticKiraNode.elementSize = SINGLE_ITEMS[1].elementSize
    self.staticKiraNode.areaThreshold = SINGLE_ITEMS[1].areaThreshold
    self.staticKiraNode.strength = self.weight
    item.rotateZ = SINGLE_ITEMS[1].rotateZ
  end

  local state = FrameBufferBindingState.create()

  self.splitFrameBuffer:bindWithViewport(true)
  self.splitFrameDrawModel:draw()
  state:restore()
end

function KiraKit:finalize()
  if (self.splitFrameBuffer ~= nil) then
    self.splitFrameBuffer:release()
  end

  if (self.splitFrameBufferSampler ~= nil) then
    self.splitFrameBufferSampler:release()
  end

  if (self.splitFrameDrawModel ~= nil) then
    self.splitFrameDrawModel:release()
  end
end

function KiraKit:getSampler()
  return self.resultSnap:getSampler()
end

function KiraKit:addNodeAndRelease(scene, node)
  scene:addNode(node)
  node:release()

  return node
end

function KiraKit:addChildNodeAndRelease(scene, node)
  scene:addChild(node)
  node:release()

  return node
end
