local module = {}
module.__index = module
module.__type = "Player"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("UserID", "string", "0")
module:CreateProperty("Character", "Object", nil)

module.new = function(id)
    local self = setmetatable(module.__base.new(id), module)
    self:SetProperty("UserID", id)

    return self
end

function module:LoadCharacter()
    local char = self:GetProperty("Character")
    if char then
        char:Destroy()
        self:SetProperty("Character", nil)
    end

    
end

return module:Register()