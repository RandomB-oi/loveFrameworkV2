local Players = Game:GetService("Players")
Players:SetProperty("StarterCharacter", Object.Create("Character"))

local MainRender = Object.Create("GUIContainer"):SetProperties({
    Name = "MainRender",
    Parent = workspace,
})

local Holder = Object.Create("Frame"):SetProperties({
    Name = "Holder",
    Size = UDim2.new(0, 16, 0, 16),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.new(1,0,1,1),
    Parent = MainRender,
})

-- task.delay(5, function()
--     local frame = Object.Create("Frame"):SetProperties({
--         Parent = Holder,
--         BackgroundColor = Color.Red,
--         Size = UDim2.new(0, 200, 0, 50),
--     })
--     task.wait(3)
--     frame:Destroy()
--     print("Gone")
-- end)


-- local WorldAspectRatio = Object.Create("UIAspectRatioConstraint"):SetProperties({
--     AspectRatio = 1,
--     Parent = Holder,
-- })

-- local WorldScale = Object.Create("UIScale"):SetProperties({
--     Name = "WorldScale",
--     Parent = Holder,
--     Scale = 5,
-- })

Players:SetProperty("CharacterParent", Holder)