local Players = Game:GetService("Players")
local PlayerDataManager = require(GamePath.."Server.PlayerDataManager")

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
    BackgroundColor = Color.Red,
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

Object.Create("RemoteEvent"):SetProperties({
    Name = "ReplicateContainerGroup",
    Parent = Remotes
})

Players:SetProperty("CharacterParent", RenderHolder)

Players.CharacterAdded:Connect(function(player, character)
    local data = PlayerDataManager.Get(player, 10)
    if not data then return end

    local newInventory = Object.Create("PlayerInventory", "InvObj"..tostring(player:GetProperty("UserID")))
    newInventory:SetProperty("Parent", player)
    newInventory:GetContainerGroup():GiveAccess(player)
    character:Teleport(data.Position)

    while player:GetProperty("Parent") and character:GetProperty("Parent") do
        data.Position = character.ServerPosition
        task.wait(1/5)
    end
end)

-- local length = 100
-- local newData = Buffer.create(length)
-- for i = 0, length-1 do
--     local value = math.random(0,255)
--     Buffer.writeu8(newData, i, value)
-- end

-- SaveService:Set("test-key", {
--     Position = Vector.new(100, 50),
--     Data = newData,
--     Name = "Hello World",
--     Bonus = {
--         "A",6,false,Enum.KeyCode.F
--     }
-- })