autoLoad(GameDirectory.."Client/SoftBody")

local InputService = Game:GetService("InputService")
local RunService = Game:GetService("RunService")

local SimContainer = Object.Create("SimulationSubStepContainer"):SetProperties({
    DesiredFPS = 200,
    Parent = Game,
})

local Viewport = Object.Create("GUIContainer"):SetProperties({
    Parent = SimContainer,
})

Object.Create("Wall"):SetProperties({
    Size = UDim2.fromScale(1,1),
    Parent = Viewport,
    PointA = Vector.zero,
    PointB = Vector.xAxis,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.fromScale(1,1),
    Parent = Viewport,
    PointA = Vector.zero,
    PointB = Vector.yAxis,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.fromScale(1,1),
    Parent = Viewport,
    PointA = Vector.xAxis,
    PointB = Vector.one,
})
Object.Create("Wall"):SetProperties({
    Size = UDim2.fromScale(1,1),
    Parent = Viewport,
    PointA = Vector.yAxis,
    PointB = Vector.one,
})

-- Object.Create("Wall"):SetProperties({
--     Size = UDim2.fromScale(1,1),
--     Parent = Viewport,
--     PointA = Vector.new(1, .5),
--     PointB = Vector.new(0.5, 1),
-- })


local function CreateCircleShape(origin, pointCount, radius, pointMass, elasticity, friction)
    local points = {}
    for i = 1, pointCount do
        local a = (i / pointCount) * math.pi * 2
        table.insert(points, Object.Create("Point"):SetProperties({
            Position = origin + UDim2.fromOffset(math.cos(a) * radius, math.sin(a) * radius),
            Mass = pointMass,
            Elasticity = elasticity,
            Friction = friction,
            Parent = Viewport
        }))
    end
    return points
end


do
-- local a = Object.Create("Point"):SetProperties({
--     Position = UDim2.fromScale(0.5, 0.5),
--     Mass = math.huge,
--     Elasticity = 0,
--     Friction = 1,
--     Velocity = Vector.xAxis*100,
--     Parent = Viewport
-- })

-- local b = Object.Create("Point"):SetProperties({
--     Position = UDim2.fromScale(0.5, 0.7),
--     Mass = 5,
--     Elasticity = 0,
--     Friction = 1,
--     Velocity = Vector.xAxis*100,
--     Parent = Viewport
-- })

-- local spring = Object.Create("Spring"):SetProperties({
--     PointA = a,
--     PointB = b,
--     Stiffness = 150,
--     Damping = 5,
--     RestLength = 100,
--     Parent = Viewport,
-- })
end

Object.GetClass("Point").Gravity = Vector.zero

Object.Create("Shape", nil, CreateCircleShape(UDim2.new(0.7, 0, 0.5, 0), 10, 100, 25, 0, .5), 2000, 21):SetProperty("Parent", Viewport)
-- Object.Create("Shape", nil, CreateCircleShape(UDim2.new(0.3, 0, 0.5, 0), 10, 100, 25, 0, .5), 1000, 50):SetProperty("Parent", Viewport)
-- Object.Create("Shape", nil, {
--     Object.Create("Point"):SetProperties({
--         Position = UDim2.fromScale(0.7, 0.5) + UDim2.fromOffset(-50, -50),
--         Mass = 100,
--         Elasticity = 0,
--     }),
    
--     Object.Create("Point"):SetProperties({
--         Position = UDim2.fromScale(0.7, 0.5) + UDim2.fromOffset(50, -50),
--         Mass = 25,
--         Elasticity = 0,
--     }),
    
--     Object.Create("Point"):SetProperties({
--         Position = UDim2.fromScale(0.7, 0.5) + UDim2.fromOffset(-50, 50),
--         Mass = 25,
--         Elasticity = 0,
--     }),
    
--     Object.Create("Point"):SetProperties({
--         Position = UDim2.fromScale(0.7, 0.5) + UDim2.fromOffset(50, 50),
--         Mass = 25,
--         Elasticity = 0,
--     }),
-- }, 100, 5):SetProperty("Parent", Viewport)

local mousePoint = Object.Create("Point"):SetProperties({
    Mass = math.huge,
    Parent = Viewport,
})

local mouseMaid

InputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.R then
        for i,v in next, Object.GetClass("Point").AllPoints do
            v.Velocity = Vector.zero
        end
    elseif input.KeyCode == Enum.KeyCode.Space then
        SimContainer:SetProperty("Simulated", not SimContainer:GetProperty("Simulated"))
    end
end)

task.spawn(function()
    while true do
        local pos = InputService:GetMouseLocation()
        mousePoint:SetProperty("Position", UDim2.new(0, pos.X, 0, pos.Y))
        -- if shape1.Lines[1] then
        --     print(shape1.Lines[1]:GetSide(pos))
        -- end
        if InputService:IsMouseButtonPressed(Enum.MouseButton.MouseButton1) then
            if not mouseMaid then
                mouseMaid = Maid.new()
                
                for i, v in next, Object.GetClass("Point").AllPoints do
                    local dist = (v.RenderPosition - pos):Length()
                    if (dist < 100) and v ~= mousePoint then
                        mouseMaid:Add(Object.Create("Spring")):SetProperties({
                            PointA = mousePoint,
                            PointB = v,
                            Parent = Viewport,
                            Stiffness = 5000,
                            Damping = 2,
                            RestLength = 0,
                        })
                    end
                end

                -- local closest, closestDist
                -- for i, v in next, Object.GetClass("Point").AllPoints do
                --     local dist = (v.RenderPosition - pos):Length()
                --     if (not closestDist or closestDist and dist < closestDist) and v ~= mousePoint then
                --         closest, closestDist = v, dist
                --     end
                -- end
                -- if closest then
                --     mouseMaid:Add(Object.Create("Spring")):SetProperties({
                --         PointA = mousePoint,
                --         PointB = closest,
                --         Parent = Viewport,
                --         Stiffness = 5000,
                --         Damping = 2,
                --         RestLength = 0,
                --     })
                -- end
            end
        else
            if mouseMaid then
                print"delete"
                mouseMaid:Destroy()
                mouseMaid = nil
            end
        end
        task.wait()
    end
end)