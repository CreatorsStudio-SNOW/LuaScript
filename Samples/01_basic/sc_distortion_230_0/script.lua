customUniDist = nil

function initialize(scene)
	EngineStatus.instance():setBoolean("useBuiltInDistortionInScript", true)
	local appDistortion = KuruUniDistortionNode.create()
	scene:addNodeAndRelease(appDistortion)
end
