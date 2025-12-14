local InputService = Game:GetService("InputService")

-- Inpu-tService.InputBegan:Connect(function(input)
--     for i,v in next, input do
--         print(i,v)
--     end
-- end)

local Viewport = Object.Create("GUIContainer"):SetProperties({
    Parent = Game,
})
local guiMainFrame = Object.Create("Frame"):SetProperties({
    Size = UDim2.new(0.5, 0, 0.5, 0),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector.one/2,
    BackgroundColor = Color.new(1,1,1,.5),
    Parent = Viewport,
})

local folderParent = guiMainFrame
for i = 1, 3 do
    folderParent = Object.Create("Folder"):SetProperties({
        Name = "Folder"..tostring(i),
        Parent = folderParent,
    })
end

local guiMain = Object.Create("GUIContainer"):SetProperties({
    Parent = folderParent,
})


local a = Object.Create("Frame"):SetProperties({
    Size = UDim2.new(0,300,0,100),
    BackgroundColor = Color.new(1,0,1,1),
    Parent = guiMain,
})

Object.Create("UIScale"):SetProperties({
    Scale = 2,
    Parent = a,
})

Object.Create("UIAspectRatioConstraint"):SetProperties({
    AspectRatio = 2,
    Parent = a,
})

Object.Create("UISizeConstraint"):SetProperties({
    Max = Vector.new(100,math.huge),
    Parent = a,
})

Object.Create("Frame"):SetProperties({
    Parent = guiMain,
    Size = UDim2.new(0,50,0,100),
    BackgroundColor = Color.new(1,1,0,1),
})

Object.Create("UIListLayout"):SetProperties({
    Parent = guiMain,
})


Object.Create("UIPadding"):SetProperties({
    Parent = a,
    PaddingLeft = UDim.new(0,6),
    PaddingRight = UDim.new(0,6),
    PaddingTop = UDim.new(0,6),
    PaddingBottom = UDim.new(0,6),
})

Object.Create("Frame"):SetProperties({
    Parent = a,
    Size = UDim2.new(1,0,1,0),
    BackgroundColor = Color.new(1,0,1,1),
})

task.spawn(function()
    while task.wait() do
        a.BackgroundColor = Color.new(math.sin(os.clock())/2+0.5, 1, 1, 1)
    end
end)