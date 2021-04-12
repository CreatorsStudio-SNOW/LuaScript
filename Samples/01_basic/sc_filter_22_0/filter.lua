require "filterConfig.lua"


g_filterNode = nil -- 제작자 의도에 따라 필터가 없을 수 있음
g_isFrontCamera = false
g_lastSliderValue = -1

---------------------------------
----- StickerItem LifeCycle -----
---------------------------------
function initialize(scene)
    initGlobals()
    createFilterNode(scene)
    updateSharpness(scene)
end

function frameReady(scene, elapsedTime)
    if isCameraChanged() and config_separateCamera then
        createFilterNode(scene)
        return
    end

    if g_filterNode == nil then
        return
    end

    local shouldEnableFilter = shouldEnableFilter()
    if shouldEnableFilter ~= g_filterNode:isEnabled() then
        g_filterNode:setEnabled(shouldEnableFilter)
    end

    updateFilterNodeIntensity()
end

-------------------------------------
----- Filter Nodes Manipulation -----
-------------------------------------

function createFilterNode(scene)
    if g_filterNode ~= nil then
        scene:removeNode(g_filterNode)
        g_filterNode = nil
    end

    local filterName = usesFrontFilter() and config_filterName or config_rearFilterName

    if filterName == '' then
        return
    end

    local filterPath = BASE_DIRECTORY .. filterName .. ".dat"

    g_filterNode = KuruLookUpTableFilterNode.create(filterPath, true, getFilterOpacity(getSliderValue()))
    g_filterNode:setEnabled(shouldEnableFilter())
    scene:addNodeAndRelease(g_filterNode)
end

function updateFilterNodeIntensity()
    if g_filterNode == nil or shouldEnableFilter() == false or config_sliderType == SliderType.Off then
        return
    end

    local sliderValue = getSliderValue()
    if g_lastSliderValue == sliderValue then
        return
    end

    g_lastSliderValue = sliderValue
    g_filterNode:setIntensity(getFilterOpacity(g_lastSliderValue))
end

function getSliderValue()
    if usesPropertyConfig() then
        return PropertyConfig.instance():getNumber(getSliderValueKey(), 0)
    else
        return usesFrontFilter() and config_initialIntensity or config_initialRearIntensity
    end
end

--------------------
----- Private ------
--------------------

function initGlobals()
    g_isFrontCamera = CameraConfig.instance().isFaceFront
    g_lastSliderValue = usesFrontFilter() and config_initialIntensity or config_initialRearIntensity
end

function shouldEnableFilter()
    -- https://oss.navercorp.com/video-division/studio-644-ios/issues/900
    -- 스페셜필터 모드에서는 항상 활성화
    -- 카메라 모드에서 사용자가 필터를 선택한 경우 비활성화
    -- 갤러리 모드에서 제작자가 필터를 비활성화한 경우 비활성화
    local isSpecialFilterMode = SceneRenderConfig.instance().filterId == KuruConfig.instance().activeStickerId 
    local isUserFilterActivatedCamera = (CameraConfig.instance():isCameraMode() and SceneRenderConfig.instance():isFilterActivated()) 
    local isFilterDisabledGallery = (CameraConfig.instance():isGalleryMode() and config_enableFilterInAlbum == false)
    return isSpecialFilterMode or (not isUserFilterActivatedCamera) and (not isFilterDisabledGallery)
end

function usesFrontFilter()
    if g_isFrontCamera then
        return true
    end

    return config_separateCamera == false
end

function isCameraChanged()
    if g_isFrontCamera == CameraConfig.instance().isFaceFront then
        return false
    end

    g_isFrontCamera = CameraConfig.instance().isFaceFront
    return true
end

function updateSharpness(scene)
    -- 갤러리 모드에서는 sharpness 0 
    -- https://oss.navercorp.com/video-division/studio-644-ios/issues/1057
    if CameraConfig.instance():isGalleryMode() then 
        scene:getConfig().sharpness = 0
        return
    end

    -- 플랫폼별 sharpness 설정 
    -- https://oss.navercorp.com/video-division/studio-644-ios/issues/936
    if DeviceConfig.instance():isAndroid() then 
        if config_iosSharpIntensity == 0.7 then
            scene:getConfig().sharpness = 0
        else
            normalizedSharpeness = ((config_iosSharpIntensity-0.8)/0.4)*0.6
            scene:getConfig().sharpness = normalizedSharpeness
        end
    else
        if config_iosSharpIntensity == 0.8 then
            scene:getConfig().sharpness = 0.7
        else
            scene:getConfig().sharpness = config_iosSharpIntensity
        end
    end

    scene:getConfig().sharpnessSlope = 0
end

function getSliderValueKey()
    if config_sliderType == SliderType.Sticker then
        return "stickerSliderValue"
    end

    return "specialFilterIntensity"
end

function getFilterOpacity(sliderValue)
    if usesFrontFilter() then
        return sliderValue * config_opacity
    else
        return sliderValue * config_rearOpacity
    end
end

function usesPropertyConfig()
    if config_sliderType == SliderType.Off then
        return false
    end
    
      -- 갤러리 모드에서 LensEditor에서 필터 컨텐츠의 경우 유저가 설정한 기본값을 사용
    if CameraConfig.instance():isGalleryMode() then
        if g_filterNode ~= nil and KuruNode.cast(g_filterNode):getStickerItem()["getEditor"] and KuruConfig.instance():isVersionOver(10, 0, 0) then
            if KuruNode.cast(g_filterNode):getStickerItem():getEditor().lensAssetType == LensAssetType.LUT_FILTER then
                return true
            end
        end
    end


    if isServiceB612() and config_sliderType == SliderType.StyleFilter and CameraConfig.instance():isGalleryMode() then
        return false
    end

    return true
end

-- Service Codes
-- http://bts.snowcorp.com/browse/WHITE-1284
function isServiceB612()
  local serviceCode = ServiceConfig.instance().serviceCode

  if serviceCode == 1 or serviceCode == 2 or serviceCode == 3 then
    return true
  end

  return false
end