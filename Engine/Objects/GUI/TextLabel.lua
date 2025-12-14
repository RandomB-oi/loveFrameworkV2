local module = {}
module.__index = module
module.__type = "TextLabel"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

local DefaultFont
local function GetDefaultFont()
	if DefaultFont then return DefaultFont end
	-- DefaultFont = love.graphics.newFont("Engine/Assets/Fonts/FiraMonoTypewriter-text-regular.ttf", 64)
	DefaultFont = love.graphics.newFont(64, "normal")
	return DefaultFont
end

module.ClassIcon = "Engine/Assets/InstanceIcons/TextLabel.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("TextColor", "Color", Color.new(0,0,0,1))
module:CreateProperty("Text", "string", "Text")
module:CreateProperty("TextStretch", "boolean", false)
module:CreateProperty("XAlignment", "XAlignment", Enum.XAlignment.Center)
module:CreateProperty("YAlignment", "YAlignment", Enum.YAlignment.Center)


module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

    self:BindToProperty("Text", function()
        self:UpdateText()
    end)

    return self
end

function module:GetDesiredText()
	return self:GetProperty("Text")
end

function module:UpdateText()
	local text = self:GetDesiredText()
    local font = self:GetProperty("Font") or GetDefaultFont()
	if (self._currentText == text and self._currentFont == font) then
		return
	end

	self._currentFont = font
	self._currentText = text

	if self._textObject then
		self._textObject:release()
		self._textObject = nil
	end

	self._textObject = love.graphics.newText(font, text)
end

function module:Draw()
    module.__base.Draw(self)
    local textColor = self:GetProperty("TextColor")
    if textColor.A > 0 then
        textColor:Apply()
        love.graphics.cleanDrawText(self._textObject, self.RenderPosition, self.RenderSize, self:GetProperty("TextStretch"), self:GetProperty("XAlignment"), self:GetProperty("YAlignment"))
    end
end

return module:Register()