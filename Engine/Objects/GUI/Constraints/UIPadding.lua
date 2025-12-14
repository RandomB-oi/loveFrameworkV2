local module = {}
module.__index = module
module.__type = "UIPadding"
module.__base = require("Engine.Objects.ConstraintBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "Padding"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
	
module:CreateProperty("PaddingLeft", "UDim", UDim.new(0,0))
module:CreateProperty("PaddingRight", "UDim", UDim.new(0,0))
module:CreateProperty("PaddingTop", "UDim", UDim.new(0,0))
module:CreateProperty("PaddingBottom", "UDim", UDim.new(0,0))

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.TopLeft = Vector.zero
	self.BottomRight = Vector.zero

	self.Changed:Connect(function()
		self:UpdateOffsets()
	end)

    return self
end

function module:BindToParent(parent)
	self.ParentMaid:GiveTask(parent.Changed:Connect(function()
		self:UpdateOffsets()
	end))
	self:UpdateOffsets()
end

function module:UpdateOffsets()
	local parent = self:GetProperty("Parent")
	local parentSize = parent and parent.RenderSize or Vector.zero

	self.TopLeft = UDim2.fromUDims(self:GetProperty("PaddingLeft"), self:GetProperty("PaddingTop")):Calculate(parentSize)
	self.BottomRight = UDim2.fromUDims(self:GetProperty("PaddingRight"), self:GetProperty("PaddingBottom")):Calculate(parentSize)
	if parent then
		parent._updateRender = true
	end
end

return module:Register()