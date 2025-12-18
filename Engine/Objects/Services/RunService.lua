local module = {}
module.__index = module
module.__type = "RunService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.RenderSignal = self.Maid:Add(Signal.new())
	self.UpdateSignal = self.Maid:Add(Signal.new())
	
	return self
end

function module:Update(dt)
	self.UpdateSignal:Fire(dt)
end

function module:Draw()
	self.RenderSignal:Fire()
end

return module:Register()