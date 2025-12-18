local module = {}
module.__index = module
module.__type = "Point"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Frame.png"
module.ClassProperties = module.__base:CopyProperties()
module:CreateProperty("Velocity", "Vector", Vector.zero)
module:CreateProperty("Mass", "number", 1)
module:CreateProperty("Elasticity", "number", 1)
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Size", UDim2.new(0,10,0,10))
module:SetDefaultProperyValue("AnchorPoint", Vector.zero)

local WallClass = require("Game.Client.SoftBody.Wall")
module.Gravity = Vector.zero
module.Gravity = Vector.yAxis*250

local function Colliding(wall, point)
    local position, size = wall.RenderPosition, wall.RenderSize
    local max = position + size

    return point.X > position.X and point.Y > position.Y and point.X < max.X and point.Y < max.Y
end
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

    local position = self.RenderPosition
    local velocity = self:GetProperty("Velocity")

    
    for id, wall in next, WallClass.AllWalls do
        if Colliding(wall, position + velocity*Vector.xAxis * dt) then
            velocity = Vector.new(velocity.X * -self:GetProperty("Elasticity"), velocity.Y)
        end
        if Colliding(wall, position + velocity*Vector.yAxis * dt) then
            velocity = Vector.new(velocity.X, velocity.Y * -self:GetProperty("Elasticity"))
        end
    end
    
    local newPosition = position + velocity * dt
    local newVelocity = velocity + module.Gravity * dt

    self:SetProperty("Position", UDim2.fromOffset(newPosition.X, newPosition.Y))
    self:SetProperty("Velocity", newVelocity)
end

function module:Draw()
    local backgroundColor = self:GetProperty("BackgroundColor")
    if backgroundColor.A > 0 then
        backgroundColor:Apply()
        love.graphics.circle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X/2)

        Color.Red:Apply()
        local velocity = self.RenderPosition + self:GetProperty("Velocity")
        love.graphics.line(self.RenderPosition.X, self.RenderPosition.Y, velocity.X, velocity.Y)
    end
end

return module:Register()