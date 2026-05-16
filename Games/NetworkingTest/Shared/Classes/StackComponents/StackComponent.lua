local module = {}
module.__index = module
module.ComponentID = "BaseComponent"
module.Components = {}

module.new = function()
    local self = setmetatable({}, module)
    
    return self
end

function module:Same() -- replication purposes
    return true
end

function module:CanCombine(other)
    return true
end

function module:Serialize()
    return
end

function module:Register()
    module.Components[self.ComponentID] = self.new
    return self
end

return module