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
module:CreateProperty("Friction", "number", 1)
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Size", UDim2.new(0,10,0,10))
module:SetDefaultProperyValue("AnchorPoint", Vector.zero)

local WallClass = require("Game.Client.SoftBody.Wall")
module.Gravity = Vector.zero
module.Gravity = Vector.yAxis*300

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

    local shapeClass = Object.GetClass("Shape")
    
    local selfShape = shapeClass.GetShapeFromPoint(self)
    for id, wall in next, WallClass.AllWalls do
        local wallShape = shapeClass.GetShapeFromWall(wall)

        if selfShape and wallShape ~= selfShape or not selfShape then
            local castPoint = wall:Cast(position, velocity * dt)
            if castPoint then
                local normal = wall:GetNormal(position)
                local elasticity = self:GetProperty("Elasticity") or 0
                local friction = self:GetProperty("Friction") or 0

                -- Split velocity
                local vn = normal * velocity:Dot(normal)   -- normal component
                local vt = velocity - vn                    -- tangent component

                -- Apply elasticity and friction
                vn = -vn * elasticity
                vt = vt * (1 - friction)

                -- Update velocity only, do NOT set position
                velocity = vn + vt


                break
            end
        end
    end

    
    position = position + velocity * dt
    velocity = velocity + module.Gravity * dt

    self:SetProperty("Position", UDim2.fromOffset(position.X, position.Y))
    self:SetProperty("Velocity", velocity)
end

--[[
function module:Update(dt)
    module.__base.Update(self, dt)

    if self:GetProperty("Mass") >= math.huge then
        return
    end

    local position = self.RenderPosition
    local velocity = self:GetProperty("Velocity")

    local shapeClass = Object.GetClass("Shape")
    
    local selfShape = shapeClass.GetShapeFromPoint(self)
    for id, wall in next, WallClass.AllWalls do
        local wallShape = shapeClass.GetShapeFromWall(wall)
        
        if wallShape ~= selfShape then
            local castPoint = wall:Cast(position, velocity*dt)
            if castPoint then
                -- do friction and elasticity
                velocity = velocity.zero
                break
            end
        end
    end
    
    position = position + velocity * dt
    velocity = velocity + module.Gravity * dt

    self:SetProperty("Position", UDim2.fromOffset(position.X, position.Y))
    self:SetProperty("Velocity", velocity)
end
-- ]]
function module:Draw()
    local backgroundColor = self:GetProperty("BackgroundColor")
    if backgroundColor.A > 0 then
        -- backgroundColor:Apply()
        -- love.graphics.circle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X/2)

        -- Color.Red:Apply()
        -- local velocity = self.RenderPosition + self:GetProperty("Velocity")
        -- love.graphics.line(self.RenderPosition.X, self.RenderPosition.Y, velocity.X, velocity.Y)
    end
end

return module:Register()