local module = {}
module.__index = module
module.__type = "UISizeConstraint"
module.__base = require("Engine.Objects.ConstraintBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "Size"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("Min", "Vector", Vector.new(0,0))
module:CreateProperty("Max", "Vector", Vector.new(math.huge,math.huge))

function module:BindToParent(parent)
	self.ParentMaid:GiveTask(self.Changed:Connect(function()
		parent._updateRender = true
	end))
	parent._updateRender = true
end

return module:Register()