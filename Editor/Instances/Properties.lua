local module = {}
module.__index = module
module.__type = "Properties"
module.__base = require("Editor.Instances.Widget")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

local Selection = Game:GetService("Selection")

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self:SetTitle("Properties")

	self.List = self.Maid:Add(Object.Create("ScrollingFrame")):SetProperties({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor = Color.Blank,
		Name = "List",
	})
	self:AttachGui(self.List)

	do
		local layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
			-- SortMode = Enum.SortMode.Name,
			Padding = UDim2.fromOffset(0, 12),
			Parent = self.List,
		})

		layout:BindToProperty("AbsoluteContentSize", function(size)
			self.List.CanvasSize = UDim2.fromOffset(size.X or 0, size.Y or 0)
		end)
	end

	do
		self.PropertyFrames = {}
		self.PropertiesList = Object.Create("Frame"):SetProperties({
			BackgroundColor = Color.Blank,
			LayoutOrder = 1,
			Parent = self.List,
		})
		
		local layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
			SortMode = Enum.SortMode.Name,
			Padding = UDim2.fromOffset(0, 0),
			Parent = self.PropertiesList,
		})

		layout:BindToProperty("AbsoluteContentSize", function(size)
			self.PropertiesList.Size = UDim2.new(1, 0, 0, size.Y or 0)
		end)
	end

	do
		self.AttributeFrames = {}
		self.AttributesList = Object.Create("Frame"):SetProperties({
			BackgroundColor = Color.Blank,
			LayoutOrder = 2,
			Parent = self.List,
		})
		
		local layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
			SortMode = Enum.SortMode.Name,
			Padding = UDim2.fromOffset(0, 0),
			Parent = self.AttributesList,
		})

		layout:BindToProperty("AbsoluteContentSize", function(size)
			self.AttributesList.Size = UDim2.new(1, 0, 0, size.Y or 0)
		end)
	end

	local Selection = Game:GetService("Selection")
	self.Maid:GiveTask(Selection.SelectionChanged:Connect(function()
		self:UpdateProperties()
	end))
	self:UpdateProperties()


	return self
end

function module:UpdateProperties()
	for propName, frame in pairs(self.PropertyFrames) do
		frame:Destroy()
		self.PropertyFrames[propName] = nil
	end
	for propName, frame in pairs(self.AttributeFrames) do
		frame:Destroy()
		self.AttributeFrames[propName] = nil
	end

	local object = Selection:Get()[1]
	print("update", object)
	if not object then return end

	for propName, info in pairs(object.ClassProperties) do
		local newFrame = Object.Create("PropertyFrame", nil, propName, info.Type):SetProperties({
			Name = propName,
			Parent = self.PropertiesList,
		})
		self.PropertyFrames[propName] = newFrame
		
		newFrame.Maid:GiveTask(object:BindToProperty(propName, function(value)
			newFrame:SetValue(value)
		end))

		newFrame:GetPropertyChangedSignal("Value"):Connect(function(newValue)
			for _, object in ipairs(Selection:Get()) do
				if object.ClassProperties[propName] then
					object:SetProperty(propName, newValue)
					-- newFrame:SetValue(object[propName])
				end
			end
		end)
	end

	-- for attribute, value in pairs(object:GetAttributes()) do
	-- 	local newFrame = Object.Create("PropertyFrame", nil, attribute, typeof(value))
	-- 	newFrame.Name = attribute
	-- 	newFrame.Parent = self.AttributesList
	-- 	newFrame:SetValue(value)
	-- 	self.AttributeFrames[attribute] = newFrame

	-- 	newFrame.Maid:GiveTask(object:GetAttributeChangedSignal(attribute):Connect(function()
	-- 		newFrame:SetValue(object:GetAttribute(attribute))
	-- 	end))

	-- 	newFrame.PropertyChanged:Connect(function(newValue)
	-- 		for _, object in ipairs(Selection:Get()) do
	-- 			object:SetAttribute(attribute, newValue)
	-- 		end
	-- 	end)
	-- end

	
	-- local addAttributeButton = Object.Create("Button")
	-- addAttributeButton.Parent = self.AttributesList
	-- addAttributeButton.Name = "!!!!!"
	-- addAttributeButton.Size = UDim2.new(1,0,0, 20)
	-- addAttributeButton.Color = Color.new(.1,.1,.1,1)
	-- self.AttributeFrames[addAttributeButton] = addAttributeButton

	
	-- local textLabel = self.Maid:Add(Object.Create("TextLabel"))
	-- textLabel.Size = UDim2.new(1, 0, 1, 0)
	-- textLabel.Position = UDim2.new(0, 0, 0, 0)
	-- textLabel.Text = "Add Attribute"
	-- textLabel.Parent = addAttributeButton
end

return module:Register()