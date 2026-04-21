local module = {}
module.__index = module
module.__type = "Character"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("ZIndex", 5)
module:SetDefaultProperyValue("AnchorPoint", Vector.new(0.5, 0.5))

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local InputService = Run:IsClient() and Game:GetService("InputService")

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    if Run:IsServer() then
        self.UpdateRemote = Object.Create("RemoteEvent"):SetProperties({
            Parent = self,
            Archivable = false,
            Name = "UpdateRemote",
        })
        self.UpdateRemote.Event:Connect(function(player, pos)
            if not self:Owns(player) then print("they dont own it") return end

            for _, otherPlayer in next, Players:GetPlayers() do
                if otherPlayer ~= player then
                    self.UpdateRemote:FireClient(otherPlayer, pos)
                end
            end

            self.Position = pos -- doesnt fire changed signals or replication
        end)
    else
        task.spawn(function()
            self.UpdateRemote = self:WaitForChild("UpdateRemote")
            self.UpdateRemote.Event:Connect(function(pos)
                self:SetProperty("Position", pos)
            end)
            while self.UpdateRemote:GetProperty("Parent") == self do
                if self:Owns() then
                    self.UpdateRemote:FireServer(self:GetProperty("Position"))
                end
                task.wait(1/20)
            end
        end)
    end

    return self
end

function module:Owns(player)
    local player = player or Players:GetProperty("LocalPlayer")
    local char = player and player:GetProperty("Character")
    return char == self
    -- local charID = char and char.ID
    -- return charID == self.ID
end

function module:Update(dt)
    module.__base.Update(self, dt)
    if Run:IsServer() then return end
    if not self:Owns() then return end

    local moveSpeed = 10

    local moveVector = Vector.zero
    if InputService:IsKeyPressed(Enum.KeyCode.W) then
        moveVector = moveVector - Vector.yAxis
    end
    if InputService:IsKeyPressed(Enum.KeyCode.S) then
        moveVector = moveVector + Vector.yAxis
    end
    
    if InputService:IsKeyPressed(Enum.KeyCode.A) then
        moveVector = moveVector - Vector.xAxis
    end
    if InputService:IsKeyPressed(Enum.KeyCode.D) then
        moveVector = moveVector + Vector.xAxis
    end

    if moveVector:Length() > 0.001 then
        local moveVector = moveVector:Normalized() * dt * moveSpeed
        self:SetProperty("Position", self:GetProperty("Position") + UDim2.fromScale(moveVector.X, moveVector.Y))
    end
end

return module:Register()