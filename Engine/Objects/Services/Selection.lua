local module = {}
module.__index = module
module.__type = "Selection"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
-- module:SetDefaultProperyValue("Simulated", true)
module:SetDefaultProperyValue("Visible", true)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.Selection = {}
	self.SelectionChanged = self.Maid:Add(Signal.new())
	
	return self
end

function module:Draw()
	for _, object in pairs(self:Get()) do
		if object.RenderSize and object.RenderPosition then
			love.graphics.drawOutline(object.RenderPosition, object.RenderSize, 0, object.AnchorPoint)
		end
	end
end

function module:Get()
	return table.shallowCopy(self.Selection)
end

function module:Set(new)
	self.Selection = new or {}
	self.SelectionChanged:Fire(self:Get())
end

function module:IsSelected(object)
	return table.find(self.Selection, object)
end

function module:Add(object)
	if self:IsSelected(object) then return end
	table.insert(self.Selection, object)
	self.SelectionChanged:Fire(self:Get())
end

function module:Remove(object)
	local index = self:IsSelected(object)
	if not index then return end
	table.remove(self.Selection, index)
	self.SelectionChanged:Fire(self:Get())
end

return module:Register()