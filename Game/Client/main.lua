autoLoad("Game/Client/SoftBody")

local InputService = Game:GetService("InputService")

local Viewport = Object.Create("GUIContainer"):SetProperties({
    Parent = Game,
})

local wallThickness = 100
local hugeWallSize = 999999

local stiffness = 50
local damping = 4
local pointMass = 25

local elasticity = 0
local pointCount = 12

local radius = 100

hugeWallSize = hugeWallSize + wallThickness
Object.Create("Wall"):SetProperties({
    Size = UDim2.new(1,0,0,hugeWallSize),
    Position = UDim2.new(0.5,0,0,wallThickness),
    AnchorPoint = Vector.new(0.5, 1),
    Parent = Viewport,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.new(1,0,0,hugeWallSize),
    Position = UDim2.new(0.5,0,1,-wallThickness),
    AnchorPoint = Vector.new(0.5, 0),
    Parent = Viewport,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.new(0,hugeWallSize,1,-wallThickness*2),
    Position = UDim2.new(0,wallThickness,.5,0),
    AnchorPoint = Vector.new(1, .5),
    Parent = Viewport,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.new(0,hugeWallSize,1,-wallThickness*2),
    Position = UDim2.new(1,-wallThickness,.5,0),
    AnchorPoint = Vector.new(0, .5),
    Parent = Viewport,
})


local points = {}

for i = 1, pointCount do
    local a = (i / pointCount) * math.pi * 2
    table.insert(points, Object.Create("Point"):SetProperties({
        Position = UDim2.new(0.5, math.cos(a) * radius, 0.5, math.sin(a) * radius),
        Mass = pointMass,
        Elasticity = elasticity,
        Parent = Viewport,
    }))
end

task.delay(.2, function()
    for i = 1, #points do
        local pointA = points[i]
        for k = i + 1, #points do
            print(i, k)
            local pointB = points[k]
            
            local spring = Object.Create("Spring"):SetProperties({
                PointA = pointA,
                PointB = pointB,
                Parent = Viewport,
                Stiffness = stiffness,
                Damping = damping,
                RestLength = (pointA.RenderPosition - pointB.RenderPosition):Length(),
            })
        end
    end
end)

local mousePoint = Object.Create("Point"):SetProperties({
    Mass = math.huge,
    Parent = Viewport,
})
local mouseSpring = Object.Create("Spring"):SetProperties({
    PointA = mousePoint,
    -- PointB = pointB,
    Parent = Viewport,
    Stiffness = stiffness,
    Damping = damping,
    RestLength = 0,
})

InputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        for i,v in next, points do
            v.Velocity = Vector.zero
        end
    end
end)

task.spawn(function()
    while true do
        local pos = InputService:GetMouseLocation()
        mousePoint:SetProperty("Position", UDim2.new(0, pos.X, 0, pos.Y))
        if InputService:IsMouseButtonPressed(Enum.MouseButton.MouseButton1) then
            if not mouseSpring.PointB then
                local closest, closestDist
                for i, v in next, points do
                    local dist = (v.RenderPosition - pos):Length()
                    if not closestDist or closestDist and dist < closestDist then
                        closest, closestDist = v, dist
                    end
                end
                mouseSpring.PointB = closest
            end
        else
            mouseSpring.PointB = nil
        end
        task.wait()
    end
end)