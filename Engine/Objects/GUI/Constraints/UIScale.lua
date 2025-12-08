local module = {}
module.__index = module
module.__type = "UIScale"
module.__base = require("Engine.Objects.ConstraintBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "Scale"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("Scale", "number", 1)

return module:Register()