local module = {}
module.__index = module
module.__type = "Shape"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/SpringConstraint.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.AllShapes = {}

module.new = function(id, points, stiffness, damping)
    local self = setmetatable(module.__base.new(id), module)
    self.Points = points
    self.Springs = {}
    self.Lines = {}

    self.PointLookup = {}
    self.WallLookup = {}
    self.SpringLookup = {}

    module.AllShapes[self.ID] = self
    self.Maid:GiveTask(function()
        module.AllShapes[self.ID] = nil
    end)

    task.delay(.1, function()
        for i = 1, #self.Points do
            local pointA = self.Maid:Add(self.Points[i])
            self.PointLookup[pointA.ID] = pointA

            local wall = self.Maid:Add(Object.Create("Wall")):SetProperties({
                Position = UDim2.fromScale(0,0),
                Size = UDim2.fromOffset(1,1),
                AnchorPoint = Vector.zero,
                Color = Color.Blank,
                Parent = self:GetProperty("Parent"),
            })
            self.WallLookup[wall.ID] = wall
            table.insert(self.Lines, wall)

            for k = i + 1, #self.Points do
                local pointB = self.Points[k]
                
                local spring = self.Maid:Add(Object.Create("Spring")):SetProperties({
                    PointA = pointA,
                    PointB = pointB,
                    Parent = self:GetProperty("Parent"),
                    Stiffness = stiffness,
                    Damping = damping,
                    Visible = false,
                    RestLength = (pointA.RenderPosition - pointB.RenderPosition):Length(),
                })
                self.SpringLookup[spring.ID] = spring
                table.insert(self.Springs, spring)
            end
        end
    end)

    self:BindToProperty("Parent", function()
        for _, list in next, {self.Points, self.Springs, self.Lines} do
            for _, node in next, list do
                node:SetProperty("Parent", self:GetProperty("Parent"))
            end
        end
    end)

    return self
end

function module.GetShapeFromPoint(point)
    for _, shape in next, module.AllShapes do
        if shape.PointLookup[point.ID] then
            return shape
        end
    end
end
function module.GetShapeFromWall(wall)
    for _, shape in next, module.AllShapes do
        if shape.WallLookup[wall.ID] then
            return shape
        end
    end
end

function module:PointIsPartOfShape(point)
    return not not self.PointLookup[point.ID]
end

function module:Update(dt)
    local total = #self.Lines
    for i = 1, total do
        local wall = self.Lines[i]

        local point1 = self.Points[i]
        local point2 = self.Points[i%total+1]

        wall:SetProperties({
            PointA = point1.RenderPosition,
            PointB = point2.RenderPosition,
        })
    end
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