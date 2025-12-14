local module = {}
module.__index = module
module.__type = "ImageLabel"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/ImageLabel.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("ImageColor", "Color", Color.White)
module:CreateProperty("Image", "string", "")

module.new = function(...)
	local self = setmetatable(module.__base.new(...), module)

	self:GetPropertyChangedSignal("Image"):Connect(function(newImage)
		-- if _G.LaunchParameters.noGraphics then return end
		if newImage then
			self._imageObject = love.graphics.newImage(newImage) -- i overwrote this with a cached function
		end
	end)

	return self
end
function module:Draw()
	module.__base.Draw(self)


	if not self._imageObject then return end
	local color = self:GetProperty("ImageColor")
	if color.A <= 0 then return end

	color:Apply()

	if self._imageObject then
		love.graphics.cleanDrawImage(self._imageObject, self.RenderPosition, self.RenderSize)
	end
end

return module:Register()