
local module = {}
module.__index = module
module.__type = "TextBox"
module.__base = require("Engine.Objects.GUI.TextLabel")
setmetatable(module, module.__base)

module.ClassIcon = "Engine/Assets/InstanceIcons/TextBox.png"
module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:SetDefaultProperyValue("Text", "")

module:CreateProperty("PlaceholderText", "string", "")
module:CreateProperty("CursorPosition", "number", -1)
module:CreateProperty("Focused", "boolean", false)

local UpperReplace = {
    ["1"] = "!",
    ["2"] = "@",
    ["3"] = "#",
    ["4"] = "$",
    ["5"] = "%",
    ["6"] = "^",
    ["7"] = "&",
    ["8"] = "*",
    ["9"] = "(",
    ["0"] = ")",
    ["["] = "{",
    ["]"] = "}",
    [";"] = ":",
    ["'"] = '"',
    [","] = "<",
    ["."] = ">",
    ["/"] = "?",
    ["-"] = "_",
    ["="] = "+",
    ["`"] = "~",
}

local function concat(list)
	local str = ""
	for i,v in pairs(list) do
		if v then
			str = str .. v
		end
	end
	return str
end


module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	local InputService = Game:GetService("InputService")

	self.Maid:GiveTask(InputService.InputBegan:Connect(function(input)
		if input.MouseButton == Enum.MouseButton.MouseButton1 then
			if self:MouseHovering() then
				self:SetProperty("CursorPosition", self:GetProperty("Text"):len()+1)
				self:SetProperty("Focused", true)
			else
				self:ReleaseFocus()
			end
		end
		
		if not self:GetProperty("Focused") then return end
		if not input.KeyCode then return end
		
		if input.KeyCode == Enum.KeyCode.Return then
			self:ReleaseFocus()
		elseif input.KeyCode == Enum.KeyCode.Left then
			self:MoveCursor(-1)
		elseif input.KeyCode == Enum.KeyCode.Right then
			self:MoveCursor(1)
		elseif input.KeyCode == Enum.KeyCode.End then
			self:SetCursor(self:GetProperty("Text"):len()+1)
		elseif input.KeyCode == Enum.KeyCode.Home then
			self:SetCursor(0)
		elseif input.KeyCode == Enum.KeyCode.Backspace then
			self:SubChar(1)
		elseif input.KeyCode == Enum.KeyCode.Space then
			self:AddChar(" ")
		else
			local keyText = input.KeyCode.ScanCode
			
			if InputService:IsKeyPressed(Enum.KeyCode.LeftShift) or InputService:IsKeyPressed(Enum.KeyCode.RightShift) then
				keyText = UpperReplace[keyText] or keyText:upper()
			end
			if keyText:len() > 1 then return end

			self:AddChar(keyText)
		end
	end))

	self:GetPropertyChangedSignal("PlaceholderText"):Connect(function()
		self:UpdateText()
	end)
	self:GetPropertyChangedSignal("CursorPosition"):Connect(function()
		self:UpdateText()
	end)

	return self
end

function module:SetCursor(value)
	self:SetProperty("CursorPosition", math.clamp(value, 1, self:GetProperty("Text"):len()+1))
end

function module:MoveCursor(amount)
	self:SetCursor(self:GetProperty("CursorPosition") + amount)
end

function module:SubChar(amount)
	local splitText = string.toArray(self:GetProperty("Text"))
	for i = self:GetProperty("CursorPosition")-1, (self:GetProperty("CursorPosition") - amount), -1 do
		splitText[i] = ""
	end
	self:SetProperty("Text", concat(splitText))
	self:MoveCursor(-amount)
end

function module:AddChar(char)
	local splitText = string.toArray(self:GetProperty("Text"))
	table.insert(splitText, self:GetProperty("CursorPosition"), char)
	self:SetProperty("Text", concat(splitText))
	self:MoveCursor(char:len())
end

function module:ReleaseFocus()
	if self:GetProperty("Focused") then
		self:SetProperty("Focused", false)
		self:SetProperty("CursorPosition", -1)
	end
end

function module:GetDesiredText()
	if self:GetProperty("Focused") and self:GetProperty("CursorPosition") ~= -1 then
		local splitText = string.toArray(self:GetProperty("Text"))
		table.insert(splitText, self:GetProperty("CursorPosition"), "|")
		return concat(splitText)
	end
	if self:GetProperty("Text") == "" then
		return self:GetProperty("PlaceholderText")
	end
	return self:GetProperty("Text")
end

function module:Draw()
	module.__base.Draw(self)

	if self:GetProperty("Focused") then
		love.graphics.drawOutline(self.RenderPosition, self.RenderSize, 0, Vector.zero)
	end
end


return module:Register()