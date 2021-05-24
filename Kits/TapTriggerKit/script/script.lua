require "KuruNodeKit/KuruNodeKit.lua"
require "TapTriggerKit/TapTriggerKit.lua"

g_gyroCameraNode = nil
g_particles = {}
g_emitters = {}
g_deviceOrientation = -1

A_PARTICLE_POSITION = {x = -10, y = 100, z = -50}
A_PARTICLE_POSITION_VAR = {x = 30, y = 300, z = 10}
A_PARTICLE_VELOCITY = {x = 3, y = -3, z = 5}

function initialize(scene)
  local originSnap = KuruNodeKit.createSnapshotNode()
  scene:addNodeAndRelease(originSnap)
  g_gyroCameraNode = KuruCameraNode.create(45, 10, 10000)
  scene:addNodeAndRelease(g_gyroCameraNode)

  initParticleNode(scene)

  TapTriggerKit.init(true, 4, updateTap) -- param #1 persistent 여부, param #2 total touchCount, param #3 update callback
  -- scene:addNodeAndRelease(KuruNodeKit.createHeadshotNode("facemask.png", originSnap:getSampler()))
  scene:addNodeAndRelease(KuruNodeKit.createSegmentationNode(originSnap:getSampler()))
  setParticleTexture(TapTriggerKit.getCurrentTouchIndex())
end

function frameReady(scene, elapsedTime)
  local curOri = KuruEngine.getInstance():getCameraConfig().deviceOrientation
  if g_deviceOrientation ~= curOri then
    g_deviceOrientation = curOri
    changeParticleOrientation()
  end
end

function finalize(scene)
  TapTriggerKit.finalize()
end

function updateTap(index, event)
  setParticleTexture(index)
end

function changeParticleOrientation()
  for i = 1, #g_particles do
    local pos = calculateOrientation(A_PARTICLE_POSITION, false)
    local posVar = calculateOrientation(A_PARTICLE_POSITION_VAR, true)
    local velocity = calculateOrientation(A_PARTICLE_VELOCITY, false)

    g_particles[i]:setAngle((g_deviceOrientation + 180) * math.pi / 180)
    g_emitters[i]:setPosition(pos, posVar)
    g_emitters[i]:setVelocity(velocity, g_emitters[i]:getVelocityVariance())
  end
end

function initParticleNode(scene)
  g_particles[1] = KuruParticleNode.create(getFilePath("a.particle"))
  g_particles[1]:setAngle(math.pi)
  g_particles[1]:start()
  g_gyroCameraNode:addChild(g_particles[1])
  g_particles[1]:release()
  g_emitters[1] = ParticleEmitter.cast(g_particles[1]:getParticleEmitter())
  g_emitters[1]:setSize(5, 5, 5, 5)
  g_emitters[1]:setEmissionRate(9)

  g_particles[2] = KuruParticleNode.create(getFilePath("a.particle"))
  g_particles[2]:setAngle(math.pi)
  g_particles[2]:start()
  g_gyroCameraNode:addChild(g_particles[2])
  g_particles[2]:release()
  g_emitters[2] = ParticleEmitter.cast(g_particles[2]:getParticleEmitter())
  g_emitters[2]:setSize(4, 4, 4, 4)
  g_emitters[2]:setEmissionRate(9)

  g_particles[3] = KuruParticleNode.create(getFilePath("a.particle"))
  g_particles[3]:setAngle(math.pi)
  g_particles[3]:start()
  g_gyroCameraNode:addChild(g_particles[3])
  g_particles[3]:release()
  g_emitters[3] = ParticleEmitter.cast(g_particles[3]:getParticleEmitter())
  g_emitters[3]:setSize(3, 3, 3, 3)
  g_emitters[3]:setEmissionRate(11)
end

function setParticleTexture(index)
  local texture = Texture.create(BASE_DIRECTORY .. "emoji_source/" .. index .. ".png", false, false)
  if texture ~= nil then
    for i, v in pairs(g_emitters) do
      v:setTexture(texture, v:getBlendMode())
    end
    texture:release()
  end
end


function calculateOrientation(vec, isVar)
  local retVec = Vector3.create(0.0, 0.0, vec.z)

  if g_deviceOrientation == 0 then
    retVec.x = vec.x
    retVec.y = vec.y
  elseif g_deviceOrientation == 270 then
    retVec.x = vec.y
    retVec.y = isVar and vec.x or - vec.x
  elseif g_deviceOrientation == 180 then
    retVec.x = vec.x
    retVec.y = isVar and vec.y or - vec.y
  else
    retVec.x = isVar and vec.y or - vec.y
    retVec.y = isVar and vec.x or - vec.x
  end

  return retVec
end

function getFilePath(fileName)
  return BASE_DIRECTORY .. fileName
end
