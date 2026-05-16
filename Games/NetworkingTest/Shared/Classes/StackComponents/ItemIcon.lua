local module = {}
module.__index = module
module.__base = require(GamePath.."Shared.Classes.StackComponents.StackComponent")
module.ComponentID = "ItemIcon"
setmetatable(module, module.__base)

module.new = function(iconPath)
    local self = setmetatable(module.__base.new(), module)
    self.IconPath = iconPath

    return self
end

function module:Serialize()
    return self.IconPath
end

function module:CanCombine(other)
    return self.IconPath == other.IconPath
end
module.Same = module.CanCombine

function module:GetPath()
    return self.IconPath
end

return module:Register()