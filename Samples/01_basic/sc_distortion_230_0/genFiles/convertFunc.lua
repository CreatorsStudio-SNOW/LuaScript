
function generateInitialize(distortionType)
    if distortionType == "app" then
        return addAppDistortion()
    elseif distortionType == "face" then
        return addFaceDistortion()
    elseif distortionType == "uni" then
        return addUniDistortion()
    elseif distortionType == "uniAndFace" then
        return addUniAndFaceDistortion()
    end
end

function addAppDistortion()
    local code = ""
    code = code .. 'EngineStatus.instance():setBoolean("useBuiltInDistortionInScript", true)\n'
    code = code .. 'local appDistortion = KuruUniDistortionNode.create()\n'
    code = code .. 'scene:addNodeAndRelease(appDistortion)\n'
    return code
end

function addFaceDistortion()
    local code = ""
    code = code .. 'local customFaceDist = KaleFaceDistortionNode.createWithPath(BASE_DIRECTORY .. "face_dist.json")\n'
    code = code .. 'scene:addNodeAndRelease(customFaceDist)\n'
    return code
end

function addUniDistortion()
    local code = ""
    code = code .. 'customUniDist = KuruUniDistortionNode.create()\n'
    code = code .. 'customUniDist:setStyle(BASE_DIRECTORY .. "uni_dist.json")\n'
    code = code .. 'scene:addNodeAndRelease(customUniDist)\n'
    return code
end

function addUniAndFaceDistortion()
    local code = ""
    local uniDistortionCode = addUniDistortion()
    code = code .. uniDistortionCode
    code = code .. 'if customUniDist["setKaleDistortionPolicy"] ~= nil then\n'
    code = code .. '    customUniDist:setKaleDistortionPolicy(KuruUniDistortionNodeKaleDistortionPolicy.MANNUAL)\n'
    code = code .. '    customUniDist:setKaleDistortion(BASE_DIRECTORY .. "face_dist.json")\n'
    code = code .. '    customUniDist:bindUniDetailAndKaleGroupAll()\n'
    code = code .. 'else\n'
    code = code .. '    local customFaceDist = KaleFaceDistortionNode.createWithPath(BASE_DIRECTORY .. "face_dist.json")\n'
    code = code .. '    scene:addNodeAndRelease(customFaceDist)\n'
    code = code .. 'end\n'
    return code
end
