local module = {}
module.__index = module
module.__type = "Character"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("ZIndex", 6)
module:SetDefaultProperyValue("AnchorPoint", Vector.new(0.5, 0.5))
module:SetDefaultProperyValue("BorderSize", 5)
module:SetDefaultProperyValue("BorderColor", Color.Red)
module:SetDefaultProperyValue("Size", UDim2.fromScale(.5, .5))
module:CreateProperty("WalkSpeed", "number", 7)

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local InputService = Run:IsClient() and Game:GetService("InputService")
local TweenService = Game:GetService("TweenService")

local ReplicationStepTime = 1/20
local ReplicateTweenInfo = TweenInfo.new(ReplicationStepTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    if Run:IsServer() then
        self.UpdateRemote = Object.Create("RemoteEvent"):SetProperties({
            Parent = self,
            Archivable = false,
            Name = "UpdateRemote",
        })
        self.UpdateRemote.Event:Connect(function(player, pos)
            if not self:Owns(player) then return end

            for _, otherPlayer in next, Players:GetPlayers() do
                if otherPlayer ~= player then
                    self.UpdateRemote:FireClient(otherPlayer, pos)
                end
            end

            self.Position = pos -- doesnt fire changed signals or replication
            -- self:SetProperty("Position", pos)
        end)
    else
        task.spawn(function()
            self.UpdateRemote = self:WaitForChild("UpdateRemote")
            self.UpdateRemote.Event:Connect(function(pos)
                -- self:SetProperty("Position", pos)

                local tween = TweenService:Create(self, ReplicateTweenInfo, {Position = pos})
                tween:Play()
            end)
            while self.UpdateRemote:GetProperty("Parent") == self do
                if self:Owns() then
                    self.UpdateRemote:FireServer(self:GetProperty("Position"))
                end
                task.wait(ReplicationStepTime)
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

function module:FixedUpdate()
    local dt = Run:GetProperty("FixedTickRate")
    module.__base.FixedUpdate(self, dt)
-- function module:Update(dt)
--     module.__base.Update(self, dt)
    if Run:IsServer() then return end
    if not self:Owns() then return end

    local moveSpeed = self:GetProperty("WalkSpeed")

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