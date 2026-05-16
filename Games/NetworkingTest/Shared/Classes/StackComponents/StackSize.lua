local module = {}
module.__index = module
module.__base = require(GamePath.."Shared.Classes.StackComponents.StackComponent")
module.ComponentID = "StackSize"
setmetatable(module, module.__base)

module.new = function(amount)
    local self = setmetatable(module.__base.new(), module)
    self.MaxAmount = amount

    return self
end

function module:Serialize()
    return self.MaxAmount
end

function module:CanCombine(other)
    return self.MaxAmount == other.MaxAmount
end
module.Same = module.CanCombine

function module:GetStackSize()
    return self.MaxAmount
end

return module:Register()