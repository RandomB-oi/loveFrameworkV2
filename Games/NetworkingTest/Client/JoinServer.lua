local Players = Game:GetService("Players")
local InputService = Game:GetService("InputService")

return function()
    local connectionMaid = Maid.new()
    local connected = true

    task.spawn(function()
        local CanvasHolder = workspace:WaitPath("WorldRender.Holder.RenderHolder")
        task.spawn(function()
            local player = Players:GetProperty("LocalPlayer")
            player.CharacterAdded:Connect(function(char)
                char:GetPropertyChangedSignal("Position"):Connect(function()
                    local renderSize = char:GetProperty("Parent").RenderSize/2
                    CanvasHolder:SetProperty("Position", -char:GetProperty("Position") + UDim2.new(0.5, renderSize.X, 0.5, renderSize.Y))
                end)
            end)

            -- while connected do
            --     local char = player and player:GetProperty("Character")
                
            --     if char then
            --         local renderSize = char:GetProperty("Parent").RenderSize/2
            --         CanvasHolder:SetProperty("Position", -char:GetProperty("Position") + UDim2.new(0.5, renderSize.X, 0.5, renderSize.Y))
            --     end
            --     task.wait()
            -- end
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
    end)

    return function()
        print("Disconnected")
        connected = false
        connectionMaid:Destroy()
    end
end