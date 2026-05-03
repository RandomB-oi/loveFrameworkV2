local ClientService = Game:GetService("ClientService")

local ConnectionMaker = require(GamePath.."Client.JoinServer")
require(GamePath.."Client.Multiplayer.main")

ClientService.Connected:Connect(function()
    print("run the connection")
    local callback = ConnectionMaker()
    ClientService.Disconnected:Wait()
    callback()
end)