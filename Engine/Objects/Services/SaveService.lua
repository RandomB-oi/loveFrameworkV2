local module = {}
module.__index = module
module.__type = "SaveService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("Mock", "boolean", false)

function getStr(value, alreadyDoneTables, tabs, oneLine)
	tabs = tabs or 0
	if type(value) == "string" then
		return "\""..value.."\""
	elseif type(value) == "table" then
		if value.IsA then
			-- return "\""..value.__tostring(value).."\""
			return "\""..type(value).."\""
		end
	
		if value.ToLua then
			return value:ToLua()
		end

		alreadyDoneTables = alreadyDoneTables or {}
		if alreadyDoneTables[value] then
			return "** cyclic table reference **"
		end
		alreadyDoneTables[value] = true

		return tableToString(value, alreadyDoneTables, tabs+1, oneLine)
	else
		return tostring(value)
	end
end

function tableToString(tbl, alreadyDoneTables, tabs, oneLine)
	local alreadyDoneTables = alreadyDoneTables or {}
	if not next(tbl) then
		return "{}"
	end
	local str = "{\n"
	for index, value in pairs(tbl) do
		local indexString = string.rep("    ", tabs).."["..getStr(index, alreadyDoneTables, nil, oneLine).."]"
		local valueString = getStr(value, alreadyDoneTables, tabs, oneLine)
		
		str = str..indexString.." = "..valueString..",\n"
	end
	str = str..string.rep("    ", tabs-1).."}"
	if oneLine then
str = str:gsub([[

]], "")
		
		str = str:gsub("    ", "")
	end
	return str
end

function getValue(str)
	if not str then return end
	return loadstring(str)()
end

-- check if a file or directory exists in this path
local function exists(file)
	local ok, err, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			-- permission denied but it exists
			return true
		end
	end
	return ok, err
end

--- Check if a directory exists in this path
local function isdir(path)
   -- "/" works on both Unix and Windows
   return exists(path.."/")
end

local function makeDirectory(path)
	path = path:gsub("/","\\")
	os.execute("mkdir "..path)
end

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self.MockData = {}

	local subPath = Game:GetService("RunService"):IsServer() and "Server" or "Client"
	self.Path = GameDirectory.."SavedData/"..subPath

	return self
end

function module:ReconcileDirectory()
	xpcall(function()
		if not isdir(self.Path) then
			makeDirectory(self.Path)
			love.filesystem.createDirectory(self.Path)
		end
	end, print)
end

function module:GetDirectory(key)
	return self.Path.."/"..key..".lua"
end

function module:IsMock()
	return self:GetProperty("Mock")
end

local function Read(self, key)
end

local function Write(self, key, data)
end

function module:Get(key)
	local data
	if self:IsMock() then
		data = self.MockData[key]
	else
		local fileDirectory = self:GetDirectory(key)

		local file = io.open(fileDirectory, "r")
		if file then
			data = file:read("*all")
			file:close()
		end
	end
	
	return getValue(data)
end

function module:Set(key, data)
	local str = "return "..getStr(data, {})

	if self:IsMock() then
		self.MockData[key] = str
	else
		local fileDirectory = self:GetDirectory(key)
		self:ReconcileDirectory()

		local file = io.open(fileDirectory, "w")
		if file then
			file:write("", str)
			file:close()
		end
	end
end

function module:Update(key, callback)
	self:Set(key, callback(self:Get(key)))
end

return module:Register()