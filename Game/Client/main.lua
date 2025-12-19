autoLoad("Game/Client/SoftBody")

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

do
    
    local positions = {
 UDim2.fromOffset(-52.02442169189453, 0.4750823974609375),
  UDim2.fromOffset(-67.64302253723145, 15.031890869140625),
  UDim2.fromOffset(-82.95414924621582, 29.30215835571289),
  UDim2.fromOffset(-98.77013206481934, 44.042978286743164),
  UDim2.fromOffset(-114.38873291015625, 58.59978675842285),
  UDim2.fromOffset(-129.39340591430664, 75.55376052856445),
  UDim2.fromOffset(-141.76775932312012, 93.24335098266602),
  UDim2.fromOffset(-149.3015956878662, 104.07735824584961),
  UDim2.fromOffset(-153.0399227142334, 123.83827209472656),
  UDim2.fromOffset(-152.36687660217285, 143.14655303955078),
  UDim2.fromOffset(-147.98566818237305, 157.74126052856445),
  UDim2.fromOffset(-138.11497688293457, 171.67970657348633),
  UDim2.fromOffset(-129.23890113830566, 183.7887954711914),
  UDim2.fromOffset(-117.88532257080078, 193.88078689575195),
  UDim2.fromOffset(-107.57327079772949, 202.81429290771484),
  UDim2.fromOffset(-94.77291107177734, 210.34107208251953),
  UDim2.fromOffset(-74.87887382507324, 212.93279647827148),
  UDim2.fromOffset(-55.17078399658203, 212.93279647827148),
  UDim2.fromOffset(-45.17077445983887, 210.79463958740234),
  UDim2.fromOffset(-34.63656425476074, 203.56225967407227),
  UDim2.fromOffset(-20.49633026123047, 195.6346893310547),
  UDim2.fromOffset(0, 188.68440628051758),
  UDim2.fromOffset(20.49633026123047, 195.6346893310547),
  UDim2.fromOffset(34.63656425476074, 203.56225967407227),
  UDim2.fromOffset(45.17077445983887, 210.79463958740234),
  UDim2.fromOffset(55.17078399658203, 212.93279647827148),
  UDim2.fromOffset(74.87887382507324, 212.93279647827148),
  UDim2.fromOffset(94.77291107177734, 210.34107208251953),
  UDim2.fromOffset(107.58000373840332, 202.81999588012695),
  UDim2.fromOffset(117.88532257080078, 193.88078689575195),
  UDim2.fromOffset(129.23890113830566, 183.7887954711914),
  UDim2.fromOffset(138.11497688293457, 171.67970657348633),
  UDim2.fromOffset(147.98566818237305, 157.74126052856445),
  UDim2.fromOffset(152.36687660217285, 143.14655303955078),
  UDim2.fromOffset(153.0399227142334, 123.83827209472656),
  UDim2.fromOffset(149.3015956878662, 104.07735824584961),
  UDim2.fromOffset(141.76775932312012, 93.24335098266602),
  UDim2.fromOffset(129.39340591430664, 75.55376052856445),
  UDim2.fromOffset(114.38873291015625, 58.59978675842285),
  UDim2.fromOffset(98.77013206481934, 44.042978286743164),
  UDim2.fromOffset(82.95414924621582, 29.30215835571289),
  UDim2.fromOffset(67.64302253723145, 15.031890869140625),
  UDim2.fromOffset(52.02442169189453, 0.4750823974609375),
    }

    local points = {}
    for i, pos in ipairs(positions) do
        local b = Object.Create("Point"):SetProperties({
            Position = pos+UDim2.fromScale(0.5, .2),
            Mass = (i == 1 or i == #positions) and math.huge or (pos.Y.Offset),
            Elasticity = 0,
            Friction = 1,
            Velocity = Vector.xAxis*100,
            Parent = Viewport,
            Simulated = false,
        })
        table.insert(points, b)
    end
    Object.Create("Shape", nil, points, 500, 10):SetProperty("Parent", Viewport)

    task.delay(1, function()
        for _, point in ipairs(points) do
            point:SetProperty("Simulated", true)
        end
    end)
end

-- Object.Create("Shape", nil, CreateCircleShape(UDim2.new(0.7, 0, 0.5, 0), 6, 100, 25, 0, 1), 5, 1):SetProperty("Parent", Viewport)
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
                -- mouseSpring.PointB = closest
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