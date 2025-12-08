--[[
This is the base class for all services
These objects are singletons, and can be retrived through the DataModel "Game"
]]

local module = {}
module.__index = module
module.__type = "Service"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:SetDefaultProperyValue("Visible", false)
module:SetDefaultProperyValue("Simulated", false)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    self:SetProperty("Parent", Game)
    return self
end

return module:Register()