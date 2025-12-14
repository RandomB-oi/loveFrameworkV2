local module = {}
module.__index = module
module.__type = "Widget"
module.__base = require("Editor.Instances.EditorInstance")
setmetatable(module, module.__base)

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)
	
	self:SetProperties({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor = Color.from255(46, 46, 46, 255),
	})
	
	self.Title = self.Maid:Add(Object.Create("TextLabel")):SetProperties({
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundColor = Color.Blank,
		TextColor = Color.White,
		Text = "Widget Title",
		Name = "Title",
		Parent = self,
	})

	self.WidgetHolder = self.Maid:Add(Object.Create("Frame")):SetProperties({
		Size = UDim2.new(1, 0, 1, -20),
		Position = UDim2.new(0, 0, 0, 20),
		BackgroundColor = Color.Blank,
		Name = "WidgetHolder",
		Parent = self,
	})

    return self
end

function module:AttachGui(gui)
	gui:SetProperty("Parent", self.WidgetHolder)
	return gui
end

function module:SetTitle(text)
	self.Title:SetProperty("Text", text or "")
	return self
end

return module:Register()