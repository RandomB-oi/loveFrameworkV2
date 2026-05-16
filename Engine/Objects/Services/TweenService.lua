local TweenClass = {}
local AllTweens = {}

local function CancelTweens(object, properties)
	for _, tween in next, AllTweens[object] or {} do
		for prop in next, properties do
			tween.Properties[prop] = nil
			tween.OriginalProperties[prop] = nil
		end
		if not next(tween.Properties) then
			tween:Destroy()
		end
	end
end

do

	local module = TweenClass
	module.__index = module
	module.__type = "Tween"
	module.__base = require("Engine.Objects.Object")
	setmetatable(module, module.__base)

	module.ClassProperties = module.__base:CopyProperties()
	module:SetDefaultProperyValue("Name", module.__type)
	module:SetDefaultProperyValue("Replicates", false)
	module:SetDefaultProperyValue("Archivable", false)

	module:CreateProperty("TimePosition", "number", 1)
	module:CreateProperty("Playing", "boolean", false)
	

	module.new = function(id, object, tweenInfo, properties)
		local self = setmetatable(module.__base.new(id), module)
		self.Object = object
		self.TweenInfo = tweenInfo -- {Time, Style, Direction}
		self.Properties = properties

		self.OriginalProperties = {}
		self.Completed = self.Maid:Add(Signal.new())

		self.Completed:Once(function()
			task.delay(1/3, function()
				self:Destroy()
			end)
		end)

		self:SetParent(self.Object)
		self.Parent = self.Object
		CancelTweens(self.Object, self.Properties)

		AllTweens[self.Object] = AllTweens[self.Object] or {}
		AllTweens[self.Object][self.ID] = self
		self.Maid:GiveTask(function()
			if AllTweens[self.Object] then
				AllTweens[self.Object][self.ID] = nil
				if not next(AllTweens[self.Object]) then
					AllTweens[self.Object] = nil
				end
			end
		end)

		return self
	end

	function module:Play()
		for prop in pairs(self.Properties) do
			self.OriginalProperties[prop] = self.Object:GetProperty(prop)
		end

		self:SetProperty("TimePosition", 0)
		self:SetProperty("Playing", true)
		return self
	end

	function module:Pause()
		self:SetProperty("Playing", false)
		return self
	end

	function module:Resume()
		self:SetProperty("Playing", true)
		return self
	end

	function module:Cancel()
		self:SetProperty("TimePosition", 0)
		self:SetProperty("Playing", false)
		return self
	end

	function module:Update(dt)
		module.__base.Update(self, dt)

		if self:GetProperty("Playing") then
			local newValue = math.clamp(self:GetProperty("TimePosition") + dt, 0, self.TweenInfo.Length)
			self:SetProperty("TimePosition", newValue)

			local alpha = self.TweenInfo:Solve(math.clamp(newValue / self.TweenInfo.Length, 0, 1))

			for prop, value in pairs(self.Properties) do
				self.Object:SetProperty(prop, math.lerp(self.OriginalProperties[prop], value, alpha))
			end

			if alpha >= 1 then
				self:Pause()
				self.Completed:Fire()
			end
		end
	end

	module:Register()
	TweenClass = module
end


local module = {}
module.__index = module
module.__type = "TweenService"
module.__base = require("Engine.Objects.Services.Service")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Simulated", true)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	return self
end

function module:CancelTweens(object, properties)
	return CancelTweens(object, properties)
end

function module:GetValue(alpha, style, direction)
	return TweenInfo._calcEasing(alpha, style, direction)
end

function module:Create(object, tweenInfo, properties)
	return Object.Create("Tween", nil, object, tweenInfo, properties)
end

return module:Register()
