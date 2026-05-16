local module = {}
module.__index = module
module.__base = require(GamePath.."Shared.Classes.StackComponents.StackComponent")
module.ComponentID = "Unique"
setmetatable(module, module.__base)

module.new = function()
    local self = setmetatable(module.__base.new(), module)

    return self
end

function module:CanCombine(other)
    return false
end
function module:Same(other)
    return true
end

return module:Register()