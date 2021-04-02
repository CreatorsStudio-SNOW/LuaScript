function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function isOverOrSameVersion(major, minor, patch)
	local appVersion = KuruConfig.instance().appVersion
	-- local appVersion = "7.1"
    local versions = appVersion:split(".")

    if (#versions <= 2) then
    	versions[3] = "0";
    end

    local majorV = tonumber(versions[1])
    local minorV = tonumber(versions[2])
    local patchV = tonumber(versions[3])

    if (majorV == nil or minorV == nil or patchV == nil) then
      return true
    end

    if (majorV * 1000000 + minorV * 1000 + patchV) >= (major * 1000000 + minor * 1000 + patch) then
        return true
    end
    
    return false;
end