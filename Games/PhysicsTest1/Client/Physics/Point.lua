local module = {}
module.__index = module
module.__type = "Point"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Frame.png"
module.ClassProperties = module.__base:CopyProperties()
module:CreateProperty("Velocity", "Vector", Vector.zero)
module:CreateProperty("Mass", "number", 1)
module:CreateProperty("Elasticity", "number", 1)
module:CreateProperty("Friction", "number", 1)
module:CreateProperty("Position", Vector.zero)
module:SetDefaultProperyValue("Name", module.__type)

-- local WallClass = require(GamePath.."Client.SoftBody.Wall")
module.Gravity = Vector.zero
module.Gravity = Vector.yAxis/3

module.AllPoints = {}

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    module.AllPoints[self.ID] = self
    self.Maid:GiveTask(function()
        module.AllPoints[self.ID] = nil
    end)
    return self
end

function module:Update(dt)
    module.__base.Update(self, dt)

    if self:GetProperty("Mass") >= math.huge then
        return
    end

    local position = self:GetProperty("Position")
    local velocity = self:GetProperty("Velocity")

    -- collision stuff
    local wallClass = Object.GetClass("Wall")
    for _, wall in next, wallClass.AllWalls do
        if wall.PointA == self or wall.PointB == self then goto continue end

        if not wall:PointColliding(position) and wall:PointColliding(position + velocity * dt) then
            print("will collide")
            break
        end
        ::continue::
    end

    position = position + velocity * dt
    velocity = velocity + module.Gravity * dt

    self:SetProperty("Position", position)
    self:SetProperty("Velocity", velocity)
end

function module:Draw()
    local backgroundColor = self:GetProperty("BackgroundColor")
    if backgroundColor.A > 0 then
        local position = self:GetProperty("Position")
        local radius = 5
        backgroundColor:Apply()
        love.graphics.circle("fill", position.X, position.Y, radius)

        Color.Red:Apply()
        local velocity = position + self:GetProperty("Velocity"):Normalized()*100
        love.graphics.line(position.X, position.Y, velocity.X, velocity.Y)
    end
end

return module:Register()