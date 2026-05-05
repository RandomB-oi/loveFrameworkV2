local Players = Game:GetService("Players")
Players:SetProperty("StarterCharacter", Object.Create("Character"))

local MainRender = Object.Create("GUIContainer"):SetProperties({
    Name = "WorldRender",
    Parent = workspace,
})

local Holder = Object.Create("Frame"):SetProperties({
    Name = "Holder",
    Size = UDim2.new(0, 1, 0, 1),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.Blank,
    Parent = MainRender,
})

local WorldScale = Object.Create("UIScale"):SetProperties({
    Name = "WorldScale",
    Parent = Holder,
    Scale = 32,
})

local RenderHolder = Object.Create("Frame"):SetProperties({
    Name = "RenderHolder",
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.fromScale(0.5,0.5),
    AnchorPoint = Vector.new(0.5,0.5),
    BackgroundColor = Color.Blank,
    Parent = Holder,
})

local Storage = Object.Create("Folder"):SetProperties({
    Name = "Storage",
    Parent = workspace,
    Visible = false,
    Simulated = false,
})

local Remotes = Object.Create("Folder"):SetProperties({
    Name = "Remotes",
    Parent = Storage,
})

local ReplicateChunkData = Object.Create("RemoteEvent"):SetProperties({
    Name = "ReplicateChunkData",
    Parent = Remotes,
})

Players:SetProperty("CharacterParent", RenderHolder)


        -- Object.Create("WorldChunk"):SetProperties({
        --     Parent = RenderHolder,
        --     -- Position = UDim2.fromScale(x*8, y*8)
        -- })
for x = -2, 2 do
    for y = -2, 2 do
        Object.Create("WorldChunk"):SetProperties({
            Parent = RenderHolder,
            Position = UDim2.fromScale(x*8, y*8)
        })
    end
end
