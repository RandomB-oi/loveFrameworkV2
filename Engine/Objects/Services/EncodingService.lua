local module = {}
module.__index = module
module.__type = "EncodingService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)

module:CreateProperty("ReplicationEncodingMethod", "EncodingMethod", Enum.EncodingMethod.Json)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	return self
end

local EncodingMethods = {
	[Enum.EncodingMethod.Json] = {
		Encode = function(tbl)
			return json.encode(tbl)
		end,

		Decode = function(str)
			return json.decode(str)
		end,
	},
}

function module:Encode(data, format)
	format = format or self:GetProperty("ReplicationEncodingMethod")
	if not EncodingMethods[format] then return false end

	return true, EncodingMethods[format].Encode(data)
end

function module:Decode(data, format)
	format = format or self:GetProperty("ReplicationEncodingMethod")
	if not EncodingMethods[format] then return false end

	return true, EncodingMethods[format].Decode(data)
end

return module:Register()