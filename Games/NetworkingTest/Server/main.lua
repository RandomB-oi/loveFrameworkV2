local MainRender = Object.Create("GUIContainer")
MainRender:SetProperties({
    Name = "MainRender",
    Parent = workspace,
})

local Holder = Object.Create("Frame")
Holder:SetProperties({
    Size = UDim2.fromScale(1,1),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.Red,
    Parent = MainRender,
})

Object.Create("UIAspectRatioConstraint"):SetProperties({
    AspectRatio = 1,
    Parent = Holder,
})

local WorldRender = Object.Create("GUIContainer")
WorldRender:SetProperties({
    Name = "WorldRender",
    Parent = Holder,
})


MainRender:Clone():SetParent(Game:GetService("ClientService"))