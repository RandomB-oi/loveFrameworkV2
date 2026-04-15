local module = {}
module.__index = module
module.__type = "SimulationSubStepContainer"
module.__base = require("Engine.Objects.Object")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/Folder.png"
module.ClassProperties = module.__base:CopyProperties()
module:CreateProperty("DesiredFPS", "number", 60)
module:SetDefaultProperyValue("Name", module.__type)

function module:_update(dt)
    if not self:GetProperty("Simulated") then return false end

    local stepAmount = math.ceil(dt*self:GetProperty("DesiredFPS"))
    local subDT = dt/stepAmount
	for i = 1, stepAmount do
		module.__base._update(self, subDT)
	end

    return true
end

return module:Register()