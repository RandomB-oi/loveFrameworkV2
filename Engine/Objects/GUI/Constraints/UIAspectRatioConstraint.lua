local module = {}
module.__index = module
module.__type = "UIAspectRatioConstraint"
module.__base = require("Engine.Objects.ConstraintBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "AspectRatio"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("AspectRatio", "number", 1)

function module:BindToParent(parent)
	self.ParentMaid:GiveTask(self.Changed:Connect(function()
		parent._updateRender = true
	end))
	parent._updateRender = true
end

return module:Register()