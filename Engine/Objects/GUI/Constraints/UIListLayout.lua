local module = {}
module.__index = module
module.__type = "UIListLayout"
module.__base = require("Engine.Objects.GUI.Constraints.UILayoutBase")
setmetatable(module, module.__base)

module.ConstraintCategory = "List"

module.ClassProperties = module.__base:CopyProperties()
module:SetDefaultProperyValue("Name", module.__type)

module:CreateProperty("Padding", "UDim2", UDim2.new(0, 6, 0, 6))
module:CreateProperty("ListAxis", "Vector", Vector.yAxis)
module:CreateProperty("AbsoluteContentSize", "Vector", Vector.zero)
module:CreateProperty("SortMode", "SortMode", Enum.SortMode.LayoutOrder)

module.new = function(...)
    local self = setmetatable(module.__base.new(...), module)

	self.OrderedChildren = {}

	self.Changed:Connect(function()
		self._updateOrder = true
	end)

    return self
end

local function newChild(self, child)
	if not child:IsA("Frame") then return end

	self:UpdateOrder()

	local connectionMaid = Maid.new()
	self.ParentMaid[child] = connectionMaid
	connectionMaid:GiveTask(function()
		self._updateOrder = true
	end)
	connectionMaid:GiveTask(child.Changed:Connect(function()
		self._updateOrder = true
	end))
end

function module:BindToParent(parent)
	self.ParentMaid:GiveTask(parent.Changed:Connect(function(prop)
		self._updateOrder = true
	end))

	for _, child in ipairs(parent:GetChildren()) do
		newChild(self, child)
	end

	self.ParentMaid:GiveTask(parent.ChildAdded:Connect(function(child)
		newChild(self, child)
	end))
	
	self.ParentMaid:GiveTask(parent.ChildRemoved:Connect(function(child)
		self.ParentMaid[child] = nil
	end))
	self._updateOrder = true
	parent._updateRender = true
end

function module:Update(dt)
	module.__base.Update(self, dt)

	local parent = self:GetProperty("Parent")
	if parent then
		if self._lastParentSize ~= parent.RenderSize then
			self._lastParentSize = parent.RenderSize
			self._updateOrder = true
		end
	end

	if self._updateOrder then
		self:UpdateOrder()
	end
end

function module:UpdateOrder()
	self._updateOrder = nil
	local parent = self:GetProperty("Parent")
	if not parent then
		self.OrderedChildren = {}
		self:SetProperty("AbsoluteContentSize", Vector.zero)
		return
	end

	local array = {}
	local lookup = {}
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("Frame") and child:IsVisible() then
			local order = 0
			if self:GetProperty("SortMode") == Enum.SortMode.LayoutOrder then
				order = child:GetProperty("LayoutOrder") or 9999
			else
				order = string.getOrder(child:GetProperty("Name"))
			end
			if not lookup[order] then
				local tbl = {order, {}}
				table.insert(array, tbl)
				lookup[order] = tbl
			end

			table.insert(lookup[order][2], child)
		end
	end

	table.sort(array, function(a, b)
		return a[1] < b[1]
	end)

	local orderedChildren = {}
	local parentSize = parent.RenderSize

	local contentSize = Vector.zero
	local listAxis = self:GetProperty("ListAxis")
	local paddingSize = self:GetProperty("Padding"):Calculate(parentSize) * listAxis
	
	for k, list in ipairs(array) do
		for index, child in ipairs(list[2]) do
			local size = child:GetModifiedSize(child:GetProperty("Size"):Calculate(parentSize))

			orderedChildren[child] = contentSize
			contentSize = contentSize + size * listAxis

			if next(list[2], index) or next(array, k) then
				contentSize = contentSize + paddingSize
			end
		end
	end

	self:SetProperty("AbsoluteContentSize", contentSize)
	self.OrderedChildren = orderedChildren
	parent._updateRender = true
end

function module:Resolve(child, parentSize, parentPos)
	local pos = self.OrderedChildren[child]
	if pos and parentSize and parentPos then
		local size = child:GetModifiedSize(child:GetProperty("Size"):Calculate(parentSize))
		pos = pos + parentPos

		return size, pos
	end

	return Vector.zero, Vector.zero
end

return module:Register()