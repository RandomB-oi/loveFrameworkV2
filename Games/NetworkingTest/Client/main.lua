local ClientService = Game:GetService("ClientService")

local GameClient = require(GamePath.."Client.GameClient")
require(GamePath.."Client.Multiplayer.main")

ClientService.Connected:Connect(function()
    print("run the connection")
    local currentClient
    ClientService.Disconnected:Once(function()
        while not currentClient do
            task.wait()
        end
        currentClient:Destroy()
        currentClient = nil
    end)
    currentClient = GameClient.new()
end)