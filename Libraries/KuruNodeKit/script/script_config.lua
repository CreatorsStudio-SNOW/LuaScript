require "KuruNodeKit/KuruNodeKit.lua" -- ResTransfer.lua 포함 (사용법은 기존과 동일)

configs = {
  {
     drawType = DrawType.GAUSSIAN_BLUR,
     id = "blur",
  },

}

function initialize(scene)
  -- KuruNodeKit.addNodesFromConfigs(scene, configs)
  --
  -- blur = KuruSnapshotNode.cast(findNode(scene, "blur"))
  -- local drawable = KuruAdjustableGaussianDrawable.cast(blur:getDrawable())
  -- drawable:setStrength(0.5)

  bg1 = KuruNodeKit.createBGNode("mask.png", {
    alpha = 0.5
  })
  scene:addNodeAndRelease(bg1)
end


function frameReady(scene, elapsedTime)
end

function onAspectRatioChanged(scene)
end

function finalize(scene)

end
