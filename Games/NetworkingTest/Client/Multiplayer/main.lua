local ClientService = Game:GetService("ClientService")
local ScreenCreator = require(GamePath.."Client.Multiplayer.ServerScreen")
local LoadingScreenCreator = require(GamePath.."Client.Multiplayer.LoadingScreen")
local GameScreenCreator = require(GamePath.."Client.Multiplayer.GameScreen")

local currentScreen
local loadingScreen
local gameScreen

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
        if connectedServer and connected then
            if not gameScreen then
                gameScreen = GameScreenCreator(Game)
            end
        else
            if gameScreen then
                gameScreen:Destroy()
                gameScreen = nil
            end
        end
        task.wait()
    end
end)