local module = {}

module.split = function(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

module.toArray = function(str)
	local list = {}
	for i = 1, str:len() do
		list[i] = str:sub(i,i)
	end
	return list
end

module.getOrder = function(name)
	local order = 0
	for i = 1, name:len() do
		order = order + name:sub(i,i):byte() ^ 3
	end
	return order
end

math.randomseed(os.time())
local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
module.GenerateID = function()
    local guid = template:gsub("[xy]", function(c)
        local r = math.random(0, 15)
        local v = (c == 'x') and r or (r % 4 + 8) -- For 'y', ensure it's 8, 9, A, or B
        return string.format("%x", v)
    end)
    return guid
end


local function tableToString(tbl, oneLine, _alreadyDoneTables, _tabs)
	local alreadyDoneTables = _alreadyDoneTables or {}
	if not next(tbl) then
		return "{}"
	end
	local str = "{\n"
	for index, value in pairs(tbl) do
		local indexString = string.rep("    ", _tabs).."["..module.tostring(index, oneLine, alreadyDoneTables, nil).."]"
		local valueString = module.tostring(value, oneLine, alreadyDoneTables, _tabs)
		
		str = str..indexString.." = "..valueString..",\n"
	end
	str = str..string.rep("    ", _tabs-1).."}"
	if oneLine then
str = str:gsub([[

]], "")
		str = str:gsub("    ", "")
	end
	return str
end

function module.tostring(value, oneLine, _alreadyDoneTables, _tabs)
	_tabs = _tabs or 0
	if _type(value) == "string" then
		return "\""..value.."\""
	elseif _type(value) == "table" then
		-- if value.IsA then
			-- return "\""..value.__tostring(value).."\""
		-- 	return "\""..typeof(value).."\""
		-- end
		
		if value.ToLua then
			return value:ToLua()
		end

		_alreadyDoneTables = _alreadyDoneTables or {}
		if _alreadyDoneTables[value] then
			return "** cyclic table reference **"
		end
		_alreadyDoneTables[value] = true

		return tableToString(value, oneLine, _alreadyDoneTables, _tabs+1)
	else
		return tostring(value)
	end
end


for i,v in pairs(string) do
	if not module[i] then
		module[i] = v
	end
end

local existingGUIDS = {}
function GenerateGUID(length)
	math.randomseed(os.clock() + os.time())
	length = length or 24
	local id = tostring(math.random(0, 10^length))
	id = id .. string.rep("0", length - id:len())

	if existingGUIDS[id] then
		return GenerateGUID(length)
	end
	existingGUIDS[id] = true
	return id
end

return module