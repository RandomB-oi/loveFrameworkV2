local module = {}
module.__index = module
module.__type = "RunService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)

module:CreateProperty("DeltaTime", "number", 0, nil, true)
module:CreateProperty("TimeScale", "number", 1)

module:CreateProperty("ElapsedTime", "number", 0, nil, true) -- local to the server/client
module:CreateProperty("SyncedTime", "number", 0, nil, true) -- synced

module:CreateProperty("FixedTickRate", "number", 1/20)

module:CreateProperty("CurrentTick", "number", 0, nil, true) -- local to the server/client
--module:CreateProperty("SyncedTick", "number", 0, nil, true)

module:CreateProperty("ServerTime", "number", 0) -- used for syncronization, use ElapsedTime or SyncedTime

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self.DeltaTime = 0

	self.RenderSignal = self.Maid:Add(Signal.new())
	self.UpdateSignal = self.Maid:Add(Signal.new())
	self._isServer = not not _G.LaunchParameters.server
	self._editor = not not _G.LaunchParameters.editor

	if self:IsClient() then -- sync it
		self.AlphaTime = 0
		self:GetPropertyChangedSignal("ServerTime"):Connect(function()
			self.AlphaTime = 0 -- could add ping to it idk if it makes a huge difference
		end)
	end

	return self
end

function module:IsServer()
	return not not self._isServer
end
function module:IsClient()
	return not self._isServer
end

function module:IsEditor()
	return self._editor
end

function module:Update(dt)
	local newTime = self:GetProperty("ElapsedTime") + dt
	self:SetProperty("ElapsedTime", newTime)

	if self:IsServer() then
		self:SetProperty("SyncedTime", newTime)

		if not self.lastReplicate or newTime - self.lastReplicate > 1 then
			self.lastReplicate = newTime
			self:SetProperty("ServerTime", newTime)
		end
	else
		self.AlphaTime = self.AlphaTime + dt
		self:SetProperty("SyncedTime", self:GetProperty("ServerTime") + self.AlphaTime)
	end
	self.UpdateSignal:Fire(dt)
end

function module:Draw()
	self.RenderSignal:Fire()
end

return module:Register()