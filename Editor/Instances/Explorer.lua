local module = {}
module.__index = module
module.__type = "Explorer"
module.__base = require("Editor.Instances.Widget")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)
module:CreateProperty("RootObject", "Object", nil)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	self:SetTitle("Explorer")

	self.ExplorerList = self.Maid:Add(Object.Create("ScrollingFrame")):SetProperties({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor = Color.Blank,
		ScrollbarPadding = Enum.ScrollbarPadding.Scrollbar,
		ScrollbarThickness = 8,
		Name = "ExplorerList",
	})
	self:AttachGui(self.ExplorerList)

	self.Layout = self.Maid:Add(Object.Create("UIListLayout")):SetProperties({
		SortMode = Enum.SortMode.Name,
		Parent = self.ExplorerList,
	})

	self:GetPropertyChangedSignal("RootObject"):Connect(function(object)
		self.Maid.GameFrame = nil
		if not object then return end
		self.Maid.GameFrame = Object.Create("ExplorerObject", nil, object):SetProperties({
			Parent = self.ExplorerList,
		})
	end)

	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function(size)
		self.ExplorerList:SetProperty("CanvasSize", UDim2.fromOffset(size.X, size.Y))
	end)

	return self
end

return module:Register()