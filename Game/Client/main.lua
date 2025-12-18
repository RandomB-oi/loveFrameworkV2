autoLoad("Game/Client/SoftBody")

local InputService = Game:GetService("InputService")
local RunService = Game:GetService("RunService")

local Viewport = Object.Create("GUIContainer"):SetProperties({
    Parent = Game,
})
local SimContainer = Object.Create("SimulationSubStepContainer"):SetProperties({
    Parent = Viewport,
    DesiredFPS = 100,
})

local wallThickness = 100
local hugeWallSize = 999999


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




Object.Create("Shape", nil, UDim2.new(0.3, 0, 0.5, 0), 10, 100, 25, 0, 5, 1):SetProperty("Parent", Viewport)
Object.Create("Shape", nil, UDim2.new(0.7, 0, 0.5, 0), 10, 100, 25, 0, 5, 1):SetProperty("Parent", Viewport)

local mousePoint = Object.Create("Point"):SetProperties({
    Mass = math.huge,
    Parent = Viewport,
})
local mouseSpring = Object.Create("Spring"):SetProperties({
    PointA = mousePoint,
    -- PointB = pointB,
    Parent = Viewport,
    Stiffness = 100,
    Damping = 2,
    RestLength = 0,
})

InputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        for i,v in next, Object.GetClass("Point").AllPoints do
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
                for i, v in next, Object.GetClass("Point").AllPoints do
                    local dist = (v.RenderPosition - pos):Length()
                    if (not closestDist or closestDist and dist < closestDist) and v ~= mousePoint then
                        closest, closestDist = v, dist
                    end
                end
                print(closest)
                mouseSpring.PointB = closest
                print("set")
            end
        else
            mouseSpring.PointB = nil
            print("remove")
        end
        task.wait()
    end
end)