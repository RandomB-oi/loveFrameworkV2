local module = {}
module.__index = module
module.__type = "DataModel"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function()
    local self = setmetatable(module.__base.new(module.__type), module)
    self.Services = {}
    return self
end

function module:GetService(name)
    if self.Services[name] then
        return self.Services[name]
    end
    local class = Object.GetClass(name)
    if not (class and class:IsA("Service")) then return end

    self.Services[name] = Object.Create(name, name)
    return self.Services[name]
end

return module:Register()