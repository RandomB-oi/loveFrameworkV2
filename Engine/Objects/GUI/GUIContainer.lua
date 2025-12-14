local module = {}
module.__index = module
module.__type = "GUIContainer"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/ScreenGui.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    self.RenderSize = Vector.zero
    self.RenderPosition = Vector.zero

    return self
end

function module:IsVisible()
    return self:GetProperty("Visible")
end

function module:GetTransform()
    local parent = self:GetProperty("Parent")
    while parent do
        if parent.RenderSize and parent.RenderPosition then
            return parent.RenderSize, parent.RenderPosition
        end
        parent = parent:GetProperty("Parent")
    end
    
    local screenSize = Vector.new(love.graphics.getDimensions())
    local origin = Vector.zero
    return screenSize, origin
end

function module:UpdateSize()
    local newSize, newPos = self:GetTransform()

    local prevSize = self.RenderSize
    local prevPos = self.RenderPosition

    if prevSize ~= newSize or prevPos ~= newPos then
        self.RenderSize = newSize
        self.RenderPosition = newPos
        return true
    end
end

function module:UpdateChildren()
    for _, child in ipairs(self:GetChildren()) do
        if child:IsA("Frame") then
            child:UpdateRenderProperties(self.RenderPosition, self.RenderSize)
        end
    end
end

function module:Update(dt)
    if self:UpdateSize() then
       self:UpdateChildren()
    end
end

-- function module:Draw()
--     love.graphics.circle("fill", (math.cos(os.clock())/2+0.5)*800, (math.sin(os.clock())/2+0.5)*600, 10)
-- end

return module:Register()