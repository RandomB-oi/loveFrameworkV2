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
module:CreateProperty("MaxForce", "number", 2000)
module:CreateProperty("RestLength", "number", 100)
module:CreateProperty("Damping", "number", 10)
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    return self
end

local function AddVelocity(point, vel, max)
    local currentVel = point:GetProperty("Velocity")
    local currentLen = currentVel:Length()
    if currentLen > max then return end
    vel = vel:Normalized() * math.min(vel:Length(), max)

    point:SetProperty("Velocity", currentVel + vel)
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


    AddVelocity(a, -force / a:GetProperty("Mass"), self:GetProperty("MaxForce"))
    AddVelocity(b, force / b:GetProperty("Mass"), self:GetProperty("MaxForce"))

    -- local vel = dir * dist * self:GetProperty("Stiffness")/2

    -- AddVelocity(a, -vel)
    -- AddVelocity(b, vel)
end

function module:Draw()
    local a,b = self.PointA, self.PointB
    if not (a and b) then return end
    
    local pa,pb = a.RenderPosition, b.RenderPosition
    if true then
        Color.Yellow:Apply()
        love.graphics.line(pa.X, pa.Y, pb.X, pb.Y)
        return
    end
    local normal = (pa-pb):Normalized()
    normal = Vector.new(-normal.Y, normal.X)

    local springPadding = .1
    local width = 10
    local coils = math.ceil(self:GetProperty("Stiffness")/5)

    local points = {
        pa,
        -- pa:Lerp(pb, springPadding/2)
    }
    for i = 1, coils do
        local alpha = ((i-1)/(coils-1))*(1-springPadding*2)+springPadding
        local p = pa:Lerp(pb, alpha)
        table.insert(points, p + normal * width * (i%2==1 and -1 or 1))
    end
    
    -- table.insert(points, pb:Lerp(pa, springPadding/2))
    table.insert(points, pb)

    Color.White:Apply()
    for i = 1, #points-1 do
        local p1, p2 = points[i], points[i+1]
        love.graphics.line(p1.X, p1.Y, p2.X, p2.Y)
    end
end

return module:Register()