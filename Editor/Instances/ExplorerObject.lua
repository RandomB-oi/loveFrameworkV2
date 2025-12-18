local module = {}
module.__index = module
module.__type = "ExplorerObject"
module.__base = require("Editor.Instances.EditorInstance")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

local Selection = Game:GetService("Selection")
local InputService = Game:GetService("InputService")

local DefaultExpanded = false
local CellHeight = 20

module.new = function(id, object, depth)
	if object:IsA("EditorInstance") or object:GetProperty("Hidden") then return end
    local self = setmetatable(module.__base.new(id), module):SetProperties({
		Name = object:GetProperty("Name"),
		Size = UDim2.new(1, 0, 0, CellHeight),
		BackgroundColor = Color.new(0.1, 0.1, 0.1, 1),
	})

	self.Object = object
	self.Depth = depth or 0
	
	self.Button = self.Maid:Add(Object.Create("Button")):SetProperties({
		Size = UDim2.new(1, -CellHeight, 0, CellHeight),
		BackgroundColor = Color.Blank,
		Position = UDim2.new(0, CellHeight, 0, 0),
		ZIndex = 0,
		Parent = self,
	})

	self.ToggleButton = self.Maid:Add(Object.Create("Button")):SetProperties({
		Size = UDim2.fromOffset(CellHeight, CellHeight),
		BackgroundColor = Color.Blank,
		ZIndex = 1,
		Parent = self,
	})

	self.ToggleButtonImage = self.Maid:Add(Object.Create("ImageLabel")):SetProperties({
		Size = UDim2.fromOffset(16,16),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector.new(0.5, 0.5),
		BackgroundColor = Color.Blank,
		ZIndex = 1,
		Parent = self.ToggleButton,
	})

	self.Title = self.Maid:Add(Object.Create("TextLabel")):SetProperties({
		Size = UDim2.new(1, -CellHeight*2, 0, CellHeight),
		Position = UDim2.new(0, CellHeight*2, 0, 0),
		Text = object:GetProperty("Name"),
		XAlignment = Enum.XAlignment.Left,
		ZIndex = 2,
		Parent = self,
		BackgroundColor = Color.Blank,
		TextColor = Color.White,
	})

	self.Line = self.Maid:Add(Object.Create("Frame")):SetProperties({
		Size = UDim2.new(0, 1, 1, -CellHeight),
		Position = UDim2.new(0, CellHeight/2, 0, CellHeight),
		BackgroundColor = Color.new(.2,.2,.2, 1),
		Parent = self,
	})

	self.Icon = self.Maid:Add(Object.Create("ImageLabel")):SetProperties({
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector.one/2,
		Position = UDim2.new(0, CellHeight+CellHeight/2, 0, CellHeight/2),
		Parent = self,
		ZIndex = 2,
		Image = object.ClassIcon or "Editor/Assets/Checkmark.png",
		BackgroundColor = Color.Blank,
	})

	self.ChildrenList = self.Maid:Add(Object.Create("Frame")):SetProperties({
		Position = UDim2.new(0, CellHeight, 0, CellHeight),
		BackgroundColor = Color.Blank,
		Parent = self,
		Visible = not not DefaultExpanded,
	})

	self.Layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
		SortMode = Enum.SortMode.Name,
		Padding = UDim2.new(0, 0, 0, 3),
		Parent = self.ChildrenList,
	})

	self.ToggleButton.LeftClicked:Connect(function()
		self.ChildrenList:SetProperty("Visible", not self.ChildrenList:GetProperty("Visible"))
	end)

	self.Maid:GiveTask(self.Object:GetPropertyChangedSignal("Name"):Connect(function(name)
		self.Title:SetProperty("Text", name)
		self:SetProperty("Name", name)
	end))

	self.Maid:GiveTask(self.Object.ChildAdded:Connect(function(newChild)
		self:NewChild(newChild)
	end))

	local first = true
	self.Maid:GiveTask(self.Object:GetPropertyChangedSignal("Parent"):Connect(function()
		if first then first = false return end
		self:Destroy()
	end))

	self.ChildrenList:GetPropertyChangedSignal("Visible"):Connect(function()
		self:UpdateScales()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:UpdateScales()
	end)

	self.Button.LeftClicked:Connect(function()
		task.spawn(function()
			if InputService:IsKeyPressed(Enum.KeyCode.LeftControl) then
				if Selection:IsSelected(self.Object) then
					Selection:Remove(self.Object)
				else
					Selection:Add(self.Object)
				end
			else
				if #Selection:Get() == 1 and select(2, next(Selection.Selection)) == self.Object then
					Selection:Set()
				else
					Selection:Set({self.Object})
				end
			end
		end)
	end)

	self.Button.RightClicked:Connect(function()
		EditorScreen:CreateContextMenu(self.Object)
	end)
	
	for _, child in ipairs(self.Object:GetChildren()) do
		self:NewChild(child)
	end

	self:UpdateSelected()
	self.Maid:GiveTask(Selection.SelectionChanged:Connect(function()
		self:UpdateSelected()
	end))

	return self
end

function module:UpdateSelected()
	if Selection:IsSelected(self.Object) then
		self.Button:SetProperty("BackgroundColor", Color.from255(70, 70, 70, 255))
	else
		self.Button:SetProperty("BackgroundColor", Color.from255(25, 25, 25, 255))
	end
end

function module:CalculateDeepestDepth()
	local depth = self.Depth

	for _, child in ipairs(self:GetChildren(true)) do
		if child.Depth then
			depth = math.max(child.Depth, depth)
		end
	end

	return depth
end

function module:UpdateScales()
	task.delay(0, function()
		local height = self.Layout:GetProperty("AbsoluteContentSize").Y
		self.ChildrenList:SetProperty("Size", UDim2.new(1, 0, 0, height))
		
		if not self.ChildrenList:GetProperty("Visible") then
			height = 0
		end
		
		local deepestDepth = self:CalculateDeepestDepth()
		self:SetProperty("Size", UDim2.new(1, (deepestDepth - self.Depth) * CellHeight, 0, CellHeight+height))
	end)
end

function module:Update(dt)
	-- self:UpdateScales()

	if self.Object._c and next(self.Object._c) then
		self.ToggleButton:SetProperty("Visible", true)
	else
		self.ToggleButton:SetProperty("Visible", false)
		self.ChildrenList:SetProperty("Visible", false)
	end

	if self.ChildrenList:GetProperty("Visible") then
		self.ToggleButtonImage:SetProperty("Image", "Editor/Assets/Expanded.png")
	else
		self.ToggleButtonImage:SetProperty("Image", "Editor/Assets/Collapsed.png")
	end
end

function module:NewChild(child)
	local newFrame = Object.Create("ExplorerObject", nil, child, self.Depth + 1)
	if not newFrame then return end
	newFrame:SetProperty("Parent", self.ChildrenList)
end

return module:Register()