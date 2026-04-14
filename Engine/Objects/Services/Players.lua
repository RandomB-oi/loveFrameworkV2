local module = {}
module.__index = module
module.__type = "Players"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	return self
end

function module:GetPlayers()
	local list = {}
	for _, v in next, self:GetChildren() do
		table.insert(list, v)
	end
	return list
end

return module:Register()