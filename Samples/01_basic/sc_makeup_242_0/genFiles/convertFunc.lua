function _getMakeupConfigDef(dataModels)
  local code = ""

  for idx,dataModel in pairs(dataModels) do
    if dataModel ~= "customImage" then
      code = code .. '^{dataModels[' .. tostring(idx) .. ']->propertyConfig}^'
    end
  end

  return code
end

function _getMakeupStrength(dataModels)
  local code = ""

  local isWritedEyeShadow = false
  for idx,dataModel in pairs(dataModels) do
    if dataModel.modelType == "lipLayer" then
        code = code .. dataModel.name .. 'Strength = ' .. '^{dataModels[' .. tostring(idx) .. '].strength}^\n'
      
    elseif dataModel.modelType == "lip_twinkle" then
        code = code .. 'lipGlossSpecPowFactor = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGlossSpecPowFactor}^\n'
        code = code .. 'highlightMaskStrength = 1.0\n'
        code = code .. 'blurStrength = 1.0\n'
        code = code .. 'lipGlossSpecFactor = 250.0\n'
        code = code .. 'highPassStrength = 1.3\n'
        code = code .. 'lioGlossMaskStrength = 0.5\n'
        code = code .. 'lipGlossStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGlossStrength}^\n'
        code = code .. 'lipGloss3dHighlightScale = 2.0\n'
        code = code .. 'lipGloss3dRoughness = 0.75\n'
        code = code .. 'lipGloss3dUsePerceptualRoughness = false\n'
        code = code .. 'afterBlurStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].afterBlurStrength}^\n'
        code = code .. 'usesLipBlur = ' .. '^{dataModels[' .. tostring(idx) .. '].usesLipBlur}^\n'
        code = code .. 'clampPowMaxYaw = ' .. '^{dataModels[' .. tostring(idx) .. '].clampPowMaxYaw}^\n'
        code = code .. 'clampLinearMaxYaw = ' .. '^{dataModels[' .. tostring(idx) .. '].clampLinearMaxYaw}^\n'
        code = code .. 'lipBlurStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].lipBlurStrength}^\n'
    elseif dataModel.modelType == "lip_glow" then
        code = code .. 'lipGlossSpecPowFactor = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGlossSpecPowFactor}^\n'
        code = code .. 'highlightMaskStrength = 1.0\n'
        code = code .. 'blurStrength = 1.0\n'
        code = code .. 'lipGlossSpecFactor = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGlossSpecFactor}^\n'
        code = code .. 'highPassStrength = 4.0\n'
        code = code .. 'lioGlossMaskStrength = 1.0\n'
        code = code .. 'lipGlossStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGlossStrength}^\n'
        code = code .. 'lipGloss3dHighlightScale = 2.0\n'
        code = code .. 'lipGloss3dRoughness = ' .. '^{dataModels[' .. tostring(idx) .. '].lipGloss3dRoughness}^\n'
        code = code .. 'lipGloss3dUsePerceptualRoughness = true\n'
        code = code .. 'afterBlurStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].afterBlurStrength}^\n'
        code = code .. 'usesLipBlur = ' .. '^{dataModels[' .. tostring(idx) .. '].usesLipBlur}^\n'
        code = code .. 'clampPowMaxYaw = ' .. '^{dataModels[' .. tostring(idx) .. '].clampPowMaxYaw}^\n'
        code = code .. 'clampLinearMaxYaw = ' .. '^{dataModels[' .. tostring(idx) .. '].clampLinearMaxYaw}^\n'
        code = code .. 'lipBlurStrength = ' .. '^{dataModels[' .. tostring(idx) .. '].lipBlurStrength}^\n'
        
    else
        code = code .. dataModel.modelType .. 'Strength = ' .. '^{dataModels[' .. tostring(idx) .. '].strength}^\n'
    end
  end

  return code
end

function _getInitialMakeUpNodeNodeDef(dataModels)
  local code = ""

  for idx,dataModel in pairs(dataModels) do
    code = code .. '^{dataModels[' .. tostring(idx) .. ']->initialize}^'
  end

  return code
end

function getAppStrength(useAppSlider, sliderType)
  if useAppSlider == true then
    if sliderType == "stickerSliderValue" then
        return 'local strength = PropertyConfig.instance():getNumber("stickerSliderValue", 1.0)\nappStrength = (maxStrength - minStrength) * strength + minStrength'
    else
        return 'local strength = PropertyConfig.instance():getNumber("makeupSliderValue", 1.0)\nappStrength = (maxStrength - minStrength) * strength + minStrength'
    end
  else
    return 'appStrength = maxStrength'
  end
end

function _convertBlendModeLuaToStikcerItem(blendMode)
  if blendMode == "BlendMode.None" then
    return "NORMAL"
  elseif blendMode == "BlendMode.Burn" then
    return "BLEND_COLOR_BURN"
  elseif blendMode == "BlendMode.Dodge" then
    return "BLEND_COLOR_DODGE"
  elseif blendMode == "BlendMode.LinearLight" then
    return "BLEND_LINEAR_LIGHT"
  elseif blendMode == "BlendMode.LinearBurn" then
    return "BLEND_LINEAR_BURN"
  elseif blendMode == "BlendMode.linearDodge" then
    return "BLEND_LINEAR_DODGE"
  end
  local blendString = string.gsub(blendMode, "BlendMode.", "")
  return "BLEND_" .. string.upper(blendString)
end

function _getParamStrengthDef(dataModels, name)
  local code = ""
  local isWritedEyeShadow = false
    local isLipLUTExist = false
  for idx,dataModel in pairs(dataModels) do
    if dataModel.modelType == "lipLUT" then
      isLipLUTExist = true
    end
  end

  for idx,dataModel in pairs(dataModels) do
    if dataModel.modelType == "lipLayer" then
        code = code .. name .. ':setLipLayerStrength(' .. _getIndexLiplayer(dataModels, dataModel.name) .. ', '.. dataModel.name .. 'Strength * appStrength)\n'
    elseif dataModel.modelType == "lip_twinkle" then
        code = code .. 'makeup_param.lipGlossSpecPowFactor = lipGlossSpecPowFactor * 14.4\n'
        code = code .. 'makeup_param.highlightMaskStrength = highlightMaskStrength\n'
        code = code .. 'makeup_param.blurStrength = blurStrength\n'
        code = code .. 'makeup_param.lipGlossSpecFactor = lipGlossSpecFactor\n'
        code = code .. 'makeup_param.highPassStrength = highPassStrength\n'
        code = code .. 'makeup_param.lioGlossMaskStrength = lioGlossMaskStrength\n'
        code = code .. 'makeup_param.lipgloss3d = lipGlossStrength\n'
        code = code .. 'makeup_param.lipGloss3dHighlightScale = lipGloss3dHighlightScale\n'
        code = code .. 'makeup_param.lipGloss3dRoughness = lipGloss3dRoughness\n'
        code = code .. 'makeup_param.lipGloss3dUsePerceptualRoughness = lipGloss3dUsePerceptualRoughness\n'
        code = code .. 'makeup_param.afterBlurStrength = afterBlurStrength\n'
        code = code .. 'if KuruConfig.instance():isVersionOver(10, 0, 0) == true then\n'
        code = code .. '    makeup_param.lipBlurStrength = lipBlurStrength\n'
        code = code .. '    makeup_param.usesLipBlur = usesLipBlur\n'
        code = code .. '    makeup_param.clampPowMaxYaw = clampPowMaxYaw\n'
        code = code .. '    makeup_param.clampLinearMaxYaw = clampLinearMaxYaw\n'
        code = code .. 'end\n'
        if isLipLUTExist == false then
            code = code .. 'makeup_param.lip = strength\n'
        end
    elseif dataModel.modelType == "lip_glow" then
        code = code .. 'makeup_param.lipGlossSpecPowFactor = lipGlossSpecPowFactor * 14.4\n'
        code = code .. 'makeup_param.highlightMaskStrength = highlightMaskStrength\n'
        code = code .. 'makeup_param.blurStrength = blurStrength\n'
        code = code .. 'makeup_param.lipGlossSpecFactor = lipGlossSpecFactor * 400\n'
        code = code .. 'makeup_param.highPassStrength = highPassStrength\n'
        code = code .. 'makeup_param.lioGlossMaskStrength = lioGlossMaskStrength\n'
        code = code .. 'makeup_param.lipgloss3d = lipGlossStrength\n'
        code = code .. 'makeup_param.lipGloss3dHighlightScale = lipGloss3dHighlightScale\n'
        code = code .. 'makeup_param.lipGloss3dRoughness = lipGloss3dRoughness\n'
        code = code .. 'makeup_param.lipGloss3dUsePerceptualRoughness = lipGloss3dUsePerceptualRoughness\n'
        code = code .. 'makeup_param.afterBlurStrength = afterBlurStrength\n'
        code = code .. 'if KuruConfig.instance():isVersionOver(10, 0, 0) == true then\n'
        code = code .. '    makeup_param.lipBlurStrength = lipBlurStrength\n'
        code = code .. '    makeup_param.usesLipBlur = usesLipBlur\n'
        code = code .. '    makeup_param.clampPowMaxYaw = clampPowMaxYaw\n'
        code = code .. '    makeup_param.clampLinearMaxYaw = clampLinearMaxYaw\n'
        code = code .. 'end\n'
        if isLipLUTExist == false then
            code = code .. 'makeup_param.lip = strength\n'
        end
    else
      code = code .. 'makeup_param.^{dataModels[' .. tostring(idx) .. ']->paramType}^' .. ' = ' .. dataModel.modelType .. 'Strength * appStrength\n'
    end
  end

  return code
end

function _modelTypeToConfig(modelType)
  if modelType == "blush" then
    return "BLUSH"
  elseif modelType == "contour" then
    return "CONTOUR"
  elseif modelType == "eyeLine" then
    return "EYELINER"
  elseif modelType == "eyeBrows" then
    return "EYEBROWS"
  elseif modelType == "eyeColor" then
    return "EYE_COLOR"
  elseif modelType == "eyeLashes" then
    return "EYELASHES"
  elseif modelType == "lipLUT" then
    return "LIP_COLOR"
  elseif modelType == "eyeShadows_L0" then
    return "EYESHADOW_LAYER0"
  elseif modelType == "eyeShadows_L1" then
    return "EYESHADOW_LAYER1"
  elseif modelType == "eyeShadows_L2" then
    return "EYESHADOW_LAYER2"
  elseif modelType == "eyeBrowLayer0" then
    return "EYEBROWS_LAYER0"
  elseif modelType == "eyeBrowLayer1" then
    return "EYEBROWS_LAYER1"
  elseif modelType == "eyeBrowLayer2" then
    return "EYEBROWS_LAYER2"
  end
  return modelType
end

function _getSetPathMethodString(makeUpType, typeId, resourceName, blendMode)
  local config = _modelTypeToConfig(makeUpType)
  local code = ""
  if typeId == "CustomImage" then
      code = code .. 'setPathAndBlendMode(KuruMakeupNodeType.' .. config .. ', BASE_DIRECTORY .. "' .. _getResourcePath(makeUpType, resourceName) .. '", ' .. blendMode .. ')'
  else
    code = 'setPathAndBlendModeById(KuruMakeupNodeType.' .. config .. ', ' .. config .. '.' .. typeId .. ', ' .. blendMode .. ')'
  end
  return code
end

function _getSetPathMethodStringForEyeShadow(makeUpType, typeId, resourceName, blendMode, animation)
  local config = _modelTypeToConfig(makeUpType)
  if typeId == "CustomImage" then
    return 'setPathAndBlendMode(KuruMakeupNodeType.' .. config .. ', BASE_DIRECTORY .. "' .. _getEyeShadowResourcePath(makeUpType, resourceName, animation) .. '", ' .. blendMode .. ')'
  else
    return 'setPathAndBlendModeById(KuruMakeupNodeType.' .. config .. ', ' .. config .. '.' .. typeId .. ', ' .. blendMode .. ')'
  end
end

function _getSetPathMethodStringForContour(makeUpType, typeId, resourceName, blendMode)
  local config = _modelTypeToConfig(makeUpType)
  if typeId == "CustomImage" then
    return 'setPathAndBlendMode(KuruMakeupNodeType.' .. config .. ', BASE_DIRECTORY .. "' .. _getResourcePath(makeUpType, resourceName) .. '", ' .. blendMode .. ')'
  end
  return 'setPathAndBlendModeById(KuruMakeupNodeType.' .. config .. ', ' .. config .. '.' .. typeId .. ', ' .. blendMode .. ')'
  
end

function _getIndexLiplayer(dataModels, name)
  local index = 0

  for idx,dataModel in pairs(dataModels) do
    if dataModel.modelType == "lipLayer" then
      if dataModel.name == name then
        return tostring(index)
      else
        index = index + 1
      end
    end
  end

  return tostring(index)
end

function _getResourcePath(modelType, resourceName)
  if modelType == "blush" then
    if resourceName == "" then
      return 'images/ ' .. resourceName
    else
      return 'images/' .. resourceName
    end
  elseif modelType == "eyeLine" then
    return 'images/' .. resourceName .. '/eye_liner.png'
  elseif modelType == "eyeColor" then
    return 'images/' .. resourceName
  elseif modelType == "eyeLashes" then
    return 'images/' .. resourceName .. '/eyelashes.png'
  end
  return 'images/' .. resourceName
end

function _getEyeShadowResourcePath(modelType, resourceName, animation)
  if modelType == "eyeShadows_L0" then
    if animation == "Single" then
      return 'images/' .. resourceName .. '/eye_shadow_L0.png'
    elseif animation == "Sequence" then
      return 'images/' .. resourceName
    end
  elseif modelType == "eyeShadows_L1" then
    if animation == "Single" then
      return 'images/' .. resourceName .. '/eye_shadow_L1.png'
    elseif animation == "Sequence" then
      return 'images/' .. resourceName
    end
  elseif modelType == "eyeShadows_L2" then
    if animation == "Single" then
      return 'images/' .. resourceName .. '/eye_shadow_L2.png'
    elseif animation == "Sequence" then
      return 'images/' .. resourceName
    end
  end
end

function _getAsianContourPath(contourType, resourceName)
  return 'images/contour_builtin/contour.png'
end

function _getLipMaskPath(lipMaskType)
  if lipMaskType == "DEFAULT" then
    return '"asset://makeup/lip_color_mask/default.dat"'
  elseif lipMaskType == "GRADATION_A" then
    return '"asset://makeup/lip_color_mask/gradation_a.dat"'
  elseif lipMaskType == "GRADATION_B" then
    return '"asset://makeup/lip_color_mask/gradation_b.dat"'
  elseif lipMaskType == "GRADATION_C" then
    return 'BASE_DIRECTORY .. "images/lipLutMask/lipLutMask_gradation_c.png"'
  elseif lipMaskType == "FULL" then
    return 'BASE_DIRECTORY .. "images/lipLutMask/lipLutMask_full.png"'
  elseif lipMaskType == "SMUDGE" then
    return 'BASE_DIRECTORY .. "images/lipLutMask/lipLutMask_smudge.png"'
  end
end

function _getSetLipMaskPathMethodString(lipMaskType)
  local code = 'if (^{parentDataModel.name}^["setLipLutMaskPath"] ~= nil) then\n'
  code = code .. '^{parentDataModel.name}^:setLipLutMaskPath('
  code = code .. _getLipMaskPath(lipMaskType)
  code = code .. ')\n'
  code = code .. 'end'
  return code
end


function _getLipglossResourcePath(resourceName)
    return 'images/' .. resourceName
end

function _getLipglossGlowResourcePath(resourceName)
    return 'images/lipGlossGlow/' .. resourceName
end

function _getLipglossTwinkleResourcePath(resourceName)
    return 'images/lipGlossTwinkle/' .. resourceName
end
                        



---- NodeWrapper END ----
