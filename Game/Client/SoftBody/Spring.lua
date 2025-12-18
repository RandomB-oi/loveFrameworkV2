local module = {}
module.__index = module
module.__type = "Spring"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/SpringConstraint.png"
module.ClassProperties = module.__base:CopyProperties()
module:CreateProperty("PointA", "Object", nil)
module:CreateProperty("PointB", "Object", nil)
module:CreateProperty("Stiffness", "number", 5)
module:CreateProperty("RestLength", "number", 100)
module:CreateProperty("Damping", "number", 10)
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    return self
end

local function AddVelocity(point, vel)
    point:SetProperty("Velocity", point:GetProperty("Velocity") + vel)
end

function module:Update(dt)
    module.__base.Update(self, dt)

    local a,b = self.PointA, self.PointB
    if not (a and b) then return end

    local delta = b.RenderPosition - a.RenderPosition
    local distance = delta:Length()
    if distance <= 0.001 then
        distance = 0.01
        delta = Vector.xAxis*distance
    end
    local direction = delta/distance

    local relativeVelocity = b:GetProperty("Velocity") - a:GetProperty("Velocity")
    local velAlongSpring = relativeVelocity:Dot(direction)

    local springForce = -self:GetProperty("Stiffness") * (distance - self:GetProperty("RestLength"))
    local dampingForce = -self:GetProperty("Damping") * velAlongSpring

    local forceMagnitude = springForce + dampingForce
    local force = direction * forceMagnitude


    AddVelocity(a, -force / a:GetProperty("Mass"))
    AddVelocity(b, force / b:GetProperty("Mass"))










    -- local vel = dir * dist * self:GetProperty("Stiffness")/2

    -- AddVelocity(a, -vel)
    -- AddVelocity(b, vel)
end

function module:Draw()
    local a,b = self.PointA, self.PointB
    if not (a and b) then return end
    
    local pa,pb = a.RenderPosition, b.RenderPosition

    Color.White:Apply()
    love.graphics.line(pa.X, pa.Y, pb.X, pb.Y)
end

return module:Register()