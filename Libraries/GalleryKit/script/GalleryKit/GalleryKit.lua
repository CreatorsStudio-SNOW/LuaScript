require "GalleryKit/type.lua"
require "JSON/json.lua"

-- last date : 190313 
-- developer : Minhwan Ho

GalleryKit = {}
GalleryKit.EVENT_NAME_RECEIVE_PHOTO = "setScriptPhotos"
GalleryKit.EVENT_NAME_GET_PHOTO_FROM_GALLERY = "getAppPhotos"
GalleryKit.eventExtension = nil
GalleryKit.typeState = nil
GalleryKit.lastSingleIndex = 1
GalleryKit.imageStates = {}

GalleryKit.addCallback = nil
GalleryKit.replaceCallback = nil
GalleryKit.removeCallback = nil

function GalleryKit.init(maxCount, maxSize, addCallback, replaceCallback, removeCallback)
  print("### GalleryKit.init ###")
  GalleryKit.maxCount = maxCount
  GalleryKit.maxSize = maxSize
  if addCallback ~= nil then GalleryKit.addCallback = addCallback end
  if replaceCallback ~= nil then GalleryKit.replaceCallback = replaceCallback end
  if removeCallback ~= nil then GalleryKit.removeCallback = removeCallback end
  GalleryKit.eventExtension = KuruEventExtension.cast(KuruEngine.getInstance():getExtension("KuruEvent"))
  GalleryKit.eventExtension:getSimpleEvent():addEventHandler(GalleryKit.onSimpleEvent)
  for i= 1, #GalleryKit.imageStates do
    local key = tostring(i)
    table.removeKey(GalleryKit.imageStates, key)
  end
end

function GalleryKit.clear()
  for i= 1, #GalleryKit.imageStates do
    local key = tostring(i)
    table.removeKey(GalleryKit.imageStates, key)
  end
end

function GalleryKit.onSimpleEvent(event)
  local eventObj = KuruEventExtensionSimpleEventArgs.cast(event)
  if eventObj:getName() ~= GalleryKit.EVENT_NAME_RECEIVE_PHOTO then
    return
  end

  local args = eventObj:getArg()
  GalleryKit.updateImageStates(args)
end


function GalleryKit.updateImageStates(state)
  print("### GalleryKit.updateImageStates ###")
  local newStates = {}
  local jsonObject = json.decode(state)
  local methodType = jsonObject[Method.TYPE]
  local methodId = jsonObject[Method.ID]
  local photoArray = jsonObject[Method.PHOTO]

  for i=1, #photoArray do
    local key = tostring(photoArray[i][Photos.INDEX])
    -- newStates[key] = { Photos.INDEX = photoArray[i][Photos.INDEX], Photos.TEXTURE_ID = photoArray[i][Photos.TEXTURE_ID], Photos.PHOTO_ID = photoArray[i][Photos.PHOTO_ID]}
    newStates[key] = {}
    newStates[key][Photos.INDEX] = photoArray[i][Photos.INDEX]
    newStates[key][Photos.TEXTURE_ID] = photoArray[i][Photos.TEXTURE_ID]
    newStates[key][Photos.PHOTO_ID] = photoArray[i][Photos.PHOTO_ID]
    newStates[key][Photos.WIDTH] = photoArray[i][Photos.WIDTH]
    newStates[key][Photos.HEIGHT] = photoArray[i][Photos.HEIGHT]
  end

  if GalleryKit.typeState == TypeState.SINGLE then
    print("###### Single update")
    if tablelength(newStates) == 1 then
      for k,v in pairs(newStates) do
        if GalleryKit.imageStates[k] == nil then
          GalleryKit.addImageStates(v[Photos.INDEX], v[Photos.PHOTO_ID], v[Photos.TEXTURE_ID], v[Photos.WIDTH], v[Photos.HEIGHT])
        elseif GalleryKit.imageStates[k][Photos.PHOTO_ID] ~= v[Photos.PHOTO_ID] then
          GalleryKit.replaceImageStates(v[Photos.INDEX], v[Photos.PHOTO_ID], v[Photos.TEXTURE_ID], v[Photos.WIDTH], v[Photos.HEIGHT])
        end
      end
    else
      GalleryKit.removeImageStates(GalleryKit.lastSingleIndex)
    end
    return
  end
  print("###### multi update")
  for k,v in pairs(GalleryKit.imageStates) do
    if newStates[k] == nil then
      GalleryKit.removeImageStates(v[Photos.INDEX])
    end
  end

  for k,v in pairs(newStates) do
    if GalleryKit.imageStates[k] == nil then
      print(tostring(k).." is nil")
      GalleryKit.addImageStates(v[Photos.INDEX], v[Photos.PHOTO_ID], v[Photos.TEXTURE_ID], v[Photos.WIDTH], v[Photos.HEIGHT])
    else
      print(tostring(k).." is not nil")
      print("not null new state "..tostring(k).. ", pid " ..tostring(v[Photos.PHOTO_ID]) .. ", index " .. v[Photos.INDEX] .." tId "..tostring(v[Photos.TEXTURE_ID]))
      print("not null before state "..tostring(k).. ", pid " ..tostring( GalleryKit.imageStates[k][Photos.PHOTO_ID]) .. ", index " ..  GalleryKit.imageStates[k][Photos.INDEX] .." tId "..tostring( GalleryKit.imageStates[k][Photos.TEXTURE_ID]))
      if GalleryKit.imageStates[k][Photos.PHOTO_ID] ~= v[Photos.PHOTO_ID] then
        print(" need replace : "..tostring(k) .. ", " ..tostring(v[Photos.INDEX]))
        GalleryKit.replaceImageStates(v[Photos.INDEX], v[Photos.PHOTO_ID], v[Photos.TEXTURE_ID], v[Photos.WIDTH], v[Photos.HEIGHT])
      end
    end
  end
  print("GalleryKit.updateImageStates imageStates size : "..tablelength(GalleryKit.imageStates))
end

function GalleryKit.addImageStates(idx, pId, tId, width, height)
  print("GalleryKit.addImageStates "..tostring(idx).. ", pid " ..tostring(pId) .. ", tId " .. tostring(tId) ..", width "..tostring(width).. ", height "..tostring(height))
  local i = tostring(idx)
  GalleryKit.imageStates[i] = {}
  GalleryKit.imageStates[i][Photos.INDEX] = idx
  GalleryKit.imageStates[i][Photos.PHOTO_ID] = pId
  GalleryKit.imageStates[i][Photos.TEXTURE_ID] = tId
  GalleryKit.imageStates[i][Photos.WIDTH] = width
  GalleryKit.imageStates[i][Photos.HEIGHT] = height
  if GalleryKit.addCallback ~= nil then
    GalleryKit.addCallback(idx, tId, width, height)
  end
end


function GalleryKit.replaceImageStates(idx, pId, tId, width, height)
  print("GalleryKit.replaceImageStates "..tostring(idx).. ", pid " ..tostring(pId) .. ", tId " .. tostring(tId) ..", width "..tostring(width).. ", height "..tostring(height))
  local i = tostring(idx)
  GalleryKit.imageStates[i][Photos.INDEX] = idx
  GalleryKit.imageStates[i][Photos.PHOTO_ID] = pId
  GalleryKit.imageStates[i][Photos.TEXTURE_ID] = tId
  GalleryKit.imageStates[i][Photos.WIDTH] = width
  GalleryKit.imageStates[i][Photos.HEIGHT] = height
  if GalleryKit.replaceCallback ~= nil then
    GalleryKit.replaceCallback(idx, tId, width, height)
  elseif GalleryKit.addCallback ~= nil then
    GalleryKit.addCallback(idx, tId, width, height)
  end
end

function GalleryKit.removeImageStates(idx)
  print("GalleryKit.removeImageStates "..tostring(idx))
  local i = tostring(idx)
  table.removeKey(GalleryKit.imageStates, i)
  GalleryKit.imageStates[i] = nil
  print("GalleryKit table length ".. tostring(tablelength(GalleryKit.imageStates)))
  if GalleryKit.removeCallback ~= nil then
    GalleryKit.removeCallback(idx)
  end
end

function GalleryKit.encodeImageStates(type, id)
  print("###### GalleryKit.encodeImageStates")
  local request = {}
  local selectedPhoto = {}
  local count = 1

  if type == Answer.GET_MULTI then
    GalleryKit.typeState = TypeState.MULTI
    for k,v in pairs(GalleryKit.imageStates) do
      selectedPhoto[count] = {}
      selectedPhoto[count][Photos.INDEX] = v[Photos.INDEX]
      selectedPhoto[count][Photos.PHOTO_ID] = v[Photos.PHOTO_ID]
      selectedPhoto[count][Photos.TEXTURE_ID] = v[Photos.TEXTURE_ID]
      count = count + 1
    end
    request[Method.TYPE] = Answer.GET_MULTI
    request[Method.MAX_PHOTO_COUNT] = GalleryKit.maxCount
  else
    GalleryKit.typeState = TypeState.SINGLE
    selectedPhoto[1] = {}
    selectedPhoto[1][Photos.INDEX] = id
    GalleryKit.lastSingleIndex = id
    local selectedObj = GalleryKit.imageStates[tostring(id)]
    if selectedObj ~= nil then
      selectedPhoto[1][Photos.PHOTO_ID] = selectedObj[Photos.PHOTO_ID]
      selectedPhoto[1][Photos.TEXTURE_ID] = selectedObj[Photos.TEXTURE_ID]
    end
    -- selectedPhoto[1][Photos.PHOTO_ID] = v[Photos.PHOTO_ID]
    -- selectedPhoto[1][Photos.TEXTURE_ID] = v[Photos.TEXTURE_ID]

    request[Method.TYPE] = Answer.GET_SINGLE
    request[Method.MAX_PHOTO_COUNT] = 1
  end
  request[Method.ID] = "gallery_multi_id"
  request[Method.SELECTED_PHOTO] = selectedPhoto

  request[Method.MAX_PHOTO_SIZE] = GalleryKit.maxSize
  local jsonString = json.encode(request)
  print(jsonString)
  return jsonString
end

function GalleryKit.requestToApp(type, id)
  local args = GalleryKit.encodeImageStates(type, id)
  GalleryKit.eventExtension:postSimpleEventToApp(GalleryKit.EVENT_NAME_GET_PHOTO_FROM_GALLERY, args)
end

function GalleryKit.getImageCount()
  local length = tablelength(GalleryKit.imageStates)
  print("image count is : "..tostring(length))
  return length
end

function GalleryKit.finalize()
  GalleryKit.eventExtension:getSimpleEvent():removeEventHandler(GalleryKit.onSimpleEvent)
end

function table.removeKey(t, k)
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local a = {}
	for i = 1,#keys do
		a[keys[i]] = values[i]
	end

	return a
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
