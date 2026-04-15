local MainRender = Object.Create("GUIContainer"):SetProperties({
    Name = "MainRender",
    Parent = workspace,
})

local Holder = Object.Create("Frame"):SetProperties({
    Name = "Holder",
    Size = UDim2.fromScale(1,1),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.new(1,0,0,.05),
    Parent = MainRender,
})

Object.Create("UIAspectRatioConstraint"):SetProperties({
    AspectRatio = 1,
    Parent = Holder,
})

local WorldRender = Object.Create("GUIContainer"):SetProperties({
    Name = "WorldRender",
    Parent = Holder,
})


local SpinFrame = Object.Create("Frame"):SetProperties({
    Size = UDim2.new(0,50,0,50),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.White,
    Name = "SpinFrame",
    Parent = WorldRender,
})

local Remote = Object.Create("RemoteEvent"):SetProperties({
    Parent = workspace,
    Name = "MoveMouse"
})
local playerFrames = {}
Remote.Event:Connect(function(player, position)
    if not playerFrames[player] then
        local frame = Object.Create("Frame"):SetProperties({
            Size = UDim2.new(0,10,0,10),
            AnchorPoint = Vector.new(0.5,0.5),
            BackgroundColor = Color.new(0,1,0,1),
            Parent = WorldRender,
        })
        playerFrames[player] = frame
    end
    playerFrames[player]:SetProperty("Position", UDim2.fromOffset(position.X, position.Y))
end)

task.spawn(function()
    while true do
        local et = os.clock()
        SpinFrame:SetProperty("Position", UDim2.fromScale(0.5 + math.cos(et)/2, 0.5 + math.sin(et)/2))
        task.wait()
    end
end)

task.spawn(function()
    while true do
        SpinFrame:SetProperty("BackgroundColor", Color.new(math.random(), math.random(), math.random(), 1))
        task.wait(1/3)
    end
end)

