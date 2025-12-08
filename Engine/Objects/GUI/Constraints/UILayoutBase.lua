local module = {}
module.__index = module
module.__type = "UILayoutBase"
module.__base = require("Engine.Objects.ConstraintBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "List"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

function module:Resolve(child, parentSize, parentPosition)
	return Vector.zero, Vector.zero
end

return module:Register()