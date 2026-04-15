local module = {}
module.__index = module
module.__type = "Workspace"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	return self
end


return module:Register()