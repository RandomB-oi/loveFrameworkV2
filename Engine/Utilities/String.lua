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