local module = {}
module.__index = module
module.__type = "RunService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)
module:CreateProperty("DeltaTime", "number", 0)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.RenderSignal = self.Maid:Add(Signal.new())
	self.UpdateSignal = self.Maid:Add(Signal.new())
	self._isServer = not not _G.LaunchParameters.server
	self._editor = not not _G.LaunchParameters.editor

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
	self.UpdateSignal:Fire(dt)
end

function module:Draw()
	self.RenderSignal:Fire()
end

return module:Register()