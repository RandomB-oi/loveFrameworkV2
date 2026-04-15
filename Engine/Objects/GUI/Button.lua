local module = {}
module.__index = module
module.__type = "Button"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/ImageButton.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("LeftClickHeld", "boolean", false)
module:CreateProperty("RightClickHeld", "boolean", false)

module.new = function(...)
	local self = setmetatable(module.__base.new(...), module)

	self.LeftClicked = self.Maid:Add(Signal.new())
	self.RightClicked = self.Maid:Add(Signal.new())
	self.LeftReleased = self.Maid:Add(Signal.new())
	self.RightReleased = self.Maid:Add(Signal.new())

	self.Maid:GiveTask(Game:GetService("InputService").InputBegan:Connect(function(input)
		if input.MouseButton == Enum.MouseButton.MouseButton1 or input.MouseButton == Enum.MouseButton.MouseButton2 then
			if self._hovering and self:IsSimulated() and self:IsVisible() then
				if input.MouseButton == Enum.MouseButton.MouseButton1 then
					self:SetProperty("LeftClickHeld", true)
					self.LeftClicked:Fire()
				elseif input.MouseButton == Enum.MouseButton.MouseButton2 then
					self:SetProperty("RightClickHeld", true)
					self.RightClicked:Fire()
				end
			end
		end
	end))

	self.Maid:GiveTask(Game:GetService("InputService").InputEnded:Connect(function(input)
		if self:GetProperty("LeftClickHeld") and input.MouseButton == Enum.MouseButton.MouseButton1 then
			self:SetProperty("LeftClickHeld", false)
			self.LeftReleased:Fire()
		elseif self:GetProperty("RightClickHeld") and input.MouseButton == Enum.MouseButton.MouseButton2 then
			self:SetProperty("RightClickHeld", false)
			self.RightReleased:Fire()
		end
	end))

	return self
end

function module:Update(dt)
	module.__base.Update(self, dt)

	local hovering = self:MouseHovering()
	if self._hovering ~= hovering then
		self._hovering = hovering
		self._changed = true
	end
end


function module:Draw()
    local backgroundColor = self:GetProperty("BackgroundColor")
    if backgroundColor.A > 0 then
		if self._hovering then
			(backgroundColor-Color.new(.2,.2,.2,0)):Apply()
		else
			backgroundColor:Apply()
		end
        love.graphics.rectangle("fill", self.RenderPosition.X, self.RenderPosition.Y, self.RenderSize.X, self.RenderSize.Y)
    end
end

return module:Register()