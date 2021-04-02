-- Update Date : 191007
-- Writer : Sunggon Hong


KiraKit = {
  HIGHLIGHT_WIDTH = 240.0,
  scene = nil,
  weight = 0.0,
  kiraNode = nil,
  highlightMaskFilter = nil,
  highlightMaskSmallFilter = nil,
  edgeDetectionShaderNode = nil,
  smallEdgeDetectionShaderNode = nil,
  splitFrameBuffer = nil,
  splitFrameBufferSampler = nil,
  splitFrameDrawModel = nil,
  staticKiraNode = nil
}

FACE_MASK_PATH = "images/f_mask.png"
MASK_PATH = "images/mask.png"
SINGLE_FILE_NAME = "images/kira.png"
ANI_FILE_NAME = "images/kiraAni"

function KiraKit.new(scene)
  local newKiraKit = {}

  setmetatable(newKiraKit, KiraKit)
  KiraKit.__index = KiraKit
  newKiraKit.scene = scene
  newKiraKit:initThisScript()

  return newKiraKit
end

function KiraKit:initThisScript()
  --useCustomHighlight
  -- 스티커 의 기준 가져옴.
  
  local width = math.floor(self.HIGHLIGHT_WIDTH)
  local height = math.floor(self.HIGHLIGHT_WIDTH * self.scene:getResolution().y / self.scene:getResolution().x)
  local cameraSnapshot = KuruSnapshotNode.create()

  self.scene:addNodeAndRelease(cameraSnapshot)

  local faceMaskSnapshot = nil

  if (IS_FACE_MASKING) then
    self.scene:addNodeAndRelease(KuruClearNode.create(Vector4.create(1, 1, 1, 0.0)))
    self.scene:addNodeAndRelease(KaleFaceSkinNode.create( KaleFaceSkinNodeBuilder.create():path(BASE_DIRECTORY .. FACE_MASK_PATH):skinType(KaleFaceSkinType.FACE_EX):build()))
    faceMaskSnapshot = KuruSnapshotNode.create()
    self.scene:addNodeAndRelease(faceMaskSnapshot)
    faceMaskSnapshot:setFrameBufferScale(0.3, 0.3)
  end

  self.splitFrameBuffer = FrameBuffer.create("STORED_FB_1", width, height, TextureFormat.RGBA)
  self.splitFrameBufferSampler = TextureSampler.createWithTexture(self.splitFrameBuffer:getRenderTarget(0):getTexture())
  self.splitFrameBufferSampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

  local splitFrameMesh = Mesh.createQuadFullscreen()

  self.splitFrameDrawModel = Model.create(splitFrameMesh)
  splitFrameMesh:release()

  if (g_kiraType == KiraType.SINGLE) then
    local highlightSampler = nil

    if (IS_LUMINANCE_MODE) then 
      highlightSampler = self:getLumiHighlightSampler(KiraType.SINGLE, cameraSnapshot, width, height, faceMaskSnapshot, -1)
    else 
      highlightSampler = self:getEdgeHighlightSampler(KiraType.SINGLE, cameraSnapshot, width, height, faceMaskSnapshot, -1)
    end

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(false):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()

    self.staticKiraNode = KuruKirakiraNode.create(builder)

    for i = 1, #SINGLE_ITEMS do
        local item = SINGLE_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = 1.0
          item.maxScale = 1.0
        end

        self.staticKiraNode:addSamplerFromPath(BASE_DIRECTORY .. SINGLE_FILE_NAME, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.staticKiraNode)

    local item = StickerItem.create()

    self.staticKiraNode:setStickerItem(item)
    self.staticKiraNode:setHighlightSampler(highlightSampler)

    g_disappearNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/disappear.frag", true)
    self.scene:addNodeAndRelease(g_disappearNode)
    g_disappearNode:getMaterial():getParameter("u_disappearStrength"):setFloat(g_disappearStrength) 
    g_disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = KuruSnapshotNode.create()

    self.scene:addNodeAndRelease(kiraSnapshot)

    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/singleMerge.frag", true)

    self.scene:addNodeAndRelease(mergeNode)

    mergeNode:setChannel1(cameraSnapshot:getSampler())
  elseif (g_kiraType == KiraType.ANIMATION) then
    local highlightSampler = nil

    if (IS_LUMINANCE_MODE) then 
      highlightSampler = self:getLumiHighlightSampler(KiraType.ANIMATION, cameraSnapshot, width, height, faceMaskSnapshot, -1)
    else 
      highlightSampler = self:getEdgeHighlightSampler(KiraType.ANIMATION, cameraSnapshot, width, height, faceMaskSnapshot, -1)
    end

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(true):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()

    self.kiraNode = KuruKirakiraNode.create(builder)

    for i=1, #ANIMATION_ITEMS do
        local item = ANIMATION_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = 1.0
          item.maxScale = 1.0
        end

        self.kiraNode:addSamplerFromPath(BASE_DIRECTORY .. ANI_FILE_NAME, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.kiraNode)

    local item = StickerItem.create()

    item.fps = ANIMATION_ITEMS[1].fps
    self.kiraNode:setStickerItem(item)
    self.kiraNode:setHighlightSampler(highlightSampler)

    g_disappearNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/disappear.frag", true)
    self.scene:addNodeAndRelease(g_disappearNode)
    g_disappearNode:getMaterial():getParameter("u_disappearStrength"):setFloat(g_disappearStrength) 
    g_disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = KuruSnapshotNode.create()

    self.scene:addNodeAndRelease(kiraSnapshot)

    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/singleMerge.frag", true)

    self.scene:addNodeAndRelease(mergeNode)
    mergeNode:setChannel1(cameraSnapshot:getSampler())
  else
    local highlightSampler = nil
    local aniHighlightSampler = nil
    if (IS_LUMINANCE_MODE) then 
      highlightSampler = self:getLumiHighlightSampler(KiraType.SINGLE, cameraSnapshot, width, height, faceMaskSnapshot, 1)
      aniHighlightSampler = self:getLumiHighlightSampler(KiraType.ANIMATION, cameraSnapshot, width, height, faceMaskSnapshot, 0)
    else 
      highlightSampler = self:getEdgeHighlightSampler(KiraType.SINGLE, cameraSnapshot, width, height, faceMaskSnapshot, 1)
      aniHighlightSampler = self:getEdgeHighlightSampler(KiraType.ANIMATION, cameraSnapshot, width, height, faceMaskSnapshot, 0)
    end

    local builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(true):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()
    self.kiraNode = KuruKirakiraNode.create(builder)

    for i=1, #ANIMATION_ITEMS do
        local item = ANIMATION_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = 1.0
          item.maxScale = 1.0
        end

        self.kiraNode:addSamplerFromPath(BASE_DIRECTORY .. ANI_FILE_NAME, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.kiraNode)

    local aniKiraSnapshot = KuruSnapshotNode.create()

    self.scene:addNodeAndRelease(aniKiraSnapshot)

    local item = StickerItem.create()

    item.fps = ANIMATION_ITEMS[1].fps
    self.kiraNode:setStickerItem(item)
    self.kiraNode:setHighlightSampler(aniHighlightSampler)

    builder = KuruKirakiraNodeBuilder.create():maxLayer(1):useNoise(false):elementSize(0):areaThreshold(3.0):strength(0.5):useOnlyKirakiraSticker(true):useRandomTimeSeed(true):useTracking(false):useCustomHighlight(true):highlightBaseWidth(math.floor(self.HIGHLIGHT_WIDTH)):build()
    self.staticKiraNode = KuruKirakiraNode.create(builder)

    for i=1, #SINGLE_ITEMS do
        local item = SINGLE_ITEMS[i]

        if (item.minScale == nil or item.maxScale == nil) then
          item.minScale = 1.0
          item.maxScale = 1.0
        end

        self.staticKiraNode:addSamplerFromPath(BASE_DIRECTORY .. SINGLE_FILE_NAME, item.minScale, item.maxScale, true, BlendMode.Add, 0)
    end

    self.scene:addNodeAndRelease(self.staticKiraNode)

    local item = StickerItem.create()

    self.staticKiraNode:setStickerItem(item)
    self.staticKiraNode:setHighlightSampler(highlightSampler)

    g_disappearNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/disappear.frag", true)
    self.scene:addNodeAndRelease(g_disappearNode)
    g_disappearNode:getMaterial():getParameter("u_disappearStrength"):setFloat(g_disappearStrength) 
    g_disappearNode:setChannel1(self.splitFrameBufferSampler)

    local kiraSnapshot = KuruSnapshotNode.create()

    self.scene:addNodeAndRelease(kiraSnapshot)

    local material = Material.createWithShaderFile("res/shaders/passthrough.vert", "res/shaders/passthrough.frag", Nil)

    material:getParameter("u_worldViewProjectionMatrix"):setMatrix(Matrix.identity())
    material:getParameter("u_texture"):setSampler(kiraSnapshot:getSampler())
    self.splitFrameDrawModel:setMaterial(material, -1)
    material:release()

    local mergeNode = KuruShaderFilterNode.createWithFragmentShaderFile(BASE_DIRECTORY .. "shaders/merge.frag", true)

    self.scene:addNodeAndRelease(mergeNode)

    mergeNode:setChannel1(cameraSnapshot:getSampler())
    mergeNode:setChannel2(aniKiraSnapshot:getSampler())
  end
end

function KiraKit:getEdgeProperties()
  local resolution = self.scene:getResolution()
  local ratio = resolution.x / resolution.y
  local width = math.floor(self.HIGHLIGHT_WIDTH * 3.0)
  local height = math.floor(self.HIGHLIGHT_WIDTH * 3.0 * self.scene:getResolution().y / self.scene:getResolution().x)
  local texelWidth = 1.0 / width
  local texelHeight = 1.0 / height
  local threshold = 0.77

  return texelWidth, texelHeight, threshold
end

function KiraKit:frameReady()
  local cameraInstance = CameraConfig.instance()

  if (cameraInstance["isPostEdit"] ~= nil and cameraInstance:isPostEdit()) then
    self.weight = PropertyConfig.instance():getNumber("stickerSliderValue", 1.0) * g_postEditStrength + 2.9
  else
    self.weight = PropertyConfig.instance():getNumber("stickerSliderValue", 1.0) * g_strength + 2.5
  end

  if (g_kiraType == KiraType.SINGLE) then
    local item = self.staticKiraNode:getStickerItem()

    if (IS_LUMINANCE_MODE) then 
      self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    else 
      local texelWidth, texelHeight, threshold = self:getEdgeProperties()
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("edgeStrength"):setFloat(self.weight)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("texelWidth"):setFloat(texelWidth)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("texelHeight"):setFloat(texelHeight)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("threshold"):setFloat(threshold)
    end
    
    self.staticKiraNode.elementSize = SINGLE_ITEMS[1].elementSize
    self.staticKiraNode.areaThreshold = SINGLE_ITEMS[1].areaThreshold
    self.staticKiraNode.strength = self.weight
    item.rotateZ = SINGLE_ITEMS[1].rotateZ
  elseif (g_kiraType == KiraType.ANIMATION) then
    local item = self.kiraNode:getStickerItem()

    if (IS_LUMINANCE_MODE) then 
      self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    else 
      local texelWidth, texelHeight, threshold = self:getEdgeProperties()
      self.edgeDetectionShaderNode:getMaterial():getParameter("edgeStrength"):setFloat(self.weight)
      self.edgeDetectionShaderNode:getMaterial():getParameter("texelWidth"):setFloat(texelWidth)
      self.edgeDetectionShaderNode:getMaterial():getParameter("texelHeight"):setFloat(texelHeight)
      self.edgeDetectionShaderNode:getMaterial():getParameter("threshold"):setFloat(threshold)
    end

    self.kiraNode.elementSize = ANIMATION_ITEMS[1].elementSize --0~ 키라키라 highlight 노이즈제거 필터용 커널 크기, 클수록 highlight가 없어지고 느려진다.
    self.kiraNode.areaThreshold = ANIMATION_ITEMS[1].areaThreshold
    self.kiraNode.strength = self.weight
    item.rotateZ = ANIMATION_ITEMS[1].rotateZ
    g_disappearNode:getMaterial():getParameter("u_disappearStrength"):setFloat(g_disappearStrength) 
  else
    local item = self.kiraNode:getStickerItem()

    if (IS_LUMINANCE_MODE) then 
      self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
      self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(self.weight)
    else 
      local texelWidth, texelHeight, threshold = self:getEdgeProperties()
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("edgeStrength"):setFloat(self.weight)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("texelWidth"):setFloat(texelWidth)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("texelHeight"):setFloat(texelHeight)
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("threshold"):setFloat(threshold)
      self.edgeDetectionShaderNode:getMaterial():getParameter("edgeStrength"):setFloat(self.weight)
      self.edgeDetectionShaderNode:getMaterial():getParameter("texelWidth"):setFloat(texelWidth)
      self.edgeDetectionShaderNode:getMaterial():getParameter("texelHeight"):setFloat(texelHeight)
      self.edgeDetectionShaderNode:getMaterial():getParameter("threshold"):setFloat(threshold)
    end

    self.kiraNode.elementSize = ANIMATION_ITEMS[1].elementSize --0~ 키라키라 highlight 노이즈제거 필터용 커널 크기, 클수록 highlight가 없어지고 느려진다.
    self.kiraNode.areaThreshold = ANIMATION_ITEMS[1].areaThreshold
    self.kiraNode.strength = self.weight
    item.rotateZ = ANIMATION_ITEMS[1].rotateZ

    item = self.staticKiraNode:getStickerItem()
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

function KiraKit:getEdgeHighlightSampler(kiraType, cameraSnapshot, bufferWidth, bufferHeight, faceMaskSnapshot, maskAlpha)
  local lightBufferNode = KuruFrameBufferNode.createWithSize(bufferWidth, bufferHeight)

  self.scene:addNodeAndRelease(lightBufferNode)

  if (kiraType == KiraType.SINGLE) then  
    local passthroughNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/first.vert", BASE_DIRECTORY .. "shaders/first.frag", true)
    
    lightBufferNode:addChildAndRelease(passthroughNode)
    passthroughNode:setChannel0(cameraSnapshot:getSampler())

    self.smallEdgeDetectionShaderNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/second.vert", BASE_DIRECTORY .. "shaders/second.frag", true)
    self.smallEdgeDetectionShaderNode:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    lightBufferNode:addChildAndRelease(self.smallEdgeDetectionShaderNode)

    if (IS_FACE_MASKING) then
      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.smallEdgeDetectionShaderNode:getMaterial():getParameter("u_maskAlpha"):setInt(maskAlpha)

    if (maskAlpha ~= -1) then 
      local maskSampler = TextureSampler.create(BASE_DIRECTORY .. MASK_PATH, false, false)

      self.smallEdgeDetectionShaderNode:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
      maskSampler:release()
    end
  else 
    local passthroughNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/first.vert", BASE_DIRECTORY .. "shaders/first.frag", true)

    lightBufferNode:addChildAndRelease(passthroughNode)
    passthroughNode:setChannel0(cameraSnapshot:getSampler())

    self.edgeDetectionShaderNode = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/second.vert", BASE_DIRECTORY .. "shaders/second.frag", true)
    self.edgeDetectionShaderNode:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    lightBufferNode:addChildAndRelease(self.edgeDetectionShaderNode)

    if (IS_FACE_MASKING) then
      self.edgeDetectionShaderNode:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    self.edgeDetectionShaderNode:getMaterial():getParameter("u_maskAlpha"):setInt(maskAlpha)

    if (maskAlpha ~= -1) then 
      local maskSampler = TextureSampler.create(BASE_DIRECTORY .. MASK_PATH, false, false)

      self.edgeDetectionShaderNode:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
      maskSampler:release()
    end
  end

  return lightBufferNode:getSampler()
end

function KiraKit:getLumiHighlightSampler(kiraType, cameraSnapshot, bufferWidth, bufferHeight, faceMaskSnapshot, maskAlpha)
  local downSamplerBuffer, blurBuffer = self:getDownSampleBuffers(cameraSnapshot, bufferWidth, bufferHeight)
  local lightBufferNode = KuruFrameBufferNode.createWithSize(bufferWidth, bufferHeight)

  self.scene:addNodeAndRelease(lightBufferNode)

  if (kiraType == KiraType.SINGLE) then 

    self.highlightMaskFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/passthrough_simple.vert", BASE_DIRECTORY .. "shaders/highlight.frag", false)
    self.highlightMaskFilter:getMaterial():getParameter("u_texture"):setSampler(downSamplerBuffer:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBuffer:getSampler())
    self.highlightMaskFilter:getMaterial():getParameter("u_strength"):setFloat(0.0)
    self.highlightMaskFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskFilter:getMaterial():getParameter("u_threshold"):setFloat(0.2)
    self.highlightMaskFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end


    if (maskAlpha ~= -1) then 
      local maskSampler = TextureSampler.create(BASE_DIRECTORY .. MASK_PATH, false, false)

      self.highlightMaskFilter:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
      maskSampler:release()
    end

    self.highlightMaskFilter:getMaterial():getParameter("u_maskAlpha"):setInt(maskAlpha)
    lightBufferNode:addChildAndRelease(self.highlightMaskFilter)
  else
    self.highlightMaskSmallFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/passthrough_simple.vert", BASE_DIRECTORY .. "shaders/highlight.frag", false)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_texture"):setSampler(downSamplerBuffer:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_blurTexture"):setSampler(blurBuffer:getSampler())
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_strength"):setFloat(0.0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_time"):setFloat(0.0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_useNoise"):setInt(0)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_grayScale"):setInt(1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_threshold"):setFloat(0.1)
    self.highlightMaskSmallFilter:getMaterial():getParameter("u_isFaceMasking"):setBool(IS_FACE_MASKING)

    if (IS_FACE_MASKING) then
      self.highlightMaskSmallFilter:getMaterial():getParameter("u_faceMaskTexture"):setSampler(faceMaskSnapshot:getSampler())
    end

    if (maskAlpha ~= -1) then 
      local maskSampler = TextureSampler.create(BASE_DIRECTORY .. MASK_PATH, false, false)

      self.highlightMaskSmallFilter:getMaterial():getParameter("u_maskTexture"):setSampler(maskSampler)
      maskSampler:release()
    end

    self.highlightMaskSmallFilter:getMaterial():getParameter("u_maskAlpha"):setInt(maskAlpha)
    lightBufferNode:addChildAndRelease(self.highlightMaskSmallFilter)
  end

  return lightBufferNode:getSampler()
end

function KiraKit:getDownSampleBuffers(cameraSnapshot, width, height)
    local downsampleBufferNode = KuruFrameBufferNode.createWithSize(width, height)

    self.scene:addNodeAndRelease(downsampleBufferNode)

    local downsampleFilter = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/passthrough_simple.vert", BASE_DIRECTORY .. "shaders/passthrough.frag", false)

    downsampleFilter:getMaterial():getParameter("u_texture"):setSampler(cameraSnapshot:getSampler())
    downsampleBufferNode:addChildAndRelease(downsampleFilter)

    local blurBufferNode = KuruFrameBufferNode.createWithSize(width, height)

    self.scene:addNodeAndRelease(blurBufferNode)

    local downsampleFilter2 = KuruShaderFilterNode.createWithFile(BASE_DIRECTORY .. "shaders/passthrough_simple.vert", BASE_DIRECTORY .. "shaders/passthrough.frag", false)

    downsampleFilter2:getMaterial():getParameter("u_texture"):setSampler(cameraSnapshot:getSampler())
    blurBufferNode:addChildAndRelease(downsampleFilter2)

    local blurNode = KuruGaussianBlurNode.create()
    blurBufferNode:addChildAndRelease(blurNode)

    local blurDrawable = KuruAdjustableGaussianDrawable.cast(blurNode:getDrawable())

    blurDrawable:setStrength(0.275)

    return downsampleBufferNode, blurBufferNode
end