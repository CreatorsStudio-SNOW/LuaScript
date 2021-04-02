require "FileIOKit/FileIOKit.lua"
require "TextKit/TextKit.lua"

g_ioValueKit = nil

g_textKit_1 = nil
g_textKit_2 = nil

g_backgroundNode_1 = nil
g_backgroundNode_2 = nil

FONT_NAME = "en_lefrench.ttf"
DEFAULT_TEXT = "SNOW CORP."

function initialize(scene)
    g_textKit_1 = TextKit:new()
    g_textKit_1[TextRequestParams.IMAGE_WIDTH] = 2000
    g_textKit_1[TextRequestParams.IMAGE_HEIGHT] = 100
    g_textKit_1[TextRequestParams.FONT_COLOR] = "22FF00FF"

    local textTexture = g_textKit_1:createTexture("Hello world!")
    if textTexture then
        local sampler = TextureSampler.createWithTexture(textTexture)
        g_backgroundNode_1 = createBGNodeWithSampler(scene, sampler)
        -- g_backgroundNode_1:setScale(0.3, 0.3, 1.0)
        g_backgroundNode_1:setTranslationY(-0.5)
        g_backgroundNode_1:setTranslationX(0.0)
        textTexture:release()
        sampler:release()
    end

    g_ioValueKit = FileIOKit.new("text.dat", FileIODataType.Value)

    local text = g_ioValueKit:read()
    if (text == nil) then text = DEFAULT_TEXT end

    g_textKit_2 = TextKit:new()
    g_textKit_2[TextRequestParams.IMAGE_WIDTH] = 2000
    g_textKit_2[TextRequestParams.IMAGE_HEIGHT] = 100
    g_textKit_2[TextRequestParams.FONT_COLOR] = "FF2200A0"
    g_textKit[TextRequestParams.FONT_FAMILY] = FONT_NAME
    g_textKit_2[TextRequestParams.DEFAULT_TEXT] = DEFAULT_TEXT
    g_textKit[TextRequestParams.PLACE_HOLDER] = text
    g_textKit_2.responseFunction = handleEventResponse

    local textTexture2 = g_textKit_2:createTexture(text)
    if textTexture2 then
        local sampler = TextureSampler.createWithTexture(textTexture2)
        g_backgroundNode_2 = createBGNodeWithSampler(scene, sampler)
        -- g_backgroundNode_2:setScale(0.4, 0.4, 1.0)
        textTexture2:release()
        sampler:release()
    end

    g_textKit_2:changeToEnableTextMode()

end

function handleEventResponse(response, textureList)
    if #textureList == 0 then return end

    local sampler = TextureSampler.createWithTexture(textureList[1])
    sampler:setWrapMode(TextureWrap.CLAMP, TextureWrap.CLAMP)

    if g_backgroundNode_2 then g_backgroundNode_2:setSampler(sampler) end

    sampler:release()

    local textString = response[TextResponseParams.TEXT] or ""
    g_textKit[TextRequestParams.PLACE_HOLDER] = textString
    g_ioValueKit:write(textString)
    g_textKit:changeToEnableTextMode()
end

function createBGNodeWithSampler(scene, sampler)
    local bgNode = KuruBackgroundImageNode.createFromSampler(sampler,
                                                             BlendMode.None)
    bgNode:setStretch(KuruBackgroundImageNodeStretch.NONE)
    scene:addNodeAndRelease(bgNode)
    return bgNode
end

g_previousWidth = 0.0

function frameReady(scene, elapsedTime)
    local s = scene:getResolution().x / 720
    g_backgroundNode_1:setScale(s, s, 1)
    g_backgroundNode_2:setScale(s, s, 1)
    g_previousWidth = scene:getResolution().x
end

function finalize(scene) TextKit.finalize() end
