--[[
This is the base class for all constraints
All subclasses of it will set a cached value in the parent, allowing for quick read access
]]

local module = {}
module.__index = module
module.__type = "ConstraintBase"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/UIAspectRatioConstraint.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.ConstraintCategory = "Unknown"

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.ParentMaid = self.Maid:Add(Maid.new())
	
	self:GetPropertyChangedSignal("Parent"):Connect(function()
		self:UpdateParent()
	end)
	self:GetPropertyChangedSignal("Visible"):Connect(function()
		self:UpdateParent()
	end)

    return self
end



function module:UpdateParent()
	self.ParentMaid:Destroy()

	if not (self:GetProperty("Visible")) then return end
	local parent = self:GetProperty("Parent")
	if not parent then return end

	if not parent._cC then -- constraint children
		parent._cC = {}
	end
	parent._cC[self.ConstraintCategory] = self

	self.ParentMaid:GiveTask(function()
		if parent._cC and parent._cC[self.ConstraintCategory] == self then
			parent._cC[self.ConstraintCategory] = nil
			if not next(parent._cC) then
				parent._cC = nil
			end
		end
	end)
	self:BindToParent(parent)
end

function module:BindToParent(parent)
end

return module:Register()