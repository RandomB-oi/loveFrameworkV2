local module = {}
module.__index = module
module.__type = "Dropdown"
module.__base = require("Engine.Objects.GUI.Frame")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(id, list)
    local self = setmetatable(module.__base.new(id), module)

	self:SetProperties({
		ZIndex = 10000,
		BackgroundColor = Color.new(0.5, 0.5, 0.5, 1),
	})

	self.List = self.Maid:Add(Object.Create("ScrollingFrame")):SetProperties({
		Size = UDim2.fromScale(1,1),
		BackgroundColor = Color.Blank,
		Parent = self,
	})

	self.Layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
		SortMode = Enum.SortMode.Name,
		Padding = UDim2.fromOffset(1, 1),
		Parent = self.List,
	})

	self.ValueSelected = self.Maid:Add(Signal.new())

	self.Layout:BindToProperty("AbsoluteContentSize", function(size)
		self:SetProperty("Size", UDim2.new(0, 112, 0, math.min(size.Y, 200)))
		self.List:SetProperty("CanvasSize", UDim2.new(0, 0, 0, size.Y))
	end)

	self.Maid:GiveTask(Game:GetService("InputService").InputBegan:Connect(function(input)
		if input.MouseButton == Enum.MouseButton.MouseButton1 then
			if not self:MouseHovering() then
				self:Destroy()
			end
		end
	end))

	for index, name in pairs(list) do
		local newButton = Object.Create("Button"):SetProperties({
			BackgroundColor = Color.new(0.3, 0.3, 0.3, 1),
			Size = UDim2.new(1, -12, 0, 20),
			LayoutOrder = index,
			Name = name,
			Parent = self.List,
		})

		local textLabel = Object.Create("TextLabel"):SetProperties({
			BackgroundColor = Color.Blank,
			TextColor = Color.new(1, 1, 1, 1),
			Size = UDim2.fromScale(1, 1),
			Text = name,
			XAlignment = Enum.XAlignment.Left,
			Parent = newButton,
		})

		newButton.LeftClicked:Connect(function()
			self.ValueSelected:Fire(name)
		end)
	end

	return self
end


return module:Register()