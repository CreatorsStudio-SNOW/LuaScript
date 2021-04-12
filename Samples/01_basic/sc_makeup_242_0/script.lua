
CONTOUR = {
	Sharp = 101,
	Glamour = 102,
	Nose = 103,
	Highlight = 104,
	Round = 105,
	Square = 106,
	Long = 107
}

BLUSH = {
	Light1 = 101,
	Light2 = 102,
	Edge1 = 103,
	Edge2 = 104,
	Edge3 = 105,
	Edge4 = 106,
	Apple1 = 107,
	Apple2 = 108,
	Apple3 = 109,
	Apple4 = 110
}

EYE_COLOR = {
	Oasis = 1,
	Moist = 2,
	Crystal = 3,
	Gray = 4,
	Brown = 5,
	Blue = 6,
	Crystal2 = 101,
	Hazel = 102,
	Gray2 = 103,
	Berry = 104,
	Indigo = 105
}

EYELASHES = {
	Lash1 = 101,
	Lash2 = 102,
	Lash3 = 103,
	Lash4 = 104,
	Lash5 = 105
}

EYELINER = {
	BR1 = 101,
	BR2 = 102,
	BR3 = 103,
	BK1 = 104,
	BK2 = 105,
	BK3 = 106,
	BK4 = 107,
	BK5 = 108
}

EYESHADOW_LAYER0 = {
	Pink = 101,
	Orange = 102,
	Brown = 103,
	Coral = 104,
	Smokey = 105
}

EYESHADOW_LAYER1 = {
	Pink = 101,
	Orange = 102
}

appStrength = 1.0
maxStrength = 1.00
minStrength = 0.00
contourStrength = 0.36
blushStrength = 0.36
eyeBrowLayer1Strength = 0.20
eyeColorStrength = 1.00
eyeLashesStrength = 0.39
eyeLineStrength = 0.35
eyeShadows_L0Strength = 0.35
eyeShadows_L1Strength = 0.46
makeup0_lipLayer8Strength = 1.00

function initialize(scene)
	local b = KuruMakeupNodeBuilder.create():useAsianModel(true):mergedResource(true)
	makeup0 = KuruMakeupNode.createWithBuilder(b:build())
	makeup0:setEyeShadowMultiStrength(true)
	scene:addNodeAndRelease(makeup0)
	makeup_param = makeup0:getParam()
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.CONTOUR, BASE_DIRECTORY .. "images/contour.jpg", BlendMode.SoftLight)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.BLUSH, BASE_DIRECTORY .. "images/blush.png", BlendMode.None)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYEBROWS_LAYER1, BASE_DIRECTORY .. "images/eyebrows.png", BlendMode.Multiply)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYE_COLOR, BASE_DIRECTORY .. "images/eye_color_0001", BlendMode.None)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYELASHES, BASE_DIRECTORY .. "images/eyelashes/eyelashes.png", BlendMode.Multiply)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYELINER, BASE_DIRECTORY .. "images/eye_liner/eye_liner.png", BlendMode.Multiply)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYESHADOW_LAYER0, BASE_DIRECTORY .. "images/eye_shadow_L0/eye_shadow_L0.png", BlendMode.Multiply)
	makeup0:setPathAndBlendMode(KuruMakeupNodeType.EYESHADOW_LAYER1, BASE_DIRECTORY .. "images/eye_shadow_L1/eye_shadow_L1.png", BlendMode.Multiply)
	makeup0:addLipLayer(BASE_DIRECTORY .. "images/liplayer.png", BlendMode.None)
	setMakeupParam()
end

function frameReady(scene, elapsedTime)
	setMakeupParam()
end

function setMakeupParam()
	local strength = PropertyConfig.instance():getNumber("stickerSliderValue", 1.0)
	appStrength = (maxStrength - minStrength) * strength + minStrength
	makeup_param.faceContour = contourStrength * appStrength
	makeup_param.cheek = blushStrength * appStrength
	makeup_param.eyeBrowLayer1 = eyeBrowLayer1Strength * appStrength
	makeup_param.colorLens = eyeColorStrength * appStrength
	makeup_param.eyeLashes = eyeLashesStrength * appStrength
	makeup_param.eyeLiner = eyeLineStrength * appStrength
	makeup_param.eyeShadowLayer0 = eyeShadows_L0Strength * appStrength
	makeup_param.eyeShadowLayer1 = eyeShadows_L1Strength * appStrength
	makeup0:setLipLayerStrength(0, makeup0_lipLayer8Strength * appStrength)
end
