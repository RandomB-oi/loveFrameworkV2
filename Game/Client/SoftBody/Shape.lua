local module = {}
module.__index = module
module.__type = "Shape"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/SpringConstraint.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(id, origin, pointCount, radius, pointMass, elasticity, stiffness, damping)
    local self = setmetatable(module.__base.new(id), module)
    self.Points = {}
    self.Springs = {}

    for i = 1, pointCount do
        local a = (i / pointCount) * math.pi * 2
        table.insert(self.Points, self.Maid:Add(Object.Create("Point")):SetProperties({
            Position = origin + UDim2.fromOffset(math.cos(a) * radius, math.sin(a) * radius),
            Mass = pointMass,
            Elasticity = elasticity,
            Parent = self:GetProperty("Parent"),
        }))
    end

    task.delay(.2, function()
        for i = 1, #self.Points do
            local pointA = self.Points[i]
            for k = i + 1, #self.Points do
                local pointB = self.Points[k]
                
                table.insert(self.Springs, self.Maid:Add(Object.Create("Spring")):SetProperties({
                    PointA = pointA,
                    PointB = pointB,
                    Parent = self:GetProperty("Parent"),
                    Stiffness = stiffness,
                    Damping = damping,
                    RestLength = (pointA.RenderPosition - pointB.RenderPosition):Length(),
                }))
            end
        end
    end)

    self:BindToProperty("Parent", function()
        for _, list in next, {self.Points, self.Springs} do
            for _, node in next, list do
                node:SetProperty("Parent", self:GetProperty("Parent"))
            end
        end
    end)

    return self
end

function module:Draw()
    Color.White:Apply()

    -- local len = #self.Points
    -- for i = 1, len-2, 2 do
    --     local a,b,c = self.Points[i].RenderPosition, self.Points[i+1].RenderPosition, self.Points[i+2].RenderPosition
    --     love.graphics.polygon("fill", a, b, c)
    -- end
end

return module:Register()