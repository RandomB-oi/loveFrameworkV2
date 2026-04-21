local InputService = Game:GetService("InputService")
local ClientService = Game:GetService("ClientService")

require(GamePath.."Client.Multiplayer.main")

local ConnectedMaid = Maid.new()


ClientService.Connected:Connect(function()
    local connected = true

    ConnectedMaid:GiveTask(function()
        connected = false
        print("left")
    end)

    task.spawn(function()
        local CanvasHolder = workspace:WaitForChild("MainRender"):WaitForChild("Holder")
        local mainFrame = CanvasHolder:WaitForChild("WorldRender")

        task.spawn(function()
            
        end)
    end)
end)

ClientService.Disconnected:Connect(function()
    ConnectedMaid:Destroy()
end)