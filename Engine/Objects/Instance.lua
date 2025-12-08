local module = {}
module.__index = module
module.__type = "Instance"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("IntValue", "number", 5, "Int")

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    return self
end

return module:Register()