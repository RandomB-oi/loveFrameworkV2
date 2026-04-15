local ClientService = Game:GetService("ClientService")
local ScreenCreator = require(GamePath.."Client.Multiplayer.ServerScreen")
local LoadingScreenCreator = require(GamePath.."Client.Multiplayer.LoadingScreen")

local currentScreen
local loadingScreen

task.spawn(function()
    while true do
        local connectedServer, connected = ClientService:ConnectedToServer()
        if connectedServer and currentScreen then
            currentScreen:Destroy()
            currentScreen = nil
        elseif not connectedServer and not currentScreen then
            currentScreen = ScreenCreator(Game)
        end
        if connectedServer and not connected then
            if not loadingScreen then
                loadingScreen = LoadingScreenCreator(Game, ClientService:GetProperty("ServerIP"), ClientService:GetProperty("ServerPort"))
            end
        else
            if loadingScreen then
                loadingScreen:Destroy()
                loadingScreen = nil
            end
        end
        task.wait()
    end
end)