require "FileIOKit/FileIOKit.lua"

g_fileIOKit = nil
g_ioValueKit = nil
g_ioTextureKit = nil

g_texture = nil
g_table = nil
g_value = nil
g_snapshot = nil

function initialize(scene)
  kuruTouch = KuruTouchExtension.cast(KuruEngine.getInstance():getExtension("KuruTouch"))
  kuruTouch:getTouchDownEvent():addEventHandler(onTouchDown)
  g_textNode = KuruTextNode.createDefault()
  scene:addNodeAndRelease(g_textNode)
   
  
  -- Table type
  g_fileIOKit = FileIOKit.new("text1", FileIODataType.Table)
  
  g_table = g_fileIOKit:read()
  
  print("[script] prev write")
  if (g_table ~= nil) then
    for key, value in pairs(g_table) do
      print("[script]" .. key .. " : " .. value)
    end
  else
    print("[script] : table is nil!")
  end
 
  
  g_fileIOKit:write( { ["a"] = 1, ["b"] = 2 } )

  g_table = g_fileIOKit:read()

  print("[script] after write")
  for key, value in pairs(g_table) do
    print("[script]" .. key .. " : " .. value)
  end


  -- Value type
  g_ioValueKit = FileIOKit.new("text2", FileIODataType.Value)

  g_value = g_ioValueKit:read()
  print("[script] prev value write")

  if (g_value == nil) then
    print("[script] value is nil")
  else
    print("[script] value : " .. g_value)
  end

  g_ioValueKit:write("abc")
  g_value = g_ioValueKit:read()
  print("[script] after value write")
  print("[script] value : " .. g_value)


  -- texture type
  g_snapshot = KuruSnapshotNode.create()
  scene:addNodeAndRelease(g_snapshot)

  g_ioTextureKit = FileIOKit.new("texture", FileIODataType.Texture)

  local texture = g_ioTextureKit:createTextureFromFile()
  if (texture == nil) then
    print("[script] texture is nil")
  else
    print("[script] texture is not nil")
    local bgNode = KuruBackgroundImageNode.createFromTexture(texture, BlendMode.Normal)
    bgNode:setScale(0.5, 0.5, 1.0)
    scene:addNodeAndRelease(bgNode)
    texture:release()
  end
end

function frameReady(scene, elapsedTime)
  g_textNode:moveTo(0.02, 0.02)
  g_textNode:addLine(string.format("Table File path = %s", g_fileIOKit:getFilePath()))
  for key, value in pairs(g_table) do
    g_textNode:addLine(string.format("Table File %s = %s", key, value))
  end
  g_textNode:addLine(string.format("Value File path = %s", g_ioValueKit:getFilePath()))
  g_textNode:addLine(string.format("Value File value = %s", g_value))
  g_textNode:addLine(string.format("Texture File path = %s", g_ioTextureKit:getFilePath()))
end

function finalize(scene)
  kuruTouch:getTouchDownEvent():removeEventHandler(onTouchDown)
end

function onTouchDown(event)
  local texture = g_snapshot:getSampler():getTexture()
  if texture ~= nil then
    g_ioTextureKit:write(texture)
  end
end