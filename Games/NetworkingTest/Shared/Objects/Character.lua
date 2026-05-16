local module = {}
module.__index = module
module.__type = "Character"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("ZIndex", 6)
module:SetDefaultProperyValue("AnchorPoint", Vector.new(0.5, 0.5))
-- module:SetDefaultProperyValue("BorderSize", 5)
-- module:SetDefaultProperyValue("BorderColor", Color.Red)
module:SetDefaultProperyValue("Size", UDim2.fromScale(.5, .5))
module:CreateProperty("WalkSpeed", "number", 7)

local Run = Game:GetService("RunService")
local Players = Game:GetService("Players")
local InputService = Run:IsClient() and Game:GetService("InputService")
local TweenService = Game:GetService("TweenService")

local ReplicationStepTime = 1/20
local ReplicateTweenInfo = TweenInfo.new(ReplicationStepTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

local MaxTimeBeforeDrop = 2
local MaxFutureTime = 5

local function IsBogus(self, packet)
	if packet.Tick % 1 ~= 0 then
		return true
	end

    local currentTick = Run:GetProperty("CurrentTick")
    local tickRate = Run:GetProperty("FixedTickRate")

	return packet.Tick < self.LastProcessedTick and packet.Tick > (currentTick + MaxFutureTime/tickRate)
end

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
    self.MoveVector = Vector.zero
    self.ServerPosition = self:GetProperty("Position")
    self.StateBuffer = {}

    if Run:IsServer() then
        self.InputQueue = {}
        self.LastProcessedTick = 0

        self.UpdateRemote = Object.Create("RemoteEvent"):SetProperties({
            Parent = self,
            Archivable = false,
            Name = "UpdateRemote",
        })
        self.UpdateRemote.Event:Connect(function(player, input)
            if not self:Owns(player) then return end

                    
            if IsBogus(self, input) then print("bogus") return end
            table.insert(self.InputQueue, input)
        end)
    else
        self.InputBuffer = {}

        task.spawn(function()
            self.UpdateRemote = self:WaitForChild("UpdateRemote")
            self.UpdateRemote.Event:Connect(function(state)
                self.LatestServerState = state

                if self:Owns() then
                    return
                end

                local tween = TweenService:Create(self, ReplicateTweenInfo, {Position = state.Position})
                tween:Play()
            end)
        end)
    end

    return self
end

function module:GetOwner()
    Players:GetPlayerByCharacter(self)
end

function module:Owns(player)
    local player = player or Players:GetProperty("LocalPlayer")
    local char = player and player:GetProperty("Character")
    return char == self
    -- local charID = char and char.ID
    -- return charID == self.ID
end

local BufferSize = 512

function module:ServerHandleTick()
    local latestTick, latestPacket = -1, nil
    local currentTick = Run:GetProperty("CurrentTick")
    local tickRate = Run:GetProperty("FixedTickRate")

	while self.InputQueue[1] do
		local inputPayload = self.InputQueue[1]

		if inputPayload.Tick > currentTick and inputPayload.Tick <= (currentTick + MaxFutureTime/tickRate) then break end

		table.remove(self.InputQueue, 1)
		
        local insideTimeFrame = inputPayload.Tick <= currentTick
        local withinReasonableTime = (currentTick-inputPayload.Tick) < MaxTimeBeforeDrop/tickRate
        local notProcessed = inputPayload.Tick > self.LastProcessedTick

		if insideTimeFrame and notProcessed and withinReasonableTime then
			self.LastProcessedTick = inputPayload.Tick
			local bufferIndex = inputPayload.Tick % BufferSize
			
            local newState = self:ProcessMovement(inputPayload)
			self.StateBuffer[bufferIndex] = newState
			
			if latestTick < inputPayload.Tick then
				latestTick, latestPacket = inputPayload.Tick, newState
			end
		end
	end
	
	if latestTick ~= -1 then
		self.UpdateRemote:FireAllClients(latestPacket)
	end
end

function module:HandleServerReconciliation()
    self.LastProcessedState = self.LatestServerState
    local currentTick = Run:GetProperty("CurrentTick")

	local serverStateBufferIndex = self.LatestServerState.Tick % BufferSize
    local v1 = Vector.new(self.LatestServerState.Position.X.Scale, self.LatestServerState.Position.Y.Scale)

    local prevState = self.StateBuffer[serverStateBufferIndex].Position
    local v2 = Vector.new(prevState.X.Scale, prevState.Y.Scale)

	local positionError = (v1 - v2):Length()
    
	if positionError > 0.05 then
		print("Reconcile")

        TweenService:CancelTweens(self, {Position = true})
        self.ServerPosition = self.LatestServerState.Position
		self.StateBuffer[serverStateBufferIndex] = self.LatestServerState

		local tickToProcess = self.LatestServerState.Tick + 1
		while tickToProcess < currentTick do
			local bufferIndex = tickToProcess%BufferSize
			local statePayload = self:ProcessMovement(self.InputBuffer[bufferIndex])

			self.StateBuffer[bufferIndex] = statePayload

			tickToProcess = tickToProcess + 1
		end
	end
end

function module:ClientHandleTick()
    if not self.UpdateRemote then return end

    local currentTick = Run:GetProperty("CurrentTick")
	if self.LatestServerState and self.LatestServerState ~= self.LastProcessedState then
		self:HandleServerReconciliation()
	end

	local bufferIndex = currentTick % BufferSize

	local inputPayload = {}
	inputPayload.Tick = currentTick
	inputPayload.InputVector = self.MoveVector
	self.InputBuffer[bufferIndex] = inputPayload

	self.StateBuffer[bufferIndex] = self:ProcessMovement(inputPayload)

	self.UpdateRemote:FireServer(inputPayload)
end

function module:ProcessMovement(input)
    local dt = Run:GetProperty("FixedTickRate")
    local moveVector = input.InputVector
    local newPos = self.ServerPosition + UDim2.fromScale(moveVector.X, moveVector.Y)
    self.ServerPosition = newPos

    if Run:IsClient() then
        TweenService:Create(self, TweenInfo.new(dt, Enum.EasingStyle.Linear), {Position = newPos}):Play()
    else
        self.Position = newPos
    end

	local statePayload = {}
	statePayload.Tick = input.Tick
	statePayload.Position = newPos

	return statePayload
end

function module:Teleport(position)
    self.ServerPosition = position
    self:SetProperty("Position", position)
    
    -- self.UpdateRemote:FireAllClients({
    --     Tick = Run:GetProperty("CurrentTick"),
    --     Position = position,
    -- })
end

function module:FixedUpdate()
    local dt = Run:GetProperty("FixedTickRate")
    module.__base.FixedUpdate(self)
    if Run:IsServer() then
        self:ServerHandleTick()
        return
    end
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
        self.MoveVector = moveVector:Normalized() * dt * moveSpeed
    else
        self.MoveVector = Vector.zero
    end

    self:ClientHandleTick()
end

return module:Register()