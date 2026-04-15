autoLoad(GameDirectory.."Client/Physics")

local InputService = Game:GetService("InputService")
local RunService = Game:GetService("RunService")

local SimContainer = Object.Create("SimulationSubStepContainer"):SetProperties({
    DesiredFPS = 200,
    Parent = Game,
})

local Viewport = Object.Create("GUIContainer"):SetProperties({
    Parent = SimContainer,
})

local wall = Object.Create("Wall"):SetProperties({
    Parent = Viewport,
    PointA = Object.Create("Point"):SetProperties({
        Position = Vector.new(100, 100),
        Mass = math.huge,
    }),
    PointB = Object.Create("Point"):SetProperties({
        Position = Vector.new(400, 400),
        Mass = math.huge,
    }),
})
wall.PointA:SetParent(wall)
wall.PointB:SetParent(wall)

local fallingPoint = Object.Create("Point"):SetProperties({
    Position = Vector.new(300, 0),
    Parent = Viewport,
    -- Mass = math.huge,
})

-- Object.GetClass("Point").Gravity = Vector.zero

task.spawn(function()
    while task.wait() do
        local pos = InputService:GetMouseLocation()
        print(wall:PointColliding(pos))
    end
end)