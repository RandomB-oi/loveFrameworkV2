local module = {}
module.__index = module

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local InputService = Game:GetService("InputService")

local ContainerMenuClass = require(GamePath.."Client.UI.ContainerMenu")

module.new = function()
    local self = setmetatable({}, module)
    self.Maid = Maid.new()

    local CanvasHolder = workspace:WaitPath("WorldRender.Holder.RenderHolder")
    local ReplicateContainer = workspace:WaitPath("Storage.Remotes.ReplicateContainerGroup")

    ReplicateContainer.Event:Connect(ContainerGroupClass.Replicate)

    local player = Players:GetProperty("LocalPlayer")

    local inventoryObject = player:WaitForChild("PlayerInventory")
    local containerGroup = inventoryObject:GetContainerGroup()

    local gameUI = self.Maid:Add(Object.Create("GUIContainer")):SetProperties({
        Parent = workspace,
    })

    local containerMenu = self.Maid:Add(ContainerMenuClass.new())
    containerMenu.Frame:SetProperties({
        Parent = gameUI,
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(.75, .4),
        AnchorPoint = Vector.new(0.5, 1),
    })
    Object.Create("UIAspectRatioConstraint"):SetProperties({
        Parent = containerMenu.Frame,
        AspectRatio = 3,
    })

    containerMenu:AttachContainer(containerGroup:GetContainer("Inventory"))

    local function newChar()
        local char = player:GetProperty("Character")
        if not char then return end

        char:BindToProperty("Position", function()
            local renderSize = char:GetProperty("Parent").RenderSize/2
            CanvasHolder:SetProperty("Position", -char:GetProperty("Position") + UDim2.new(0.5, renderSize.X, 0.5, renderSize.Y))
        end)
    end

    player.CharacterAdded:Connect(newChar)
    newChar()
    
    task.spawn(function()
        while self.Connected do
            local char = player and player:GetProperty("Character")
            
            if char then
            end
            task.wait()
        end
    end)

    -- task.spawn(function()
    --     local object = Object.Create("Frame"):SetProperties({
    --         AnchorPoint = Vector.one/2,
    --         Parent = CanvasHolder:GetProperty("Parent"),
    --         Size = UDim2.fromOffset(20, 20),
    --         BackgroundColor = Color.Red,
    --         BorderColor = Color.Green,
    --         BorderSize = 3,
    --     })
    --     while task.wait(1/3) do
    --         local mousePos = InputService:GetMouseLocation()-object:GetProperty("Parent").RenderPosition
    --         Game:GetService("TweenService"):Create(
    --             object,
    --             -- TweenInfo.new(1/3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
    --             TweenInfo.new(1/3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
    --             {Position = UDim2.fromOffset(mousePos.X, mousePos.Y)}
    --         ):Play()
    --     end
    -- end)

    return self
end

function module:Destroy()
    print("Disconnected")
    self.Connected = nil
    self.Maid:Destroy()
end

return module