local module = {}
module.__index = module
module.__type = "PropertyFrame"
module.__base = require("Editor.Instances.EditorInstance")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("Value", "any", nil)

local CellHeight = 20
local existingDropdown

local stringRound = function(value)
	if type(value) == "number" then
		return tostring(math.round(value*1000)/1000)
	end
	return tostring(value)
end

local PropConverters = {
	UDim2 = {
		tostring = function(value)
			return stringRound(value.X.Scale)..", "..tostring(math.round(value.X.Offset))..", "..stringRound(value.Y.Scale)..", "..tostring(math.round(value.Y.Offset))
		end,
		tovalue = function(str)
			local split = string.split(str, ",")

			return UDim2.new(
				tonumber(split[1]) or 0,
				tonumber(split[2]) or 0,
				tonumber(split[3]) or 0,
				tonumber(split[4]) or 0
			)
		end
	},
	UDim = {
		tostring = function(value)
			return stringRound(value.Scale)..", "..tostring(math.round(value.Offset))
		end,
		tovalue = function(str)
			local split = string.split(str, ",")

			return UDim.new(
				tonumber(split[1]) or 0,
				tonumber(split[2]) or 0
			)
		end
	},

	Color = {
		tostring = function(value)
			return tostring(math.round(value.R*255))..", "..tostring(math.round(value.G*255))..", "..tostring(math.round(value.B*255))..", "..tostring(math.round(value.A*255))
		end,
		tovalue = function(str)
			local split = string.split(str, ",")

			return Color.new(
				(tonumber(split[1]) or 0)/255,
				(tonumber(split[2]) or 0)/255,
				(tonumber(split[3]) or 0)/255,
				(tonumber(split[4]) or 255)/255
			)
		end
	},
	
	Vector = {
		tostring = function(value)
			return stringRound(value.X)..", "..stringRound(value.Y)
		end,
		tovalue = function(str)
			local split = string.split(str, ",")

			return Vector.new(
				tonumber(split[1]) or 0,
				tonumber(split[2]) or 0
			)
		end
	},
	NumberRange = {
		tostring = function(value)
			return stringRound(value.Min)..", "..stringRound(value.Max)
		end,
		tovalue = function(str)
			local split = string.split(str, ",")

			return NumberRange.new(
				tonumber(split[1]) or 0,
				tonumber(split[2]) or 0
			)
		end
	},
	number = {
		tostring = stringRound,
		tovalue = tonumber,
	},
	string = {
		tostring = tostring,
		tovalue = tostring,
	},
}

module.new = function(id, propertyName, propertyType)
    local self = setmetatable(module.__base.new(id), module)

	self.PropertyName = propertyName
	self.PropertyType = propertyType

	self:SetProperties({
		Size = UDim2.new(1, 0, 0, CellHeight),
		BackgroundColor = Color.new(0.1, 0.1, 0.1, 1),
	})

	self.Title = self.Maid:Add(Object.Create("TextLabel")):SetProperties({
		Size = UDim2.fromScale(0.5, 1),
		Text = propertyName,
		XAlignment = Enum.XAlignment.Left,
		BackgroundColor = Color.Blank,
		TextColor = Color.White,
		ZIndex = 1,
		Parent = self,
	})

	self.Line = self.Maid:Add(Object.Create("Frame")):SetProperties({
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor = Color.new(0.3, 0.3, 0.3, 1),
		AnchorPoint = Vector.one/2,
		Parent = self,
	})

	self.InteractArea = self.Maid:Add(Object.Create("Frame")):SetProperties({
		Size = UDim2.fromScale(0.5, 1),
		Position = UDim2.fromScale(1, 0),
		BackgroundColor = Color.Blank,
		AnchorPoint = Vector.xAxis,
		Parent = self,
	})

	if propertyType == "boolean" then
		local boolFrame = self.Maid:Add(Object.Create("Button")):SetProperties({
			Size = UDim2.fromOffset(CellHeight, CellHeight),
			BackgroundColor = Color.Blank,
			Parent = self.InteractArea,
		})

		local icon = self.Maid:Add(Object.Create("ImageLabel")):SetProperties({
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector.one/2,
			Size = UDim2.fromOffset(20, 20),
			Parent = boolFrame,
			BackgroundColor = Color.Blank,
			ImageColor = Color.White
		})

		boolFrame.LeftClicked:Connect(function()
			self:SetValue(not self:GetValue())
		end)

		self:GetPropertyChangedSignal("Value"):Connect(function(newValue)
			if newValue then
				icon:SetProperty("Image", "Editor/Assets/Checkmark.png")
			else
				icon:SetProperty("Image", "Editor/Assets/EmptyCheckBox.png")
			end
		end)
	elseif Enum[propertyType] then
		local button = self.Maid:Add(Object.Create("Button")):SetProperties({
			Size = UDim2.fromScale(1, 1),
			BackgroundColor = Color.new(.5, .5, .5, 1),
			Parent = self.InteractArea,
		})

		local textLabel = self.Maid:Add(Object.Create("TextLabel")):SetProperties({
			Size = UDim2.fromScale(1, 1),
			XAlignment = Enum.XAlignment.Left,
			Parent = button,
			BackgroundColor = Color.Blank,
			TextColor = Color.White,
		})
		
		self:GetPropertyChangedSignal("Value"):Connect(function(newValue)
			textLabel:SetProperty("Text", newValue.Name)
		end)

		button.LeftClicked:Connect(function()
			if existingDropdown then
				existingDropdown:Destroy()
				existingDropdown = nil
			end
			
			local enumAsList = {}
			for name, enumItem in pairs(Enum[propertyType]) do
				enumAsList[enumItem.Value] = name
			end
			local dropdown = Object.Create("Dropdown", enumAsList):SetProperties({
				AnchorPoint = Vector.xAxis,
				Position = UDim2.fromOffset(button.RenderPosition.X, button.RenderPosition.Y),
				Parent = EditorScreen,
				Enabled = true,
			})
			dropdown.ValueSelected:Connect(function(value)
				self:SetValue(Enum[propertyType][value])
			end)
			existingDropdown = dropdown
		end)
	elseif PropConverters[propertyType] then
		local textbox = self.Maid:Add(Object.Create("TextBox")):SetProperties({
			Size = UDim2.fromScale(1, 1),
			XAlignment = Enum.XAlignment.Left,
			Parent = self.InteractArea,
			BackgroundColor = Color.Blank,
			TextColor = Color.White,
		})

		textbox:GetPropertyChangedSignal("Focused"):Connect(function(isFocused)
			if isFocused then return end
			local value = PropConverters[propertyType].tovalue(textbox:GetProperty("Text"))
			self:SetValue(value)
		end)

		self:GetPropertyChangedSignal("Value"):Connect(function(newValue)
			textbox:SetProperty("Text", PropConverters[propertyType].tostring(newValue))
		end)
	end

	return self
end

function module:GetValue()
	return self:GetProperty("Value")
end

function module:SetValue(newValue)
	self:SetProperty("Value", newValue)
end

return module:Register()