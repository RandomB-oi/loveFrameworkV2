local module = {}

local SaveService = Game:GetService("SaveService")
local RunService = Game:GetService("RunService")
local Players = Game:GetService("Players")
local PlayerDataTemplate = require(GamePath.."Server.PlayerDataTemplate")

local All = {}
module.Get = function(player, timeout)
    if not All[player] and timeout then
        local begin = RunService:GetProperty("ElapsedTime")
        repeat
            task.wait()
        until RunService:GetProperty("ElapsedTime") - begin > timeout or All[player]
    end
    return All[player]
end

module.LoadPlayerData = function(player)
    local existing = module.Get(player)
    if existing then return existing end

    local data = SaveService:Get("PlayerData_"..player:GetProperty("UserID")) or table.copy(PlayerDataTemplate)

    All[player] = data

    return data
end

module.SavePlayerData = function(player, remove)
    local data = module.Get(player)
    if not data then return end

    SaveService:Set("PlayerData_"..player:GetProperty("UserID"), data)

    if remove then
        All[player] = nil
    end
end

module.SaveAndRemovePlayerData = function(player)
    return module.SavePlayerData(player, true)
end

module.SaveAll = function()
    for player in next, All do
        module.SavePlayerData(player)
    end
end

Players.PlayerAdded:Connect(module.LoadPlayerData)
Players.PlayerRemoved:Connect(module.SaveAndRemovePlayerData)

task.spawn(function()
    while task.wait(1) do
        module.SaveAll()
    end
end)

return module