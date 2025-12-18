local module = {}
module.__index = module
module.__type = "Wall"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Frame.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.AllWalls = {}

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    module.AllWalls[self.ID] = self
    self.Maid:GiveTask(function()
        module.AllWalls[self.ID] = nil
    end)
    return self
end

function module:Draw()
    module.__base.Draw(self)
    Color.Red:Apply()
    love.graphics.rectangle("line", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)
end

return module:Register()